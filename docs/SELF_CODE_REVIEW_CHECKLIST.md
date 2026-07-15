# Self Code Review Checklist

1. Robocop checks pass.
2. Dry-run execution completes without errors.
3. Use clear, descriptive names for test cases, keywords, arguments, and variables.
4. Standard timeout variables should be used. See documentation: [Overriding Timeout Variables](https://github.com/zebratechnologies/sws_wfm_test_automation/blob/main/docs/CONTRIBUTING.md#overrid…).
5. All configuration, such as feature flags and data formats, must be defined in `config.json`.
6. Test data is clearly defined using test templates as applicable. Refer to:
    - `docs/SIMPLIFIED_DATA_PROVIDER_GUIDE.md`
    - `docs/TEST_DATA_PLACEMENT_GUIDE.md`
7. Templates should be used only in test cases, not in keywords.
8. Constants and configs can be used in both keywords and test cases.
9. Do not use sleep statements. Use `Wait Until ...` keywords or appropriate timeout mechanisms.
10. For Common Keywords like ones below ensure custom error messages are provided to make it clear what failed and why. Do not rely on default error messages which may not provide sufficient context.:
    - Click Element On Webpage
    - Double Click Element On Webpage
    - Wait Until Element Is Visible On Webpage
    - Wait Until Element Is Present On Webpage etc., 
11. All keywords should have brief documentation. Refer .github\instructions\keyword-documentation.instructions.md for documentation guidelines and samples.
12. Avoid using user-facing labels or text for validation/verification in non-globalized test cases:
    - Check if the notification bar indicates success, without verifying the message text. Use the "Verify Success Toast Notification" keyword defined in `common.resource`. Refer to its usage in test cases and keywords.
    - Prefer checking if an element contains non-empty text rather than comparing with actual text.
13. Test case name in .robot file should follow format `<TEST_CASE_ID>: <TEST_CASE_DESCRIPTION>`. For example, `TC001: Verify Login Functionality`. For test cases with no id use NO_ID as placeholder. For example, `NO_ID: Verify Login Functionality`.
