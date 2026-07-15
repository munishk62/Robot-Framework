Test data can be classified in following types.
| No | Description | Example | Changes by  |
|------|-------------|-------------------|--------------|
| 1 | Configurations | my work enabled, app_url, rta_enabled expected_time_format | Environment. Can have default values.  |
| 2 | Logical Constants / Enums  | dayoff_reason_types, STORE1, USER1 | Environment. Can have default values.  |
| 3 | Constants specific to test cases | duration, relative dates (1_2) | Test or can be constant  |
| 4 | User Data | SM1_STORE1, ESS1_STORE1 | Environment.  User data has sensitive information like passwords and hence we prefer it in .env variables|

