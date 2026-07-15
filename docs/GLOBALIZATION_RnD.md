# Globalization Automation

## Globalization Expectations : Test Areas for WFM
1. Main Menu & Sub Menu for different user roles - SYSADMIN, STORE ADMIN, ESS USER etc.
2. Some Screens have third level menus
3. Transaction Data - Add Day Off, Add Shift (notification messages) 

### Common Challenge For UI:

1. For each screen, we need to know the elements on screen that are expected to be translated.
2. Locator : Ability to select the elements on the screen via automation.

### Challenges specific to WFM

1. Main Menu & Sub Menu for different user roles - SYSADMIN, STORE ADMIN, ESS USER etc.
- Generic Globalization Testing via capturing visible text and comparing with a map of globalized text is in progress.
- A lot of visible text will never be globalized like id, names, - Whitelisting this required for each screen.
- Not All Visible text is atomic. It may be a combination of text and other elements. e.g of 103, At 2:00am, 10 / 20 etc, Store1 - Store1 Name
- Any dynamic element like popup, filters etc per screen would need specific automation steps. Knowledge / Grooming of all Such is required. 

**Suggestion**: Base coverage can be automated but all dynamic elements require details knowledge of the screen and the elements on the screen. Module team can better do this per screen.

2. Some Screens have third level menus [NOT Covered in PDV as well]
- There is no generic pattern for these menus.
- All such screens need to be documented.
- Some of these are directly seen via second level menu, some are visible only after clicking a link in second level menu screen.
- Links may be cyclic in nature.

**Suggestion**:  Generic Pattern to be followed by engineering for generic automation & document the screens that have such menus. Module team can better do this per screen instead.

3. Transaction Data - Add Day Off, Add Shift (notification messages) Sanity Test!
- Dates currency format is already being considered in sanity tests! Should continue.
- Additional Info from engineering would be required - locator, globalization key used for every text, label

**Suggestion**:  API testing should be covering this rather than UI testing.



## Layered i18n Testing Approach - Overview

A Layered, Resilient Globalization Testing Strategy for Complex Web Applications
The goal of this strategy is to achieve comprehensive and highly automated globalization testing despite significant architectural complexities, including:

- An opaque mapping between UI keys and backend .properties file keys.
- Translation data being a subset of multiple source files (module-specific and common).
- Multiple sources of truth for translated text (JS map, properties files, database).
- Dynamic UI elements that appear after user interaction.
- Dynamic, non-translatable data (e.g., names, numbers) that must be ignored.

Each layer in this strategy serves a distinct purpose, building upon the others to create a robust quality gate for your globalized application.

## Layer 1: The Proactive Foundation - Pseudo-localization
This layer is your first line of defense and is performed before any real translation work begins.

Why it's needed: To find fundamental internationalization (i18n) bugs as early and cheaply as possible. Fixing a layout bug found by a developer during the development cycle is orders of magnitude cheaper and faster than finding it after translations are complete. It validates the readiness of your application to be localized.

### What it achieves:
Finds Hardcoded Strings: Any text in the UI that does not appear "pseudo-localized" is instantly identified as a hardcoded string that was not externalized.
Detects UI Layout Issues: By artificially expanding strings by 30-40%, this technique automatically reveals UI elements where text will be truncated, overflow its container, or break the page layout.
Verifies Character Encoding: By introducing accented and non-Latin characters, it ensures your application's entire stack (UI, backend, database) is fully UTF-8 compliant and has the necessary fonts.

## Layer 2: The Data Pipeline Confidence Check - "Canary" Spot-Testing
This is a small, fast, and highly targeted test to ensure the core data pipeline is working correctly.

Why it's needed: Your architecture has an opaque mapping between the keys used in the UI (i18nFn('Shift Modify')) and the keys in the properties files (label.shift.modify). This makes a full, automated comparison of the entire dataset impossible. This layer provides a pragmatic solution to gain confidence without attempting the impossible.

### What it achieves:
Builds Confidence in the Data Pipeline: By manually mapping a small, representative set of critical keys (e.g., a common button, a screen-specific title), this test verifies that the end-to-end process of Properties File -> Spring Backend -> Live JS Map is functioning as expected.

Acts as an Early Warning System: If this simple test fails, it indicates a fundamental problem in the data loading mechanism, saving you from running more extensive and time-consuming UI tests.

## Layer 3: The Comprehensive UI Verification - "Intelligent DOM Inventory"
This is the core of your UI globalization testing. It is a powerful, generic, and highly automated method for verifying all visible text on a screen.

### Why it's needed: This is the direct solution to your biggest challenges:

It avoids the unscalable and brittle approach of locating and verifying hundreds of individual elements.

It automatically handles dynamic content (popups, modals) that appears after user interaction, which a simple page-load scan would miss.

It is designed to handle multiple sources of truth (JS map, properties, DB) and filter out dynamic data (names, numbers).

### What it achieves:

Comprehensive Coverage: It captures every piece of text that becomes visible on the screen during a test, regardless of when or how it appears.

Accurate Bug Detection: By using the "Inventory, Aggregate, Filter, and Verify" process, it provides a single, powerful validation step:

Inventory: A MutationObserver collects all UI text.

Aggregate: It builds a "Master Set of Truth" containing all valid translated strings from the JS map, all relevant properties files, and the database.

Filter: It uses a configurable list of regular expressions to ignore known non-translatable dynamic data.

Verify: It reports any text that is not in the master set and does not match an ignore pattern, providing a highly accurate list of hardcoded strings or translation bugs.

## Layer 4: The Isolated Backend Check - API-Level Verification
This layer focuses on testing server-side globalization logic in isolation, without the overhead and flakiness of a full browser UI test.

Why it's needed: For dynamic content that originates from an API call (like a success toast message), testing through the UI is slow and couples the test to the frontend implementation. A change in the toast's animation could break a UI test, even if the translation is correct.

What it achieves:

Fast and Reliable Validation: By directly calling the API with the appropriate Accept-Language header, you can instantly verify that the server's JSON response contains the correctly translated message.

True Isolation: It tests the backend's globalization logic independently, ensuring that even if the UI has a bug, you can confirm the server is behaving correctly.

## Layer 5: The Visual Integrity Gate - Visual Regression Testing
This final layer catches the critical bugs that functional automation, by its nature, cannot see.

Why it's needed: A string can be functionally "correct" (i.e., the text matches the expected value) but visually disastrous. Functional tests will not detect text overflow, broken layouts, incorrect font rendering, or issues with Right-to-Left (RTL) mirroring. Manually checking this across 20 languages is not feasible.

What it achieves:

Automates Layout Validation: It automatically detects any visual regressions caused by text of varying lengths.

Ensures RTL Compliance: It is the most effective way to verify that the entire UI layout has been correctly mirrored for RTL languages like Arabic or Hebrew.

Provides a Visual Quality Gate: It ensures that the final product not only works correctly but also looks professional and polished in every supported language.

By implementing this multi-layered strategy, you create a comprehensive and resilient testing process that addresses each of your application's specific challenges, providing maximum confidence in your product's global readiness.
