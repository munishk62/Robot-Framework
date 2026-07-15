"""
Advanced Settings API Endpoints and Patterns

This module contains API URL patterns and regex patterns for Advanced Settings operations.
These patterns are used to intercept and verify API responses during weekplan generation.

Based on HAR file analysis:
- Forecast: /RWS4/servlet/RwsFcstQueueServlet
- Workload: /RWS4/servlet/RwsWLSchdQueueServlet?...genType=RW
- Schedule: /RWS4/servlet/RwsWLSchdQueueServlet?...genType=RS

Usage:
    from resources.web.rws.advanced_settings.advanced_settings_api import FORECAST_GENERATION_API_REGEX

    ${promise}=    Promise To    Wait For Response    ${FORECAST_GENERATION_API_REGEX}
"""

# API Regex patterns for weekplan generation operations (from HAR file analysis)
FORECAST_GENERATION_API_REGEX = r".*/servlet/RwsFcstQueueServlet"
WORKLOAD_GENERATION_API_REGEX = r".*/servlet/RwsWLSchdQueueServlet\?.*genType=RW"
SCHEDULE_GENERATION_API_REGEX = r".*/servlet/RwsWLSchdQueueServlet\?.*genType=RS"
WORKLOAD_SCHEDULE_API_REGEX = r".*/servlet/RwsWLSchdQueueServlet"
