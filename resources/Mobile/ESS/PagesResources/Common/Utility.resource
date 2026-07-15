*** Settings ***
Documentation       This resource file contains utility keywords which are used across multiple test cases in mobile ESS.

Library             Collections
Library             DateTime
Library             re
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Variables           resources/Mobile/ESS/Locators/common_data.py


*** Variables ***
${LOCAL_PLANNING_WEEK}      ${EMPTY}


*** Keywords ***
Calculate Week Start
    [Documentation]    Used for calculating the start of the week based on the fiscal week start.
    ...
    ...    Args:
    ...    ${date}: <date> in YYYY-MM-DD format(%Y-%m-%d)
    [Arguments]    ${date}
    ${fiscalWeekDay}    Get Config Value    FISCAL_WEEK_START_DAY
    ${today_weekday}    Evaluate    (datetime.date(*map(int, '${date}'.split('-'))).isoweekday() % 7) + 1
    ${offset}    Evaluate    (${today_weekday} - ${fiscalWeekDay}) % 7
    ${target_date}    DateTime.Subtract Time From Date    ${date}    ${offset} days
    RETURN    ${target_date}

Calculate Week End
    [Documentation]    Used for calculating the end of the week based on the fiscal week start.
    ...
    ...    Args:
    ...    ${date}: <date> in YYYY-MM-DD format(%Y-%m-%d)
    [Arguments]    ${date}
    ${fiscalWeekDay}    Get Config Value    FISCAL_WEEK_START_DAY
    ${today_weekday}    Evaluate    (datetime.date(*map(int, '${date}'.split('-'))).isoweekday() % 7) + 1
    ${offset}    Evaluate    (${today_weekday} - ${fiscalWeekDay}) % 7
    ${target_date}    DateTime.Subtract Time From Date    ${date}    ${offset} days
    ${target_week_end_date}    DateTime.Add Time To Date    ${target_date}    6 days
    RETURN    ${target_week_end_date}

Calculate Date Difference In Days
    [Documentation]    Calculates the day difference between two already-converted dates.
    ...    | =Arguments= | =Description= |
    ...    | ${start_date} | Start date string in the supplied format. |
    ...    | ${end_date} | End date string in the supplied format. |
    ...    | ${date_format} | Date format used to parse both dates, defaults to server date format. |
    ...
    ...    *Returns*: The raw gap in days between the two dates.
    [Arguments]    ${start_date}    ${end_date}    ${date_format}=${EMPTY}
    IF    '${date_format}' == ''
        ${date_format}    Get Config Value    SERVER_DF
    END
    ${raw_gap_days}    Evaluate
    ...    (datetime.datetime.strptime('${end_date}', '${date_format}') - datetime.datetime.strptime('${start_date}', '${date_format}')).days
    ...    modules=datetime
    RETURN    ${raw_gap_days}

Calculate Days Between Date Offsets
    [Documentation]    Converts two week_day offset dates to server format and returns the inclusive day span between them.
    ...    | =Arguments= | =Description= |
    ...    | ${start_date_offset} | Start date in week_day offset format (e.g., 2_5). |
    ...    | ${end_date_offset} | End date in week_day offset format (e.g., 3_0). |
    ...
    ...    *Returns*: A tuple-like pair of converted dates and the inclusive day count as: (${start_date_converted}, ${end_date_converted}, ${inclusive_days}).
    [Arguments]    ${start_date_offset}    ${end_date_offset}
    ${date_format}    Get Config Value    SERVER_DF
    ${start_date_converted}    Calculate Date From Week Day Offset    ${start_date_offset}    ${date_format}
    ${end_date_converted}    Calculate Date From Week Day Offset    ${end_date_offset}    ${date_format}
    ${raw_gap_days}    Calculate Date Difference In Days    ${start_date_converted}    ${end_date_converted}    ${date_format}
    ${inclusive_days}    Evaluate    ${raw_gap_days} + 1
    RETURN    ${inclusive_days}

Tap Multiple Time On Element
    [Documentation]    Used for swiping until element is visible.
    ...    Arguments:
    ...    ${locator}: locator of element to be visible
    ...    ${number_of_taps}: number of taps
    ...    ${duration}: length of time to tap, in ms. Default: 1ms
    [Arguments]    ${locator}    ${number_of_taps}=10x    ${duration}=1
    ${element_rect}    Get Element Rect    ${locator}
    VAR    ${x1}    ${element_rect['x']}
    VAR    ${y1}    ${element_rect['y']}
    VAR    ${x2}    ${element_rect['x']} + ${element_rect['width']}
    VAR    ${y2}    ${element_rect['y']} + ${element_rect['height']}
    ${center_x}    Evaluate    (${x1} + ${x2}) / 2
    ${center_y}    Evaluate    (${y1} + ${y2}) / 2
    VAR    @{firstFinger}    ${center_x}    ${center_y}
    Repeat Keyword    ${number_of_taps}    Tap With Positions    ${duration}    ${firstFinger}

Swipe Until Element Not Visible
    [Documentation]    Used for swiping until element is not visible.
    ...    Arguments:
    ...    ${locator}: <locator of element to be visible>
    ...    ${direction}: <direction of swipe> default is down
    ...    ${maxSwipes}: <maximum swipes> default is 10
    ...    Raises:
    ...    - Fail: If element is visible after maximum swipes
    ...    Example:
    ...    - Swipe Until Visible    ${locator}    up    10
    [Arguments]    ${locator}    ${direction}="down"    ${maxSwipes}=10
    ${screen_width}    Get Window Width
    ${screen_height}    Get Window Height
    ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=3s
    IF    '${is_visible}' == 'True'
        Fail    Element locator '${locator}' is visible
    END
    FOR    ${_}    IN RANGE    ${maxSwipes}
        IF    ${direction} == "down"
            ${start_x}    Evaluate    ${screen_width} * 0.5
            ${start_y}    Evaluate    ${screen_height} * 0.6
            ${end_x}    Evaluate    ${screen_width} * 0.5
            ${end_y}    Evaluate    ${screen_height} * 0.3
        ELSE IF    ${direction} == "up"
            ${start_x}    Evaluate    ${screen_width} * 0.5
            ${start_y}    Evaluate    ${screen_height} * 0.3
            ${end_x}    Evaluate    ${screen_width} * 0.5
            ${end_y}    Evaluate    ${screen_height} * 0.6
        ELSE IF    ${direction} == "right"
            ${start_x}    Evaluate    ${screen_width} * 0.8
            ${start_y}    Evaluate    ${screen_height} * 0.5
            ${end_x}    Evaluate    ${screen_width} * 0.2
            ${end_y}    Evaluate    ${screen_height} * 0.5
        ELSE IF    ${direction} == "left"
            ${start_x}    Evaluate    ${screen_width} * 0.2
            ${start_y}    Evaluate    ${screen_height} * 0.5
            ${end_x}    Evaluate    ${screen_width} * 0.8
            ${end_y}    Evaluate    ${screen_height} * 0.5
        END
        Swipe    ${start_x}    ${start_y}    ${end_x}    ${end_y}    1000
        Sleep    1s
        ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=3s
        IF    '${is_visible}' == 'True'
            Fail    Element locator '${locator}' is visible
        END
    END
    ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=3s
    IF    '${is_visible}' == 'True'
        Fail    Element locator '${locator}' is visible after ${maxSwipes} swipes
    END

Get Formatted Date From
    [Documentation]    Converts a date string from one format to another format.
    ...    Args:
    ...    ${date_string}: The date string to convert (e.g., "2024-11-25").
    ...    ${from_format}: The format of the provided date string (e.g., "%Y-%m-%d").
    ...    ${to_format}: The desired output format (e.g., "%d/%m/%Y").
    [Arguments]    ${date_string}    ${from_format}    ${to_format}
    ${formatted_date}    Convert Date
    ...    ${date_string}
    ...    date_format=${from_format}
    ...    result_format=${to_format}
    RETURN    ${formatted_date}

Swipe Up On Element
    [Documentation]    Performs Swipe up operation on the element.
    ...    Args:
    ...    ${locator}: Locator in which need to perform swipe up operation.
    ...    ${swipe_count}: Number of swipes to be performed. Default is 1.
    [Arguments]    ${locator}    ${swipe_count}=1

    ${element_size}    Get Element Size    ${locator}
    ${element_location}    Get Element Location    ${locator}
    ${start_x}    Evaluate    ${element_location['x']} + (${element_size['width']} * 0.5)
    ${start_y}    Evaluate    ${element_location['y']} + (${element_size['height']} * 0.5)
    ${end_x}    Evaluate    ${element_location['x']} + (${element_size['width']} * 0.5)
    ${end_y}    Evaluate    ${element_location['y']} + (${element_size['height']} * 0.2)
    FOR    ${_}    IN RANGE    ${swipe_count}
        Swipe    ${start_x}    ${start_y}    ${end_x}    ${end_y}    500
        Sleep    1
    END

Swipe Up On Small Element
    [Documentation]    Performs Swipe up operation on the small element.
    ...    Args:
    ...    ${locator}: Locator in which need to perform swipe up operation.
    ...    ${swipe_count}: Number of swipes to be performed. Default is 1.
    [Arguments]    ${locator}    ${swipe_count}=1

    ${element_size}    Get Element Size    ${locator}
    ${element_location}    Get Element Location    ${locator}
    ${start_x}    Evaluate    ${element_location['x']} + (${element_size['width']} * 0.5)
    ${start_y}    Evaluate    ${element_location['y']} + (${element_size['height']} * 1)
    ${end_x}    Evaluate    ${element_location['x']} + (${element_size['width']} * 0.5)
    ${end_y}    Evaluate    ${element_location['y']} + (${element_size['height']} * 0.1)
    FOR    ${_}    IN RANGE    ${swipe_count}
        Swipe    ${start_x}    ${start_y}    ${end_x}    ${end_y}    500
        Sleep    1
    END

Swipe Right On Element
    [Documentation]    Performs Swipe right operation on the element.
    ...    Args:
    ...    ${locator}: Locator in which need to perform swipe up operation.
    ...    ${swipe_count}: Number of swipes to be performed. Default is 1.
    [Arguments]    ${locator}    ${swipe_count}=1

    ${element_size}    Get Element Size    ${locator}
    ${element_location}    Get Element Location    ${locator}
    ${start_x}    Evaluate    ${element_location['x']} + (${element_size['width']} * 0.8)
    ${start_y}    Evaluate    ${element_location['y']} + (${element_size['height']} * 0.5)
    ${end_x}    Evaluate    ${element_location['x']} + (${element_size['width']} * 0.2)
    ${end_y}    Evaluate    ${element_location['y']} + (${element_size['height']} * 0.5)
    FOR    ${_}    IN RANGE    ${swipe_count}
        Swipe    start_x=${start_x}    start_y=${start_y}    end_x=${end_x}    end_y=${end_y}    duration=500
        Sleep    1
    END

Swipe Down On Element
    [Documentation]    Performs Swipe down operation on the element.
    ...    Args:
    ...    ${locator}: Locator in which need to perform swipe down operation.
    ...    ${swipe_count}: Number of swipes to be performed. Default is 1.
    [Arguments]    ${locator}    ${swipe_count}=1
    ${element_size}    Get Element Size    ${locator}
    ${element_location}    Get Element Location    ${locator}
    ${start_x}    Evaluate    ${element_location['x']} + (${element_size['width']} * 0.5)
    ${start_y}    Evaluate    ${element_location['y']} + (${element_size['height']} * 0.2)
    ${end_x}    Evaluate    ${element_location['x']} + (${element_size['width']} * 0.5)
    ${end_y}    Evaluate    ${element_location['y']} + (${element_size['height']} * 0.5)
    FOR    ${_}    IN RANGE    ${swipe_count}
        Swipe    ${start_x}    ${start_y}    ${end_x}    ${end_y}    500
        Sleep    1
    END

Swipe Down On Small Element
    [Documentation]    Performs Swipe down operation on the small element.
    ...    Args:
    ...    ${locator}: Locator in which need to perform swipe down operation.
    ...    ${swipe_count}: Number of swipes to be performed. Default is 1.
    [Arguments]    ${locator}    ${swipe_count}=1
    ${element_size}    Get Element Size    ${locator}
    ${element_location}    Get Element Location    ${locator}
    ${start_x}    Evaluate    ${element_location['x']} + (${element_size['width']} * 0.5)
    ${start_y}    Evaluate    ${element_location['y']} + (${element_size['height']} * 0.1)
    ${end_x}    Evaluate    ${element_location['x']} + (${element_size['width']} * 0.5)
    ${end_y}    Evaluate    ${element_location['y']} + (${element_size['height']} * 1)
    FOR    ${_}    IN RANGE    ${swipe_count}
        Swipe    ${start_x}    ${start_y}    ${end_x}    ${end_y}    500
        Sleep    1
    END

Get Date From Number Of Days Before Or After Current Date
    [Documentation]    Gets date after specified duration from current date
    ...    Args:
    ...    ${days_count}: No. of days from current date
    ...    ${before_after_date}: Flag for checking if past date or future date, False for past True for future
    [Arguments]    ${days_count}    ${before_after_date}=True
    ${current_date}    Get Current Date    result_format=%Y-%m-%d
    IF    '${before_after_date}' =="True"
        ${date}    Add Time To Date    ${current_date}    ${days_count} days    result_format=%Y%m%d
    ELSE
        ${date}    Add Time To Date    ${current_date}    -${days_count} days    result_format=%Y%m%d
    END
    RETURN    ${date}

Convert 24 Hour Time To Total Minutes
    [Documentation]    Converts a 24-hour time string (e.g., "4:30","16:30") to total minutes. Leading 0 not allowed
    ...    Args:
    ...    ${time_string}: The time string in "HH:MM" format.
    [Arguments]    ${time_string}
    ${hours}    ${minutes}    Split String    ${time_string}    :
    ${total_minutes}    Evaluate    int(${hours}) * 60 + int(${minutes})
    RETURN    ${total_minutes}

Convert Total Minutes To 12 Hour Time
    [Documentation]    Converts total minutes to a 12-hour time format with am/pm.
    ...    Args:
    ...    ${total_minutes}: Total minutes to convert (e.g., 270 for 4:30 or 990 for 16:30).
    [Arguments]    ${total_minutes}
    ${hours}    Evaluate    int(${total_minutes} // 60)
    ${minutes}    Evaluate    int(${total_minutes} % 60)
    ${adjusted_hours}    Evaluate    12 if ${hours} == 0 else (${hours} - 12 if ${hours} > 12 else ${hours})
    ${time}    Evaluate    "{:02d}:{:02d}".format(${adjusted_hours}, ${minutes})
    ${am_pm}    Evaluate    "am" if ${hours} < 12 else "pm"
    RETURN    ${time} ${am_pm}

Swipe Right Until Element Visible
    [Documentation]    Performs a swipe action to the right within a specific window until the element is visible.
    ...    Arguments:
    ...    ${window_locator}: Locator of the window to restrict the swipe action.
    ...    ${element_locator}: Locator of the element to be visible.
    ...    ${maxSwipes}: Maximum number of swipes. Default is 20.
    ...    Raises:
    ...    - Fail: If the element is not visible after maximum swipes.
    [Arguments]    ${window_locator}    ${element_locator}    ${maxSwipes}=5

    ${window_size}    Get Element Size    ${window_locator}
    ${window_location}    Get Element Location    ${window_locator}

    ${start_x}    Evaluate    ${window_location['x']} + (${window_size['width']} * 0.75)
    ${start_y}    Evaluate    ${window_location['y']} + (${window_size['height']} * 0.5)
    ${end_x}    Evaluate    ${window_location['x']} + (${window_size['width']} * 0.25)
    ${end_y}    Evaluate    ${window_location['y']} + (${window_size['height']} * 0.5)

    FOR    ${index}    IN RANGE    ${maxSwipes}
        Log    Swipe attempt ${index + 1}
        ${is_visible}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    ${element_locator}
        ...    timeout=2s
        IF    ${is_visible}    BREAK

        Swipe    ${start_x}    ${start_y}    ${end_x}    ${end_y}    500
        Sleep    0.5s
    END

    ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${element_locator}    timeout=2s
    IF    not ${is_visible}
        Fail    Element locator '${element_locator}' not visible after ${maxSwipes} swipes
    END

Swipe Right Until Element Not Visible
    [Documentation]    Swipes to the right within a window to confirm an element is not visible.
    ...    Fails if the element is found during swipes.
    [Arguments]    ${window_locator}    ${element_locator}    ${maxSwipes}=5

    ${window_size}    Get Element Size    ${window_locator}
    ${window_location}    Get Element Location    ${window_locator}

    ${start_x}    Evaluate    ${window_location['x']} + (${window_size['width']} * 0.75)
    ${start_y}    Evaluate    ${window_location['y']} + (${window_size['height']} * 0.5)
    ${end_x}    Evaluate    ${window_location['x']} + (${window_size['width']} * 0.25)
    ${end_y}    Evaluate    ${window_location['y']} + (${window_size['height']} * 0.5)

    FOR    ${index}    IN RANGE    ${maxSwipes}
        Log    Swipe attempt ${index + 1} to ensure '${element_locator}' is not visible
        ${is_visible}    Run Keyword And Return Status    Page Should Contain Element    ${element_locator}
        IF    ${is_visible}
            Fail    Element '${element_locator}' unexpectedly found on swipe ${index + 1}
        END

        Swipe    ${start_x}    ${start_y}    ${end_x}    ${end_y}    500
        Sleep    0.5s
    END

    Log    '${element_locator}' not found after ${maxSwipes} swipes – confirmed not visible.

Calculate Time Difference In Hours
    [Documentation]    Calculates time difference in hours (float) between two HH:MM times, handling overnight shifts.
    [Arguments]    ${start_time}    ${end_time}
    ${diff}    Evaluate
    ...    round(((__import__('datetime').datetime.strptime("${end_time}", "%H:%M") + __import__('datetime').timedelta(days=1) if __import__('datetime').datetime.strptime("${end_time}", "%H:%M") < __import__('datetime').datetime.strptime("${start_time}", "%H:%M") else __import__('datetime').datetime.strptime("${end_time}", "%H:%M")) - __import__('datetime').datetime.strptime("${start_time}", "%H:%M")).total_seconds() / 3600, 2)
    RETURN    ${diff}
