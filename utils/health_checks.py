#!/usr/bin/env python
"""Pre-execution health checks for WFM test automation."""

import json
import os
import re
from typing import Dict, Tuple
from urllib.request import Request, urlopen

from dotenv import dotenv_values

from utils.logger import get_logger

# Get logger for this module
logger = get_logger(__name__)


def build_runtime_env_for_health_check(test_environment: str) -> Dict[str, str]:
    """Build the runtime env used by pre-execution health checks."""
    from pathlib import Path

    from utils.environment_scoped_manager import EnvironmentScopedManager

    scoped_manager = EnvironmentScopedManager(test_env=test_environment)
    scoped_env_file = scoped_manager.get_scoped_env_filepath()
    runtime_env = os.environ.copy()

    if scoped_env_file.exists():
        try:
            runtime_env.update(scoped_manager.get_subprocess_env(scoped_env_file))
            runtime_env["WFM_ENV_FILE"] = str(scoped_env_file)
            logger.debug(
                "Using scoped environment variables for health checks: %s",
                scoped_env_file,
            )
            return runtime_env
        except Exception as exc:
            logger.warning(
                "Failed to load scoped environment file for health checks (%s): %s",
                scoped_env_file,
                exc,
            )

    workspace_root = Path(__file__).resolve().parent.parent
    legacy_env_file = workspace_root / ".env"
    if legacy_env_file.exists():
        try:
            runtime_env.update(
                {
                    key: value
                    for key, value in dotenv_values(legacy_env_file).items()
                    if value is not None
                }
            )
            runtime_env["WFM_ENV_FILE"] = str(legacy_env_file)
            logger.debug(
                "Scoped environment file not found for health checks, falling back to %s",
                legacy_env_file,
            )
        except Exception as exc:
            logger.warning(
                "Failed to load legacy .env file for health checks (%s): %s",
                legacy_env_file,
                exc,
            )

    return runtime_env


def _sanitize_db2_error_message(message: str) -> str:
    """Redact potential credential fragments from DB2 error text."""
    sanitized = message or ""
    patterns = [
        r"(?i)(PWD\s*=\s*)([^;\s]+)",
        r"(?i)(UID\s*=\s*)([^;\s]+)",
        r'(?i)("password"\s*:\s*")([^"]+)(")',
        r'(?i)("username"\s*:\s*")([^"]+)(")',
    ]
    replacements = [r"\1***", r"\1***", r"\1***\3", r"\1***\3"]

    for pattern, replacement in zip(patterns, replacements):
        sanitized = re.sub(pattern, replacement, sanitized)

    return sanitized


def _check_application_health(base_url: str, timeout: int = 10) -> Tuple[bool, str]:
    """Verify application is reachable before starting suite execution."""
    normalized_base_url = (base_url or "").strip().rstrip("/")
    if not normalized_base_url:
        return False, "base_url is not configured"

    headers = {"User-Agent": "WFM-Test-Automation-HealthCheck"}
    for endpoint in (normalized_base_url, f"{normalized_base_url}/reflexisversion.txt"):
        for method in ("HEAD", "GET"):
            request = Request(endpoint, headers=headers, method=method)
            try:
                with urlopen(request, timeout=timeout) as response:
                    status_code = getattr(response, "status", response.getcode())
                    if 100 <= status_code < 500:
                        return True, f"{method} {endpoint} returned HTTP {status_code}"
            except Exception as exc:
                status_code = getattr(exc, "code", None)
                if isinstance(status_code, int) and 100 <= status_code < 500:
                    return True, f"{method} {endpoint} returned HTTP {status_code}"
                logger.debug("Application health probe failed for %s: %s", endpoint, exc)

    return False, f"Application is not reachable for base URL: {normalized_base_url}"


def _load_db2_config(runtime_env: Dict[str, str]) -> Tuple[bool, Dict[str, str], str]:
    """Load DB2 configuration from runtime env for pre-execution checks."""
    db2_connection_json = (runtime_env.get("DB2_CONNECTION") or "").strip()
    if not db2_connection_json:
        return False, {}, "DB2_CONNECTION is not configured"

    try:
        db2_config = json.loads(db2_connection_json)
    except json.JSONDecodeError as exc:
        return False, {}, f"DB2_CONNECTION is not valid JSON: {exc}"

    required_keys = ("database", "hostname", "port", "username", "password")
    missing_keys = [key for key in required_keys if not db2_config.get(key)]
    if missing_keys:
        return (
            False,
            {},
            "DB2_CONNECTION is missing required keys: " + ", ".join(sorted(missing_keys)),
        )

    return True, db2_config, ""


def _build_db2_connection_string(db2_config: Dict[str, str], timeout: int) -> str:
    """Build DB2 connection string with connect timeout using shared builder."""
    # Import here to avoid circular dependency
    from resources.web.common.db2_connection import DB2Connection

    db2_connection = DB2Connection()
    db2_connection.connection_config = dict(db2_config)
    connection_string = db2_connection._build_connection_string()

    if "CONNECTTIMEOUT=" not in connection_string.upper():
        safe_timeout = max(int(timeout), 1)
        connection_string += f"CONNECTTIMEOUT={safe_timeout};"

    return connection_string


def _load_ibm_db_module() -> Tuple[bool, object, str]:
    """Load ibm_db from the shared DB2 runtime module used across the project."""
    try:
        from resources.web.common import db2_connection
    except Exception as exc:
        return False, None, _sanitize_db2_error_message(str(exc))

    if not getattr(db2_connection, "HAS_IBM_DB", False):
        return False, None, "ibm_db module is not available in DB2 runtime"

    ibm_db = getattr(db2_connection, "ibm_db", None)
    if ibm_db is None:
        return False, None, "ibm_db module was not initialized by DB2 runtime"

    return True, ibm_db, ""


def _check_db2_connectivity(runtime_env: Dict[str, str], timeout: int = 10) -> Tuple[bool, str]:
    """Check DB2 connection health before queue-threshold validation."""
    ibm_db_ok, ibm_db, ibm_db_error = _load_ibm_db_module()
    if not ibm_db_ok:
        return False, f"ibm_db module is not usable: {ibm_db_error}"

    config_ok, db2_config, config_error = _load_db2_config(runtime_env)
    if not config_ok:
        return False, config_error

    connection_handle = None
    try:
        connection_string = _build_db2_connection_string(db2_config, timeout)
        connection_handle = ibm_db.connect(connection_string, "", "")
        return (
            True,
            "Connected to DB2 "
            f"{db2_config['hostname']}:{db2_config['port']}/{db2_config['database']}",
        )
    except Exception as exc:
        safe_error = _sanitize_db2_error_message(str(exc))
        return False, f"DB2 connectivity check failed: {safe_error}"
    finally:
        if connection_handle:
            try:
                ibm_db.close(connection_handle)
            except Exception:
                logger.debug("Failed to close DB2 connection after connectivity check")


def _check_pending_queue_threshold(
    runtime_env: Dict[str, str],
    timeout: int = 10,
    queue_pending_threshold: int = 100,
) -> Tuple[bool, str]:
    """Abort execution when DB queue has rows with JOBS_PENDING over threshold."""
    ibm_db_ok, ibm_db, ibm_db_error = _load_ibm_db_module()
    if not ibm_db_ok:
        return False, f"ibm_db module is not usable: {ibm_db_error}"

    config_ok, db2_config, config_error = _load_db2_config(runtime_env)
    if not config_ok:
        return False, config_error

    connection_handle = None
    try:
        safe_threshold = max(int(queue_pending_threshold), 0)
        connection_string = _build_db2_connection_string(db2_config, timeout)

        connection_handle = ibm_db.connect(connection_string, "", "")
        statement = ibm_db.exec_immediate(
            connection_handle,
            f"select * from rfx_queue where JOBS_PENDING > {safe_threshold}",
        )
        overloaded_row = ibm_db.fetch_assoc(statement)

        if overloaded_row:
            return (
                False,
                "DB2 queue overload: found rfx_queue row(s) with "
                f"JOBS_PENDING > {safe_threshold}",
            )

        return (
            True,
            "DB2 queue healthy: no rfx_queue rows with "
            f"JOBS_PENDING > {safe_threshold}",
        )
    except Exception as exc:
        safe_error = _sanitize_db2_error_message(str(exc))
        return False, f"Queue threshold check failed: {safe_error}"
    finally:
        if connection_handle:
            try:
                ibm_db.close(connection_handle)
            except Exception:
                logger.debug("Failed to close DB2 connection after queue precheck")


def run_pre_execution_health_checks(
    base_url: str,
    runtime_env: Dict[str, str],
    timeout: int = 10,
    check_database: bool = True,
    queue_pending_threshold: int = 100,
) -> None:
    """
    Run pre-execution checks in sequence and abort at first failure.

    | =Arguments= | =Description= |
    | base_url | Application base URL to check connectivity. |
    | runtime_env | Runtime environment variables containing DB2_CONNECTION config. |
    | timeout | Timeout in seconds for health checks (default: 10). |
    | check_database | Whether to check database connectivity and queue threshold (default: True). |
    | queue_pending_threshold | Max allowed JOBS_PENDING before failing queue check (default: 100). |

    Raises RuntimeError if any health check fails.
    """
    app_ok, app_message = _check_application_health(base_url=base_url, timeout=timeout)
    if not app_ok:
        raise RuntimeError(f"Application health check failed: {app_message}")
    logger.info("Application health check passed: %s", app_message)

    if check_database:
        db_ok, db_message = _check_db2_connectivity(runtime_env=runtime_env, timeout=timeout)
        if not db_ok:
            raise RuntimeError(f"Database health check failed: {db_message}")
        logger.info("Database health check passed: %s", db_message)

        queue_ok, queue_message = _check_pending_queue_threshold(
            runtime_env=runtime_env,
            timeout=timeout,
            queue_pending_threshold=queue_pending_threshold,
        )
        if not queue_ok:
            raise RuntimeError(f"Queue health check failed: {queue_message}")
        logger.info("Queue health check passed: %s", queue_message)



