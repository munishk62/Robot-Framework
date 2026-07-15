#   Challenges

## First set
    - complex code structure
    - test data management issues
    - Way test cases are accounted. 10 logout = 10 test cases.
    - test performance. 8 hrs for 150 test cases.
1. The code structure was such that given a test suite / case it was difficult to gather all the inputs \ keywords \ variables used in the test
2. The test suite was not modular enough, leading to duplication of code and making it hard to maintain
3. Each test case had logic to first load test data from csv. This makes sense for some dynamic data but not for static data.
4. Credentials were read from encrypted file, which meant each test case had to decrupt and read the file, leading to performance issues.

action taken:
    - asked to follow new modular structure. Hard to convince the team to follow this structure
    - using env vars for credentials.

## Second set
    - No style guide was followed. Checks were bypassed.
    - Team extracted existing keywords / test cases
    - Lack of knowledge on best practices / design of test case.
    - We started with ESS but its actually HR side of ess requests.
    - New info about apis, test scenarios brought to light by Abhishek.

## Third set
    - Selenium test data is not accessible to the team. Swami knows
    - Need to module wise test cases currently present by variation.

## Data / Globalization
TBD