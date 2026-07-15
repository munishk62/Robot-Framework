# Some Design considerations

## Indirect Imports
**Problem**: The test cases were importing libraries indirectly, which made it difficult to track dependencies and understand the code. There was one super module that imported all the libraries and then each test case imported this super module. This made it hard to locate the keywords & their files used in the test cases

**Solution**: The test cases should directly import the required libraries. This makes it easier to understand the dependencies and improves code readability. 

## Test Data - readability and setup
**Problem**: Each test first gets the data by test id.Given a test case / test suite it was not easy to understand the test data required. Each test first required to execute the test data setup keyword to ensure test data is available for it. This makes the test less readable and coupled to csv file.

**Solution**: In addition to solution of Indirect imports, we have ensured all the test data directly required in the test cases are clearly defined in the robot test file itself. This improves readability and makes it easier to understand the test data required for each test case. Variables that are global in nature and required only by internal keywords would reside only int the respective resource file. E.g. APP_URL even though used (indirectly) in each test case via "Login And Launch WFM Web App" keyword, it is defined only in login.resource.

**Advance / Recommended**: We should have entity based data providers that can be used to fetch test data from external JSON files.This is also known as Data Builder Pattern. Entity based data provider will make the tests more readable & self documenting. Predefined template for data, with ability to override within test case, further makes them reusable. This allows for easy management of test data and makes it easier to add new test cases without modifying the existing ones. The provider can be used in both Robot Framework and Python tests, ensuring consistency across the test suite.
e.g.
``` robot
*** Test Cases ***
Create Time Off Request
    Get User Data    user_key=ess_user1
    ${timeoff_data}=    Get Time Off Data    start_date=1_1   # only override start date, rest will be from template
    Login To WFM Application
    Create Time Off Request    ${timeoff_data}
    Verify Time Off Request Created    ${timeoff_data}
```
Further to this approach, we can even have data seeder that can make certain API calls to the given environment to set up the test data. The data seeder will run before running test. Constants / Enums like DayOffReasonTypes, RequestStatus etc can be set into external json files using this approach. The test would be using the data provider to fetch these constants, making it easier to manage and update them without modifying the test cases and running against any new environment.


## User Credentials 
**Problem**: The users were stored in an encrypted file in the repo. Each test case had logic to first decrypt the file and then read the user credentials. The test cases eventually reveal the user credentials in the logs, which is a security risk.

**Solution**: The users details should be stored in environment variable. Security responsibility of this environment variable is on the test runner and not on test case. The user credentials are stored in an environment variable `USER_CREDENTIALS` in the `.env` file. Its a json with key as user id which the test case uses. The value is a dictionary with keys `username` and `password`. We can add more fields as required. The executor.py used to execute the tests will ensure this environment variable is available for the test cases.

## Planning Week Start
**Problem**: The planning week is used to define dates in the test cases relative to PLANNING_WEEK_START date. There were 2 problems here 
    - The PLANNING_WEEK_START is a hardcoded in data file and requires edit for every test run (if we change the week). To avoid this QA was giving relative dates that are 10-14 weeks from start date that can cause problems in long run and requires ensuring data available for wider range of dates.
    - The relative dates were defined in format PW{WeekNo}-D{dayNo}. Each test case relying on this required to use regex matcher to extrat WeekNo and DayNo from the string. 

**Solution**:
1. The PLANNING_WEEK_START should be dynamically calculated based on the current date and the FISCAL_WEEK_START date. This will ensure that the planning week is always up to date and eliminates the need for manual edits. Also all dates in test cases will be relative to the current week start date. The FISCAL_WEEK_START takes care of environment specific week start day. The executor.puy has provision to pass the FISCAL_WEEK_START as an argument.
2. The relative dates should be defined in a simpler format, such as `{weekoffset}_{dayoffset}` (e.g., 1_4 means next week and 5th day of that week (0=week start, 6=week end date), 0_0 means current week start date, 1_4 means next week Friday - with Sun has start). 


## Sleep Statements
**Problem**: The test cases were using sleep statements to wait for certain conditions to be met. This can lead to flaky tests and unnecessary delays.

**Solution**: The test cases should use `Wait **` related keywords with appropriate timeouts

## Pure UI vs Hybrid Tests
**Problem**: The test cases are pure UI driven, which made them slow and less reliable. They were also not using any API calls to verify the data.
**Solution**: The test cases should be hybrid, using both UI and API calls to verify the data. This will improve the speed and reliability of the tests. The API calls can be used to verify the data before and after performing actions on the UI. This is conditional based on where all the apis are available and is function of the screen under test.

### Independent & Repeatable Tests
**Problem**: The test cases were not independent and required specific data to be set up before running. This made it difficult to run tests in parallel and led to flaky tests.
**Solution**: The test cases should be independent and repeatable. This can be achieved by
    1. Using Test Setup & Teardown keywords to ensure that the test data is set up and cleaned up before and after each test case. Note: some test do use Test Setup & Teardown keywords, but were mostly used for Opening and Closing the browser.
    2. Using api calls to set up the test data before running the test case. This will ensure that the test data is always available and consistent across test runs.

## Miscellaneous
1. Avoid sleep statements at all costs. Use Wait Until Keyword Succeeds or Wait Until Page Contains Element for better synchronization. Hybrid tests are way to go.
2. Globalization test cases can be handled for custom locale such that all globalized text appends (g) to the end of the en-US text. This will help in identifying the globalized text.

### Globalization Strategy

Layered Testing is required

Layer 1: Shift Left
- Validate before app execution - all entries in .properties exist for all locales. Check for missing keys
- Lint the code for hardcoded strings and non-localized resources
- Developers to use pseudo localization during development to identify potential issues early on
    - Text Expansion. generally 30% expansion is expected, but it can vary based on the language. For example, German and Russian
    - Character Substitution. Replace characters with accented versions to identify encoding issues and ensure proper rendering. (e.g., 'a' becomes 'ā', 'e' becomes 'ē').
    - Adding Delimiters (Brackets/Markers) (e.g., [...string...]). This helps identify the boundaries of text and ensures that UI elements can accommodate longer translations without truncation or layout issues.
    - Right-to-Left (RTL) Simulation. For languages that are read from right to left (e.g., Arabic, Hebrew), simulate RTL layout to identify potential issues with text alignment, mirroring of UI elements, and overall layout adjustments.


Layer 2: Functional Automation using data-testid!
- Use data-testid attributes to identify elements in the UI for testing
- Do not assert exact transalations, but rather check for the presence of the element and that it is displayed correctly. ?? transalation key found and value rendered correctly
- Dates currency format is already being considered in sanity tests! SHould continue.


Layer 3: Visual Validation.
- Use visual validation tools to compare screenshots of the application in different locales. This can help identify layout issues, truncation, and other visual defects that may not be caught by functional tests.