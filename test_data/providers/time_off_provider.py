"""
Provider for time off request data.
"""

from robot.api.deco import keyword

# Change relative imports to absolute imports
from test_data.constants import date_helper
from test_data.providers.base_provider import BaseDataProvider


class TimeOffDataProvider(BaseDataProvider):
    """Provides test data specifically for time off request tests."""

    def __init__(self):
        super().__init__("time_off")

    @keyword
    def get_time_off_data(self, test_id=None, template_name="default", **overrides):
        """
        Returns test data for a time off request test case.

        Args:
            test_id: Optional test ID to return data for a specific test case
            template_name: Name of the template to use (default is 'default')
            **overrides: Any field values to override in the base template

        Returns:
            Dict: Test data object with all required fields for time off requests
        """
        # Start with the base template
        if template_name not in self.templates:
            template_name = "default"

        base_data = self.templates[template_name].copy()

        # Apply test-specific overrides if a test ID is provided
        if test_id:
            test_overrides = self._get_test_override(test_id)
            base_data.update(test_overrides)

        # Apply any additional overrides passed to the function
        base_data.update(overrides)

        # Process date placeholders
        base_data = self._process_date_placeholders(base_data)

        # Resolve logical constants to environment-specific system values
        base_data = self._resolve_constant_values(
            base_data, ["TimeOffReasonType", "RequestStatus"]
        )

        # Add the test ID to the returned data
        base_data["test_id"] = test_id or "GENERIC"

        # Add environment information for traceability
        base_data["environment"] = self.env_manager.get_current_environment()

        return base_data

    def _process_date_placeholders(self, data):
        """Replace date placeholders with actual dates."""
        for key in ["start_date", "end_date"]:
            if key in data and isinstance(data[key], str):
                if data[key].startswith("PLANNING_WEEK"):
                    parts = data[key].split("_")
                    if len(parts) >= 3:
                        week_num = int(parts[2])
                        day_num = int(parts[4]) if len(parts) >= 5 else 1
                        data[key] = date_helper.get_planning_date(week_num, day_num)
                elif data[key].startswith("TODAY"):
                    offset = 0
                    if "+" in data[key]:
                        offset = int(data[key].split("+")[1])
                    elif "-" in data[key]:
                        offset = -int(data[key].split("-")[1])
                    data[key] = date_helper.get_date_with_offset(offset)

        # Process time values if needed
        for key in ["start_time", "end_time"]:
            if key in data and isinstance(data[key], str):
                # No processing needed for time values yet, but could be added here
                pass

        return data
