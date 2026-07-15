import argparse
import logging
import os
import platform
import re
import shlex
import subprocess
import sys

# Regular expression to match ANSI escape sequences
ansi_escape = re.compile(r"\x1B[@-_][0-?]*[ -/]*[@-~]")


class StripAnsiFilter(logging.Filter):
    def filter(self, record):
        record.msg = ansi_escape.sub("", record.msg)
        return True


# Configure logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Console handler with ANSI color codes
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
console_handler.setFormatter(
    logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
)
logger.addHandler(console_handler)

# File handler without ANSI color codes
file_handler = logging.FileHandler("install_bundle_script.log")
file_handler.setLevel(logging.INFO)
file_handler.setFormatter(
    logging.Formatter(
        "%(asctime)s - [File: %(filename)s, Line: %(lineno)d] - %(levelname)s - %(message)s"
    )
)
file_handler.addFilter(StripAnsiFilter())
logger.addHandler(file_handler)

logger.info(f"Current Working Directory: {os.getcwd()}")


def _normalize_tokens(command):
    """Normalize a command (string or list) replacing 'python' and 'pip' tokens safely.

    Rules:
      - 'python' -> sys.executable
      - standalone 'pip' -> sys.executable -m pip
      - sequence python -m pip kept as <sys.executable> -m pip
      - trailing 'pip' token (e.g. upgrade pip) treated same as standalone
    Returns list of tokens.
    """
    if isinstance(command, str):
        # On Windows use posix=False to preserve backslashes
        tokens = shlex.split(command, posix=platform.system() != "Windows")
    elif isinstance(command, (list, tuple)):
        tokens = [str(t) for t in command]
    else:
        raise ValueError("Unsupported command type; must be str, list, or tuple")

    python_exec = sys.executable
    normalized = []
    for i, tok in enumerate(tokens):
        if tok == "python":
            normalized.append(python_exec)
            continue
        if tok == "pip":
            # If command is invoked via uv, treat pip as literal subcommand (don't expand)
            if normalized and normalized[0] == "uv":
                normalized.append("pip")
                continue
            if i > 0 and tokens[i - 1] == "-m":  # part of python -m pip
                normalized.append("pip")
                continue
            if (
                len(normalized) >= 3
                and normalized[0] == python_exec
                and normalized[1] == "-m"
                and normalized[2] == "pip"
            ):  # already expanded
                normalized.append("pip")
                continue
            if python_exec not in normalized:
                normalized.extend([python_exec, "-m", "pip"])
            else:
                normalized.append("pip")
            continue
        normalized.append(tok)
    return normalized


def _tokens_to_command(tokens):
    # Build a shell command string for logging / getoutput usage
    if platform.system() == "Windows":
        return subprocess.list2cmdline(tokens)
    # Quote tokens with spaces on POSIX
    return " ".join(shlex.quote(t) for t in tokens)


def run_command_and_return_output(command):
    tokens = _normalize_tokens(command)
    log_cmd = _tokens_to_command(tokens)
    logger.info(f"Running command: {log_cmd}")
    try:
        result = subprocess.getoutput(log_cmd)
        logger.info(result)
        return result
    except subprocess.CalledProcessError as e:
        logger.error(f"An error occurred while running command: {log_cmd}")
        logger.error(e.stdout)
        sys.exit(1)


def _run_command(command):
    if not command:
        raise ValueError("Command must be provided")

    tokens = _normalize_tokens(command)
    log_cmd = _tokens_to_command(tokens)
    logger.info(f"Running command: {log_cmd}")
    try:
        process = subprocess.Popen(
            tokens,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
        assert process.stdout is not None
        for line in process.stdout:
            logger.info(line.rstrip())
        process.wait()
        if process.returncode != 0:
            logger.error(f"An error occurred while running command: {log_cmd}")
            sys.exit(process.returncode)
    except Exception as e:
        logger.error(f"An exception occurred: {e}")
        sys.exit(1)


def install_all_packages_in_directory():
    package_list = [
        f
        for f in os.listdir(".")
        if os.path.isfile(f) and (f.endswith(".zip") or f.endswith(".whl"))
    ]
    logger.info(f"Package list to install: {package_list}")
    python_exec = sys.executable
    for package in package_list:
        cmd = f"uv pip install --force-reinstall {package}"
        logger.info(f"Running command: {cmd}")
        try:
            output = subprocess.check_output(cmd, shell=True, text=True)
            logger.info(output)
        except subprocess.CalledProcessError as e:
            logger.error(f"An error occurred while running command: {cmd}")
            logger.error(e.output)
            sys.exit(1)


def uninstall_appium_drivers():
    # Run the command to list installed drivers
    output = run_command_and_return_output("appium driver ls")
    if output is None:
        logger.error("Failed to retrieve the list of installed drivers.")
        sys.exit(1)
    # Debug log the output
    logger.debug(f"Output of 'appium driver ls':\n{output}")
    # Remove ANSI escape sequences
    cleaned_output = ansi_escape.sub("", output)
    # Parse the cleaned output to find installed drivers
    installed_drivers = re.findall(r"- (\w+)@\d+\.\d+\.\d+ \[installed", cleaned_output)
    # Debug log the installed drivers
    logger.debug(f"Installed drivers found: {installed_drivers}")
    # Uninstall each installed driver
    for driver in installed_drivers:
        run_command_and_return_output(f"appium driver uninstall {driver}")


def main(args):
    # Bootstrap pip if missing (some environments may lack pip initially)
    def ensure_uv():
        """Check that 'uv' is available; exit with guidance if not."""
        res = subprocess.run(
            [
                sys.executable,
                "-c",
                'import shutil,sys;sys.exit(0 if shutil.which("uv") else 1)',
            ]
        )
        if res.returncode != 0:
            logger.error(
                "'uv' command not found. Please install uv: https://github.com/astral-sh/uv#installation"
            )
            sys.exit(1)

    ensure_uv()

    # # Step 1: (pip upgrade/uninstalls removed; using uv exclusively.)
    # _run_command("uv pip uninstall -y selenium")
    # _run_command("uv pip uninstall -y robotframework-seleniumlibrary")

    # Step 2: Install internal wheel/zip packages with uv
    os.chdir("InternalPackages")
    install_all_packages_in_directory()
    os.chdir("..")

    # Step 3: Install project requirements using uv
    _run_command("uv pip install -r requirements.txt")

    # Step 4: Install playwright browsers (use uv run to ensure correct environment)
    _run_command("uv run playwright install")

    # Step 5: Clean and initialize rfbrowser
    _run_command("rfbrowser --silent clean-node")
    _run_command("rfbrowser --silent init")

    # Check if we should exclude device-related steps
    if not args.exclude_device:
        # Step 7: Uninstall and reinstall appium globally using npm
        run_command_and_return_output(
            "npm uninstall -g --silent --no-progress --loglevel=error appium",
        )
        run_command_and_return_output(
            "npm install -g --silent --no-progress --loglevel=error appium",
        )

        # Step 8: Uninstall only installed appium drivers
        uninstall_appium_drivers()
        run_command_and_return_output("appium driver install uiautomator2")

        # Step 9: Uninstall and reinstall kill-port globally using npm
        run_command_and_return_output(
            "npm uninstall -g --silent --no-progress --loglevel=error kill-port",
        )
        run_command_and_return_output(
            "npm install -g --silent --no-progress --loglevel=error kill-port",
        )

        # Step 10: List node and appium information
        run_command_and_return_output("appium -v")
        run_command_and_return_output("appium driver ls")
        run_command_and_return_output("npm ls -g")
        run_command_and_return_output("npm ls")

    # Step 11: List pip packages
    run_command_and_return_output("uv pip list")
    # Final Step: Print confirmation message
    logger.info("Bundle Installed Successfully!")


if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(
        description="Install and configure the required packages and tools."
    )
    parser.add_argument(
        "--exclude_device",
        action="store_true",
        help="Exclude device-related steps (steps 7 to 10).",
    )
    args = parser.parse_args()
    main(args)
