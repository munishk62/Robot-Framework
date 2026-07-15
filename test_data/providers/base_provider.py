"""
Base data provider with common functionality for all data providers.
"""

import os
import json
from pathlib import Path

# Change relative import to absolute import
from test_data.environment_manager import EnvironmentManager


class BaseDataProvider:
    """Base class for all data providers."""

    def __init__(self, domain_name):
        """
        Initialize the base data provider.

        Args:
            domain_name (str): The domain for which data is being provided
                (e.g., 'users', 'day_off', 'time_off')
        """
        self.domain_name = domain_name
        self.env_manager = EnvironmentManager()

        # Get the root directory of the test data
        self.test_data_dir = Path(os.path.dirname(os.path.dirname(__file__)))
        self.templates_dir = self.test_data_dir / "entities" / domain_name
        self.base_template_path = self.templates_dir / "base_templates.json"
        self.override_dir = self.templates_dir / "overrides"

        # Load templates
        self.templates = self._load_templates()

        # Storage for test-specific overrides
        self.test_overrides = {}

    def _load_templates(self):
        """Load base templates and any environment-specific overrides."""
        if not self.base_template_path.exists():
            return {"default": {}}

        with open(self.base_template_path, "r", encoding="utf-8") as file:
            templates = json.load(file)

        # Check for environment-specific template overrides
        env = self.env_manager.get_current_environment()
        env_override_path = self.override_dir / f"{env}_templates.json"

        if env_override_path.exists():
            with open(env_override_path, "r", encoding="utf-8") as file:
                overrides = json.load(file)
                # Merge overrides with base templates
                for template_name, override_data in overrides.items():
                    if template_name in templates:
                        templates[template_name].update(override_data)
                    else:
                        templates[template_name] = override_data

        return templates

    def _get_test_override(self, test_id):
        """Load test-specific overrides from file if available."""
        print(f"Fetching test override for ID: {test_id}")
        if test_id in self.test_overrides:
            return self.test_overrides[test_id]

        test_override_path = self.override_dir / f"{test_id}.json"
        print(f"Fetching test override path: {test_override_path}")
        if test_override_path.exists():
            with open(test_override_path, "r", encoding="utf-8") as file:
                self.test_overrides[test_id] = json.load(file)
                print(
                    f"Loaded test override for {test_id}: {self.test_overrides[test_id]}"
                )
                return self.test_overrides[test_id]

        return {}

    def _resolve_constant_values(self, data, constantClassNames=None):
        if constantClassNames is None:
            return
        """Resolve logical constants to environment-specific system values."""
        if isinstance(data, dict):
            result = {}
            for key, value in data.items():
                result[key] = self._resolve_constant_values(value, constantClassNames)
            return result
        elif isinstance(data, list):
            return [
                self._resolve_constant_values(item, constantClassNames) for item in data
            ]
        elif isinstance(data, str):
            # Enhanced to handle nested: "StoreEntity.STORE1.store_id"
            if "." in data and any(
                data.startswith(prefix) for prefix in constantClassNames
            ):
                parts = data.split(".")
                if len(parts) == 2:  # Current: "RequestStatus.APPROVED"
                    class_name, constant_name = parts
                    return self.env_manager.get_system_value(class_name, constant_name)
                elif len(parts) == 3:  # New: "StoreEntity.STORE1.store_id"
                    class_name, entity_name, attribute = parts
                    # Get nested value from constants
                    constants = self.env_manager.constants
                    if class_name in constants and entity_name in constants[class_name]:
                        entity_data = constants[class_name][entity_name]
                        if isinstance(entity_data, dict) and attribute in entity_data:
                            return entity_data[attribute]
            return data
        else:
            return data
