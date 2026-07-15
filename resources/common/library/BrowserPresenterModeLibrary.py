"""
Helpers for toggling `robotframework-browser` presenter mode at runtime.

Presenter mode highlights selectors before many Browser keywords. If highlight fails
(e.g. hidden flyout items), the library may fall back to ``Record Selector``, which
requires a non-headless browser. DataDriver CSV generation touches such nodes, so
we temporarily disable presenter mode around that work.
"""

from __future__ import annotations

from typing import Any

from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn


class BrowserPresenterModeLibrary:
    """Stack-based save/restore for ``Browser.presenter_mode``."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self) -> None:
        self._presenter_mode_stack: list[Any] = []

    @keyword
    def push_browser_presenter_mode_disabled(self) -> None:
        """Saves current ``Browser`` presenter mode and sets it to off.

        Pair with ``Pop Browser Presenter Mode`` (typically in a ``FINALLY`` block).

        Example:
        | Push Browser Presenter Mode Disabled
        | TRY
        |     Hover    ${locator}
        | FINALLY
        |     Pop Browser Presenter Mode
        | END
        """
        browser = BuiltIn().get_library_instance("Browser")
        self._presenter_mode_stack.append(browser.presenter_mode)
        browser.presenter_mode = False

    @keyword
    def pop_browser_presenter_mode(self) -> None:
        """Restores ``Browser`` presenter mode to the value from the matching push.

        No-op if the stack is empty (avoids failures after partial setup).
        """
        if not self._presenter_mode_stack:
            return
        browser = BuiltIn().get_library_instance("Browser")
        browser.presenter_mode = self._presenter_mode_stack.pop()
