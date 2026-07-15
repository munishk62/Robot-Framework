"""
Centralized logging utility for the test automation framework.
Provides consistent logging across all modules.
"""

import logging
import sys
import os
from pathlib import Path

# Default log format
DEFAULT_LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
BASE_DIR = Path(__file__).resolve().parent.parent

# Map string log levels to logging constants
LOG_LEVELS = {
    "DEBUG": logging.DEBUG,
    "INFO": logging.INFO,
    "WARNING": logging.WARNING,
    "ERROR": logging.ERROR,
    "CRITICAL": logging.CRITICAL,
}

# Map Robot Framework log levels to Python logging levels
ROBOT_TO_PYTHON_LOG_LEVELS = {
    "TRACE": logging.DEBUG,  # Robot's TRACE maps to Python's DEBUG
    "DEBUG": logging.DEBUG,
    "INFO": logging.INFO,
    "WARN": logging.WARNING,  # Robot's WARN maps to Python's WARNING
    "NONE": logging.CRITICAL + 1,  # Higher than any standard level
}

# Environment variable name for log level
LOG_LEVEL_ENV_VAR = "WFM_TEST_LOG_LEVEL"


class LoggerFactory:
    """Factory class for creating and managing loggers."""

    # Singleton instance
    _instance = None
    # Track configured loggers
    _loggers = {}
    # Default configuration
    _default_level = logging.INFO
    _format = DEFAULT_LOG_FORMAT
    _file_handler = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(LoggerFactory, cls).__new__(cls)
            cls._instance._configured = False
            # Check for environment variable on first initialization
            cls._instance._check_env_log_level()
        return cls._instance

    def configure(self, level=None, format=None, log_file=None):
        """
        Configure global logging settings.

        Args:
            level: Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
            format: Log format string
            log_file: Path to log file (if None, logging to file is disabled)
        """
        # Set log level
        if level:
            self._default_level = self._get_log_level(level)

        # Set format
        if format:
            self._format = format

        # Configure file handler if log_file is provided
        if log_file:
            base_logs_path = BASE_DIR / "logs"
            # Ensure directory exists
            log_dir = Path(base_logs_path / log_file).parent
            if not str(log_dir).startswith(str(BASE_DIR)):
                print(
                    f"Warning: Log file path {log_file} is outside the base directory. Using default log file location & file test_logs.log."
                )
                log_file = "test_logs.log"
                log_dir = Path(base_logs_path / log_file).parent

            log_dir.mkdir(exist_ok=True, parents=True)

            # Create file handler
            self._file_handler = logging.FileHandler(log_dir / (log_file.name))
            self._file_handler.setFormatter(logging.Formatter(self._format))
            self._file_handler.setLevel(self._default_level)

        # Update existing loggers with new configuration
        for logger in self._loggers.values():
            self._apply_configuration(logger)

        self._configured = True

    def get_logger(self, name):
        """
        Get or create a logger with the given name.

        Args:
            name: Logger name (typically __name__ of the calling module)

        Returns:
            logging.Logger: Configured logger instance
        """
        if name not in self._loggers:
            logger = logging.getLogger(name)

            # Apply default configuration
            self._apply_configuration(logger)

            # Store in cache
            self._loggers[name] = logger

        return self._loggers[name]

    def _apply_configuration(self, logger):
        """Apply current configuration to a logger."""
        # Set level
        logger.setLevel(self._default_level)

        # Clear existing handlers
        for handler in logger.handlers[:]:
            logger.removeHandler(handler)

        # Add console handler
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setFormatter(logging.Formatter(self._format))
        logger.addHandler(console_handler)

        # Add file handler if configured
        if self._file_handler:
            logger.addHandler(self._file_handler)

        # Prevent duplicate logs through ancestor handlers
        logger.propagate = False

    def _get_log_level(self, level):
        """Convert string log level to logging constant."""
        if isinstance(level, str):
            level_upper = level.upper()
            # First try Robot Framework levels
            if level_upper in ROBOT_TO_PYTHON_LOG_LEVELS:
                return ROBOT_TO_PYTHON_LOG_LEVELS[level_upper]
            # Then try standard Python levels
            return LOG_LEVELS.get(level_upper, logging.INFO)
        return level

    def _check_env_log_level(self):
        """Check for log level in environment variable and apply it."""
        env_log_level = os.getenv(LOG_LEVEL_ENV_VAR)
        if env_log_level:
            try:
                self._default_level = self._get_log_level(env_log_level)
                # Apply to any existing loggers
                for logger in self._loggers.values():
                    self._apply_configuration(logger)
            except (KeyError, ValueError):
                # If invalid log level, stick with default
                pass


# Create singleton instance
logger_factory = LoggerFactory()


def get_logger(name):
    """
    Get a logger with the given name.

    Args:
        name: Logger name (typically __name__ of the calling module)

    Returns:
        logging.Logger: Configured logger instance
    """
    return logger_factory.get_logger(name)


def configure_logging(level=None, format=None, log_file=None):
    """
    Configure global logging settings.

    Args:
        level: Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
        format: Log format string
        log_file: Path to log file (if None, logging to file is disabled)
    """
    logger_factory.configure(level, format, log_file)
