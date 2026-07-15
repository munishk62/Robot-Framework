# API endpoint templates for RWS Upload and Data Import operations
# These templates use placeholders that are replaced at runtime with actual values

# Data Import Feed API
# POST {BASE_URL}/controller/connect/dataimports/v1_0/feed.json
# This API endpoint is used for multiple data import feed types:
# - HRBA: User creation via HRBA data import feed
# - HRCI: User status updates via HRCI data import feed
# - HRAC: Leave accrual data import via HRAC data import feed
DATA_IMPORT_FEED_API_TEMPLATE = "{BASE_URL}/controller/connect/dataimports/v1_0/feed.json"

