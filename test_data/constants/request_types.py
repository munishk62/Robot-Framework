"""
Logical request type definitions for WFM application
"""


class DayOffReasonType:
    """Logical request type identifiers (not actual system values)"""

    # Day Off Types
    PAID_VACATION = "PAID_VACATION"
    UNPAID_DAY_OFF = "UNPAID_DAY_OFF"


class TimeOffReasonType:
    # Time Off Types
    UNPAID_TIME_OFF = "UNPAID_TIME_OFF"
    PAID_TIME_OFF = "PAID_TIME_OFF"


class RequestStatus:
    """Logical request status identifiers"""

    NOT_REVIEWED = "NOT_REVIEWED"
    PENDING = "PENDING"
    APPROVED = "APPROVED"
    DECLINED = "DECLINED"
    CANCELED = "CANCELED"
    EXPIRED = "EXPIRED"


##/how the constant are used based on env specific example:
# in one env the request type is "PAID_VACATION" and in another it is "PAID_TIME_OFF" in terms of using same tests across environments
# in one env the request status is "NOT_REVIEWED" and in another it is "Pending" but with different system values

# can we rename the file name as request_constants.py to be more generic?
