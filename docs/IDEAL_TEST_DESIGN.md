# Ideal Test Case Design

1. The test case should be designed to cover a **specific scenario or functionality**.
2. The test case should be **readable** and easy to understand, with clear and meaningful names for variables, keywords, and arguments.
3. The test case should be **independent** and not rely on the execution of other test cases.
4. The test case should be **repeatable** and produce consistent results. Setup and Teardown steps should be clearly defined.
5. The test case should be **maintainable**, with clear and concise code that is easy to understand.
6. The test case should be **environment agnostic**, meaning it can run in different environments without modification. The test case should handle various flow based on configuration variables or environment settings.


## Readable Test Cases
- The test case should use meaningful names for variables, keywords, and arguments.
- The test case should have documentation comments that explain the purpose of the test case and its components.
- The test case should clearly specify the data required to run the test and what is the expected outcome.
- The test case should specify all the configurations required to run the test.

## Independent & Repeatable Test Cases
- The test case should not rely on the execution of other test cases.
- The test case should have its own setup and teardown steps to ensure it can run independently.
- The test case should produce consistent results when run multiple times. Same input should result in same output.
- Avoid any sleeps or hardcoded delays in the test case. Use waits or conditions to ensure the application is ready for the next action.

## Parallel Executions
-  Parallel execution is possible if tests are independent and repeatable.

## Environment Agnostic Test Cases
- Use logical constants, configuration variables or environment settings to handle different environments.
- For controlled environment tests we can have logical constants like DayOffReason.PAID, DayOffReason.UNPAID, SM1_STORE1, ESS1_STORE1 which can be mapped to different values in different environments.
- If a test requires a specific configuration, it should be clearly specified in the test case. No hardcoding of configuration or driven by some data file. Read [Test Data Provider Strategy for more details on how to provide test data] (TEST_DATA_PROVIDER_STRATEGY.md) for more information on how we handle this.
- The test execution should be able to adapt to the current environment's capabilities, such as enabled configurations or available data. Read - [Using the Pre-run Modifier to Skip Tests Based on Enabled Configurations](CONFIG_AWARE_TEST_EXECUTION.md) for more details on how we handle this.
- In past dynamic data is used in tests like first employee, first empty cell for add shift was used to make a test run across multiple customer environments. However this makes test flaky & less reliable. Also parallel execution of such test cases is a challenge. Each run of the test does not guarantee same employee / cell selection especially in parallel executions. This approach does not get you wide and in depth test coverage anyways. We dont recommend this. 

## Standard Test Case Design

### Recommended File Structure

When adding new test cases, follow the existing file structure:
- filenames are in lowercase and use underscores to separate words(not space *)
- directories are in lowercase and use underscores to separate words(not space*)
- keep the directory structure as flat as possible to avoid deep nesting. Grouping by modules is preferred.
- avoid repeatition of words in filenames and directories. e.g. if you are in the `ess` directory, you don't need to repeat `ess` in the filename or directory name.
- for locator files, use the format `pageName_page.py` where `pageName` is the name of the screen being tested. This helps in following the Page Object Model (POM) design pattern.

```
wfm-automation/
├── web/
│   ├── bootup/  # all bootup related files go here. like reading credentials from .env file
│   ├── test_data/    # test data files. Check docs\TEST_DATA_PROVIDER_STRATEGY.md
│   ├── resources/   # Reusable keywords are stored in .resource files in the resources folder.
│   │   ├── common
│   │   ├── hr # HR is a module related reusable keywords
│   │   |   ├── request_calendar.resource   # reusable keywords for request calendar
│   │   |   └── request_calendar_page.py # locator file for the request calendar. Following the page object model
│   │   |   └── request_calendar_api.py # Any api urls / regex for urls used in the request calendar
│   ├── tests/   # the Test Suites can be organized in multiple .robot files and subfolders
│   │   ├── authentication/
│   │   │   ├── login.robot
│   │   ├── hr/
│   │   │   ├── 01_day_off_scenarios.robot # test suites can be grouped by functionality
│   │   │   ├── 02_time_off_scenarios.robot # test suites can be grouped by functionality
│   ├── libraries/  #Custom Python Keyword libraries can go here
|── executor.py  # The main script to run the tests
```
### ***Settings***
- Ensure all the required libraries are imported directly in the test suite file (*.robot)
- Ensure all the resources are imported directly in the test suite file (*.robot). No indirect or mask resource files should be created. This makes it more readable and maintainable.
- Add any suite level tags as required. Tags should be used to group test cases based on functionality or type of test.
- Use `Documentation` to provide a brief description of the test suite and its purpose.
- Based on setup & teardown strategy available in the test suite, use `Test Setup` and `Test Teardown` to define any setup or teardown steps that are required for the test suite.

### ***Variables***
- Avoid defining static variables in the test cases. Refer [Test data strategy](TEST_DATA_PROVIDER_STRATEGY.md) for more details on providing test data.

### ***Test Cases***
#### Naming Conventions [TestID_Test_Case_Description]
- Use clear and descriptive names for test cases that reflect the functionality being tested. Focus on the behavior being tested.
- Start with a verb to indicate the action being performed, e.g., `Verify User Can Login`, `Check Day Off Request Can Be Created`.
- Prefix the name with Test Case Id, e.g., `TC001_Verify_Valid_User_Can_Login`.
- Use underscores '_' to separate words in the test case name.

#### Documentation
- Use the `Documentation` keyword to provide a brief description of the test case and its purpose DO NOT SKIP THIS.

#### Tags
- Use tags to categorize test cases based on functionality, type of test, or any other relevant criteria.
- Also include tags for any configuration dependencies, e.g. config:rta, config:holiday_hrs. We can leverage this to filter the test cases based on configuration.

#### Test Steps
- Start a test with all the data required to run the test case. This includes any setup data, configuration data, or any other data required to run the test case.
- Follow the test data provider strategy to provide test data. Do not hardcode any data in the test case.
- Use keywords to perform actions and assertions. Avoid using raw Robot Framework keywords directly in the test case.
- Use **hybrid test** strategy rather than pure UI. This means using API calls or direct database queries to perform actions or assertions where possible. E.g. below keyword  creates a day off request and verifies the api response (to create day off request). Once the response of API is received, we also verify the success notification on UI. 
- With the above approach we are avoiding any wait / sleep time that makes test case flaky and unreliable. The verify success notificatin (or any subsequent steps)only executes once the api response is returned and hence it depends on the time the api takes rather than some predefined sleep.
- The api response is also returned so that any subsequent steps can use the information to carry out next steps. Here the teardown uses this response to delete the created day off request using request no. This is a hybrid test case as it uses both API and UI to verify the functionality.

**Note**: This avoids use of sleep or hardcoded delays in the test case and makes it more reliable and consistent.
```
*** Keywords ***
ESS Create Day Off Request And Verify API Success
    [Documentation]    Creates a day off request as ESS and verifies the API response
    [Arguments]    ${start_date}    ${end_date}    ${reason_type}
    ESS Fill Form For Add Day Off Request
    ...    ${start_date}
    ...    ${end_date}
    ...    ${reason_type}
    ${promise}    Promise To    Wait For Response    ${ADD_DAY_OFF_API_REGEX_ESS}
    ESS Click Day Off Request Save Button
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    200
    Verify Success Toast Notification
    RETURN    ${response_body.body.metaInfo.addedDayoffRequestObject}

TC9999_Verify_ESS_Can_Create_Day_Off
    [Documentation]    Verify if ESS can create a day off request
    [Tags]    dayoff
    ${smuser}=    Get User    user_key=SM1_STORE1
    ${essuser}=    Get User    user_key=ESS1_STORE1
    ${day_off_data}=    Get Day Off Data    template_name=approval_scenario
    Login To WFM Using Provider    ${essuser}[user_key]
    ESS Navigate To ESS Request Calendar Page
    ${created_day_off}=    ESS Create Day Off Request And Verify API Success    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    ...    ${day_off_data}[reason]
    [Teardown]    SM Deletes Day Off Request Via API    ${smuser}[username]    ${smuser}[store_id]    ${created_day_off}    A    
```

```note
How do I get the api details?
- As QE we are already aware of browser developer tools
- Perform the test steps manually yourself until the point where the final step that needs api verification. 
- For E.g. in Create day off request by SM. You will go to the calendar page, click add day off, fill all the details
- Just before hitting the submit button or any specific scenario for which you need api. Open the developer tools (right click on browser -> inspect)
- Go to Network tab, click filter -> Fetch/XHR 
- Clear the network log (if any)
- Now click the submit button (the point at which your api gets called)
- In the network tab, look for api calls. 
- Incase of multiple api calls, look at the Response tab of each api & match it with the Success message you see on UI. e.g. "Request Added Successfully", "Shift Added Successfully" etc.
- Identify the url for that api (It will be in Headers tab, Request URL field)
- Identify the regex - strip any env specific prefix and params specific to the particular instance. 
- Please refer the possbile wildcards / patterns  here from browser library in robot. https://marketsquare.github.io/robotframework-browser/Browser.html#Wait%20For%20Response
![alt text](chrome_dev_tool_sample.png)
```

#### Teardowns
- Every test case or test suite should have a tear down where it cleans up all the data it created and leave the environment under test to its original state.
- API driven teardowns are gold standards.
- UI driven should be used as fallbacks.


## QA Environments Vs Customer Environments

| Apsect | Customer Environments | QA Environments |
|-----|-----|----|
|Purpose|Healthchecks, Availability, Basic validations| Deep functional scenarios, Business rules, edge cases|
|Data|State Agnoistic (assume nothing*) |State Aware - control data|
|Coverage| Shallow & Wide| Deep & Specific|
|Selectors| Dynamic (first empty cell, first emp)| Static (specific store, employee)|

One suite cant serve both purposes. We need to have separate suites for customer environments and QA environments. The test cases should be designed to run in the appropriate environment based on the configuration or environment settings. The tests in either suite should be configuration-aware and able to adapt to the specific context in which they are executed.
