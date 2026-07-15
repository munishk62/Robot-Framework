# Add/Save/Edit Driver API - POST to JSP page with 302 redirect response
# Endpoint: /RWS4/rfp/workload/config/cfg_wdr_drv_process.jsp
# Response: HTTP 302 redirect to cfg_wdr_drv.jsp
SAVE_DRIVER_API_REGEX = "**/cfg_wdr_drv_process.jsp**"

# Delete Driver API - Also uses the same JSP endpoint
# The action is determined by form parameters, not URL
DELETE_DRIVER_API_REGEX = "**/cfg_wdr_drv_process.jsp**"

# Note: This is a legacy JSP form submission (not JSON REST API)
# - POST method with form data
# - Returns HTTP 302 redirect (not 200/201)
# - Success is indicated by redirect to listing page
