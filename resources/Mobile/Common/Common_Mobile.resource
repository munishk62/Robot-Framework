*** Settings ***
Documentation       This resource file contains utility keywords which are used across multiple test cases in mobile ESS.

Library             Collections
Library             DateTime
Library             re
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/web/clock/webclock_db.resource
Variables           resources/Mobile/Common/Timeout_Variables_Mobile.py


*** Variables ***
${LOCAL_PLANNING_WEEK}      ${EMPTY}


*** Keywords ***
Swipe Until Visible
    [Documentation]    Used for swiping until element is visible.
    ...    Arguments:
    ...    ${locator}: <locator of element to be visible>
    ...    ${direction}: <direction of swipe> default is down
    ...    ${maxSwipes}: <maximum swipes> default is 20
    ...    Raises:
    ...    - Fail: If element is not visible after maximum swipes
    ...    Example:
    ...    - Swipe until visible    ${locator}    up    10
    [Arguments]    ${locator}    ${direction}="down"    ${maxSwipes}=5
    ${screen_width}    Get Window Width
    ${screen_height}    Get Window Height
    Hide Keyboard
    FOR    ${_}    IN RANGE    ${maxSwipes}
        ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=3s

        IF    ${is_visible}    BREAK
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

        ${start_x}    Convert To Integer    ${start_x}
        ${start_y}    Convert To Integer    ${start_y}
        ${end_x}    Convert To Integer    ${end_x}
        ${end_y}    Convert To Integer    ${end_y}

        Swipe    start_x=${start_x}    start_y=${start_y}    end_x=${end_x}    end_y=${end_y}    duration=1000ms
        Sleep    1s
    END
    ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=2s
    IF    not ${is_visible}
        Capture Page Screenshot
        Fail    Element locator '${locator}' not visible after ${maxSwipes} swipes
    END

Swipe In Container Until Visible
    [Documentation]
    ...    Swipes inside a scrollable container until the target element is both visible
    ...    and positioned within the container's boundaries.
    ...    First it checks if the target element is already visible and within the container bounds to avoid unnecessary swipes.
    ...    If not found, it performs swipes while checking for the element after each swipe.
    ...    It also includes a mechanism to swipe in the reverse direction a few times before starting the main swiping loop,
    ...    which can help in cases where the container is partially visible and the target element is just outside the visible area.
    ...    This is a generic wrapper for in-container scrolling and can be reused wherever
    ...    a scrollable box/list needs to be navigated to find a specific element.
    ...    | =Arguments=          | =Description=                                                                 |
    ...    | ${container_locator} | Locator of the scrollable container/box element.                              |
    ...    | ${target_locator}    | Locator of the target element to find inside the container.                   |
    ...    | ${max_swipes}        | Maximum number of upward swipes before failing. Default: 9.                   |
    ...    | ${start_ratio}       | Fraction of container height from top to start the swipe. Default: 0.8.      |
    ...    | ${end_ratio}         | Fraction of container height from top to end the swipe. Default: 0.2.        |
    ...    | ${max_reverse_swipes}| Maximum number of swipes to go in the reverse direction                      |
    ...
    ...    Example usage:
    ...    | Swipe In Container Until Visible    ${container_locator}    ${target_locator}
    ...    | Swipe In Container Until Visible    ${container_locator}    ${target_locator}    max_swipes=15
    [Arguments]    ${container_locator}    ${target_locator}    ${max_swipes}=9    ${start_ratio}=0.8    ${end_ratio}=0.2    ${max_reverse_swipes}=2
    Run Keyword And Ignore Error    Swipe Until Visible    ${container_locator}
    ${metrics}    Get Container Swipe Metrics    ${container_locator}    ${start_ratio}    ${end_ratio}
    Log    Container — top: ${metrics['box_top']}, bottom: ${metrics['box_bottom']}
    Log    Swipe coords — x: ${metrics['swipe_x']}, start_y: ${metrics['swipe_start_y']}, end_y: ${metrics['swipe_end_y']}

    ${found}    Is Target Visible In Container
    ...    ${target_locator}    ${metrics['box_top']}    ${metrics['box_bottom']}
    IF    ${found}    RETURN

    FOR    ${_}    IN RANGE    ${max_reverse_swipes}
        Swipe    start_x=${metrics['swipe_x']}    start_y=${metrics['swipe_end_y']}    end_x=${metrics['swipe_x']}    end_y=${metrics['swipe_start_y']}    duration=1000ms
        Sleep    1s
    END

    # There are some rare cases where due to the reverse swiping the container is getting partially visible hence handled in below condition
    # before starting the actual swipe with calculating the coordinates.
    # Below case will handle the scenario where due to the reverse swapping if the container is getting partially visible
    # and we need to get the container in view so that proper height and width can be calculated for the swipe action.
    # This will calculate based on the screen height and the direction for the swipe and get the container in view.
    ${screen_height}    Get Window Height
    IF    ${start_ratio} > ${end_ratio}
        VAR    ${swipe_start_y_for_box}    ${metrics}[box_top]
        ${swipe_end_y_for_box}      Evaluate    ${screen_height} * 0.2
    ELSE
        VAR    ${swipe_start_y_for_box}    ${metrics}[box_bottom]
        ${swipe_end_y_for_box}      Evaluate    ${screen_height} * 0.8
    END

    Log    Swipe coords for box adjustment — x: ${metrics['swipe_x']}, start_y: ${swipe_start_y_for_box}, end_y: ${swipe_end_y_for_box}
    Swipe    start_x=${metrics['swipe_x']}    start_y=${swipe_start_y_for_box}    end_x=${metrics['swipe_x']}    end_y=${swipe_end_y_for_box}   duration=1000ms
    Sleep    1s

    # Actual swiping actions in the container starts here
    VAR    ${found}    False
    FOR    ${_}    IN RANGE    ${max_swipes}
        ${metrics}    Get Container Swipe Metrics    ${container_locator}    ${start_ratio}    ${end_ratio}
        Log    Container — top: ${metrics['box_top']}, bottom: ${metrics['box_bottom']}
        Log    Swipe coords — x: ${metrics['swipe_x']}, start_y: ${metrics['swipe_start_y']}, end_y: ${metrics['swipe_end_y']}
        ${found}    Is Target Visible In Container
        ...    ${target_locator}    ${metrics['box_top']}    ${metrics['box_bottom']}
        IF    ${found}    BREAK
        Swipe    start_x=${metrics['swipe_x']}    start_y=${metrics['swipe_start_y']}    end_x=${metrics['swipe_x']}    end_y=${metrics['swipe_end_y']}    duration=1000ms
        Sleep    1s
    END
    IF    not ${found}
        Capture Page Screenshot
        Fail    Target element '${target_locator}' not found within container after ${max_swipes} swipes.
    END

Get Container Swipe Metrics
    [Documentation]
    ...    Gets container bounds and swipe coordinates from the given start and end ratios.
    ...    | =Arguments=          | =Description=                                            |
    ...    | ${container_locator} | Locator of the scrollable container/box element.         |
    ...    | ${start_ratio}       | Start ratio for swipe Y coordinate within container.     |
    ...    | ${end_ratio}         | End ratio for swipe Y coordinate within container.       |
    ...
    ...    *Returns*: Dictionary with box_top, box_bottom, swipe_x, swipe_start_y, swipe_end_y.
    [Arguments]    ${container_locator}    ${start_ratio}    ${end_ratio}
    ${box}    Get WebElement    ${container_locator}
    ${box_loc}    Get Element Location    ${box}
    ${box_size}    Get Element Size    ${box}
    ${box_x}    Get From Dictionary    ${box_loc}    x
    ${box_y}    Get From Dictionary    ${box_loc}    y
    ${box_width}    Get From Dictionary    ${box_size}    width
    ${box_height}    Get From Dictionary    ${box_size}    height
    ${box_top}    Convert To Number    ${box_y}
    ${box_bottom}    Evaluate    ${box_y} + ${box_height}
    ${swipe_x}    Evaluate    ${box_x} + (${box_width} / 2)
    ${swipe_start_y}    Evaluate    ${box_y} + (${box_height} * ${start_ratio})
    ${swipe_end_y}    Evaluate    ${box_y} + (${box_height} * ${end_ratio})
    VAR    &{metrics}
    ...    box_top=${box_top}
    ...    box_bottom=${box_bottom}
    ...    swipe_x=${swipe_x}
    ...    swipe_start_y=${swipe_start_y}
    ...    swipe_end_y=${swipe_end_y}
    ...    scope=LOCAL

    RETURN    &{metrics}

Get Locator Center Metrics
    [Documentation]
    ...    Gets the center point coordinates for the given locator.
    ...    | =Arguments=          | =Description=                                |
    ...    | ${locator}           | Locator to calculate the center point for.   |
    ...
    ...    *Returns*: Dictionary with center_x and center_y.
    [Arguments]    ${locator}
    ${element}    Get WebElement    ${locator}
    ${element_location}    Get Element Location    ${element}
    ${element_size}    Get Element Size    ${element}
    ${element_x}    Get From Dictionary    ${element_location}    x
    ${element_y}    Get From Dictionary    ${element_location}    y
    ${element_width}    Get From Dictionary    ${element_size}    width
    ${element_height}    Get From Dictionary    ${element_size}    height
    ${center_x}    Evaluate    int(${element_x} + (${element_width} / 2))
    ${center_y}    Evaluate    int(${element_y} + (${element_height} / 2))
    VAR    &{metrics}
    ...    center_x=${center_x}
    ...    center_y=${center_y}
    ...    scope=LOCAL

    RETURN    &{metrics}

Select Clickable Point Above Center
    [Documentation]
    ...    Clicks the locator at center, or slightly above/below center using platform-native mobile gestures.
    ...    | =Arguments= | =Description= |
    ...    | locator | Locator to click. |
    ...    | vertical_direction | Tap direction relative to center: center, above, or below. Default: center. |
    ...    | vertical_offset_ratio | Fraction of element height used as vertical offset from center. Default: 0.15. |
    [Arguments]    ${locator}    ${vertical_direction}=center    ${vertical_offset_ratio}=0.15
    ${metrics}    Get Locator Center Metrics    ${locator}
    ${element}    Get WebElement    ${locator}
    ${element_size}    Get Element Size    ${element}
    ${element_height}    Get From Dictionary    ${element_size}    height
    VAR    ${center_x}    ${metrics}[center_x]
    VAR    ${center_y}    ${metrics}[center_y]
    ${offset_y}    Evaluate    int(${element_height} * ${vertical_offset_ratio})
    IF    '${vertical_direction}' == 'above'
        ${tap_y}    Evaluate    int(${center_y} - ${offset_y})
    ELSE IF    '${vertical_direction}' == 'below'
        ${tap_y}    Evaluate    int(${center_y} + ${offset_y})
    ELSE
        VAR    ${tap_y}    ${center_y}
    END
    IF    '${MOBILE_PLATFORM}'=='ios'
        Execute Script    mobile: tap    x=${center_x}    y=${tap_y}
    ELSE
        Execute Script    mobile: clickGesture    x=${center_x}    y=${tap_y}
    END

Is Target Visible In Container
    [Documentation]
    ...    Checks if target element is visible and inside the container vertical bounds.
    ...    | =Arguments=          | =Description=                                            |
    ...    | ${target_locator}    | Locator of the target element to check.                  |
    ...    | ${box_top}           | Top Y coordinate of the container.                       |
    ...    | ${box_bottom}        | Bottom Y coordinate of the container.                    |
    ...
    ...    *Returns*: True if visible and within bounds; otherwise False.
    [Arguments]    ${target_locator}    ${box_top}    ${box_bottom}
    ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${target_locator}    timeout=${SHORT_TIMEOUT}
    IF    not ${is_visible}    RETURN    False
    ${ele}    Get WebElement    ${target_locator}
    ${ele_loc}    Get Element Location    ${ele}
    Log    Element location: ${ele_loc}
    ${element_y}    Get From Dictionary    ${ele_loc}    y
    ${in_container}    Evaluate    $box_top <= $element_y <= $box_bottom
    Log    Element in container bounds: ${in_container}
    RETURN    ${in_container}

Get Today Date With Timezone
    [Documentation]    Used for formatting date from planning week format ro required format.
    ...
    ...    Args:
    ...    ${format}: date format from ENUM and if you want to pass your date format then pass it as it is and keep ${ignore_format}=True
    ...    ${unit_id}: unit id to get timezone from DB
    [Arguments]    ${format}    ${unit_id}
    ${time_zone}    Get Store Timezone From DB    ${unit_id}
    ${today}    Evaluate
    ...    datetime.datetime.now(pytz.timezone('${time_zone}')).strftime('%Y-%m-%d %H:%M:%S')
    ...    modules=datetime,pytz
    ${formatted_date}    Convert Date    ${today}    ${format}
    RETURN    ${formatted_date}

Strip Leading Zeros From Date
    [Documentation]    Uses a regex that strips leading zero from any 1–2 digit number not preceded/followed by another digit. This works for any separator (-, /, ., space, etc.)
    ...    Designed only for date strings and for regular strings.
    ...    Args:
    ...    ${date}: date in any format which contains leading zeros in day or month part and needs to be stripped for locator to work.
    [Arguments]    ${date}
    ${stripped_date}    Evaluate    re.sub(r'(?<!\\d)0(\\d)(?!\\d)', r'\\1', $date)    modules=re
    RETURN    ${stripped_date}
