import os
import copy

# Change relative imports to absolute imports
from test_data.environment_manager import EnvironmentManager


class UserProvider:
    """
    Provider for user data across different environments and test scenarios.
    Uses environment variables for credentials.
    """

    def __init__(self, env_manager=None):
        self.env_manager = env_manager or EnvironmentManager()
        self.base_dir = os.path.join(
            os.path.dirname(os.path.dirname(__file__)), "templates", "users"
        )
        self.override_dir = os.path.join(self.base_dir, "overrides")
        self._credentials = self._load_credentials()

    def _load_credentials(self):
        """Load credentials from the credentials.py module or directly from environment variables"""
        credentials = {}

        # Try to load directly from environment variable
        try:
            import os
            import json
            import logging
            from dotenv import load_dotenv

            # Suppress dotenv warnings for multi-line values
            dotenv_logger = logging.getLogger("dotenv.main")
            original_level = dotenv_logger.level
            dotenv_logger.setLevel(logging.ERROR)

            try:
                # Ensure environment variables are loaded
                load_dotenv()
            finally:
                dotenv_logger.setLevel(original_level)

            creds_json = os.getenv("USER_CREDENTIALS")
            if creds_json:
                print(
                    "Found USER_CREDENTIALS environment variable, attempting to parse"
                )
                # Try to clean up any extra quotes that might be present
                creds_json = creds_json.strip()
                if creds_json.startswith('"') and creds_json.endswith('"'):
                    creds_json = creds_json[1:-1]

                credentials = json.loads(creds_json)
                print(
                    f"Successfully loaded credentials from environment for users: {list(credentials.keys())}"
                )
                return credentials
        except Exception as e:
            print(f"Error loading credentials from environment: {str(e)}")

        # Return empty dict if no credentials could be loaded
        print("No credentials could be loaded, using empty dictionary")
        return {}

    def _mask_sensitive_data(self, user_data):
        """
        Create a copy of user data with sensitive fields masked for security.

        Args:
            user_data (dict): The original user data dictionary

        Returns:
            dict: Copy of user data with password fields masked
        """
        if not user_data or not isinstance(user_data, dict):
            return user_data

        # Create a deep copy to avoid modifying the original
        masked_data = copy.deepcopy(user_data)

        # List of sensitive field names to mask (case-insensitive)
        sensitive_fields = ["password", "secret", "token", "auth"]

        # Mask all sensitive fields
        for key in masked_data:
            if isinstance(masked_data[key], str) and any(
                sensitive_word in key.lower() for sensitive_word in sensitive_fields
            ):
                masked_data[key] = "********"

        return masked_data

    def get_available_users(self):
        """
        Returns a list of available user IDs from credentials.

        Returns:
            list: List of user IDs available in credentials
        """
        return list(self._credentials.keys())

    def get_user(self, user_key=None, mask_password=True, **kwargs):
        """
        Get user data for a specific user type and role.
        Prioritizes credentials if user_key is provided, falls back to templates.

        Args:
            user_key (str, optional): Specific user ID to fetch from credentials. Defaults to None.
            mask_password (bool): Whether to mask password in the returned data. Defaults to True.
            **kwargs: Additional parameters to customize the user data

        Returns:
            dict: User data with environment-specific values resolved and passwords masked if requested
        """
        if not user_key:
            raise ValueError("User key is required to fetch user data")
        # First try to get from credentials if user_key is provided
        if user_key not in self._credentials:
            # If user_key is not found, log a warning and return None
            raise ValueError(f"User key '{user_key}' not found in credentials")

        user_data = self._credentials[user_key].copy()
        user_data["user_key"] = user_key  # Ensure user_key is set

        # Apply any additional custom attributes
        user_data.update(kwargs)

        # Mask passwords if requested
        if mask_password:
            return self._mask_sensitive_data(user_data)
        return user_data

        # Apply any additional custom attributes
        user_data.update(kwargs)

        return user_data
