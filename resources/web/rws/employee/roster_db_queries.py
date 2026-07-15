# Query to retrieve staff group ID from the database using person ID
ROSTER_STAFF_GROUP_ID_BY_PERSON_ID = """
SELECT 
    STAFF_GROUP_ID 
FROM 
    RWS_EMP_STAFF_GRP 
WHERE 
    OWNER_ID = '{OWNER_ID}' 
    AND person_id = {PERSON_ID}
"""
