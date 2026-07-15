# Database queries for Template Calendar / Work Pattern operations

# Query to get existing available work pattern (template) name from RWS_SCHEDULE_TEMPLATE table
# Returns: Single row with TEMPLATE_NAME column
# Filters by: OWNER_ID (from config OWNER_ID), STATUS='A' (active), TEMPLATE_TYPE='S' (shift template), LAST_USER='SYSADMIN'
# Orders by: LAST_UPDATE_TIME ASC to get the oldest template
# Limit: Returns only the first row
GET_AVAILABLE_WORK_PATTERN_NAME = """
SELECT TEMPLATE_NAME
FROM RWS_SCHEDULE_TEMPLATE
WHERE OWNER_ID = {owner_id}
AND STATUS = 'A'
AND TEMPLATE_TYPE = 'S'
AND LAST_USER = 'SYSADMIN'
ORDER BY LAST_UPDATE_TIME ASC
FETCH FIRST ROW ONLY
"""

# Query to get work pattern (template) name available for a particular week
# Returns: Single row with TEMPLATE_NAME column
# Filters by: OWNER_ID (from config OWNER_ID), DIST_LIST_ID (store identifier),
#            FISCAL_YEAR (calendar fiscal year), WEEK (calendar week number)
# Logic: Joins RWS_SCHEDULE_TEMPLATE with RWS_CALENDAR_ATTR to find the template
#        assigned to the specified week via WEEK_TYPE
GET_WORK_PATTERN_BY_WEEK = """
SELECT TEMPLATE_NAME
FROM RWS_SCHEDULE_TEMPLATE
WHERE OWNER_ID = {owner_id}
AND TEMPLATE_ID = (
    SELECT WEEK_TYPE
    FROM RWS_CALENDAR_ATTR
    WHERE OWNER_ID = {owner_id}
    AND DIST_LIST_ID = '{dist_list_id}'
    AND FISCAL_YEAR = '{fiscal_year}'
    AND WEEK = '{week}'
)
"""
