"""
Provider for clock native register data.
"""

from robot.api.deco import keyword

from test_data.providers.base_provider import BaseDataProvider


class ClockNativeRegisterDataProvider(BaseDataProvider):
    """Provides test data specifically for native clock registration tests."""

    def __init__(self):
        super().__init__("clock_native_register")

    @keyword
    def get_native_clock_register_data(
        self, test_id=None, template_name="default", **overrides
    ):
        """
        Returns test data for a clock native register test case.

        This keyword provides realistic clock registration data that can be customized
        for specific test scenarios using templates and parameter overrides.

        Args:
            test_id: Optional test ID to return data for a specific test case
            template_name: Name of the template to use (default is 'default')
            **overrides: Any field values to override in the base template

        Returns:
            Dict: Test data object with all required fields for clock registration

        Examples:
            | ${register_data}=    Get Native Clock Register Data
            | ${register_data}=    Get Native Clock Register Data    template_name=custom
            | ${register_data}=    Get Native Clock Register Data    device_location=Back End
            | ${register_data}=    Get Native Clock Register Data    enable_location_services=${True}
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

        # Add the test ID to the returned data
        base_data["test_id"] = test_id or "GENERIC"

        # Add environment information for traceability
        base_data["environment"] = self.env_manager.get_current_environment()

        return base_data

