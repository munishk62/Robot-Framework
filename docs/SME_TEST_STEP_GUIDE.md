# Test Details required for automation from SME
Following details are expected from SME in a test cases

## Pre-Conditions
- All details required to decide whether the test should be run should be provided.
    - Product feature details, UIC details, profile permission ids, any other source of configurations required.
    ```Note
    We need actual ids here and not just generic description like RTA has to be enabled. 
    We need to know which profile permission id, product feature or any other configuration enables RTA.
    ```
- If part of the test requires any specific configuration, it should be documented and provided.

## Setup
- Before any test is run, some test setup may be required. Those setup steps should be clearly documented.
e.g. Verify SM User Can Add Shift In Future Week. requires schedule to be generated for future week as a setup step.
- There can be multiple setup steps as requried.
- Gold Standard for setup is using API calls to create any necessary test data or configurations. Due to product limitations, this may not always be possible.

## Test Data
- Any input required to run the test case is required to be specified.
- Generally we need user, resource details that we are testing.
e.g. SM1_STORE1, ESS1_STORE1 - details for login user.
While adding day off resource, we may need data like duration - 6hrs, reason - Unpaid Time Off, Date Next Week 4th Day (relative dates)

### Guidelines for test data
- The user ids used in steps are logical users ids and not the actual users.
- SME to maintain and decide the logical user ids for test cases. For e.g. if some test needs same store manager say SM1_STORE1 then all those test cases should specify SM1_STORE1 in their test data and they will always execute against same Store Manager in any environment. 
```Note
The SM1_STORE1 user might map to a different user in different environments. 
So in QA28 it might be STORE20, QA24 it might be STORE30.
```
```TODO
If SME can document the pattern or decision process in deciding logical user id, 
we can extend it to identify actual user ids for each environment.
Till that we have to manually map logical user ids to actual user ids for each environment.
Its one time effort for each logical user id & environment.
```
- Provide relative dates in test data where applicable. e.g. next week 2nd day, previous week any day. 2 weeks from now etc
- Provide logical resource details that are being tested. e.g. while adding day off, paid and unpaid are 2 reason codes that alter the behavior and so as far as we pick any paid reason code or unpaid reason code, it should be fine.


## Steps
Actual Test steps. refer [sample](../manual_test_template.txt)

## Tear Down
- In order to make a test repeatable, any changes made to the environment during the test should be cleaned up.
- This may include deleting test data, resetting configurations, or any other necessary cleanup steps.
- Specify those steps / actions clearly.
- Gold Standard for tear down is using API calls to revert any changes made during the test. Due to product limitations, this may not always be possible.
