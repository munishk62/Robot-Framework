"""
Pre-run modifier to auto-publish Robot test results to TestRay.

Injects a per-test teardown that:
- Executes all existing teardown keywords except 'Close Browser'
- Imports the TestRay resource
- Publishes status to TestRay
- Then executes any 'Close Browser' keyword(s) last

The call to import/publish is wrapped in "Run Keyword And Ignore Error" so
suites without the resource import won't fail.

Usage: executor adds this modifier only when --testray-plan is provided.
"""

from pathlib import Path
from robot.api import SuiteVisitor
from robot.libraries.BuiltIn import BuiltIn

try:
    from utils.logger import get_logger
except Exception:  # Fallback if logger isn't available in early import contexts
    import logging

    def get_logger(name: str):
        logging.basicConfig(level=logging.INFO)
        return logging.getLogger(name)


logger = get_logger(__name__)

# Absolute path to the TestRay resource
RESOURCE_PATH = (
    Path(__file__).resolve().parent
    / "resources"
    / "api"
    / "testray_integration.resource"
).as_posix()


class TestRayPublisher(SuiteVisitor):
    """Robot Framework SuiteVisitor that injects a teardown per test.

    If a test already has a teardown, it is re-sequenced so that:
      - All existing teardown keywords except any 'Close Browser' run first
      - Then TestRay resource import and status publish occur
      - Finally any 'Close Browser' keyword(s) run at the very end

    If no teardown exists, a new one is created to import the resource and publish.
    The publisher keyword is provided the bearer token from the OS environment
    variable BEARER_TOKEN at runtime.
    """

    def visit_test(self, test):  # type: ignore[override]
        try:
            # BuiltIn keywords used
            run_keywords = "Run Keywords"
            safe_call = "Run Keyword And Ignore Error"
            import_resource = "Import Resource"
            publisher_keyword = "Publish Test Status To TestRay"
            token_arg = "%{BEARER_TOKEN}"  # resolves from OS env at runtime
            close_browser = "Close Browser"
            AND = "AND"

            def decompose_segments(
                name: str | None, args: list[str]
            ) -> list[list[str]]:
                """Return a list of segments, each like [kw_name, arg1, ...]."""
                if not name:
                    return []
                if name == run_keywords:
                    segs: list[list[str]] = []
                    current: list[str] = []
                    for tok in args or []:
                        if tok == AND:
                            if current:
                                segs.append(current)
                                current = []
                        else:
                            current.append(tok)
                    if current:
                        segs.append(current)
                    return segs
                # Single keyword teardown
                return [[name, *args]]

            def build_run_keywords_args(segments: list[list[str]]) -> list[str]:
                """Flatten segments into Run Keywords args with AND separators."""
                flat: list[str] = []
                for idx, seg in enumerate(segments):
                    if idx > 0:
                        flat.append(AND)
                    flat.extend(seg)
                return flat

            if test.teardown and getattr(test.teardown, "name", None):
                existing_name = test.teardown.name
                existing_args = list(getattr(test.teardown, "args", []) or [])

                segments = decompose_segments(existing_name, existing_args)

                # Split segments: others first, then any Close Browser segments
                other_segments: list[list[str]] = []
                close_segments: list[list[str]] = []

                for seg in segments:
                    if not seg:
                        continue
                    is_close = False
                    # Direct call: Close Browser ...
                    if seg[0] == close_browser:
                        is_close = True
                    # Wrapped safe call: Run Keyword And Ignore Error, Close Browser, ...
                    elif (
                        seg[0] == safe_call
                        and len(seg) >= 2
                        and seg[1] == close_browser
                    ):
                        is_close = True

                    if is_close:
                        close_segments.append(seg)
                    else:
                        other_segments.append(seg)

                # Build final order:
                # 1) others
                # 2) safe import resource
                # 3) safe publish with token
                # 4) any Close Browser segments
                final_segments: list[list[str]] = []
                final_segments.extend(other_segments)
                final_segments.append([safe_call, import_resource, RESOURCE_PATH])
                final_segments.append([safe_call, publisher_keyword, token_arg])
                final_segments.extend(close_segments)

                test.teardown.config(
                    name=run_keywords,
                    args=build_run_keywords_args(final_segments),
                )
                logger.debug(
                    "Re-sequenced teardown for '%s': others → import/publish → Close Browser",
                    getattr(test, "longname", "unknown"),
                )
            else:
                # No existing teardown: just import and publish
                segments = [
                    [safe_call, import_resource, RESOURCE_PATH],
                    [safe_call, publisher_keyword, token_arg],
                ]
                test.teardown.config(
                    name=run_keywords,
                    args=build_run_keywords_args(segments),
                )
                logger.debug(
                    "Added TestRay import+publisher teardown to '%s'",
                    getattr(test, "longname", "unknown"),
                )
        except Exception as exc:
            logger.warning(
                "PRE-RUN: Could not inject TestRay publisher for '%s': %s",
                getattr(test, "longname", "unknown"),
                exc,
            )


class TestRaySuiteSetupListener:
    """Listener to publish TestRay results when suite setup fails.

    When a suite setup fails, individual test teardowns are not executed,
    so the normal publisher teardown never runs. This listener hooks into
    ``end_test`` and, for tests whose failure is caused by a suite setup
    problem, calls the existing Robot keyword
    ``Publish Test Status To TestRay`` in a safe, best-effort manner.
    """

    ROBOT_LISTENER_API_VERSION = 3

    def __init__(self) -> None:
        self._builtin = BuiltIn()

    def end_test(self, data, result) -> None:  # type: ignore[override]
        try:
            message = (result.message or "").lower()
            if "suite setup failed" not in message:
                # Normal tests are handled via the original injected test teardown.
                return

            # Import the TestRay resource and publish the status.
            # Both calls are wrapped in "Run Keyword And Ignore Error"
            # so they never break test execution.
            self._builtin.run_keyword(
                "Run Keyword And Ignore Error",
                "Import Resource",
                RESOURCE_PATH,
            )
            self._builtin.run_keyword(
                "Run Keyword And Ignore Error",
                "Publish Test Status To TestRay",
            )
        except Exception as exc:
            logger.warning(
                "LISTENER: Failed to publish TestRay result for '%s': %s",
                getattr(data, "longname", "unknown"),
                exc,
            )
