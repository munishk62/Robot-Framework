# Ask For Developers
This document captures some asks / recommendations that developers need to encorporate in the application, so that tests can be robust, maintainable, repeatble.

## Use of Unique data-testid for locators
- All key elements on UI should have a **data-testid** attribute with a unique value
- This allows testers to uniquely identify elements in the User Interface (UI) for testing purposes, making automated tests more reliable and maintainable.
```html
<button data-testid="sm-dayoff-submit-button">Submit</button>
```
### Best practices
- To maximize the effectiveness of data-testid, it's crucial to follow these best practices:
- Unique Identifiers: Ensure each data-testid value is unique to avoid ambiguity when selecting elements in tests.
- Descriptive Naming: Use clear and meaningful names that describe the element's function or role, such as login-button.
- Selective Use: Apply data-testid strategically to crucial elements that are prone to change or are difficult to select otherwise; avoid overusing it and cluttering the HTML.
- Consistency: Maintain a consistent naming convention for data-testid attributes across your project.
- Collaboration: Foster collaboration between developers and QA engineers to define and implement data-testid attributes effectively