"""Appium driver bootstrap that pushes credentials through Selenium's ``ClientConfig``
instead of embedding them in the remote URL.

= Why this exists =

Selenium 4.x emits ``UserWarning: Embedding username and password in URL could be
insecure, use ClientConfig instead`` whenever the URL passed to ``webdriver.Remote``
contains ``user:password@``. ``AppiumLibrary.Open Application`` accepts only the
URL form, so cloud-grid runs against LambdaTest/zTest trip the warning on every
session start.

The keyword exported here is a drop-in replacement for ``Open Application`` that:

- accepts the same arguments (``remote_url`` first, then ``alias`` and capabilities),
- if the URL contains embedded credentials, strips them out and feeds them into
  ``AppiumClientConfig.username`` / ``AppiumClientConfig.password``,
- otherwise picks up explicit ``username`` / ``password`` kwargs,
- builds ``appium.webdriver.Remote(command_executor=<clean_url>, options=..., client_config=...)``,
- registers the resulting driver into the running ``AppiumLibrary`` instance's
  ``ApplicationCache`` so that every other AppiumLibrary keyword (``Click Element``,
  ``Close Application``, screenshots, etc.) keeps working unchanged.

Selenium still produces the same ``Authorization: Basic <b64>`` HTTP header,
just via ``ClientConfig.get_auth_header()`` rather than by parsing the URL — so the
behavior on the wire is identical, only the warning disappears.
"""

from typing import Any, Optional, Tuple
from urllib.parse import urlsplit, urlunsplit

from appium import webdriver
from appium.options.common import AppiumOptions
from appium.webdriver.client_config import AppiumClientConfig
from robot.libraries.BuiltIn import BuiltIn


def _split_url_credentials(remote_url: str) -> Tuple[str, Optional[str], Optional[str]]:
    """Return ``(clean_url, username, password)`` for ``remote_url``.

    If ``remote_url`` does not embed credentials, ``username`` and ``password``
    are returned as ``None`` and the URL is returned unchanged. When credentials
    are present (``https://user:token@host/path``), they are removed from the
    URL string so Selenium does not re-parse them and re-issue the warning.
    """
    parsed = urlsplit(remote_url)
    if not parsed.username:
        return remote_url, None, None

    host = parsed.hostname or ""
    if parsed.port is not None:
        host = f"{host}:{parsed.port}"
    clean = urlunsplit(
        (parsed.scheme, host, parsed.path, parsed.query, parsed.fragment)
    )
    return clean, parsed.username, parsed.password


def open_appium_application(
    remote_url: str, alias: Optional[str] = None, **capabilities: Any
) -> int:
    """Open a new Appium session and register it with ``AppiumLibrary``.

    Authentication is configured via ``AppiumClientConfig`` (Selenium 4 best
    practice) instead of embedding ``user:password@`` in the remote URL, which
    suppresses the ``UserWarning: Embedding username and password in URL`` that
    Selenium otherwise emits at session start.

    | =Arguments= | =Description= |
    | remote_url | Appium server URL. May embed credentials (``https://user:token@host/wd/hub``); they will be lifted out automatically. |
    | alias | Optional alias for the registered application. Same semantics as ``AppiumLibrary.Open Application``. |
    | capabilities | Flat Appium capability map. Reserved keys ``username``, ``password``, ``direct_connection``, ``keep_alive`` and ``ignore_certificates`` are consumed by the client config; everything else is forwarded to Appium. |

    *Returns*: the integer index returned by ``ApplicationCache.register``; can be
    used with ``AppiumLibrary.Switch Application``.

    Example usage:
    | VAR    &{caps}    platformName=Android    deviceName=Pixel.*    app=lt://APP123
    | Open Appium Application    https://mobile-hub.lambdatest.com/wd/hub    username=${CLOUD_USERNAME}    password=${CLOUD_TOKEN}    &{caps}
    """
    remote_url, url_user, url_pass = _split_url_credentials(remote_url)

    # Explicit kwargs win over URL-embedded credentials so callers can keep
    # using whichever form is more convenient at the call site.
    username = capabilities.pop("username", None) or url_user
    password = capabilities.pop("password", None) or url_pass

    # Pull connection-level config out before handing the rest to AppiumOptions;
    # defaults mirror AppiumLibrary.Open Application so behavior is unchanged.
    direct_connection = capabilities.pop("direct_connection", True)
    keep_alive = capabilities.pop("keep_alive", False)
    ignore_certificates = capabilities.pop("ignore_certificates", True)

    options = AppiumOptions().load_capabilities(capabilities)
    client_config = AppiumClientConfig(
        remote_server_addr=remote_url,
        username=username,
        password=password,
        direct_connection=direct_connection,
        keep_alive=keep_alive,
        ignore_certificates=ignore_certificates,
    )

    driver = webdriver.Remote(
        command_executor=remote_url,
        options=options,
        client_config=client_config,
    )

    library = BuiltIn().get_library_instance("AppiumLibrary")
    # ApplicationCache.register is inherited from robot.utils.ConnectionCache and
    # returns the index used by AppiumLibrary.Switch Application.
    index = library._cache.register(driver, alias)
    BuiltIn().log(
        f"Opened Appium application with session id {driver.session_id}", level="DEBUG"
    )
    return index
