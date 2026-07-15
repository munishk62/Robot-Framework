#!/usr/bin/env python
import argparse
import datetime
import importlib.util
import os
import subprocess
import sys
from pathlib import Path
from test_data.environment_manager import EnvironmentManager
from urllib.error import URLError
from urllib.request import Request, urlopen

SUPPORTED_BROWSERS = {"chrome", "firefox", "edge", "safari"}
SUPPORTED_MOBILE_PLATFORMS = ["android", "ios"]
SUPPORTED_CLOUD_PLATFORMS = ["none", "lambdaTest", "zTest"]

# Import the logger utility
from utils.logger import configure_logging, get_logger
from utils.security import ensure_safe_name, resolve_workspace_path
from utils.environment_scoped_manager import EnvironmentScopedManager

# Base directory of the project
BASE_DIR = Path(__file__).resolve().parent

# Get logger for this module
logger = get_logger(__name__)

# Lambda Test parallel device limit
LAMBDA_TEST_PARALLEL_DEVICES = 8


def classify_robot_return_code(return_code: int) -> str:
    """Classify Robot Framework/Pabot process return codes.

    Return value categories:
    - success: tests executed and no failures
    - test_failures: tests executed and one or more tests failed
    - execution_error: invalid usage, interrupted run, or internal/runtime error
    - Check https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#return-codes why 250.
    """
    if return_code == 0:
        return "success"
    if 1 <= return_code <= 250:
        return "test_failures"
    return "execution_error"


def fetch_app_version(base_url: str, timeout: int = 10) -> str:
    """Fetch the app version from the reflexisversion.txt endpoint."""
    # Use the base URL to locate the environment version file for metadata.
    if not base_url:
        return ""

    version_url = f"{base_url.rstrip('/')}/reflexisversion.txt"
    request = Request(version_url, headers={"User-Agent": "WFM-Test-Automation"})
    try:
        with urlopen(request, timeout=timeout) as response:
            return response.read().decode("utf-8", errors="ignore").strip()
    except URLError as exc:
        logger.warning(
            "Unable to read app version from %s: %s",
            version_url,
            exc,
        )
    except Exception as exc:  # pragma: no cover - defensive guardrail
        logger.warning(
            "Unexpected error reading app version from %s: %s",
            version_url,
            exc,
        )
    return ""


def load_python_variables(file_path):
    """Load variables from a Python file and return them as a dictionary."""
    module_name = Path(file_path).stem
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    # Get all variables from the module (excluding special variables starting with underscore)
    variables = {
        name: value
        for name, value in module.__dict__.items()
        if not name.startswith("_") and not callable(value)
    }

    return variables


def _cleanup_scoped_env_file(scoped_manager, scoped_env_file):
    """
    Clean up scoped environment file in CI/Jenkins environments only.

    Local developers reuse scoped env files across multiple test runs.
    Legacy .env files are never deleted for backward compatibility.

    Args:
        scoped_manager: EnvironmentScopedManager instance
        scoped_env_file: Path to the scoped environment file
    """
    is_ci_environment = os.environ.get("BUILD_ID") or os.environ.get("CI")
    is_legacy_env_file = scoped_env_file == (BASE_DIR / ".env")

    if not scoped_env_file.exists():
        return

    if is_ci_environment and not is_legacy_env_file:
        try:
            scoped_manager.cleanup_scoped_env_file()
            logger.debug(f"Cleaned up scoped environment file: {scoped_env_file}")
        except Exception as e:
            logger.warning(f"Failed to cleanup scoped environment file: {e}")
    elif not is_legacy_env_file:
        logger.debug(f"Keeping scoped environment file for reuse: {scoped_env_file}")


def process_cognos_excel_file(cognos_file_path: Path, batch_size: int = 2000):
    """
    Process Cognos custom reports Excel file by splitting it into batches if needed.

    Args:
        cognos_file_path: Path to the original Excel file
        batch_size: Maximum rows per sheet (default: 2000)

    Returns:
        Tuple of (processed_file_path, list_of_sheet_names)
    """
    from resources.web.rws.reports import excel_operations

    if not cognos_file_path.exists():
        logger.warning(f"Cognos reports file not found: {cognos_file_path}")
        return None, []

    # Check row count
    row_count = excel_operations.get_row_count(cognos_file_path)
    logger.info(f"Cognos reports file has {row_count} data rows")

    # Create processed file path
    processed_file_name = cognos_file_path.stem + "_processed" + cognos_file_path.suffix
    processed_file_path = cognos_file_path.parent / processed_file_name

    # Split Excel file into batches
    sheet_names = excel_operations.split_excel_to_sheets(
        cognos_file_path, processed_file_path, batch_size
    )

    logger.info(f"Created processed file with {len(sheet_names)} sheets: {sheet_names}")
    return processed_file_path, sheet_names


def run_tests(
        test_files,
        global_data_file_name=None,
        include_tags=None,
        exclude_tags=None,
        dry_run=False,
        environmentName="QA28_B0",
        suite_name=None,
        results_dir="results",
        show_browser=False,
        processes=1,
        log_level="INFO",
        extra_robot_args=None,
        browser_name="chrome",
        validate_user_keys=False,
        cognos_input_filename="cognos_custom_reports.xlsx",
        testray_plan=None,
        testray_cycle=None,
        payroll_recompute_file="payroll_recompute_stores.xlsx",
        # Mobile automation parameters
        mobile_platform="",
        device="",
        cloud_platform="none",
        enable_self_heal=False,
        # Retry parameter (default disabled; Jenkins opts in via --retry-count).
        # The failure-rate gate lives as a policy constant inside
        # dev_utils.retry_manager.MAX_FAILURE_PCT and is not configurable
        # at runtime; edit and commit to change it.
        retry_count=0,
):
    """
    Loads Python variables and runs the robot test cases.
    """
    logger.debug("run_tests() called (extra_robot_args count=%s)", len(extra_robot_args or []))
    creds_file = BASE_DIR / "utils" / "load_credentials.py"

    # Validate mobile platform
    if mobile_platform and mobile_platform not in SUPPORTED_MOBILE_PLATFORMS:
        logger.error(
            f"Unsupported mobile platform '{mobile_platform}'. Supported platforms: {', '.join(SUPPORTED_MOBILE_PLATFORMS)}"
        )
        sys.exit(1)

    if mobile_platform:
        logger.info(f"Mobile platform selected: {mobile_platform}")
        if device:
            logger.info(f"Target device: {device}")

    sanitized_test_files = []
    for test_file in test_files:
        try:
            sanitized_test_files.append(
                str(
                    resolve_workspace_path(
                        test_file,
                        workspace_root=BASE_DIR,
                        description="Test file path",
                    )
                )
            )
        except ValueError as exc:
            logger.error(exc)
            sys.exit(1)
    test_files = sanitized_test_files

    browser = browser_name.strip().lower()
    if browser not in SUPPORTED_BROWSERS:
        logger.error(
            "Unsupported browser '%s'. Supported browsers: %s",
            browser_name,
            ", ".join(sorted(SUPPORTED_BROWSERS)),
        )
        sys.exit(1)

    logger.info("Browser selected: %s", browser)

    suite_suffix = ""
    if suite_name:
        try:
            safe_suite_name = ensure_safe_name(
                suite_name,
                description="Suite name",
            )
        except ValueError as exc:
            logger.error(exc)
            sys.exit(1)
        suite_suffix = f"_{safe_suite_name}"

    # Auto-scope results directory by environment name if using default
    # This allows parallel test execution on same VM without conflicts
    # and makes local test results organized by environment
    # Example: "results" becomes "results/results_QA29_B0"
    if results_dir == "results":  # Default value
        results_dir = str(
            Path("results") / f"results_{environmentName}{suite_suffix}"
        )
        logger.info(
            "Auto-scoping results directory to: %s (based on environment: %s)",
            results_dir,
            environmentName,
        )

    # Ensure results directory exists
    try:
        results_dir = resolve_workspace_path(
            results_dir,
            workspace_root=BASE_DIR,
            description="Results directory",
        )
    except ValueError as exc:
        logger.error(exc)
        sys.exit(1)
    results_dir.mkdir(parents=True, exist_ok=True)

    # Write the resolved results directory path to a marker file for Jenkins/CI integration
    # Marker file includes environment and optional suite name to avoid collisions
    # in parallel test runs on the same Jenkins node.
    results_dir_marker_file = BASE_DIR / (
        f".results_dir_{environmentName}{suite_suffix}.txt"
    )
    try:
        with open(results_dir_marker_file, "w", encoding="utf-8") as f:
            # Write relative path from repo root for portability across Windows/Unix
            relative_results_path = results_dir.relative_to(BASE_DIR)
            f.write(str(relative_results_path))
        logger.debug(
            f"Results directory path written to {results_dir_marker_file}: {relative_results_path}"
        )
    except Exception as e:
        logger.debug(
            f"Could not write results directory marker file: {e}. "
            "Jenkins will use default path."
        )



    # Set environment variable if provided
    env_vars = os.environ.copy()
    if environmentName:
        try:
            safe_env_name = ensure_safe_name(
                environmentName,
                description="Environment name",
            )
        except ValueError as exc:
            logger.error(exc)
            sys.exit(1)
        logger.info(f"Setting TEST_ENVIRONMENT to {safe_env_name}")
        env_vars["TEST_ENVIRONMENT"] = safe_env_name
        os.environ["TEST_ENVIRONMENT"] = safe_env_name

    env_dir = BASE_DIR / "test_data" / "environments" / env_vars["TEST_ENVIRONMENT"]
    if not env_dir.exists():
        logger.error(
            f"Environment directory does not exist: {env_dir}. Please ensure it exists under test_data/environments/. Exiting now."
        )
        sys.exit(1)

    data_file_path = None
    if global_data_file_name:
        try:
            safe_data_name = ensure_safe_name(
                global_data_file_name,
                description="Global data file name",
            )
        except ValueError as exc:
            logger.error(exc)
            sys.exit(1)

        data_file_path = env_dir / safe_data_name
        if data_file_path.suffix != ".py":
            data_file_path = data_file_path.with_suffix(".py")

        if not data_file_path.exists():
            logger.error(f"Global data file not found: {data_file_path}")
            sys.exit(1)

    env_manager = EnvironmentManager()
    base_url = str(env_manager.get_config_value("base_url", "")).strip()
    app_version = fetch_app_version(base_url) if base_url else ""
    if app_version:
        logger.info("Detected app version: %s", app_version)
    else:
        logger.info(
            "App version not detected for environment %s",
            env_vars.get("TEST_ENVIRONMENT"),
        )

    cognos_custom_reports_file = env_dir / cognos_input_filename

    payroll_recompute_file = env_dir / payroll_recompute_file

    # Process Cognos Excel file if it exists and test file is cognos_custom_reports_smoketest.robot or cognos_custom_reports_download_csv_report.robot
    processed_cognos_file = None
    sheet_names = []
    is_cognos_test = any(
        "cognos_custom_reports_smoketest.robot" in str(test_file)
        or "cognos_custom_reports_download_csv_report.robot" in str(test_file)
        for test_file in test_files
    )

    if is_cognos_test and cognos_custom_reports_file.exists():
        logger.info("Detected Cognos custom reports test, processing Excel file...")
        logger.info(f"Cognos reports input file: {cognos_custom_reports_file}")
        processed_cognos_file, sheet_names = process_cognos_excel_file(
            cognos_custom_reports_file
        )

        if not sheet_names:
            logger.error("Failed to process Cognos Excel file or no sheets created")
            sys.exit(1)

    # Track scoped manager and env file for cleanup after all batches
    scoped_manager = None
    scoped_env_file = None

    # If we have multiple sheets, run tests for each sheet separately
    if sheet_names and len(sheet_names) > 1:
        logger.info(f"Executing tests for {len(sheet_names)} batches")
        for sheet_name in sheet_names:
            logger.info(f"{'=' * 60}")
            logger.info(f"Processing batch: {sheet_name}")
            logger.info(f"{'=' * 60}")

            # Create sheet-specific results directory
            sheet_results_dir = results_dir / sheet_name

            scoped_manager, scoped_env_file = execute_single_test_run(
                test_files=test_files,
                creds_file=creds_file,
                data_file_path=data_file_path,
                include_tags=include_tags,
                exclude_tags=exclude_tags,
                dry_run=dry_run,
                env_vars=env_vars,
                results_dir=sheet_results_dir,
                show_browser=show_browser,
                processes=processes,
                log_level=log_level,
                extra_robot_args=extra_robot_args,
                browser=browser,
                validate_user_keys=validate_user_keys,
                app_version=app_version,
                cognos_file=processed_cognos_file,
                sheet_name=sheet_name,
                testray_plan=testray_plan,
                testray_cycle=testray_cycle,
                payroll_recompute_file=payroll_recompute_file,
                # Mobile automation parameters
                mobile_platform=mobile_platform,
                device=device,
                cloud_platform=cloud_platform,
                enable_self_heal=enable_self_heal,
                # Retry parameters
                retry_count=retry_count,
            )
    else:
        # Single execution (no batching or single batch)
        if sheet_names and len(sheet_names) == 1:
            sheet_name = sheet_names[0]
            cognos_file = processed_cognos_file
        else:
            sheet_name = None
            cognos_file = cognos_custom_reports_file

        scoped_manager, scoped_env_file = execute_single_test_run(
            test_files=test_files,
            creds_file=creds_file,
            data_file_path=data_file_path,
            include_tags=include_tags,
            exclude_tags=exclude_tags,
            dry_run=dry_run,
            env_vars=env_vars,
            results_dir=results_dir,
            show_browser=show_browser,
            processes=processes,
            log_level=log_level,
            extra_robot_args=extra_robot_args,
            browser=browser,
            validate_user_keys=validate_user_keys,
            app_version=app_version,
            cognos_file=cognos_file,
            sheet_name=sheet_name,
            testray_plan=testray_plan,
            testray_cycle=testray_cycle,
            payroll_recompute_file=payroll_recompute_file,
            # Mobile automation parameters
            mobile_platform=mobile_platform,
            device=device,
            cloud_platform=cloud_platform,
            enable_self_heal=enable_self_heal,
            # Retry parameters
            retry_count=retry_count,
        )

    # Cleanup scoped environment file after all test runs complete
    # This is safe because all Cognos batches have finished
    if scoped_manager and scoped_env_file:
        _cleanup_scoped_env_file(scoped_manager, scoped_env_file)


def execute_single_test_run(
        test_files,
        creds_file,
        data_file_path,
        include_tags,
        exclude_tags,
        dry_run,
        env_vars,
        results_dir,
        show_browser,
        processes,
        log_level,
        extra_robot_args,
        browser,
        validate_user_keys,
        app_version,
        cognos_file,
        sheet_name=None,
        testray_plan=None,
        testray_cycle=None,
        payroll_recompute_file=None,
        # Mobile automation parameters
        mobile_platform="",
        device="",
        cloud_platform="none",
        enable_self_heal=False,
        # Retry parameter (default disabled). The failure-rate gate is a
        # policy constant inside dev_utils.retry_manager.MAX_FAILURE_PCT.
        retry_count=0,
):
    """
    Execute a single test run with specified parameters.

    This function now uses environment-scoped variables to prevent conflicts
    when multiple pipelines execute in parallel on the same VM.

    Returns:
        tuple: (scoped_manager, scoped_env_file) for cleanup by caller
    """
    # Ensure results directory exists
    try:
        results_dir = resolve_workspace_path(
            results_dir,
            workspace_root=BASE_DIR,
            description="Results directory",
        )
    except ValueError as exc:
        logger.error(exc)
        sys.exit(1)
    results_dir.mkdir(parents=True, exist_ok=True)

    # Initialize environment-scoped manager for this test run
    # Scoped by environment name only
    test_env = env_vars.get("TEST_ENVIRONMENT", "QA28_B0")
    scoped_manager = EnvironmentScopedManager(test_env=test_env)
    scoped_env_file = scoped_manager.get_scoped_env_filepath()

    # Check if scoped environment file exists
    # (it should have been created by decrypt_creds.py)
    if not scoped_env_file.exists():
        logger.warning(
            f"Scoped environment file not found: {scoped_env_file}. "
            f"Attempting to locate legacy .env file for backward compatibility."
        )
        legacy_env_file = BASE_DIR / ".env"
        if legacy_env_file.exists():
            logger.info(f"Using legacy .env file: {legacy_env_file}")
            scoped_env_file = legacy_env_file
        else:
            logger.warning(
                "Neither scoped .env nor legacy .env file found. "
                "Proceeding with current environment variables."
            )

    # Construct the robot command using uv
    base_uv_command = ["uv", "run", "robot"]
    if processes > 1:
        # Limit parallel processes for cloud platforms
        if (
                cloud_platform == "lambdaTest"
                and processes > LAMBDA_TEST_PARALLEL_DEVICES
        ):
            logger.warning(
                f"Limiting parallel execution to {LAMBDA_TEST_PARALLEL_DEVICES} devices for LambdaTest"
            )
            processes = LAMBDA_TEST_PARALLEL_DEVICES

        base_uv_command = [
            "uv",
            "run",
            "pabot",
            "--processes",
            str(processes),
            "--artifacts",
            "png,webm,mp4",
            "--artifactsinsubfolders",  # Collect artifacts from parallel runs
        ]

    uv_command = [
        *base_uv_command,
        "--outputdir",
        str(results_dir),
        "--loglevel",
        log_level,
        "--pythonpath",
        str(BASE_DIR),
        "--variable",
        f"COGNOS_CUSTOM_REPORTS_FILE:{cognos_file}",
        "--metadata",
        f"Environment:{env_vars.get('TEST_ENVIRONMENT', 'N/A')}",
        "--metadata",
        f"Browser:{browser}",
        "--metadata",
        f"App Version:{app_version or 'Unknown'}",
        "--variable",
        f"PAYROLL_RECOMPUTE_FILE:{payroll_recompute_file}",
    ]

    # Apply config-based test filtering only for real runs.
    # In dry-run mode we want to validate every test file irrespective of
    # the environment's enabled_configs / config values.
    if not dry_run:
        uv_command.extend(["--prerunmodifier", "ConfigFilter.py"])
    else:
        logger.info(
            "Dry run: skipping ConfigFilter pre-run modifier so no test is "
            "skipped due to disabled configs."
        )

    # Always use credentials loader as variable file
    uv_command.extend(["--variablefile", f"{creds_file}"])

    # Add mobile automation variables if mobile platform is specified
    if mobile_platform:
        uv_command.extend(
            [
                "--variable",
                f"MOBILE_PLATFORM:{mobile_platform}",
                "--metadata",
                f"Mobile Platform:{mobile_platform}",
            ]
        )
        if device:
            uv_command.extend(
                [
                    "--variable",
                    f"DUT1:{device}",
                    "--metadata",
                    f"Device:{device}",
                ]
            )
        if cloud_platform != "none":
            uv_command.extend(
                [
                    "--variable",
                    f"CLOUD_PLATFORM:{cloud_platform}",
                    "--metadata",
                    f"Cloud Platform:{cloud_platform}",
                ]
            )

    # Add self-healing support if enabled
    if enable_self_heal:
        logger.info("Self-healing enabled")
        uv_command.extend(
            [
                "--expandkeywords",
                "tag:self_healed",
                "--listener",
                "robotframework_zrobo_healer",
            ]
        )

    # Add sheet name variable if provided
    if sheet_name:
        uv_command.extend(["--variable", f"SheetName:{sheet_name}"])
        logger.info(f"Setting SheetName variable to: {sheet_name}")

    if validate_user_keys:
        uv_command.extend(
            [
                "--prerunmodifier",
                "UserCredentialFilter.py",
            ]
        )

    # Add tag filtering if specified
    if include_tags:
        for tag in include_tags.split(","):
            uv_command.extend(["--include", tag.strip()])

    if exclude_tags:
        for tag in exclude_tags.split(","):
            uv_command.extend(["--exclude", tag.strip()])

    if data_file_path and data_file_path.exists():
        uv_command.extend(["--variablefile", f"{data_file_path}"])

    browser_conflict_message_logged = False
    # Use explicit display value from Jenkins if provided; otherwise derive from extra_robot_args
    if args.extra_robot_args_display:
        extra_robot_args_metadata = args.extra_robot_args_display.strip() or "N/A"
        if len(extra_robot_args_metadata) > 500:
            extra_robot_args_metadata = extra_robot_args_metadata[:500] + " ...[truncated]"
    else:
        extra_robot_args_metadata = "N/A"
    logger.debug(f"extra_robot_args received: {extra_robot_args!r}")
    logger.debug(f"extra_robot_args_display from Jenkins: {args.extra_robot_args_display!r}")
    if extra_robot_args:
        cleaned_extra_robot_args = []
        index = 0
        while index < len(extra_robot_args):
            argument = extra_robot_args[index]

            if argument in ("--variable", "-v"):
                if index + 1 < len(extra_robot_args):
                    value = extra_robot_args[index + 1]
                    if value.startswith("BROWSER_NAME:") or value.startswith(
                            "BROWSER_NAME="
                    ):
                        if not browser_conflict_message_logged:
                            logger.warning(
                                "Ignoring BROWSER_NAME provided via Robot arguments. Use --browser to set it."
                            )
                            browser_conflict_message_logged = True
                        index += 2
                        continue
                    cleaned_extra_robot_args.extend([argument, value])
                    index += 2
                    continue
                cleaned_extra_robot_args.append(argument)
                index += 1
                continue

            if argument.startswith("--variable="):
                value = argument.split("=", 1)[1]
                if value.startswith("BROWSER_NAME:") or value.startswith(
                        "BROWSER_NAME="
                ):
                    if not browser_conflict_message_logged:
                        logger.warning(
                            "Ignoring BROWSER_NAME provided via Robot arguments. Use --browser to set it."
                        )
                        browser_conflict_message_logged = True
                    index += 1
                    continue

            if argument.startswith("-v") and argument != "-v":
                value = argument[2:]
                if value.startswith("BROWSER_NAME:") or value.startswith(
                        "BROWSER_NAME="
                ):
                    if not browser_conflict_message_logged:
                        logger.warning(
                            "Ignoring BROWSER_NAME provided via Robot arguments. Use --browser to set it."
                        )
                        browser_conflict_message_logged = True
                    index += 1
                    continue

            cleaned_extra_robot_args.append(argument)
            index += 1

        extra_robot_args = cleaned_extra_robot_args
        logger.debug(f"extra_robot_args after cleaning: {extra_robot_args!r}")

    # If Jenkins didn't provide explicit display value, derive from extra_robot_args
    if not extra_robot_args_metadata or extra_robot_args_metadata == "N/A":
        if extra_robot_args:
            derived_metadata = " ".join(extra_robot_args).strip() or "N/A"

            # Keep report header metadata concise in case large arg lists are passed.
            if len(derived_metadata) > 500:
                derived_metadata = derived_metadata[:500] + " ...[truncated]"
            extra_robot_args_metadata = derived_metadata
            logger.debug(f"Extra Robot Args metadata derived from parse_known_args: {extra_robot_args_metadata!r}")
        else:
            logger.info("No extra robot args detected; metadata will show N/A")

    uv_command.extend(["--metadata", f"Extra Robot Args:{extra_robot_args_metadata}"])

    uv_command.extend(["--variable", f"BROWSER_NAME:{browser}"])

    # Add dry run flag if specified
    if dry_run:
        uv_command.append("--dryrun")
        # Some suites (e.g. DataDriver-based ones) have templated test cases
        # whose bodies are generated at runtime. In dry-run mode those bodies
        # remain empty and Robot fails them with "Test cannot be empty." even
        # when the suite is tagged `robot:skip`. Since `robot:skip` explicitly
        # marks the test as not intended to run, exclude it from dry-run too.
        uv_command.extend(["--exclude", "robot:skip"])

    # Browser mode: default headless unless user explicitly requests UI
    if show_browser:
        uv_command.extend(
            [
                "--variable",
                "ENABLE_BROWSER_HEADLESS_MODE:False",
                "--variable",
                "PRESENTER_MODE_DURATION:100ms",
            ]
        )
    else:
        uv_command.extend(
            [
                "--variable",
                "ENABLE_BROWSER_HEADLESS_MODE:True",
                "--variable",
                "PRESENTER_MODE_DURATION:100ms",
            ]
        )

    if testray_plan:
        uv_command.extend(["--variable", f"TESTRAY_PLAN:{testray_plan}"])
        # Auto-inject per-test teardown publisher via pre-run modifier
        uv_command.extend(["--prerunmodifier", "TestRayPublisher.TestRayPublisher"])
        uv_command.extend(["--listener", "TestRayPublisher.TestRaySuiteSetupListener"])

    if testray_cycle:
        uv_command.extend(["--variable", f"TESTRAY_CYCLE:{testray_cycle}"])

    if extra_robot_args:
        uv_command.extend(extra_robot_args)

    # Snapshot the command prefix (everything before the trailing test
    # files) so the retry orchestrator can reuse the exact same options
    # for retry attempts, only swapping --outputdir and injecting
    # --rerunfailed. Never mutated after this point.
    options_prefix_for_retry = list(uv_command)
    uv_command.extend(test_files)

    logger.info(f"Executing command: {' '.join(uv_command)}")

    # delete the robotframework-cache.json file if it exists
    cache_file = BASE_DIR / "robotframework-cache.json"
    if cache_file.exists():
        cache_file.unlink()

    # Get process environment with scoped variables
    subprocess_env = os.environ.copy()
    if scoped_env_file.exists():
        try:
            subprocess_env.update(
                scoped_manager.get_subprocess_env(scoped_env_file)
            )
            subprocess_env["WFM_ENV_FILE"] = str(scoped_env_file)
            logger.debug(f"Injected scoped environment variables from {scoped_env_file}")
        except Exception as e:
            logger.warning(f"Failed to load scoped environment variables: {e}")

    # Execute the robot command while streaming stdout
    process = None
    try:
        process = subprocess.Popen(
            uv_command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            env=subprocess_env,
            universal_newlines=True,
        )

        if process.stdout:
            for line in process.stdout:
                logger.info(line.rstrip())

        return_code = process.wait()

        # Retry orchestration. Guarded so the default (retry_count == 0)
        # path is byte-for-byte identical to the pre-feature behavior:
        # no attempt_* subdirectories are created, no rebot --merge is
        # invoked, no retry_summary artifacts are emitted.
        if retry_count > 0 and not dry_run:
            try:
                from dev_utils.retry_manager import maybe_run_retries
            except Exception as exc:
                logger.warning(
                    "Retry disabled (import failed): %s. Continuing with "
                    "single-run behavior.",
                    exc,
                )
            else:
                retry_result = maybe_run_retries(
                    initial_return_code=return_code,
                    options_prefix=options_prefix_for_retry,
                    test_files_suffix=list(test_files),
                    subprocess_env=subprocess_env,
                    results_dir=results_dir,
                    retry_count=retry_count,
                )
                return_code = retry_result.final_return_code
                if retry_result.retry_ran:
                    logger.info(
                        "Retry orchestration used %d attempt(s); "
                        "merged output at %s (merged=%s).",
                        retry_result.attempts_used,
                        results_dir / "output.xml",
                        retry_result.merged,
                    )
                elif retry_result.retry_skipped_reason:
                    logger.info(
                        "Retry skipped: %s",
                        retry_result.retry_skipped_reason,
                    )

        return_code_type = classify_robot_return_code(return_code)

        if return_code_type == "success":
            logger.info("Test execution completed successfully!")
        elif return_code_type == "test_failures":
            if return_code == 250:
                logger.warning(
                    "Test execution completed with 250 or more failed tests. "
                    "Continuing so downstream reporting can process output.xml/xunit.xml."
                )
            else:
                logger.warning(
                    "Test execution completed with failed test count: %s. "
                    "Continuing so downstream reporting can process output.xml/xunit.xml.",
                    return_code,
                )
        else:
            logger.error(
                "Test execution failed due to Robot runtime/usage error "
                "with return code %s",
                return_code,
            )
            sys.exit(return_code)

    except FileNotFoundError:
        logger.error(
            "The 'uv' command is not available. Make sure it is installed and in your PATH."
        )
        sys.exit(1)
    except KeyboardInterrupt:
        logger.warning("Execution interrupted by user. Terminating Robot process.")
        if process and process.poll() is None:
            process.terminate()
        sys.exit(130)

    # Return scoped manager and env file for cleanup by caller
    # Cleanup is deferred to run_tests() to support Cognos batching
    return scoped_manager, scoped_env_file


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run Robot Framework tests.")
    parser.add_argument(
        "test_files_path",
        nargs="+",
        help="List of robot test files or directories to execute.",
    )
    parser.add_argument(
        "--test-env",
        type=str,
        help="The environment name (one word) to run the tests against. Please ensure the directory with same name exists under test_data/environments/.",
    )
    parser.add_argument(
        "--suite-name",
        type=str,
        help=(
            "Optional suite name used to scope results directories and "
            "marker files for parallel runs."
        ),
    )
    parser.add_argument(
        "--include-tags",
        type=str,
        help="Only run tests with these tags (comma-separated).",
    )
    parser.add_argument(
        "--exclude-tags",
        type=str,
        help="Exclude tests with these tags (comma-separated).",
    )
    parser.add_argument(
        "--results-dir",
        type=str,
        default="results",
        help="Directory to store test results.",
    )
    parser.add_argument(
        "--global-data-file-name",
        type=str,
        help="A global data file name to be used across all tests. This should be a Python file without the .py extension. It should be located in test_data/environments/{TEST_ENV}/ and contain variables to be used in the tests.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Perform a dry run without executing the tests.",
    )
    parser.add_argument(
        "--log-level",
        type=str,
        choices=["TRACE", "DEBUG", "INFO", "WARN", "NONE"],
        default="INFO",
        help="Set the logging level. Available levels: TRACE, DEBUG, INFO (default), WARN, NONE.",
    )
    parser.add_argument("--log-file", type=str, help="File to write logs to.")
    parser.add_argument(
        "--show-browser",
        action="store_true",
        default=False,
        help="Show browser UI (headed mode). Omit for headless execution (default).",
    )
    parser.add_argument(
        "--processes",
        type=int,
        default=1,
        help="Number of parallel processes to use for test execution.",
    )
    parser.add_argument(
        "--browser",
        type=str,
        default="chrome",
        choices=sorted(SUPPORTED_BROWSERS),
        help="Browser to use for execution. Defaults to chrome. Supported values: chrome, firefox, edge, safari.",
    )
    parser.add_argument(
        "--validate-user-keys",
        action="store_true",
        default=False,
        help=(
            "Enable UserCredentialFilter pre-run modifier to skip tests that reference user keys "
            "missing from the USER_CREDENTIALS environment variable."
        ),
    )
    parser.add_argument(
        "--cognos-input-filename",
        type=str,
        default="cognos_custom_reports.xlsx",
        help="Input file name for that has cognos reports details used for test execution.",
    )
    parser.add_argument("--testray-plan", type=str, help="TestRay Test Plan ID.")
    parser.add_argument(
        "--testray-cycle", type=str, help="TestRay custom Test Cycle name."
    )
    parser.add_argument(
        "--payroll-recompute-file",
        type=str,
        default="payroll_recompute_stores.xlsx",
        help="Input file name that has payroll recompute stores details used for test execution.",
    )
    # Mobile automation arguments
    parser.add_argument(
        "--mobile-platform",
        type=str,
        default="android",
        choices=[""] + SUPPORTED_MOBILE_PLATFORMS,
        help="Mobile platform to use for testing. Supported values: android, ios.",
    )
    parser.add_argument(
        "--device",
        type=str,
        default="",
        help="Device identifier for mobile testing (e.g., device serial number or UDID).",
    )
    parser.add_argument(
        "--cloud-platform",
        type=str,
        default="none",
        choices=SUPPORTED_CLOUD_PLATFORMS,
        help="Cloud platform for mobile testing. Supported values: lambdaTest, zTest, none (default).",
    )
    parser.add_argument(
        "--enable-self-heal",
        action="store_true",
        default=False,
        help="Enable self-healing of test scripts using robotframework-zrobo-healer.",
    )
    parser.add_argument(
        "--extra-robot-args-display",
        type=str,
        default="",
        help="Display value for extra robot args metadata (populated by Jenkins only; for metadata display).",
    )
    parser.add_argument(
        "--retry-count",
        type=int,
        default=0,
        help=(
            "Number of retry attempts for failed tests after the initial "
            "run (default 0 = disabled). Retries reuse the same pabot "
            "command, target only previously failing tests via "
            "--rerunfailed, and merge the final result at the top-level "
            "results directory. Jenkins jobs set this via the RETRY_COUNT "
            "parameter; manual local runs leave it at 0. The failure-rate "
            "safety gate is a policy constant "
            "(dev_utils.retry_manager.MAX_FAILURE_PCT) — edit and commit "
            "to change it."
        ),
    )
    # Parse known and unknown args to allow passing robot-specific params
    args, extra_robot_args = parser.parse_known_args()

    logger.debug(f"parse_known_args() captured extra_robot_args: {extra_robot_args!r}")

    # Set log level as environment variable so all modules can use it
    os.environ["WFM_TEST_LOG_LEVEL"] = args.log_level

    # Configure logging first
    if args.log_file:
        try:
            log_file = resolve_workspace_path(
                args.log_file,
                workspace_root=BASE_DIR,
                description="Log file",
            )
        except ValueError as exc:
            logger.error(exc)
            sys.exit(1)
    else:
        log_file = (
                BASE_DIR
                / "logs"
                / f"test_run_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        ).resolve()

    log_file.parent.mkdir(parents=True, exist_ok=True)
    configure_logging(level=args.log_level, log_file=log_file)

    logger.info(f"Starting test execution with log level: {args.log_level}")
    logger.info(f"Logs will be written to: {log_file}")

    # Convert test_files to sanitized absolute paths
    test_files_abs = []
    missing_files = []
    for user_path in args.test_files_path:
        try:
            safe_path = resolve_workspace_path(
                user_path,
                workspace_root=BASE_DIR,
                description="Test file path",
            )
        except ValueError as exc:
            logger.error(exc)
            sys.exit(1)

        if not safe_path.exists():
            missing_files.append(str(safe_path))
        test_files_abs.append(str(safe_path))

    if missing_files:
        logger.error("The following test files/directories do not exist:")
        for file in missing_files:
            logger.error(f"  - {file}")
        sys.exit(1)

    if args.test_env:
        logger.info(f"Using environment: {args.test_env}")
    else:
        logger.warning("No environment specified.")
    if args.include_tags:
        logger.info(f"Including tags: {args.include_tags}")
    if args.exclude_tags:
        logger.info(f"Excluding tags: {args.exclude_tags}")
    if args.global_data_file_name:
        logger.info(f"Using data file: {args.global_data_file_name}")
    if args.dry_run:
        logger.info("Performing dry run")
    if args.show_browser:
        logger.info("Browser UI will be visible (headed mode)")
    else:
        logger.info("Browser will run in headless mode (default)")
    if args.browser and args.browser.lower() == "safari" and not args.show_browser:
        logger.warning(
            "Safari runs headed only. Add --show-browser to avoid launch failures."
        )
    if args.mobile_platform:
        logger.info(f"Mobile automation enabled: {args.mobile_platform}")
    if args.cloud_platform != "none":
        logger.info(f"Using cloud platform: {args.cloud_platform}")
    if args.enable_self_heal:
        logger.info("Self-healing mode enabled")

    # Sanitize retry parameters. Retries are always off for dry runs
    # since there is nothing meaningful to retry.
    retry_count = max(0, int(args.retry_count))
    if args.dry_run and retry_count > 0:
        logger.info(
            "Dry run requested with --retry-count=%d; retries disabled "
            "for dry-run mode.",
            retry_count,
        )
        retry_count = 0

    if retry_count > 0:
        from dev_utils.retry_manager import MAX_FAILURE_PCT
        logger.info(
            "Retry enabled: up to %d retry attempt(s); skip retry when "
            "initial failure rate exceeds %.1f%% "
            "(policy constant dev_utils.retry_manager.MAX_FAILURE_PCT).",
            retry_count,
            MAX_FAILURE_PCT,
        )

    run_tests(
        test_files_abs,
        global_data_file_name=args.global_data_file_name,
        include_tags=args.include_tags,
        exclude_tags=args.exclude_tags,
        dry_run=args.dry_run,
        environmentName=args.test_env or "QA28_B0",
        suite_name=args.suite_name,
        results_dir=args.results_dir,
        show_browser=args.show_browser,
        processes=args.processes,
        log_level=args.log_level,
        extra_robot_args=extra_robot_args,
        browser_name=args.browser,
        validate_user_keys=args.validate_user_keys,
        cognos_input_filename=args.cognos_input_filename,
        testray_plan=args.testray_plan,
        testray_cycle=args.testray_cycle,
        payroll_recompute_file=args.payroll_recompute_file,
        mobile_platform=args.mobile_platform,
        device=args.device,
        cloud_platform=args.cloud_platform,
        enable_self_heal=args.enable_self_heal,
        retry_count=retry_count,
    )

