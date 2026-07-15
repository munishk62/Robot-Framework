"""
Database queries for Punch Import functionality.

This module contains SQL query templates for TA_PUNCH table operations.
Query placeholders (e.g., {owner_id}, {badge_id}) should be replaced using
Robot Framework's 'Replace String' keyword before execution.
"""

# Query to check if punches exist for a specific associate, device, store, and date
# Returns: Single row with COUNT(*) - number of punches found
# Filters by: OWNER_ID, BADGE_ID, DEVICE_ID, UNIT_ID, and PUNCH_DATE
# Use case: Skip punch import test if punches already exist for today
CHECK_EXISTING_PUNCHES_COUNT = """SELECT COUNT(*) FROM TA_PUNCH WHERE OWNER_ID = '{owner_id}' AND BADGE_ID = '{badge_id}' AND DEVICE_ID = '{device_id}' AND UNIT_ID = '{unit_id}' AND PUNCH_DATE = '{punch_date}'"""
