"""Robot Framework listener: POST Microsoft Teams (or compatible) webhook on test FAIL.

Webhook URL (**first match wins**)

1. **Listener arguments** — URL passed next to the listener class (good for one-off runs).

   Robot splits ``name:args`` on the **first** ``:`` **or** ``;``. URLs contain many ``:``
   (``https://``), so use a **semicolon** between the listener class and the URL — then the
   whole URL is one argument (query strings with ``&`` are fine inside **quotes**).

   Bash::

       robot '--listener' 'listener.notify_failures_to_teams.TeamsWebhookListener;https://hook.example/webhook?asd=as&a=c&d=1'

   cmd.exe (quote the argument so ``&`` is not a command separator)::

       robot "--listener" "listener.notify_failures_to_teams.TeamsWebhookListener;https://hook.example/webhook?asd=as&a=c&d=1"

   **Alternative:** use ``:`` after the listener name and escape **each** colon inside the URL
   as ``\\:`` (Robot merges segments back when instantiating). Semicolon is simpler.

2. **Environment variable** ``TEST_FAILURE_NOTIFICATION_WEBHOOK`` — full webhook URL (e.g. set by
   Jenkins ``withCredentials`` / shell export). Quote in cmd.exe when the URL contains ``&``.

This module is **not** registered in ``executor.py``; pass ``--listener`` explicitly when needed.
"""

from __future__ import annotations

import json
import logging
import os
import urllib.request
from datetime import datetime
from typing import Any

logger = logging.getLogger(__name__)

_teams_webhook_failure_logged = False

_ENV_WEBHOOK = "TEST_FAILURE_NOTIFICATION_WEBHOOK"
_POST_TIMEOUT_SEC = 15.0

_TIMESTAMP_FORMAT = "%Y-%m-%d %H:%M:%S %Z"


def _resolved_test_display_name(data: Any) -> str:
    raw = (
        getattr(data, "full_name", None)
        or getattr(data, "longname", None)
        or getattr(data, "name", None)
        or "?"
    )
    try:
        from robot.libraries.BuiltIn import BuiltIn

        return BuiltIn().replace_variables(raw)
    except Exception:
        return raw


def listener_args_to_webhook_url(args: tuple[str, ...]) -> str:
    """Rebuild URL from Robot listener ``__init__`` args.

    Prefer ``--listener module.Class;<URL>`` so Robot passes the URL as **one** arg.

    If ``:`` was used as the separator after the class name, Robot splits the URL on ``:`` and
    passes multiple strings; joining with ``:`` restores ``https://host:port/...``.
    """
    if not args:
        return ""
    if len(args) == 1:
        return args[0].strip()
    return ":".join(args).strip()


def webhook_url_from_environment() -> str:
    """Return webhook URL from ``TEST_FAILURE_NOTIFICATION_WEBHOOK``, or empty string."""
    return (os.environ.get(_ENV_WEBHOOK) or "").strip()


def _resolve_jenkins_build_fact() -> str:
    """Return a markdown-formatted Jenkins build descriptor, or ``"local"`` outside Jenkins.

    Examples:
        - ``"[my-job #42](https://jenkins/job/my-job/42/)"`` when ``BUILD_URL`` is set.
        - ``"my-job #42"`` when only ``BUILD_NUMBER``/``JOB_NAME`` are set.
        - ``"local"`` when no Jenkins env vars are present.
    """
    build_url = (os.environ.get("BUILD_URL") or "").strip()
    build_number = (os.environ.get("BUILD_NUMBER") or "").strip()
    job_name = (os.environ.get("JOB_NAME") or "").strip()

    if not (build_url or build_number or job_name):
        return "local"

    label_parts: list[str] = []
    if job_name:
        label_parts.append(job_name)
    if build_number:
        label_parts.append(f"#{build_number}")
    label = " ".join(label_parts) or "build"

    return f"[{label}]({build_url})" if build_url else label


def _now_timestamp() -> str:
    return datetime.now().astimezone().strftime(_TIMESTAMP_FORMAT).strip()


def _teams_message_card_payload(
    *,
    display_name: str,
    message: str,
    test_env: str,
    build_fact: str,
    timestamp: str,
) -> dict[str, Any]:
    """Office 365 Connector / Teams Incoming Webhook MessageCard-style body.

    ``activitySubtitle`` carries the test name once, so no duplicate ``Test`` fact is added.
    """
    facts: list[dict[str, str]] = [
        {"name": "Environment", "value": test_env or "N/A"},
        {"name": "Build", "value": build_fact},
        {"name": "Time", "value": timestamp},
    ]
    if message:
        facts.append({"name": "Failure message", "value": message})

    return {
        "@type": "MessageCard",
        "@context": "http://schema.org/extensions",
        "themeColor": "FF0000",
        "summary": f"FAILED: {display_name}",
        "sections": [
            {
                "activityTitle": "Robot Framework — test failed",
                "activitySubtitle": display_name,
                "facts": facts,
                "markdown": True,
            }
        ],
    }


def _post_json(url: str, payload: dict[str, Any]) -> None:
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        headers={"Content-Type": "application/json; charset=utf-8"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=_POST_TIMEOUT_SEC) as resp:
        resp.read()


def _post_teams_webhook_safe(url: str, payload: dict[str, Any]) -> None:
    """POST to the webhook without propagating urllib/network errors.

    Malformed URLs (``ValueError``), I/O errors (``OSError``), and other failures
    during POST are swallowed so the listener never aborts the Robot run.
    The first failure in the process is logged once at WARNING with the exception
    message and traceback.
    """
    global _teams_webhook_failure_logged
    try:
        _post_json(url, payload)
    except Exception as exc:
        if not _teams_webhook_failure_logged:
            logger.exception(
                "Teams webhook notification failed (%s: %s); further webhook errors "
                "in this process will not be logged.",
                type(exc).__name__,
                exc,
            )
            _teams_webhook_failure_logged = True


class TeamsWebhookListener:
    """Notify a webhook when a test finishes with status ``FAIL``.

    Per-run context (webhook URL, environment label, Jenkins build descriptor) is resolved
    **once per listener instance** — it cannot change within a single Robot/pabot process —
    so each ``end_test`` only computes the test-specific bits (name, message, timestamp).
    """

    ROBOT_LISTENER_API_VERSION = 3

    def __init__(self, *args: str) -> None:
        # Populated when ``--listener ...;<url>`` or ``...:<escaped-url>`` is used.
        self._listener_url_override = listener_args_to_webhook_url(args)
        self._webhook_url: str | None = None
        self._test_env: str = (os.environ.get("TEST_ENVIRONMENT") or "").strip()
        self._build_fact: str = _resolve_jenkins_build_fact()

    def start_suite(self, _data: Any, _result: Any) -> None:
        # Resolve webhook URL eagerly on the first (top-level) suite.
        if self._webhook_url is None:
            self._webhook_url = (
                self._listener_url_override or webhook_url_from_environment() or ""
            )

    def end_test(self, data: Any, result: Any) -> None:
        if getattr(result, "status", None) != "FAIL":
            return
        if not self._webhook_url:
            return

        payload = _teams_message_card_payload(
            display_name=_resolved_test_display_name(data),
            message=(getattr(result, "message", None) or "").strip(),
            test_env=self._test_env,
            build_fact=self._build_fact,
            timestamp=_now_timestamp(),
        )

        _post_teams_webhook_safe(self._webhook_url, payload)
