"""
Implementation module for `WebInternationalizationLibrary`.

Robot Libdoc reads the *library class* docstring as `introduction`; keyword docs come from
each ``@keyword`` method docstring.
"""

from __future__ import annotations

import hashlib
import json
import os
import sys
from pathlib import Path
from typing import Any, ClassVar, Dict, List, Optional, Sequence, Set, Tuple

from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn

_REPO_ROOT = Path(__file__).resolve().parents[3]
if str(_REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(_REPO_ROOT))

from dev_utils.globalization.i18n.extra_translation_sources import (
    dedupe_preserve_order,
    extend_load_result_with_strings,
    fetch_db2_translation_strings_for_locale,
    load_single_menu_json_file,
)
from dev_utils.globalization.i18n.loader import LoadResult, TranslationLoader
from dev_utils.globalization.i18n.shared_i18n_contract_loader import (
    read_db2_locale_sources_file_from_contract,
    read_menu_json_paths_from_contract,
    resolve_shared_i18n_contract_path,
)
from dev_utils.globalization.i18n.visible_text import (
    VisibleTextCoverageReport,
    analyze_visible_texts_against_flat_load,
    cast_flat_values,
    count_distinct_values_in_flat_load,
)

_NS = "__rfxDomTextInventory"

# Injected as JSON: select / ARIA / placeholder / legacy Angular-Bootstrap-style menus.
_START_INVENTORY_JS_TEMPLATE = r"""
() => {
  const NS = "__NS__";
  const OPTS = __OPTS__;

  function isIgnoredElement(el) {
    if (!el || el.nodeType !== 1) return true;
    const tag = el.tagName;
    if (tag === "SCRIPT" || tag === "STYLE" || tag === "NOSCRIPT") return true;
    if (el.closest("script, style, noscript")) return true;
    return false;
  }

  function isVisible(el) {
    if (!el || el.nodeType !== 1) return false;
    if (isIgnoredElement(el)) return false;
    if (el.hasAttribute("hidden")) return false;
    const h = el.getAttribute("aria-hidden");
    if (h === "true") return false;
    const st = getComputedStyle(el);
    if (st.display === "none" || st.visibility === "hidden" || st.opacity === "0") return false;
    const r = el.getBoundingClientRect();
    if (r.width > 0 || r.height > 0) return true;
    if (st.display === "contents") return true;
    return false;
  }

  function normText(s) {
    return String(s || "").replace(/\s+/g, " ").trim();
  }

  /**
   * Remember which DOM node(s) contributed a string (truncated outerHTML) for dev/debug logs on mismatch.
   */
  function recordString(bucket, text, el) {
    const t = normText(text);
    if (!t) return;
    bucket.add(t);
    const refs = window[NS].elementRefs;
    if (!el || el.nodeType !== 1) return;
    if (isIgnoredElement(el)) return;
    try {
      let snippet = el.outerHTML || "";
      if (snippet.length > 480) snippet = snippet.slice(0, 480) + "…";
      if (!refs[t]) refs[t] = [];
      const arr = refs[t];
      if (arr.length < 10 && !arr.includes(snippet)) arr.push(snippet);
    } catch (e) {}
  }

  function addText(bucket, s, el) {
    recordString(bucket, s, el);
  }

  function collectFromSubtree(root) {
    const bucket = window[NS].texts;
    function visit(node) {
      if (!node) return;
      if (node.nodeType === 3) {
        const raw = node.nodeValue;
        if (!raw || !String(raw).trim()) return;
        const parent = node.parentElement;
        if (!parent || !isVisible(parent)) return;
        const t = String(raw).replace(/\s+/g, " ").trim();
        if (t) recordString(bucket, t, parent);
        return;
      }
      if (node.nodeType !== 1) return;
      if (!isVisible(node)) return;
      const el = node;
      for (let i = 0; i < el.childNodes.length; i++) visit(el.childNodes[i]);
    }
    visit(root);
  }

  /** Native <select>: option textContent + optgroup label only (user-facing). Omit option ``value`` (often ids/keys). */
  function collectSelectOptions(root, bucket) {
    if (!OPTS.select || !root || root.nodeType !== 1) return;
    const list =
      root.tagName === "SELECT" ? [root] : Array.from(root.querySelectorAll("select"));
    for (const sel of list) {
      if (isIgnoredElement(sel)) continue;
      try {
        sel.querySelectorAll("option").forEach((opt) => {
          addText(bucket, opt.textContent, opt);
        });
        sel.querySelectorAll("optgroup").forEach((og) => {
          const lab = og.getAttribute("label");
          if (lab) addText(bucket, lab, og);
        });
      } catch (e) {}
    }
  }

  /**
   * Custom / Angular / ARIA widgets: listbox options, menu items, tabs — uses textContent so
   * off-screen or display:none popup panels still contribute strings that will show when opened.
   */
  function collectAriaPopupLike(root, bucket) {
    if (!OPTS.aria || !root || root.nodeType !== 1) return;
    const roleSelectors = [
      "[role=\"option\"]",
      "[role=\"menuitem\"]",
      "[role=\"menuitemcheckbox\"]",
      "[role=\"menuitemradio\"]",
      "[role=\"tab\"]",
    ];
    for (const q of roleSelectors) {
      try {
        root.querySelectorAll(q).forEach((el) => {
          if (isIgnoredElement(el)) return;
          let t = normText(el.textContent);
          if (!t) t = normText(el.getAttribute("aria-label") || "");
          if (!t) t = normText(el.getAttribute("title") || "");
          if (t) recordString(bucket, t, el);
        });
      } catch (e) {}
    }
    try {
      root.querySelectorAll("[role=\"combobox\"]").forEach((el) => {
        if (isIgnoredElement(el)) return;
        const al = el.getAttribute("aria-label");
        if (al) addText(bucket, al, el);
      });
      root.querySelectorAll("[role=\"listbox\"]").forEach((el) => {
        if (isIgnoredElement(el)) return;
        const al = el.getAttribute("aria-label");
        if (al) addText(bucket, al, el);
      });
    } catch (e) {}
  }

  /** placeholder and title often hold i18n even when the control is not focused / tooltip not shown. */
  function collectPlaceholderTitle(root, bucket) {
    if (!OPTS.placeholder || !root || root.nodeType !== 1) return;
    try {
      root.querySelectorAll("input[placeholder], textarea[placeholder]").forEach((el) => {
        if (isIgnoredElement(el)) return;
        const p = el.getAttribute("placeholder");
        if (p) addText(bucket, p, el);
      });
      root.querySelectorAll("[title]").forEach((el) => {
        if (isIgnoredElement(el)) return;
        const t = el.getAttribute("title");
        if (t) addText(bucket, t, el);
      });
    } catch (e) {}
  }

  /**
   * Heuristic AngularJS / Bootstrap-style menus (no reliable role). Enable only when needed
   * (may add extra noise). ui-select / uib-dropdown-menu patterns included.
   */
  function collectLegacyAngularDropdowns(root, bucket) {
    if (!OPTS.legacyAngularDropdown || !root || root.nodeType !== 1) return;
    try {
      root
        .querySelectorAll(
          ".dropdown-menu > li, .dropdown-menu li > a, [uib-dropdown-menu] li, [uib-typeahead-popup] li, .ui-select-choices-row"
        )
        .forEach((el) => {
          if (isIgnoredElement(el)) return;
          addText(bucket, el.textContent, el);
        });
    } catch (e) {}
  }

  function runExtraCollectors(root, bucket) {
    collectSelectOptions(root, bucket);
    collectAriaPopupLike(root, bucket);
    collectPlaceholderTitle(root, bucket);
    collectLegacyAngularDropdowns(root, bucket);
  }

    function cleanupInventoryState(inv) {
        if (!inv) return;
        if (inv.observers) {
            try {
                inv.observers.forEach((obs) => obs.disconnect());
            } catch (e) {}
            inv.observers = [];
        }
        if (inv.frameListeners) {
            try {
                inv.frameListeners.forEach((entry) => {
                    if (!entry || !entry.el || !entry.fn) return;
                    try {
                        entry.el.removeEventListener("load", entry.fn);
                    } catch (e) {}
                });
            } catch (e) {}
            inv.frameListeners = [];
        }
    }

    function getAccessibleFrameDocument(frameEl) {
        try {
            if (!frameEl || frameEl.nodeType !== 1) return null;
            if (frameEl.tagName !== "IFRAME" && frameEl.tagName !== "FRAME") return null;
            return frameEl.contentDocument || (frameEl.contentWindow && frameEl.contentWindow.document) || null;
        } catch (e) {
            return null;
        }
    }

    function scanDocument(doc) {
        if (!doc || !doc.body) return;
        collectFromSubtree(doc.body);
        runExtraCollectors(doc.body, window[NS].texts);
    }

    function walkFramesRecursively(doc, seenDocs) {
        if (!doc || seenDocs.has(doc)) return;
        seenDocs.add(doc);
        scanDocument(doc);

        let frameEls = [];
        try {
            frameEls = Array.from(doc.querySelectorAll("iframe, frame"));
        } catch (e) {}

        for (const frameEl of frameEls) {
            const childDoc = getAccessibleFrameDocument(frameEl);
            if (!childDoc) continue;
            walkFramesRecursively(childDoc, seenDocs);
    }
    }

    function wireFrame(frameEl, observedDocs, seenFrames) {
        if (!frameEl || seenFrames.has(frameEl)) return;
        seenFrames.add(frameEl);

        const attach = () => {
            const childDoc = getAccessibleFrameDocument(frameEl);
            if (!childDoc) return;
            walkFramesRecursively(childDoc, window[NS].scannedDocs);
            observeDocument(childDoc, observedDocs, seenFrames);
        };

        try {
            frameEl.addEventListener("load", attach);
            if (window[NS] && window[NS].frameListeners) {
                window[NS].frameListeners.push({ el: frameEl, fn: attach });
            }
        } catch (e) {}

        attach();
    }

    function observeDocument(doc, observedDocs, seenFrames) {
        if (!doc || !doc.body || observedDocs.has(doc)) return;
        observedDocs.add(doc);

        const obs = new MutationObserver((mutations) => {
            for (const m of mutations) {
                if (m.type !== "childList") continue;
                m.addedNodes.forEach((n) => {
                    if (n.nodeType === 1) {
                        collectFromSubtree(n);
                        runExtraCollectors(n, window[NS].texts);

                        if (n.matches && n.matches("iframe, frame")) {
                            wireFrame(n, observedDocs, seenFrames);
                        }
                        if (n.querySelectorAll) {
                            n.querySelectorAll("iframe, frame").forEach((fr) =>
                                wireFrame(fr, observedDocs, seenFrames)
                            );
                        }
                    } else if (n.nodeType === 3 && n.parentElement) {
                        collectFromSubtree(n.parentElement);
                    }
        });
            }
        });

        obs.observe(doc.body, { childList: true, subtree: true });
        window[NS].observers.push(obs);

        try {
            doc.querySelectorAll("iframe, frame").forEach((fr) => wireFrame(fr, observedDocs, seenFrames));
        } catch (e) {}
    }

    if (window[NS]) {
    try {
            cleanupInventoryState(window[NS]);
    } catch (e) {}
  }
    window[NS] = {
        texts: new Set(),
        elementRefs: {},
        observers: [],
        frameListeners: [],
        scannedDocs: new WeakSet(),
        opts: OPTS,
    };

    const observedDocs = new WeakSet();
    const seenFrames = new WeakSet();

    walkFramesRecursively(document, window[NS].scannedDocs);
    observeDocument(document, observedDocs, seenFrames);
}
"""


def _build_start_inventory_js(
    *,
    collect_select_options: bool = True,
    collect_aria_menu_and_custom_dropdown_texts: bool = True,
    collect_placeholder_and_title_attributes: bool = True,
    collect_legacy_angularjs_dropdown_lists: bool = False,
) -> str:
    opts = {
        "select": collect_select_options,
        "aria": collect_aria_menu_and_custom_dropdown_texts,
        "placeholder": collect_placeholder_and_title_attributes,
        "legacyAngularDropdown": collect_legacy_angularjs_dropdown_lists,
    }
    return (
        _START_INVENTORY_JS_TEMPLATE.replace("__NS__", _NS).replace("__OPTS__", json.dumps(opts))
    )


def _browser() -> Any:
    return BuiltIn().get_library_instance("Browser")


def _eval_js(*function_lines: str) -> Any:
    # RF-Browser: new Function("return " + script)(). Leading \n before "() =>" triggers ASI
    # (return; …) so the wrapper returns undefined instead of the arrow function — inventory never runs.
    joined = "\n".join(function_lines).strip()
    return _browser().evaluate_javascript(None, joined)


_STOP_AND_LIST_JS = f"""
() => {{
  const NS = "{_NS}";
  const inv = window[NS];
    if (inv && inv.observers) {{
        try {{ inv.observers.forEach((obs) => obs.disconnect()); }} catch (e) {{}}
        inv.observers = [];
    }}
    if (inv && inv.frameListeners) {{
        try {{
            inv.frameListeners.forEach((entry) => {{
                if (!entry || !entry.el || !entry.fn) return;
                try {{ entry.el.removeEventListener("load", entry.fn); }} catch (e) {{}}
            }});
        }} catch (e) {{}}
        inv.frameListeners = [];
  }}
  if (!inv || !inv.texts) return {{ texts: [], elementRefs: {{}} }};
  return {{
    texts: Array.from(inv.texts),
    elementRefs: inv.elementRefs || {{}},
  }};
}}
"""

_COLLECT_I18N_JS = """
() => {
  function walk(o, acc) {
    if (o === null || o === undefined) return;
    if (typeof o === "string") {
      const t = o.trim();
      if (t) acc.add(t);
      return;
    }
    if (typeof o !== "object") return;
    if (Array.isArray(o)) {
      o.forEach((x) => walk(x, acc));
      return;
    }
    for (const k of Object.keys(o)) walk(o[k], acc);
  }
  const s = new Set();
  try {
    if (typeof i18n !== "undefined") walk(i18n, s);
  } catch (e) {}
  return Array.from(s);
}
"""


class WebInternationalizationLibrary:
    """
    Visible DOM text inventory using a ``MutationObserver``, compared to locale ``.properties``
    bundles, optional page ``i18n`` strings, and optional cached extras (WFM menu JSON
    ``displayLabelLangMap``, DB2 ``LANG_MAPPING`` / ``RFX_USER_TRANSLATIONS``).

    The extra cache stores tagged rows ``(source, value)``. By default *all* rows are kept
    (duplicates allowed). Use `Set Extra Translation Cache Store Distinct Only` to keep
    distinct strings only. Debug-level ``translate-metrics`` lines (when enabled) use
    ``total_translations_in_source`` / ``distinct_translations_in_source`` for the row being
    logged; ``total_translations_in_cache`` / ``distinct_translations_in_cache`` refer **only**
    to the class-level **extra** cache (menu JSON / DB2), not to ``.properties`` or page
    ``i18n``. The merged allow-list size is summarized at INFO by
    `Verify Visible Texts Against Locale Bundles`. Optional TSV debug:
    environment variable ``I18N_TRANSLATION_DEBUG_LOG`` or `Configure I18n Translation Debug Log`.

    Inventory includes native ``<select>`` option *labels* (not ``value``), ARIA menu/listbox
    strings (including hidden popups), and ``placeholder`` / ``title`` text—see
    `Start Visible Text Inventory`. On stop, the library records truncated ``outerHTML`` of the
    contributing element per string; `Verify Visible Texts Against Locale Bundles` can log those as
    ``I18N | dom_context`` when ``log_unmatched_dom_context=True``.
    Optional ``text_whitelist`` / ``text_whitelist_file`` / class-level cache (``Set Cached I18n Text Whitelist``)
    skips exact literal strings (e.g. employee names, IDs) before bundle matching; stats include whitelist skip counts,
    with per-string lines at log level DEBUG. The cache is class-level (shared across tests in the same process), like
    menu/DB extra translations.

    **Class-level data (same worker process):** (1) Parsed ``.properties`` flat loads in ``_flat_bundle_load_cache``
    keyed by ``(bundles_dir, locale, scope)`` — shared across every suite/test until cleared. (2) Menu/DB strings in
    ``_cached_extra_translation_entries``. (3) Optional default bundle root from `Set Default I18n Bundles Dir For Visible Text Verify`
    so Verify can use ``bundles_dir=${EMPTY}`` like other app-wide settings. Page ``i18n`` is still read from the browser
    per Verify when enabled (not a static disk cache).

    Primary flow: `Start Visible Text Inventory` → interact →
    `Stop Visible Text Inventory And Return Texts` → `Verify Visible Texts Against Locale Bundles`.
    For offline analysis (no DOM verification), `Write I18n Translation Sources To File` writes the
    same merged allow-list sources (``.properties``, optional page ``i18n``, optional menu/DB cache) to TSV.
    See `keywords` for the full list.

    = Requirements =
    - ``Browser`` (robotframework-browser)
    - ``dev_utils.globalization.i18n`` with repo root on ``sys.path`` (this module inserts it)

    = Browser / JavaScript note =
    RF-Browser wraps scripts with ``new Function("return " + script)()``. Pass a bare
    ``() => { ... }`` (not an IIFE) and avoid a leading newline before ``(``; otherwise
    JavaScript ASI turns ``return`` into ``return;``, the wrapper yields ``undefined``, and
    ``page.evaluate`` never runs. ``_eval_js`` strips snippets to avoid that.
    """

    ROBOT_LIBRARY_SCOPE = "TEST"
    ROBOT_LIBRARY_VERSION = "1.15.0"

    # (source_tag, value) — persists across tests (class-level). Source examples: menu_json:SHIFT.json, LANG_MAPPING.
    _cached_extra_translation_entries: ClassVar[List[Tuple[str, str]]] = []
    # Literal strings skipped during visible-text verify (class-level); merged with file/inline args when enabled.
    _cached_text_whitelist: ClassVar[List[str]] = []
    # When ``store distinct only`` is on, normalized keys already stored (see ``Set Extra Translation Cache Store Distinct Only``).
    _extra_cache_distinct_norm_keys: ClassVar[Set[str]] = set()
    _extra_cache_store_distinct_only: ClassVar[bool] = False
    _extra_cache_dedupe_case_sensitive: ClassVar[bool] = True
    # Written on Verify when path set (keyword or env ``I18N_TRANSLATION_DEBUG_LOG``).
    _translation_debug_log_path: ClassVar[Optional[str]] = None
    # ``TranslationLoader.load_flat`` results keyed by ``(resolved_bundles_dir, locale, scope)``.
    _flat_bundle_load_cache: ClassVar[Dict[Tuple[str, str, str], LoadResult]] = {}
    # Optional app-level bundle root (same intent as suite ``${BUNDLES_DIR}``): used when Verify/Dump/Warm-up get ``${EMPTY}``.
    _default_bundles_dir_for_visible_text_verify: ClassVar[str] = ""

    @classmethod
    def _norm_extra_cache_key(cls, text: str) -> str:
        t = text.strip()
        if not cls._extra_cache_dedupe_case_sensitive:
            t = t.casefold()
        return t

    @classmethod
    def _extra_cache_total_and_distinct(cls) -> Tuple[int, int]:
        ent = cls._cached_extra_translation_entries
        n = len(ent)
        u = len(dict.fromkeys(e[1] for e in ent))
        return n, u

    def _append_extra_translations(self, source_tag: str, strings: Sequence[str]) -> None:
        cls = type(self)
        for s in strings:
            if s is None:
                continue
            t = str(s).strip()
            if not t:
                continue
            if cls._extra_cache_store_distinct_only:
                k = cls._norm_extra_cache_key(t)
                if k in cls._extra_cache_distinct_norm_keys:
                    continue
                cls._extra_cache_distinct_norm_keys.add(k)
            cls._cached_extra_translation_entries.append((source_tag, t))

    @classmethod
    def _clear_extra_translation_cache_buffers(cls) -> None:
        cls._cached_extra_translation_entries.clear()
        cls._extra_cache_distinct_norm_keys.clear()

    @classmethod
    def _flat_bundle_cache_key(cls, bundles_dir: str, locale: str, scope: str) -> Tuple[str, str, str]:
        root = str(Path(bundles_dir).expanduser().resolve())
        return (root, str(locale).strip(), str(scope).strip())

    @classmethod
    def _get_cached_flat_bundle_load(
        cls,
        bundles_dir: str,
        locale: str,
        *,
        scope: str = "web",
    ) -> LoadResult:
        key = cls._flat_bundle_cache_key(bundles_dir, locale, scope)
        hit = cls._flat_bundle_load_cache.get(key)
        if hit is not None:
            return hit
        loader = TranslationLoader(bundles_dir)
        flat = loader.load_flat(locale, scope=scope)  # type: ignore[arg-type]
        cls._flat_bundle_load_cache[key] = flat
        props = [p for p in flat.files_loaded if isinstance(p, str) and p.lower().endswith(".properties")]
        bundle_root = key[0]
        BuiltIn().log(
            "I18N | bundle disk load (in-process cache miss; subsequent Verify calls reuse memory): "
            f"locale={locale!r} scope={scope!r} .properties_files={len(props)} root={bundle_root!r}",
            level="INFO",
        )
        for p in props:
            BuiltIn().log(f"I18N DEBUG | bundle property file: {p}", level="DEBUG")
        return flat

    def _resolve_bundles_dir_for_verify(
        self,
        bundles_dir: Any = None,
        *,
        contract_path: str = "",
    ) -> str:
        """
        Resolve ``.properties`` root: explicit ``bundles_dir`` → class default from suite setup
        (`Set Default I18n Bundles Dir For Visible Text Verify`) → `Get Resolved I18n Bundles Dir`
        (env override or environment-folder auto-discovery).
        """
        raw = "" if bundles_dir is None else str(bundles_dir).strip()
        if raw:
            return raw
        d = type(self)._default_bundles_dir_for_visible_text_verify.strip()
        if d:
            return d
        try:
            return self.get_resolved_i18n_bundles_dir()
        except ValueError as ex:
            BuiltIn().fail(str(ex))

    def _ordered_deduped_values_from_extra_cache(self) -> List[str]:
        return dedupe_preserve_order([e[1] for e in type(self)._cached_extra_translation_entries])

    def _log_translate_metrics(
        self,
        *,
        source: str,
        total_translations_in_source: int,
        distinct_translations_in_source: int,
        total_translations_in_cache: int,
        distinct_translations_in_cache: int,
        level: str = "INFO",
    ) -> None:
        BuiltIn().log(
            "I18N | translate-metrics | "
            f"source={source!r} | "
            f"total_translations_in_source={total_translations_in_source} | "
            f"distinct_translations_in_source={distinct_translations_in_source} | "
            f"extra_cache_rows_after={total_translations_in_cache} | "
            f"extra_cache_distinct_strings_after={distinct_translations_in_cache}",
            level=level,
        )

    def _log_verify_allow_list_summary(
        self,
        *,
        bundles_dir: str,
        locale: str,
        scope: str,
        include_page_i18n: bool,
        merge_extras: bool,
        properties_file_count: int,
        bundle_composite_keys: int,
        bundle_distinct_values: int,
        page_i18n_total: int,
        page_i18n_distinct: int,
        extra_cache_rows: int,
        extra_cache_distinct: int,
        extras_merged_deduped_keys: int,
        extras_merged_raw_rows: int,
        merged_composite_keys: int,
        merged_distinct_values: int,
    ) -> None:
        """One INFO line describing how the merged allow-list was built (Verify / Dump)."""
        extras_part = (
            f"menu_db_extra_cache rows={extra_cache_rows} distinct={extra_cache_distinct} "
            f"merged_as_keys={extras_merged_deduped_keys} from_raw_rows={extras_merged_raw_rows}"
            if merge_extras
            else "menu_db_extra_cache merge=off"
        )
        BuiltIn().log(
            "I18N | allow-list SUMMARY | "
            f"locale={locale!r} scope={scope!r} | "
            f".properties files={properties_file_count} bundle_keys={bundle_composite_keys} "
            f"bundle_distinct_values={bundle_distinct_values} | "
            f"page_i18n total_strings={page_i18n_total} distinct={page_i18n_distinct} merged={include_page_i18n} | "
            f"{extras_part} | "
            f"allow_list_all_sources composite_keys={merged_composite_keys} "
            f"distinct_translation_values={merged_distinct_values} "
            f"(.properties + optional page_i18n + optional menu/DB extras as synthetic keys; used for DOM matching) | "
            f"bundles_dir={bundles_dir!r}",
            level="INFO",
        )

    @classmethod
    def _resolve_translation_debug_log_path(cls, override: Optional[str]) -> Optional[str]:
        o = (override or "").strip() if override is not None else ""
        if o:
            return o
        p = (cls._translation_debug_log_path or "").strip()
        if p:
            return p
        env = os.environ.get("I18N_TRANSLATION_DEBUG_LOG")
        return env.strip() if env and str(env).strip() else None

    def _write_translation_debug_tsv_file(
        self,
        path: str,
        flat: LoadResult,
        i18n_vals: Sequence[str],
        *,
        strip: bool,
        case_sensitive: bool,
        include_extra_cache: bool = True,
    ) -> None:
        """One row per distinct translation (after strip/case rules); column1=pipe-joined sources, column2=text."""
        acc: Dict[str, Tuple[str, Set[str]]] = {}

        def norm_key(s: str) -> str:
            t = s.strip() if strip else s
            if not t:
                return ""
            return t if case_sensitive else t.casefold()

        def add(display: str, src: str) -> None:
            d = display.strip() if strip else display
            if not d:
                return
            nk = norm_key(d)
            if not nk:
                return
            if nk not in acc:
                acc[nk] = (d, {src})
            else:
                acc[nk][1].add(src)

        for v in cast_flat_values(flat.data if isinstance(flat.data, dict) else {}).values():
            add(str(v), "properties_bundles")
        for s in i18n_vals:
            add(str(s), "page_i18n")
        if include_extra_cache:
            for src, val in type(self)._cached_extra_translation_entries:
                add(val, src)

        out_path = Path(path)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        lines = [
            "# I18N translation debug — distinct values; col1=source tags (|), col2=display text\n",
            "sources\tdisplay_value\n",
        ]
        for _nk, (disp, srcs) in sorted(acc.items(), key=lambda kv: kv[1][0].lower()):
            lines.append(f"{'|'.join(sorted(srcs))}\t{disp}\n")
        with open(out_path, "w", encoding="utf-8") as f:
            f.writelines(lines)
        BuiltIn().log(f"I18N | wrote translation debug TSV ({len(acc)} distinct rows) to {out_path}", level="INFO")

    @staticmethod
    def _coerce_visible_text_list(visible_texts: Any) -> List[str]:
        """
        Ensure Robot passed a real list/tuple of strings.

        ``raw_visible`` / STATS use ``len`` of this list. If you see a smaller count than
        ``inventory_stop_returned_list_len`` from Stop, the wrong value was passed (e.g. a string
        or a different variable). Use ``${visible_texts}`` as one argument, not ``@{visible_texts}``.
        """
        if visible_texts is None:
            BuiltIn().log("I18N | WARN visible_texts is None; using empty list", level="WARN")
            return []
        if isinstance(visible_texts, str):
            BuiltIn().log(
                "I18N | WARN visible_texts is a single string; expected a list from "
                "Stop Visible Text Inventory. Pass ${var} not split scalars.",
                level="WARN",
            )
            return [visible_texts]
        try:
            return [str(x) for x in list(visible_texts)]
        except TypeError:
            BuiltIn().log(
                f"I18N | WARN visible_texts not iterable ({type(visible_texts)!r}); wrapping as one item.",
                level="WARN",
            )
            return [str(visible_texts)]

    @staticmethod
    def _parse_inventory_browser_payload(raw: Any) -> Tuple[List[str], Dict[str, List[str]]]:
        """
        Normalize RF-Browser return value from stop/peek inventory script.

        New scripts return ``{ "texts": [...], "elementRefs": { text: [outerHTML, ...] } }``;
        legacy list-only payloads are still accepted.
        """
        if raw is None:
            return [], {}
        if isinstance(raw, dict):
            texts_raw = raw.get("texts")
            refs_raw = raw.get("elementRefs") or raw.get("element_refs") or {}
            out_refs: Dict[str, List[str]] = {}
            if isinstance(refs_raw, dict):
                for k, v in refs_raw.items():
                    ks = str(k)
                    if isinstance(v, list):
                        out_refs[ks] = [str(x) for x in v if x is not None]
                    elif v is not None:
                        out_refs[ks] = [str(v)]
            if isinstance(texts_raw, list):
                return [str(x) for x in texts_raw], out_refs
            return [], out_refs
        if isinstance(raw, list):
            return [str(x) for x in raw], {}
        return [str(raw)], {}

    @staticmethod
    def _normalize_ignore_string_patterns(patterns: Any) -> Optional[List[str]]:
        if patterns is None:
            return None
        if isinstance(patterns, (list, tuple)):
            out = [str(x) for x in patterns if x is not None and str(x).strip()]
            return out or None
        if isinstance(patterns, str) and patterns.strip():
            return [patterns.strip()]
        BuiltIn().log(
            f"I18N | WARN ignore_string_patterns has unexpected type {type(patterns)!r}; "
            "use ${var} where var was set with Create List (not @{list} in the argument).",
            level="WARN",
        )
        return None

    @staticmethod
    def _coerce_text_whitelist_inline(inline: Any) -> List[str]:
        if inline is None:
            return []
        if isinstance(inline, str):
            s = inline.strip()
            return [s] if s else []
        try:
            return [str(x).strip() for x in list(inline) if x is not None and str(x).strip()]
        except TypeError:
            s = str(inline).strip()
            return [s] if s else []

    @staticmethod
    def _load_text_whitelist_file(path: str) -> List[str]:
        """
        One non-empty string per line; ``#`` starts a full-line comment. UTF-8.
        """
        p = (path or "").strip()
        if not p:
            return []
        fp = Path(p)
        if not fp.is_file():
            raise FileNotFoundError(f"text whitelist file not found: {p!r}")
        out: List[str] = []
        with fp.open(encoding="utf-8", newline="") as fh:
            for line in fh:
                s = line.rstrip("\r\n").strip()
                if not s or s.startswith("#"):
                    continue
                out.append(s)
        return out

    def _build_effective_text_whitelist(
        self,
        inline: Any,
        file_path: str,
        *,
        merge_cached: bool,
    ) -> Tuple[List[str], int, int, int]:
        """
        File lines, then inline argument, then class-level cache (when ``merge_cached``); de-duplicated first-seen order.

        Returns ``(merged, n_file_lines, n_inline_values, n_cached_values)``.
        """
        fp = (file_path or "").strip()
        from_file = self._load_text_whitelist_file(fp) if fp else []
        from_inline = self._coerce_text_whitelist_inline(inline)
        from_cache = list(type(self)._cached_text_whitelist) if merge_cached else []
        merged = list(dict.fromkeys([*from_file, *from_inline, *from_cache]))
        return merged, len(from_file), len(from_inline), len(from_cache)

    @keyword("Start Visible Text Inventory")
    def start_visible_text_inventory(
        self,
        *,
        collect_select_options: bool = True,
        collect_aria_menu_and_custom_dropdown_texts: bool = True,
        collect_placeholder_and_title_attributes: bool = True,
        collect_legacy_angularjs_dropdown_lists: bool = False,
    ) -> None:
        """
        Inject visible-text inventory: DOM walk plus ``MutationObserver`` on ``document.body``.

        Also collects strings that are part of dropdowns or chrome but not always painted.

        | =Arguments= | =Description= |
        | collect_select_options | When ``True``, collect ``<option>`` label text and ``<optgroup label>`` (not ``option.value``), including when the select is closed. |
        | collect_aria_menu_and_custom_dropdown_texts | When ``True``, collect ARIA roles (option, menuitem, …), combobox/listbox ``aria-label``, via ``textContent`` so hidden popups still contribute. |
        | collect_placeholder_and_title_attributes | When ``True``, collect ``placeholder`` and ``title`` attributes. |
        | collect_legacy_angularjs_dropdown_lists | When ``True``, Bootstrap / ``uib-dropdown-menu`` / ``ui-select`` heuristics (optional; may add noise). |

        Shadow DOM is not pierced; extend selectors in the library for other stacks.

        Examples:
        | Start Visible Text Inventory
        | Start Visible Text Inventory    collect_legacy_angularjs_dropdown_lists=${True}
        """
        _collector_flags = {
            "select": collect_select_options,
            "aria": collect_aria_menu_and_custom_dropdown_texts,
            "placeholder": collect_placeholder_and_title_attributes,
            "legacyAngularDropdown": collect_legacy_angularjs_dropdown_lists,
        }
        BuiltIn().log(
            f"I18N | start inventory collectors: {json.dumps(_collector_flags)}",
            level="INFO",
        )
        self._inventory_element_refs = {}
        _eval_js(
            _build_start_inventory_js(
                collect_select_options=collect_select_options,
                collect_aria_menu_and_custom_dropdown_texts=collect_aria_menu_and_custom_dropdown_texts,
                collect_placeholder_and_title_attributes=collect_placeholder_and_title_attributes,
                collect_legacy_angularjs_dropdown_lists=collect_legacy_angularjs_dropdown_lists,
            )
        )

    @keyword("Log Visible Text Inventory Debug State")
    def log_visible_text_inventory_debug_state(self) -> None:
        """
        Log inventory debug state (namespace object, set size, body child count).

        Use after `Start Visible Text Inventory` when the collected list is unexpectedly empty.

        Examples:
        | Log Visible Text Inventory Debug State
        """
        dbg_js = f"""
() => {{
  const NS = "{_NS}";
  const inv = window[NS];
  const n = inv && inv.texts ? inv.texts.size : null;
  return {{
    hasBody: !!document.body,
    bodyChildCount: document.body ? document.body.children.length : 0,
    hasInventory: !!inv,
    textSetSize: n,
        observerConnected: !!(inv && inv.observers && inv.observers.length),
    elementRefKeys: inv && inv.elementRefs ? Object.keys(inv.elementRefs).length : 0,
  }};
}}
"""
        try:
            info = _eval_js(dbg_js)
            BuiltIn().log(f"I18N DEBUG | inventory state: {json.dumps(info, default=str)}", level="INFO")
        except Exception as ex:
            BuiltIn().log(f"I18N DEBUG | could not read inventory state: {ex!r}", level="WARN")

    @keyword("Stop Visible Text Inventory And Return Texts")
    def stop_visible_text_inventory_and_return_texts(self) -> List[str]:
        """
        Stop inventory and return all collected strings (arbitrary order).

        Also stores a map of string → up to 10 truncated ``outerHTML`` snippets of elements that
        contributed each string. Pass ``log_unmatched_dom_context=${True}`` to
        `Verify Visible Texts Against Locale Bundles` to log those snippets under each
        ``I18N UNMATCHED`` line.

        | =Returns= | =Description= |
        | list[str] | Distinct strings gathered since `Start Visible Text Inventory` (arbitrary order). |

        Examples:
        | ${texts}=    Stop Visible Text Inventory And Return Texts
        """
        raw = _eval_js(_STOP_AND_LIST_JS.strip())
        texts, refs = self._parse_inventory_browser_payload(raw)
        self._inventory_element_refs = refs
        if raw is None:
            BuiltIn().log("I18N | inventory_stop_returned_list_len=0 (browser returned null)", level="INFO")
            return []
        n_snip = sum(len(v) for v in refs.values())
        BuiltIn().log(
            f"I18N | inventory_stop_returned_list_len={len(texts)} (distinct strings from page); "
            f"element_ref_groups={len(refs)} total_snippets={n_snip}",
            level="INFO",
        )
        return texts

    @keyword("Get Collected Visible Texts Without Stopping")
    def get_collected_visible_texts_without_stopping(self) -> List[str]:
        """
        Return a snapshot of collected strings without stopping the observer.

        | =Returns= | =Description= |
        | list[str] | Copy of current inventory strings (observer keeps running). |

        Examples:
        | ${peek}=    Get Collected Visible Texts Without Stopping
        """
        peek_js = f"""
() => {{
  const inv = window["{_NS}"];
  if (!inv || !inv.texts) return {{ texts: [], elementRefs: {{}} }};
  return {{ texts: Array.from(inv.texts), elementRefs: inv.elementRefs || {{}} }};
}}
"""
        raw = _eval_js(peek_js.strip())
        texts, refs = self._parse_inventory_browser_payload(raw)
        self._inventory_element_refs = refs
        return texts

    @keyword("Get Page I18n String Values")
    def get_page_i18n_string_values(self) -> List[str]:
        """
        Collect string values from the global ``i18n`` object (recursive walk).

        | =Returns= | =Description= |
        | list[str] | All non-empty string leaves; empty if ``i18n`` is missing or unusable. |

        Examples:
        | ${i18n_strings}=    Get Page I18n String Values
        """
        raw = _eval_js(_COLLECT_I18N_JS.strip())
        if not raw:
            return []
        return [str(x) for x in raw]

    @keyword("Clear Extra Translation Sources For Visible Text Verify")
    def clear_extra_translation_sources_for_visible_text_verify(self) -> None:
        """
        Clear the class-level cache of extra allowed strings (menu JSON / DB2).

        Call at suite start if a prior run left data in-process, or before switching locale/build.

        Examples:
        | Clear Extra Translation Sources For Visible Text Verify
        """
        type(self)._clear_extra_translation_cache_buffers()
        BuiltIn().log("I18N | cleared cached extra translation entries (menu JSON / DB2)", level="INFO")

    @keyword("Clear I18n Flat Bundle Load Cache")
    def clear_i18n_flat_bundle_load_cache(self) -> None:
        """
        Drop cached ``TranslationLoader.load_flat`` results (``.properties`` allow-list) for all keys.

        Call when switching ``bundles_dir`` / locale in the same process, or between suites that must
        not reuse prior bundle parses. Normal DataDriver runs for one locale do not need this.

        Examples:
        | Clear I18n Flat Bundle Load Cache
        """
        n = len(type(self)._flat_bundle_load_cache)
        type(self)._flat_bundle_load_cache.clear()
        BuiltIn().log(f"I18N | cleared flat bundle load cache ({n} entr(y/ies))", level="INFO")

    @keyword("Set Default I18n Bundles Dir For Visible Text Verify")
    def set_default_i18n_bundles_dir_for_visible_text_verify(self, bundles_dir: str) -> None:
        """
        Remember ``bundles_dir`` for this process (optional). `Verify Visible Texts Against Locale Bundles` and
        related keywords resolve the bundle root automatically via `Get Resolved I18n Bundles Dir` when this is
        unset—call this from `Configure I18n Bundles Dir From Contract` so the resolved path is cached once per
        suite. The parsed ``.properties`` flat load lives in ``_flat_bundle_load_cache`` keyed by
        ``(resolved_dir, locale, scope)``.

        | =Arguments= | =Description= |
        | bundles_dir | Resource bundle root (e.g. ``${BUNDLES_DIR}`` after ``Configure I18n Bundles Dir From Contract``). |

        Examples:
        | Set Default I18n Bundles Dir For Visible Text Verify    ${BUNDLES_DIR}
        | Verify Visible Texts Against Locale Bundles    ${I18N_LOCALE}    ${texts}
        """
        v = str(bundles_dir or "").strip()
        if not v:
            BuiltIn().fail("bundles_dir is required for Set Default I18n Bundles Dir For Visible Text Verify")
        type(self)._default_bundles_dir_for_visible_text_verify = v
        BuiltIn().log(f"I18N | default bundles_dir for verify set ({v!r})", level="INFO")

    @keyword("Clear Default I18n Bundles Dir For Visible Text Verify")
    def clear_default_i18n_bundles_dir_for_visible_text_verify(self) -> None:
        """
        Clears the process default set by `Set Default I18n Bundles Dir For Visible Text Verify`.

        Examples:
        | Clear Default I18n Bundles Dir For Visible Text Verify
        """
        type(self)._default_bundles_dir_for_visible_text_verify = ""
        BuiltIn().log("I18N | default bundles_dir for verify cleared", level="INFO")

    @keyword("Get I18n Pabot Suite File Stamp")
    def get_i18n_pabot_suite_file_stamp(self, explicit_stamp: str = "") -> str:
        """
        Return a short stable stamp for Pabot parallel keys and shared JSON filenames.

        Precedence: environment ``I18N_PABOT_CACHE_STAMP`` (shared job id so a bootstrap suite and role
        suites reuse the same cache files) → non-empty ``explicit_stamp`` → hash of ``${SUITE_SOURCE}``.

        When ``explicit_stamp`` is non-empty after strip, returns a filesystem-safe substring of it.
        Otherwise uses ``BuiltIn`` variable ``${SUITE_SOURCE}`` (same for all workers running the same
        ``*.robot`` file) and returns the first 12 hex chars of ``sha256(suite_source)``.

        | =Arguments= | =Description= |
        | explicit_stamp | Optional override (e.g. suite-specific id from CI). |

        | =Returns= | =Description= |
        | str | Stamp for ``i18n_extra_<stamp>.json`` and parallel key suffixes. |

        Examples:
        | ${stamp}=    Get I18n Pabot Suite File Stamp
        | ${stamp}=    Get I18n Pabot Suite File Stamp    my_ci_label
        """
        job = (os.environ.get("I18N_PABOT_CACHE_STAMP") or "").strip()
        if job:
            safe = "".join(c if c.isalnum() or c in ("-", "_") else "_" for c in job)[:64]
            return safe or "default"
        raw = (explicit_stamp or "").strip()
        if raw:
            safe = "".join(c if c.isalnum() or c in ("-", "_") else "_" for c in raw)[:64]
            return safe or "default"
        try:
            src = BuiltIn().get_variable_value("${SUITE_SOURCE}", default="")
        except Exception:
            src = ""
        if not (src or "").strip():
            return "default"
        h = hashlib.sha256(str(src).encode("utf-8", errors="replace")).hexdigest()[:12]
        return h

    @keyword("Get I18n Web Directory Shared Cache Stamp")
    def get_i18n_web_directory_shared_cache_stamp(
        self, suite_fallback: str = "", contract_path: str = ""
    ) -> str:
        """
        Return a stamp shared by all suites under ``tests/web/internationalization/`` for one run.

        Precedence: environment ``I18N_PABOT_CACHE_STAMP`` (same rules as ``Get I18n Pabot Suite File Stamp``) when set,
        so CI can pin one artifact namespace. Otherwise returns a short hash of a fixed namespace plus the **resolved
        locale** (filesystem-safe suffix) so back-to-back jobs for different locales do not reuse the same JSON
        basenames under ``test_data/generated/``.

        | =Arguments= | =Description= |
        | suite_fallback | Passed to ``Get Resolved I18n Locale`` (e.g. ``${I18N_LOCALE_SUITE_FALLBACK}``). |
        | contract_path | Passed to ``Get Resolved I18n Locale`` (e.g. ``${I18N_SHARED_CONTRACT_PATH}``). |

        | =Returns= | =Description= |
        | str | Use as ``cache_key_stamp`` for ``Save I18n Shared Cache Files`` / ``Import I18n Caches Into Library``. |

        Examples:
        | ${s}=    Get I18n Web Directory Shared Cache Stamp
        | ${s}=    Get I18n Web Directory Shared Cache Stamp    ${I18N_LOCALE_SUITE_FALLBACK}    ${I18N_SHARED_CONTRACT_PATH}
        """
        job = (os.environ.get("I18N_PABOT_CACHE_STAMP") or "").strip()
        if job:
            safe = "".join(c if c.isalnum() or c in ("-", "_") else "_" for c in job)[:64]
            return safe or "default"
        locale = self.get_resolved_i18n_locale(suite_fallback, contract_path)
        loc_safe = "".join(c if c.isalnum() or c in ("-", "_") else "_" for c in locale)[:32]
        ns = "i18n_web_internationalization_shared_v1|" + locale
        h = hashlib.sha256(ns.encode("utf-8", errors="replace")).hexdigest()[:12]
        return f"{h}_{loc_safe}" if loc_safe else h

    @keyword("Get Resolved I18n Locale")
    def get_resolved_i18n_locale(self, suite_fallback: str = "", contract_path: str = "") -> str:
        """
        Resolve the active locale for i18n UI suites.

        Precedence:

        1. Environment variable ``I18N_LOCALE``.
        2. Robot ``${I18N_LOCALE}`` (``--variable`` / suite or resource ``Variables`` — default ``en_US`` in
           ``i18n_pabot_shared.resource``).
        3. Non-empty ``suite_fallback`` (typically ``${I18N_LOCALE_SUITE_FALLBACK}``).
        4. Literal ``en_US``.

        The ``contract_path`` argument is **ignored** (kept for backward-compatible Robot call shapes). Optional
        ``shared_i18n_contract.yaml`` is only for menu paths / DB2 paths — not locale.

        | =Arguments= | =Description= |
        | suite_fallback | Optional locale when env and ``${I18N_LOCALE}`` are unset. |
        | contract_path | Ignored. |

        | =Returns= | =Description= |
        | str | Locale tag (e.g. ``es_MX``). |

        Examples:
        | ${loc}=    Get Resolved I18n Locale
        | ${loc}=    Get Resolved I18n Locale    ${I18N_LOCALE_SUITE_FALLBACK}
        """
        _ = contract_path
        env_loc = (os.environ.get("I18N_LOCALE") or "").strip()
        if env_loc:
            return env_loc
        try:
            v = BuiltIn().get_variable_value("${I18N_LOCALE}", default="")
        except Exception:
            v = ""
        if isinstance(v, str) and v.strip():
            return v.strip()
        sf = (suite_fallback or "").strip()
        if sf:
            return sf
        return "en_US"

    @keyword("Get Menu Json Paths From I18n Contract")
    def get_menu_json_paths_from_i18n_contract(self, contract_path: str = "") -> List[str]:
        """
        Return ``menu_json_paths`` from the shared i18n contract YAML (non-empty strings only).

        | =Arguments= | =Description= |
        | contract_path | Optional path; empty uses ``I18N_SHARED_CONTRACT_PATH`` or default ``test_data/i18n/…``. |

        | =Returns= | =Description= |
        | list[str] | Paths in file order. |
        """
        cp = (contract_path or "").strip()
        path = resolve_shared_i18n_contract_path(cp or None, repo_root=_REPO_ROOT)
        return read_menu_json_paths_from_contract(path)

    @staticmethod
    def _read_nonempty_text_file_lines(path: Path) -> List[str]:
        out: List[str] = []
        with path.open(encoding="utf-8", newline="") as fh:
            for line in fh:
                s = line.rstrip("\r\n").strip()
                if s and not s.startswith("#"):
                    out.append(s)
        return out

    @keyword("Get Menu Json Paths From Environment")
    def get_menu_json_paths_from_environment(self) -> List[str]:
        """
        Return menu JSON paths from environment configuration.

        Precedence:

        1. Environment variable ``I18N_MENU_JSON_PATHS`` (comma-separated file paths).
        2. Auto-discovery under
           ``test_data/environments/<TEST_ENVIRONMENT>/i18n_data/menu_json_files/*.json``
           (or ``<TEST_ENV>`` alias), sorted by filename.
        3. Empty list.

        | =Returns= | =Description= |
        | list[str] | Paths in discovered order (env order for #1, filename order for #2). |
        """
        raw = (os.environ.get("I18N_MENU_JSON_PATHS") or "").strip()
        if raw:
            return [p.strip() for p in raw.split(",") if p.strip()]

        test_env = (os.environ.get("TEST_ENVIRONMENT") or os.environ.get("TEST_ENV") or "").strip()
        if not test_env:
            try:
                v = BuiltIn().get_variable_value("${TEST_ENVIRONMENT}", default="")
            except Exception:
                v = ""
            if isinstance(v, str) and v.strip():
                test_env = v.strip()
        if not test_env:
            try:
                v = BuiltIn().get_variable_value("${TEST_ENV}", default="")
            except Exception:
                v = ""
            if isinstance(v, str) and v.strip():
                test_env = v.strip()
        if not test_env:
            return []

        menu_dir = Path(_REPO_ROOT) / "test_data" / "environments" / test_env / "i18n_data" / "menu_json_files"
        if not menu_dir.is_dir():
            return []
        files = sorted(
            [p for p in menu_dir.glob("*.json") if p.is_file()],
            key=lambda p: p.name.lower(),
        )
        return [str(p) for p in files]

    @keyword("Get Resolved I18n Text Whitelist File Path")
    def get_resolved_i18n_text_whitelist_file_path(self) -> str:
        """
        Resolve optional UTF-8 whitelist file for ``Verify Visible Texts Against Locale Bundles``.

        Precedence: env ``I18N_TEXT_WHITELIST_FILE`` → Robot ``${I18N_TEXT_WHITELIST_FILE}`` (e.g. set in a suite or
        ``i18n_pabot_shared.resource``) → environment-aware default file under
        ``test_data/environments/<TEST_ENVIRONMENT>/i18n_data/whitelist_text/whitelist_text.txt`` when present → empty string.

        | =Returns= | =Description= |
        | str | File path or empty. |
        """
        fp = (os.environ.get("I18N_TEXT_WHITELIST_FILE") or "").strip()
        if fp:
            return fp
        token = "${I18N_TEXT_WHITELIST_FILE}"
        try:
            expanded = BuiltIn().replace_variables(token)
        except Exception:
            expanded = ""
        if isinstance(expanded, str):
            resolved = expanded.strip()
            if resolved and resolved != token:
                return resolved
        try:
            v = BuiltIn().get_variable_value(token, default="")
        except Exception:
            v = ""
        if isinstance(v, str) and v.strip():
            return v.strip()
        test_env = (os.environ.get("TEST_ENVIRONMENT") or os.environ.get("TEST_ENV") or "").strip()
        if test_env:
            candidate = (
                Path(_REPO_ROOT)
                / "test_data"
                / "environments"
                / test_env
                / "i18n_data"
                / "whitelist_text"
                / "whitelist_text.txt"
            )
            if candidate.is_file():
                return str(candidate)
        return ""

    @keyword("Get Resolved I18n Ignore String Patterns")
    def get_resolved_i18n_ignore_string_patterns(self, *resource_default_patterns: Any) -> List[str]:
        """
        Build the regex list for ``ignore_string_patterns`` on ``Verify Visible Texts Against Locale Bundles``.

        Precedence (de-duplicated, first-seen order preserved):

        1. Lines from file path in env ``I18N_IGNORE_PATTERNS_FILE`` (UTF-8, ``#`` full-line comments skipped).
        2. Segments from env ``I18N_IGNORE_PATTERNS`` split on ``|||`` (triple pipe) so patterns can contain commas.
        3. Positional arguments (pass ``@{I18N_IGNORE_PATTERNS}`` from ``i18n_pabot_shared.resource`` or a suite).

        | =Arguments= | =Description= |
        | resource_default_patterns | Zero or more strings; in Robot pass ``@{I18N_IGNORE_PATTERNS}``. |

        | =Returns= | =Description= |
        | list[str] | Regex strings (may be empty). |
        """
        merged: List[str] = []
        fp = (os.environ.get("I18N_IGNORE_PATTERNS_FILE") or "").strip()
        if fp:
            p = Path(fp).expanduser()
            if p.is_file():
                merged.extend(self._read_nonempty_text_file_lines(p))
            else:
                BuiltIn().log(f"I18N | WARN I18N_IGNORE_PATTERNS_FILE not found: {p!r}", level="WARN")
        raw = (os.environ.get("I18N_IGNORE_PATTERNS") or "").strip()
        if raw:
            merged.extend([x.strip() for x in raw.split("|||") if x.strip()])
        for item in resource_default_patterns:
            if item is None:
                continue
            if isinstance(item, (list, tuple)):
                for x in item:
                    s = str(x).strip() if x is not None else ""
                    if s:
                        merged.append(s)
            else:
                s = str(item).strip()
                if s:
                    merged.append(s)
        return list(dict.fromkeys(merged))

    @keyword("Get Resolved I18n Bundles Dir")
    def get_resolved_i18n_bundles_dir(
        self,
        suite_fallback: str = "",
        contract_path: str = "",
    ) -> str:
        """
        Resolve the ``.properties`` bundle root directory.

        Precedence:

        1. ``BUNDLES_DIR``
        2. ``WFM_RESOURCE_BUNDLES_DIR``
        3. ``test_data/environments/<TEST_ENVIRONMENT>/i18n_data/resource_bundles``
           (or ``<TEST_ENV>`` alias) when present

        Robot ``${BUNDLES_DIR}``, contract YAML, and ``suite_fallback`` are **not** read (arguments are ignored for
        backward-compatible call shapes). Environment variables remain explicit overrides; otherwise the
        checked-in environment folder is used.

        | =Arguments= | =Description= |
        | suite_fallback | Ignored. |
        | contract_path | Ignored. |

        | =Returns= | =Description= |
        | str | Bundle root directory. |

        | =Raises= | =Description= |
        | ValueError | If neither env override nor environment-folder default can be resolved. |
        """
        _ = (suite_fallback, contract_path)
        d = (os.environ.get("BUNDLES_DIR") or "").strip()
        if d:
            return d
        w = (os.environ.get("WFM_RESOURCE_BUNDLES_DIR") or "").strip()
        if w:
            return w
        test_env = (os.environ.get("TEST_ENVIRONMENT") or os.environ.get("TEST_ENV") or "").strip()
        if not test_env:
            try:
                v = BuiltIn().get_variable_value("${TEST_ENVIRONMENT}", default="")
            except Exception:
                v = ""
            if isinstance(v, str) and v.strip():
                test_env = v.strip()
        if not test_env:
            try:
                v = BuiltIn().get_variable_value("${TEST_ENV}", default="")
            except Exception:
                v = ""
            if isinstance(v, str) and v.strip():
                test_env = v.strip()
        if test_env:
            candidate = (
                Path(_REPO_ROOT)
                / "test_data"
                / "environments"
                / test_env
                / "i18n_data"
                / "resource_bundles"
            )
            if candidate.is_dir():
                return str(candidate)
        raise ValueError(
            "i18n bundles dir: set environment variable BUNDLES_DIR or WFM_RESOURCE_BUNDLES_DIR, "
            "or provide checked-in bundles under test_data/environments/<TEST_ENVIRONMENT>/"
            "i18n_data/resource_bundles."
        )

    @keyword("Get Db2 Locale Sources Path From I18n Contract")
    def get_db2_locale_sources_path_from_i18n_contract(self, contract_path: str = "") -> str:
        """
        Return ``db2_locale_sources_file`` from the contract YAML if set (custom DB2 query list file).

        Empty string means use packaged ``db2_locale_translation_sources.yaml`` / env
        ``I18N_DB2_LOCALE_SOURCES_FILE``.

        | =Arguments= | =Description= |
        | contract_path | Optional contract YAML path override. |

        | =Returns= | =Description= |
        | str | File path or empty. |
        """
        cp = (contract_path or "").strip()
        path = resolve_shared_i18n_contract_path(cp or None, repo_root=_REPO_ROOT)
        return read_db2_locale_sources_file_from_contract(path)

    @keyword("Warm Up I18n Flat Bundles For Locale")
    def warm_up_i18n_flat_bundles_for_locale(
        self,
        locale: str,
        *,
        bundles_dir: Optional[str] = None,
        scope: str = "web",
    ) -> None:
        """
        Pre-load and cache ``TranslationLoader.load_flat`` for the resolved bundle root + ``locale`` (same cache as verify).

        Use in suite setup to surface bundle parse errors early and to pay parse cost before DataDriver rows.

        | =Arguments= | =Description= |
        | locale | Locale tag (e.g. ``es_MX``). |
        | bundles_dir | Optional override; when omitted, same resolution as `Verify Visible Texts Against Locale Bundles`. |
        | scope | Bundle scope. Default ``web``. |

        Examples:
        | Warm Up I18n Flat Bundles For Locale    ${I18N_LOCALE}
        """
        bd = self._resolve_bundles_dir_for_verify(bundles_dir)
        flat = self._get_cached_flat_bundle_load(bd, locale, scope=scope)
        n_files = len([p for p in flat.files_loaded if str(p).lower().endswith(".properties")])
        BuiltIn().log(
            f"I18N | warm-up flat bundles: locale={locale!r} scope={scope!r} "
            f"properties_files_loaded={n_files} warnings={len(flat.warnings)} errors={len(flat.errors)}",
            level="INFO",
        )
        for w in flat.warnings[:20]:
            BuiltIn().log(w, level="WARN")
        for e in flat.errors[:20]:
            BuiltIn().log(e, level="ERROR")

    @keyword("Set Cached I18n Text Whitelist")
    def set_cached_i18n_text_whitelist(self, strings: Any) -> None:
        """
        Replace the class-level literal whitelist used by `Verify Visible Texts Against Locale Bundles` when
        ``merge_cached_text_whitelist`` is ``True`` (default). Same process-wide sharing as the menu/DB extra cache.

        Use from suite setup, or consume files produced by ``Save I18n Shared Cache Files`` / ``Import I18n Caches Into Library``
        (see ``resources/web/internationalization/i18n_pabot_shared.resource``). For Pabot, workers typically use
        ``Import Cached I18n Text Whitelist From File`` after ``Get Parallel Value For Key``.

        | =Arguments= | =Description= |
        | strings | List of strings, or a single string. Empty entries dropped; list de-duplicated (first-seen order). |

        Examples:
        | ${wl}=    Get I18n Text Whitelist From Db |
        | Set Cached I18n Text Whitelist    ${wl}
        """
        items = self._coerce_text_whitelist_inline(strings)
        type(self)._cached_text_whitelist = list(dict.fromkeys(items))
        BuiltIn().log(
            f"I18N | cached text_whitelist replaced: {len(type(self)._cached_text_whitelist)} unique literal(s)",
            level="INFO",
        )

    @keyword("Add To Cached I18n Text Whitelist")
    def add_to_cached_i18n_text_whitelist(self, strings: Any) -> None:
        """
        Append literals to the class-level whitelist (de-duplicated, first-seen order preserved for prior entries).

        | =Arguments= | =Description= |
        | strings | List of strings or one string (same coercion as `Set Cached I18n Text Whitelist`). |

        Examples:
        | Add To Cached I18n Text Whitelist    ${more_literals}
        """
        items = self._coerce_text_whitelist_inline(strings)
        cur = type(self)._cached_text_whitelist
        type(self)._cached_text_whitelist = list(dict.fromkeys([*cur, *items]))
        BuiltIn().log(
            f"I18N | cached text_whitelist extended: {len(type(self)._cached_text_whitelist)} unique literal(s)",
            level="INFO",
        )

    @keyword("Clear Cached I18n Text Whitelist")
    def clear_cached_i18n_text_whitelist(self) -> None:
        """
        Clear the class-level literal whitelist. Optional before switching owner/data in the same process.

        Examples:
        | Clear Cached I18n Text Whitelist
        """
        type(self)._cached_text_whitelist.clear()
        BuiltIn().log("I18N | cleared cached text_whitelist entries", level="INFO")

    @keyword("Get Cached I18n Text Whitelist Count")
    def get_cached_i18n_text_whitelist_count(self) -> int:
        """
        Return the number of unique literals currently in the class-level whitelist cache.

        | =Returns= | =Description= |
        | int | Count of cached whitelist strings. |

        Examples:
        | ${n}=    Get Cached I18n Text Whitelist Count
        """
        return len(type(self)._cached_text_whitelist)

    @keyword("Import Cached I18n Text Whitelist From File")
    def import_cached_i18n_text_whitelist_from_file(self, path: str) -> None:
        """
        Replace the class-level text whitelist from a UTF-8 file (same as importing into the cache). If the file
        (after leading whitespace) starts with ``[``, it is parsed as a JSON array of strings; otherwise the same line
        rules as ``text_whitelist_file`` on Verify apply (one string per line, ``#`` full-line comments).

        | =Arguments= | =Description= |
        | path | Filesystem path written by `Save Cached I18n Text Whitelist To File` or a line-based whitelist file. |

        Examples:
        | Import Cached I18n Text Whitelist From File    ${OUTPUT_DIR}${/}i18n_shared${/}i18n_whitelist.json
        """
        p = (path or "").strip()
        if not p:
            raise ValueError("path is required for Import Cached I18n Text Whitelist From File")
        fp = Path(p)
        if not fp.is_file():
            raise FileNotFoundError(f"whitelist cache file not found: {p!r}")
        raw = fp.read_text(encoding="utf-8")
        lead = raw.lstrip()
        if lead.startswith("["):
            try:
                data = json.loads(raw)
            except json.JSONDecodeError as ex:
                raise ValueError(f"invalid JSON whitelist file {p!r}: {ex}") from ex
            items = self._coerce_text_whitelist_inline(data)
        else:
            items = []
            for line in raw.splitlines():
                s = line.rstrip("\r\n").strip()
                if not s or s.startswith("#"):
                    continue
                items.append(s)
            items = list(dict.fromkeys(items))
        type(self)._cached_text_whitelist = list(dict.fromkeys(items))
        BuiltIn().log(
            f"I18N | cached text_whitelist from file: {len(type(self)._cached_text_whitelist)} unique literal(s) ({p!r})",
            level="INFO",
        )

    @keyword("Save Cached I18n Text Whitelist To File")
    def save_cached_i18n_text_whitelist_to_file(self, path: str, strings: Any) -> None:
        """
        Write the current whitelist *values* (argument ``strings``) to ``path`` as a UTF-8 JSON array for later
        `Import Cached I18n Text Whitelist From File`.

        Parent directories are created when missing.

        | =Arguments= | =Description= |
        | path | Output file path. |
        | strings | List or single string (same coercion as `Set Cached I18n Text Whitelist`). |

        Examples:
        | Save Cached I18n Text Whitelist To File    ${OUT}${/}wl.json    ${whitelist_list}
        """
        out = Path((path or "").strip())
        if not str(out):
            raise ValueError("path is required for Save Cached I18n Text Whitelist To File")
        items = self._coerce_text_whitelist_inline(strings)
        out.parent.mkdir(parents=True, exist_ok=True)
        with out.open("w", encoding="utf-8") as fh:
            json.dump(items, fh, ensure_ascii=False, indent=2)
        BuiltIn().log(
            f"I18N | wrote {len(items)} whitelist string(s) to {str(out)!r}",
            level="INFO",
        )

    @keyword("Export Cached Extra Translations To File")
    def export_cached_extra_translations_to_file(self, path: str) -> None:
        """
        Save the class-level extra translation cache ``(source_tag, value)`` rows to a UTF-8 JSON file
        (array of ``[source_tag, value]`` pairs). Pair with `Import Cached Extra Translations From File` and Pabot
        ``Set Parallel Value For Key`` pointing at this path.

        | =Arguments= | =Description= |
        | path | Output file path. |

        Examples:
        | Export Cached Extra Translations To File    ${OUTPUT_DIR}${/}i18n_shared${/}i18n_extra_translations.json
        """
        out = Path((path or "").strip())
        if not str(out):
            raise ValueError("path is required for Export Cached Extra Translations To File")
        rows = [[a, b] for a, b in type(self)._cached_extra_translation_entries]
        out.parent.mkdir(parents=True, exist_ok=True)
        with out.open("w", encoding="utf-8") as fh:
            json.dump(rows, fh, ensure_ascii=False)
        BuiltIn().log(
            f"I18N | exported extra translation cache: {len(rows)} row(s) to {str(out)!r}",
            level="INFO",
        )

    @keyword("Import Cached Extra Translations From File")
    def import_cached_extra_translations_from_file(self, path: str, *, append: bool = False) -> None:
        """
        Import extra translation rows from a JSON file produced by `Export Cached Extra Translations To File`
        (into the class-level cache). When ``append`` is ``False`` (default), clears the extra cache and distinct-key
        tracking first so the file replaces the cache. Each pair is appended using the same rules as menu/DB add keywords
        (including ``store_distinct_only``).

        | =Arguments= | =Description= |
        | path | Input JSON file path. |
        | append | When ``True``, keep existing cache rows and append from file. Default ``False``. |

        Examples:
        | Import Cached Extra Translations From File    ${OUTPUT_DIR}${/}i18n_shared${/}i18n_extra_translations.json
        """
        p = (path or "").strip()
        if not p:
            raise ValueError("path is required for Import Cached Extra Translations From File")
        fp = Path(p)
        if not fp.is_file():
            raise FileNotFoundError(f"extra translation cache file not found: {p!r}")
        with fp.open(encoding="utf-8") as fh:
            data = json.load(fh)
        if not isinstance(data, list):
            raise ValueError(f"extra translation cache file must be a JSON array: {p!r}")
        cls = type(self)
        if not append:
            cls._clear_extra_translation_cache_buffers()
        loaded = 0
        for row in data:
            if not isinstance(row, (list, tuple)) or len(row) != 2:
                continue
            src, val = str(row[0]), str(row[1])
            self._append_extra_translations(src, [val])
            loaded += 1
        BuiltIn().log(
            f"I18N | imported extra translation cache: {loaded} row(s) from {p!r} (append={append})",
            level="INFO",
        )

    @keyword("Configure I18n Translation Debug Log")
    def configure_i18n_translation_debug_log(self, path: str = "") -> None:
        """
        Enable or clear the translation debug TSV path used by `Verify Visible Texts Against Locale Bundles`.

        When ``path`` is non-empty, Verify writes a TSV of *distinct* allow-list strings with source tags.
        Overrides environment ``I18N_TRANSLATION_DEBUG_LOG`` while set. Pass ``${EMPTY}`` or ``""`` to clear
        and use env only. Prefer a temp or CI artifact path (files can be large).

        | =Arguments= | =Description= |
        | path | Filesystem path for the TSV output, or empty / ``${EMPTY}`` to clear this keyword override (env may still apply). |

        Examples:
        | Configure I18n Translation Debug Log    ${OUTPUT_DIR}${/}i18n.tsv
        | Configure I18n Translation Debug Log    ${EMPTY}
        """
        type(self)._translation_debug_log_path = path.strip() or None
        if type(self)._translation_debug_log_path:
            BuiltIn().log(
                f"I18N | translation debug file enabled: {type(self)._translation_debug_log_path!r}",
                level="INFO",
            )
        else:
            BuiltIn().log(
                "I18N | translation debug file path cleared (use I18N_TRANSLATION_DEBUG_LOG env if set)",
                level="INFO",
            )

    @keyword("Write I18n Translation Sources To File")
    def write_i18n_translation_sources_to_file(
        self,
        path: str,
        locale: str,
        *,
        bundles_dir: Optional[str] = None,
        scope: str = "web",
        include_page_i18n: bool = False,
        merge_cached_extra_translation_sources: bool = True,
        strip: bool = True,
        case_sensitive: bool = True,
    ) -> None:
        """
        Write merged translation sources to a UTF-8 TSV for analysis (does not run visible-text verification).

        Loads locale ``.properties`` via ``TranslationLoader`` (same roots as `Verify Visible Texts Against Locale Bundles`),
        optionally merges `Get Page I18n String Values` when ``include_page_i18n`` is ``True`` (requires an open browser
        page with ``i18n``), and optionally includes class-level extra cache rows (menu JSON / DB2) when
        ``merge_cached_extra_translation_sources`` is ``True``. Populate the extra cache first with
        `Add Translation Sources From Menu Json Files`, `Add Translation Sources From Db2 For Locale`,
        `Import Cached Extra Translations From File`, or resource steps such as `Save I18n Shared Cache Files` /
        `Import I18n Caches Into Library`.

        Output format matches the debug TSV from `Verify Visible Texts Against Locale Bundles` /
        `Configure I18n Translation Debug Log`: one row per *distinct* display string; column 1 is pipe-joined
        source tags (``properties_bundles``, ``page_i18n``, ``menu_json:…``, table names, etc.), column 2 is the text.

        | =Arguments= | =Description= |
        | path | Output file path (``.tsv`` recommended). Parent directories are created when missing. |
        | locale | Locale to load (e.g. ``en_US``). |
        | bundles_dir | Optional bundle root override; when omitted, same resolution as Verify. |
        | scope | Bundle scope label. Default ``web``. |
        | include_page_i18n | When ``True``, merge strings from `Get Page I18n String Values`. Default ``False`` (no browser required). |
        | merge_cached_extra_translation_sources | When ``True``, include ``(source_tag, value)`` rows from the class-level extra cache. Default ``True``. |
        | strip | When ``True``, strip whitespace before grouping rows (same as Verify). Default ``True``. |
        | case_sensitive | When ``True``, distinct rows are case-sensitive. Default ``True``. |

        Examples:
        | Write I18n Translation Sources To File    ${OUTPUT_DIR}${/}i18n_sources.tsv    en_US
        | Write I18n Translation Sources To File    ${OUT}${/}all.tsv    es_MX    include_page_i18n=${True}
        """
        out = (path or "").strip()
        if not out:
            raise ValueError("path is required for Write I18n Translation Sources To File")
        bd = self._resolve_bundles_dir_for_verify(bundles_dir)
        loc = (locale or "").strip()
        if not loc:
            raise ValueError("locale is required for Write I18n Translation Sources To File")

        flat = self._get_cached_flat_bundle_load(bd, loc, scope=scope)
        bi = BuiltIn()
        for w in flat.warnings:
            bi.log(w, level="WARN")
        for e in flat.errors:
            bi.log(e, level="ERROR")

        i18n_vals: List[str] = []
        if include_page_i18n:
            try:
                i18n_vals = self.get_page_i18n_string_values()
            except Exception as ex:
                bi.log(f"I18N | write translation sources: page i18n unavailable ({ex!r}); using empty", level="WARN")

        self._write_translation_debug_tsv_file(
            out,
            flat,
            i18n_vals,
            strip=strip,
            case_sensitive=case_sensitive,
            include_extra_cache=merge_cached_extra_translation_sources,
        )
        bi.log(
            f"I18N | wrote translation sources TSV for locale={loc!r} bundles_dir={bd!r} "
            f"include_page_i18n={include_page_i18n} merge_cached_extra={merge_cached_extra_translation_sources} "
            f"to {out!r}",
            level="INFO",
        )

    @keyword("Set Extra Translation Cache Store Distinct Only")
    def set_extra_translation_cache_store_distinct_only(self, enabled: bool = False) -> None:
        """
        Control whether extra translation cache rows are stored distinct-only.

        When ``enabled`` is ``${True}``, `Add Translation Sources From Menu Json Files` and
        `Add Translation Sources From Db2 For Locale` keep only distinct strings (strip + optional
        case-fold). Default ``${False}`` keeps every row; `Verify Visible Texts Against Locale Bundles`
        still dedupes when merging.

        Call `Clear Extra Translation Sources For Visible Text Verify` after toggling so counts stay
        consistent. `Set Extra Translation Cache Dedupe Case Sensitive` affects normalization when
        distinct-only is on.

        | =Arguments= | =Description= |
        | enabled | ``${True}`` = store distinct strings only; ``${False}`` = keep every appended row. |

        Examples:
        | Set Extra Translation Cache Store Distinct Only    ${True}
        """
        type(self)._extra_cache_store_distinct_only = bool(enabled)
        BuiltIn().log(
            f"I18N | extra cache store_distinct_only={type(self)._extra_cache_store_distinct_only}",
            level="INFO",
        )

    @keyword("Set Extra Translation Cache Dedupe Case Sensitive")
    def set_extra_translation_cache_dedupe_case_sensitive(self, case_sensitive: bool = True) -> None:
        """
        Control case sensitivity for distinct-only extra cache keys.

        | =Arguments= | =Description= |
        | case_sensitive | ``${False}`` = case-fold when checking distinct membership (only with `Set Extra Translation Cache Store Distinct Only` ``${True}``). Default ``${True}``. |

        Examples:
        | Set Extra Translation Cache Dedupe Case Sensitive    ${False}
        """
        type(self)._extra_cache_dedupe_case_sensitive = bool(case_sensitive)
        BuiltIn().log(
            f"I18N | extra cache dedupe_case_sensitive={type(self)._extra_cache_dedupe_case_sensitive}",
            level="INFO",
        )

    @keyword("Get Cached Extra Translation Total In Cache")
    def get_cached_extra_translation_total_in_cache(self) -> int:
        """
        Return ``total_translations_in_cache`` (row count including duplicates unless distinct-only).

        | =Returns= | =Description= |
        | int | Number of cached ``(source, value)`` rows. |

        Examples:
        | ${n}=    Get Cached Extra Translation Total In Cache
        """
        return len(type(self)._cached_extra_translation_entries)

    @keyword("Get Cached Extra Translation Distinct In Cache")
    def get_cached_extra_translation_distinct_in_cache(self) -> int:
        """
        Return ``distinct_translations_in_cache`` (unique values in the extra cache).

        | =Returns= | =Description= |
        | int | Count of distinct ``value`` strings currently in the extra cache. |

        Examples:
        | ${u}=    Get Cached Extra Translation Distinct In Cache
        """
        _, u = type(self)._extra_cache_total_and_distinct()
        return u

    @keyword("Get Cached Extra Translation Source Count")
    def get_cached_extra_translation_source_count(self) -> int:
        """
        Deprecated alias for `Get Cached Extra Translation Total In Cache` (row count).

        | =Returns= | =Description= |
        | int | Same as `Get Cached Extra Translation Total In Cache`. |
        """
        return self.get_cached_extra_translation_total_in_cache()

    @keyword("Add Translation Sources From Menu Json Files")
    def add_translation_sources_from_menu_json_files(
        self,
        menu_json_paths: Any,
        *,
        locale_mode: str = "current",
        locale: Optional[str] = None,
    ) -> None:
        """
        Load WFM menu JSON files and append ``displayLabelLangMap`` strings to the extra cache.

        Cached strings are merged into the allow-list when `Verify Visible Texts Against Locale Bundles`
        runs with ``merge_cached_extra_translation_sources=${True}``.

        | =Arguments= | =Description= |
        | menu_json_paths | List of file paths (``Create List``) or one path string. |
        | locale_mode | ``all`` = every locale in each map; ``current`` = only ``locale`` (``ll_RR``). Default ``current``. |
        | locale | Required when ``locale_mode=current`` (e.g. ``en_US``). |

        Examples:
        | @{paths}=    Create List    ${MENU_DIR}${/}SHIFT.json
        | Add Translation Sources From Menu Json Files    ${paths}    locale_mode=all
        """
        paths = self._normalize_menu_json_paths_arg(menu_json_paths)
        if not paths:
            BuiltIn().log("I18N | menu JSON paths empty; nothing added", level="WARN")
            return
        loc = str(locale).strip() if locale is not None else None
        if loc == "":
            loc = None
        files_ok = 0
        for p in paths:
            strings, warn = load_single_menu_json_file(p, locale_mode=locale_mode, locale=loc)
            if warn:
                BuiltIn().log(f"I18N | menu json: {warn}", level="WARN")
                continue
            files_ok += 1
            base = Path(p).name
            source_tag = f"menu_json:{base}"
            total_src = len(strings)
            distinct_src = len(dict.fromkeys(strings))
            self._append_extra_translations(source_tag, strings)
            tc, dc = type(self)._extra_cache_total_and_distinct()
            BuiltIn().log(
                f"I18N | menu json: loaded {base} | rows={total_src} distinct_in_file={distinct_src} "
                f"| extra_cache now rows={tc} distinct_values={dc}",
                level="INFO",
            )
            self._log_translate_metrics(
                source=source_tag,
                total_translations_in_source=total_src,
                distinct_translations_in_source=distinct_src,
                total_translations_in_cache=tc,
                distinct_translations_in_cache=dc,
                level="DEBUG",
            )
        if files_ok == 0:
            BuiltIn().log("I18N | menu json: no files loaded", level="WARN")

    @keyword("Add Translation Sources From Db2 For Locale")
    def add_translation_sources_from_db2_for_locale(
        self,
        locale: str,
        *,
        owner_lang_mapping: int = 111110051,
        owner_rfx_user: int = 121890099,
        sources_config_path: str = "",
    ) -> None:
        """
        Query DB2 translation tables for a locale and append strings to the extra cache.

        SQL and ``source_tag`` labels come from ``db2_locale_translation_sources.yaml`` (next to
        ``db2_locale_sources.py``) unless overridden by ``sources_config_path`` or env
        ``I18N_DB2_LOCALE_SOURCES_FILE``. Add a ``queries`` entry in that YAML to support another table
        without changing Robot resources.

        Uses ``DB2_CONNECTION`` from the environment. Connects once per call—for large extracts, run
        once per suite or CI stage, not per test.

        | =Arguments= | =Description= |
        | locale | Locale key such as ``en_US`` (normalized to ``ll_RR``). |
        | owner_lang_mapping | Owner id bound to YAML ``owner_param: owner_lang_mapping``. Default ``111110051``. |
        | owner_rfx_user | Owner id bound to YAML ``owner_param: owner_rfx_user``. Default ``121890099``. |
        | sources_config_path | Optional path to a YAML file with the same schema as the packaged default. Empty uses env or default. |

        Examples:
        | Add Translation Sources From Db2 For Locale    en_US
        | Add Translation Sources From Db2 For Locale    en_US    sources_config_path=${CURDIR}/custom_db2_sources.yaml
        """
        scp = (sources_config_path or "").strip()
        by_tag, warns, table_stats = fetch_db2_translation_strings_for_locale(
            locale,
            owner_lang_mapping=owner_lang_mapping,
            owner_rfx_user=owner_rfx_user,
            sources_config_path=scp or None,
        )
        for w in warns:
            BuiltIn().log(f"I18N | db2: {w}", level="WARN")
        for st in table_stats:
            vals = by_tag.get(st.table, [])
            self._append_extra_translations(st.table, vals)
            tc, dc = type(self)._extra_cache_total_and_distinct()
            BuiltIn().log(
                f"I18N | db2: loaded {st.table} | rows={st.rows_non_empty_value} distinct_in_source={st.distinct_values} "
                f"| extra_cache now rows={tc} distinct_values={dc}",
                level="INFO",
            )
            self._log_translate_metrics(
                source=st.table,
                total_translations_in_source=st.rows_non_empty_value,
                distinct_translations_in_source=st.distinct_values,
                total_translations_in_cache=tc,
                distinct_translations_in_cache=dc,
                level="DEBUG",
            )

    @staticmethod
    def _normalize_menu_json_paths_arg(paths: Any) -> List[str]:
        if paths is None:
            return []
        if isinstance(paths, str):
            return [paths] if paths.strip() else []
        try:
            return [str(x) for x in list(paths) if x is not None and str(x).strip()]
        except TypeError:
            return [str(paths)] if str(paths).strip() else []

    @keyword("Dedupe Ordered String List")
    def dedupe_ordered_string_list(self, values: Any) -> List[str]:
        """
        Return ``values`` as strings stripped of outer whitespace, de-duplicated with first-seen order preserved.

        Accepts a list/tuple or a single string (same coercion style as menu JSON path lists).

        | =Arguments= | =Description= |
        | values | List-like or one string. |

        | =Returns= | =Description= |
        | list[str] | Non-empty unique strings in order. |

        Examples:
        | ${u}=    Dedupe Ordered String List    ${paths}
        """
        base = self._normalize_menu_json_paths_arg(values)
        return list(dict.fromkeys(base))

    def _merge_cached_extra_strings_into_load(self, merged: LoadResult, *, use_extras: bool) -> tuple[LoadResult, int, int]:
        """
        Returns ``(load_result, deduped_extras_merged, raw_extra_cache_rows)``.
        ``raw_extra_cache_rows`` is ``len(entries)`` when ``use_extras`` else ``0`` (for logging).
        """
        if not use_extras:
            return merged, 0, 0
        raw = type(self)._cached_extra_translation_entries
        raw_n = len(raw)
        extras = self._ordered_deduped_values_from_extra_cache()
        if not extras:
            return merged, 0, raw_n
        return extend_load_result_with_strings(merged, extras, prefix="__i18n_extra::"), len(extras), raw_n

    @staticmethod
    def _flat_str_entry_count(lr: LoadResult) -> int:
        """Composite key count for string values in a flat ``LoadResult`` (includes synthetic keys)."""
        return len(cast_flat_values(lr.data if isinstance(lr.data, dict) else {}))

    @staticmethod
    def _extend_flat_with_strings(
        base: LoadResult,
        extra: Sequence[str],
        *,
        prefix: str = "__page_i18n::",
    ) -> LoadResult:
        data = dict(cast_flat_values(base.data if isinstance(base.data, dict) else {}))
        for i, s in enumerate(extra):
            data[f"{prefix}{i}"] = str(s)
        return LoadResult(
            data=data,
            warnings=list(base.warnings),
            errors=list(base.errors),
            files_loaded=list(base.files_loaded),
        )

    @staticmethod
    def _log_coverage_report(
        report: VisibleTextCoverageReport,
        *,
        max_properties_files_to_log: int = 80,
        log_matched_preview_limit: int = 0,
        log_unmatched_dom_context: bool = False,
        inventory_element_refs: Optional[Dict[str, List[str]]] = None,
        verbose: bool = False,
    ) -> None:
        bi = BuiltIn()
        lr = report.load_result
        for w in getattr(lr, "warnings", []) or []:
            bi.log(w, level="WARN")
        for e in getattr(lr, "errors", []) or []:
            bi.log(e, level="ERROR")

        if verbose:
            bi.log(
                f"I18N | bundles_dir={report.bundles_dir!r} locale={report.locale!r} "
                f"scope={report.bundle_scope!r} include_page_i18n={report.include_page_i18n}",
                level="INFO",
            )
            bi.log(
                f"I18N | properties files loaded: {report.bundle_properties_files_loaded} | "
                f"final_distinct_allowed_translation_values={report.known_translation_values} "
                "(same as allow-list distinct after all merges; see 'I18N | allow-list | how counts add up' above)",
                level="INFO",
            )
            bi.log(
                "I18N STATS | DOM inventory input: "
                f"visible_texts_list_len={report.total_input_strings} "
                "(number of entries in the Python list you passed to Verify — usually the return value of "
                "'Stop Visible Text Inventory And Return Texts'; should match the earlier log line "
                "'inventory_stop_returned_list_len' when you pass the same ${variable}; "
                "this is not 'unique strings on screen' until Verify applies its own dedupe/filtering)",
                level="INFO",
            )
            bi.log(
                "I18N STATS | matching: "
                f"empty_skipped={report.skipped_empty} | "
                f"ratio_suffix_stripped_count={report.ratio_suffix_preprocess_changed} | "
                f"numeric_time_and_date_literal_noise_filtered_out={report.numeric_filtered_out} | "
                f"user_regex_filtered_out={report.user_regex_filtered_out} | "
                f"whitelist_skipped={report.whitelist_filtered_out} | "
                f"whitelist_skipped_distinct={len(report.whitelist_skipped_unique_texts)} | "
                f"unique_checked={report.unique_checked} | "
                f"unique_matched={report.unique_matched} | "
                f"unique_unmatched={report.unique_unmatched} | "
                f"matched_via_date_suffix_relaxation={report.matched_via_date_suffix_relaxation}",
                level="INFO",
            )
        else:
            bi.log(
                "I18N STATS | "
                f"visible_input_list_len={report.total_input_strings} "
                f"(list passed to Verify; not deduped screen-unique count until matching) | "
                f"unique_checked={report.unique_checked} unique_matched={report.unique_matched} "
                f"unique_unmatched={report.unique_unmatched} | "
                f"empty_skipped={report.skipped_empty} "
                f"numeric_date_noise_filtered={report.numeric_filtered_out} "
                f"regex_filtered={report.user_regex_filtered_out} "
                f"ratio_suffix_stripped={report.ratio_suffix_preprocess_changed} | "
                f"whitelist_skipped={report.whitelist_filtered_out} "
                f"whitelist_skipped_distinct={len(report.whitelist_skipped_unique_texts)} | "
                f"date_suffix_relaxed_matches={report.matched_via_date_suffix_relaxation}",
                level="INFO",
            )
        for err in report.ignore_pattern_errors:
            bi.log(f"I18N | ignore regex compile error: {err}", level="WARN")
        for h in report.extra_log_hints:
            bi.log(f"I18N | {h}", level="INFO")

        for s in report.whitelist_skipped_unique_texts:
            bi.log(
                f"I18N DEBUG | whitelist skipped (not validated against bundles): {s!r}",
                level="DEBUG",
            )

        files = list(getattr(lr, "files_loaded", None) or [])
        prop_files = [p for p in files if isinstance(p, str) and p.lower().endswith(".properties")]
        if verbose:
            bi.log("I18N | bundle file paths (.properties):", level="INFO")
            cap = max(0, int(max_properties_files_to_log))
            for i, p in enumerate(prop_files[:cap]):
                bi.log(f"  [{i + 1}] {p}", level="INFO")
            if len(prop_files) > cap:
                bi.log(f"  ... and {len(prop_files) - cap} more property files", level="INFO")

        preview = int(log_matched_preview_limit)
        if preview > 0 and report.matched_texts:
            sample = report.matched_texts[:preview]
            bi.log(f"I18N | sample matched strings (first {len(sample)}): {sample!r}", level="INFO")

        bi.log(f"I18N UNIQUE MATCHED: {report.unique_matched} unique strings", level="INFO")
        bi.log(f"I18N UNMATCHED ({report.unique_unmatched} unique, copy-friendly lines):", level="INFO")
        refs = inventory_element_refs or {}
        for line in report.unmatched_texts:
            bi.log(f"  - {line}", level="INFO")
            if not log_unmatched_dom_context:
                continue
            snippets = refs.get(line, [])
            if snippets:
                bi.log(
                    "      I18N | dom_context: truncated outerHTML of element(s) that contributed this string "
                    f"(up to {len(snippets)}):",
                    level="INFO",
                )
                for i, snip in enumerate(snippets, 1):
                    bi.log(f"      [{i}] {snip}", level="INFO")

    @keyword("Log I18n Bundle And Page Diagnostics")
    def log_i18n_bundle_and_page_diagnostics(
        self,
        locale: str,
        *,
        bundles_dir: Optional[str] = None,
        scope: str = "web",
        include_page_i18n: bool = True,
        max_modules_to_log: int = 40,
        max_files_to_log: int = 80,
        page_i18n_sample_limit: int = 20,
    ) -> None:
        """
        Log bundle modules, loaded ``.properties`` paths for ``locale``, and optional ``i18n`` sample.

        Does not start visible-text inventory; run after the app shell is available (e.g. post-login).

        | =Arguments= | =Description= |
        | locale | Locale to load (e.g. ``en_US``). |
        | bundles_dir | Optional bundle root override; when omitted, same resolution as Verify. |
        | scope | Bundle scope label. Default ``web``. |
        | include_page_i18n | When ``True``, log distinct count and sample from `Get Page I18n String Values`. |
        | max_modules_to_log | Max module names listed in the log. Default ``40``. |
        | max_files_to_log | Max ``.properties`` paths listed. Default ``80``. |
        | page_i18n_sample_limit | Max ``i18n`` strings in sample; ``0`` skips sample lines. Default ``20``. |

        Examples:
        | Log I18n Bundle And Page Diagnostics    en_US
        """
        bi = BuiltIn()
        bd = self._resolve_bundles_dir_for_verify(bundles_dir)
        loader = TranslationLoader(bd)
        modules = loader.list_modules(scope=scope)  # type: ignore[arg-type]
        flat = self._get_cached_flat_bundle_load(bd, locale, scope=scope)
        for w in flat.warnings:
            bi.log(w, level="WARN")
        for e in flat.errors:
            bi.log(e, level="ERROR")
        mod_n = len(modules)
        head = modules[: max(0, int(max_modules_to_log))]
        bi.log(
            f"I18N DIAG | bundles_dir={bd!r} locale={locale!r} scope={scope!r}",
            level="INFO",
        )
        bi.log(f"I18N DIAG | modules in scope: {mod_n} (showing up to {len(head)}): {head!r}", level="INFO")
        files = [p for p in flat.files_loaded if isinstance(p, str) and p.lower().endswith(".properties")]
        bi.log(f"I18N DIAG | locale property files loaded: {len(files)}", level="INFO")
        cap = max(0, int(max_files_to_log))
        for i, p in enumerate(files[:cap]):
            bi.log(f"  [{i + 1}] {p}", level="INFO")
        if len(files) > cap:
            bi.log(f"  ... and {len(files) - cap} more", level="INFO")
        if include_page_i18n:
            try:
                raw = self.get_page_i18n_string_values()
            except Exception as ex:
                bi.log(f"I18N DIAG | page i18n: could not read ({ex!r})", level="WARN")
                raw = []
            uniq = list(dict.fromkeys(raw))
            bi.log(f"I18N DIAG | page i18n distinct string count: {len(uniq)}", level="INFO")
            lim = max(0, int(page_i18n_sample_limit))
            if lim:
                bi.log(f"I18N DIAG | page i18n sample (first {min(lim, len(uniq))}): {uniq[:lim]!r}", level="INFO")

    @keyword("Verify Visible Texts Against Locale Bundles")
    def verify_visible_texts_against_locale_bundles(
        self,
        locale: str,
        visible_texts: Any,
        *,
        bundles_dir: Optional[str] = None,
        include_page_i18n: bool = True,
        skip_numeric_looking: bool = True,
        try_date_suffix_relaxation: bool = True,
        strip_trailing_ratio_time: bool = False,
        ignore_string_patterns: Any = None,
        scope: str = "web",
        strip: bool = True,
        case_sensitive: bool = True,
        dedupe: bool = True,
        max_properties_files_to_log: int = 80,
        log_matched_preview_limit: int = 0,
        merge_cached_extra_translation_sources: bool = True,
        translation_debug_log_path: Optional[str] = None,
        log_unmatched_dom_context: bool = False,
        text_whitelist: Any = None,
        text_whitelist_file: str = "",
        merge_cached_text_whitelist: bool = True,
        verbose_allow_list_logs: bool = False,
    ) -> None:
        """
        Assert every collected visible string exists in locale bundles (plus optional page ``i18n`` and extras).

        On failure, Robot fails after logging each unmatched string (``I18N UNMATCHED`` lines). When
        ``log_unmatched_dom_context`` is ``True``, the log also includes indented ``I18N | dom_context``
        lines (truncated ``outerHTML`` of element(s) that contributed each string), using refs from
        `Stop Visible Text Inventory And Return Texts` in the same test. Default is ``False`` so logs stay
        compact. On success, logs one ``I18N | allow-list SUMMARY`` line (sources → merged allow-list),
        then compact ``I18N STATS``. Set ``verbose_allow_list_logs=${True}`` for legacy per-step metrics
        and full ``.properties`` path listing in the coverage block. Whitelist skips are counted in
        ``I18N STATS``; each distinct skipped string is logged at DEBUG. For JSON without failing, use
        `Dump Visible Text Check Result As Json`.

        **Bundle root:** Resolved automatically (same order as `Get Resolved I18n Bundles Dir`): optional explicit
        ``bundles_dir`` override → value from suite setup `Set Default I18n Bundles Dir For Visible Text Verify`
        (called by `Configure I18n Bundles Dir From Contract`) → env / Robot / contract. Parsed ``.properties`` are
        cached **class-wide** in ``_flat_bundle_load_cache`` keyed by ``(resolved_dir, locale, scope)``.

        | =Arguments= | =Description= |
        | locale | Locale to verify (e.g. ``en_US``). |
        | visible_texts | List from `Stop Visible Text Inventory And Return Texts`. Pass ``${var}``, not ``@{var}``. |
        | bundles_dir | Optional; only if you must override the resolved app bundle root for this call. |
        | include_page_i18n | When ``True``, merge `Get Page I18n String Values` into the allow-list. Default ``True``. |
        | skip_numeric_looking | When ``True``, skip digit-heavy strings and whole-string numeric dates (ISO / slash / dot with 4-digit year). Default ``True``. |
        | try_date_suffix_relaxation | When ``True``, allow date-suffixed UI text to match shorter bundle values. |
        | strip_trailing_ratio_time | When ``True``, strip trailing `` / H:MM``-style suffixes before match. |
        | ignore_string_patterns | Optional list of regex strings; ``re.search`` skips matching inputs. |
        | scope | Bundle scope. Default ``web``. |
        | strip | When ``True``, strip whitespace before compare. Default ``True``. |
        | case_sensitive | When ``True``, case-sensitive match. Default ``True``. |
        | dedupe | When ``True``, dedupe visible inputs before check. Default ``True``. |
        | max_properties_files_to_log | Cap for ``.properties`` paths when ``verbose_allow_list_logs=True``. Default ``80``. |
        | log_matched_preview_limit | If ``> 0``, log a sample of matched strings. Default ``0``. |
        | merge_cached_extra_translation_sources | When ``True``, merge menu/DB extra cache. Default ``True``. |
        | translation_debug_log_path | Optional TSV path override; else `Configure I18n Translation Debug Log` or env ``I18N_TRANSLATION_DEBUG_LOG``. |
        | log_unmatched_dom_context | When ``True``, after each unmatched line log ``I18N | dom_context`` with truncated ``outerHTML`` from inventory (same test). Default ``False``. |
        | text_whitelist | Optional list of literal strings to skip (exact match after ``strip`` / ``case_sensitive``). Merged with file and cache when enabled. |
        | text_whitelist_file | Optional UTF-8 path: one string per line, ``#`` full-line comments. Merged first, then ``text_whitelist``, then cache. |
        | merge_cached_text_whitelist | When ``True``, merge literals from `Set Cached I18n Text Whitelist` / `Add To Cached I18n Text Whitelist`. Default ``True``. |
        | verbose_allow_list_logs | When ``True``, emit per-step ``translate-metrics`` (DEBUG columns = extra cache only), long allow-list merge text, and list every ``.properties`` path in the coverage report. Default ``False``. |

        | =Raises= | =Description= |
        | BuiltIn.fail | Any visible string is missing from the merged allow-list after logging ``I18N UNMATCHED`` lines (and ``dom_context`` lines if ``log_unmatched_dom_context=True``). |

        Examples:
        | ${texts}=    Stop Visible Text Inventory And Return Texts
        | Verify Visible Texts Against Locale Bundles    en_US    ${texts}
        | Verify Visible Texts Against Locale Bundles    en_US    ${texts}    log_unmatched_dom_context=${True}
        | Verify Visible Texts Against Locale Bundles    en_US    ${texts}    text_whitelist=${SKIP_LITERALS}    text_whitelist_file=${CURDIR}/i18n_text_whitelist.txt
        """
        coerced = self._coerce_visible_text_list(visible_texts)
        bd = self._resolve_bundles_dir_for_verify(bundles_dir)
        det = "INFO" if verbose_allow_list_logs else "DEBUG"
        BuiltIn().log(
            f"I18N | verify_input_list_len={len(coerced)} (coerced list passed to analysis)",
            level=det,
        )

        flat = self._get_cached_flat_bundle_load(bd, locale, scope=scope)

        d_bundles = count_distinct_values_in_flat_load(flat, strip=strip, case_sensitive=case_sensitive)
        n_ent_bundles = self._flat_str_entry_count(flat)
        tc0, dc0 = type(self)._extra_cache_total_and_distinct()
        self._log_translate_metrics(
            source="properties_bundles",
            total_translations_in_source=n_ent_bundles,
            distinct_translations_in_source=d_bundles,
            total_translations_in_cache=tc0,
            distinct_translations_in_cache=dc0,
            level=det,
        )

        i18n_vals: List[str] = []
        if include_page_i18n:
            try:
                i18n_vals = self.get_page_i18n_string_values()
            except Exception:
                i18n_vals = []
        merged = self._extend_flat_with_strings(flat, i18n_vals) if include_page_i18n else flat
        i18n_distinct = len(dict.fromkeys(i18n_vals)) if i18n_vals else 0

        dbg_path = self._resolve_translation_debug_log_path(translation_debug_log_path)
        if dbg_path:
            self._write_translation_debug_tsv_file(
                dbg_path,
                flat,
                i18n_vals,
                strip=strip,
                case_sensitive=case_sensitive,
            )

        if include_page_i18n:
            tc1, dc1 = type(self)._extra_cache_total_and_distinct()
            self._log_translate_metrics(
                source="page_i18n_object",
                total_translations_in_source=len(i18n_vals),
                distinct_translations_in_source=i18n_distinct,
                total_translations_in_cache=tc1,
                distinct_translations_in_cache=dc1,
                level=det,
            )
        else:
            tc1, dc1 = type(self)._extra_cache_total_and_distinct()
            self._log_translate_metrics(
                source="page_i18n_object",
                total_translations_in_source=0,
                distinct_translations_in_source=0,
                total_translations_in_cache=tc1,
                distinct_translations_in_cache=dc1,
                level=det,
            )

        d_before_extras = count_distinct_values_in_flat_load(merged, strip=strip, case_sensitive=case_sensitive)
        n_before_extras = self._flat_str_entry_count(merged)

        if merge_cached_extra_translation_sources and type(self)._cached_extra_translation_entries:
            raw_e, dist_e = type(self)._extra_cache_total_and_distinct()
            self._log_translate_metrics(
                source="menu_json_and_db2_combined_cache",
                total_translations_in_source=raw_e,
                distinct_translations_in_source=dist_e,
                total_translations_in_cache=raw_e,
                distinct_translations_in_cache=dist_e,
                level=det,
            )

        merged, extra_n, extra_raw_n = self._merge_cached_extra_strings_into_load(
            merged, use_extras=merge_cached_extra_translation_sources
        )
        d_after_merge = count_distinct_values_in_flat_load(merged, strip=strip, case_sensitive=case_sensitive)
        n_after_merge = self._flat_str_entry_count(merged)

        prop_n = len(
            [p for p in flat.files_loaded if isinstance(p, str) and str(p).lower().endswith(".properties")]
        )
        ex_rows, ex_distinct = type(self)._extra_cache_total_and_distinct()
        self._log_verify_allow_list_summary(
            bundles_dir=bd,
            locale=locale,
            scope=scope,
            include_page_i18n=include_page_i18n,
            merge_extras=merge_cached_extra_translation_sources,
            properties_file_count=prop_n,
            bundle_composite_keys=n_ent_bundles,
            bundle_distinct_values=d_bundles,
            page_i18n_total=len(i18n_vals),
            page_i18n_distinct=i18n_distinct,
            extra_cache_rows=ex_rows,
            extra_cache_distinct=ex_distinct,
            extras_merged_deduped_keys=extra_n,
            extras_merged_raw_rows=extra_raw_n,
            merged_composite_keys=n_after_merge,
            merged_distinct_values=d_after_merge,
        )

        if merge_cached_extra_translation_sources and extra_raw_n > 0:
            collapsed = extra_raw_n - extra_n
            BuiltIn().log(
                f"I18N | allow-list | merging extras into allow-list: "
                f"extra_cache_rows={extra_raw_n} | deduped_values_added_as_keys={extra_n} | "
                f"duplicate_rows_collapsed_within_cache={collapsed}",
                level=det,
            )
        elif merge_cached_extra_translation_sources:
            BuiltIn().log(
                "I18N | allow-list | merge_cached_extra_translation_sources=True but extra cache empty",
                level=det,
            )
        else:
            BuiltIn().log(
                "I18N | allow-list | merge_cached_extra_translation_sources=False (extras not merged)",
                level=det,
            )

        if merge_cached_extra_translation_sources and extra_n > 0:
            net_new_distinct = d_after_merge - d_before_extras
            extras_overlap_prior = extra_n - net_new_distinct
            BuiltIn().log(
                "I18N | allow-list | how counts add up: "
                f"composite_str_entries: {n_before_extras} + {extra_n} synthetic extra keys = {n_after_merge}. "
                f"distinct_translation_values: {d_before_extras} (bundles+i18n) + {net_new_distinct} "
                f"net-new from extras = {d_after_merge}. "
                f"Of {extra_n} deduped extras, {extras_overlap_prior} matched a value already in bundles/i18n "
                f"(extra keys added, distinct count unchanged for those). "
                f"Within menu/DB cache only: {extra_raw_n} raw rows → {extra_n} deduped "
                f"({extra_raw_n - extra_n} collapsed).",
                level=det,
            )

        ign = self._normalize_ignore_string_patterns(ignore_string_patterns)
        if ignore_string_patterns is not None and not ign:
            BuiltIn().log(
                "I18N | WARN ignore_string_patterns was set but no usable patterns after normalize. "
                "Typical fixes: assign with ``${p}=  Create List  ^ZStore\\\\d+,\\\\s*Associate\\\\d+$`` "
                "(double backslashes in .robot); do not use ``VAR @{x}  ...`` when the regex contains a comma.",
                level="WARN",
            )
        elif ign:
            BuiltIn().log(f"I18N | ignore_string_patterns active ({len(ign)}): {ign!r}", level="INFO")

        try:
            merged_wl, wl_file_n, wl_inline_n, wl_cache_n = self._build_effective_text_whitelist(
                text_whitelist,
                text_whitelist_file,
                merge_cached=merge_cached_text_whitelist,
            )
        except OSError as ex:
            BuiltIn().log(f"I18N | ERROR text_whitelist_file: {ex}", level="ERROR")
            raise
        if merged_wl:
            BuiltIn().log(
                f"I18N | text_whitelist: {len(merged_wl)} unique literal(s) "
                f"(file_lines={wl_file_n}, inline_values={wl_inline_n}, cached_values={wl_cache_n}, "
                f"merge_cached={merge_cached_text_whitelist})",
                level="DEBUG",
            )

        report = analyze_visible_texts_against_flat_load(
            merged,
            coerced,
            strip=strip,
            case_sensitive=case_sensitive,
            dedupe=dedupe,
            skip_numeric_looking=skip_numeric_looking,
            try_date_suffix_relaxation=try_date_suffix_relaxation,
            include_page_i18n=include_page_i18n,
            page_i18n_distinct_values=i18n_distinct,
            bundle_scope=scope,
            bundles_dir=bd,
            locale=locale,
            strip_trailing_ratio_time=strip_trailing_ratio_time,
            ignore_string_patterns=ign,
            text_whitelist=merged_wl,
        )
        self._log_coverage_report(
            report,
            max_properties_files_to_log=max_properties_files_to_log,
            log_matched_preview_limit=log_matched_preview_limit,
            log_unmatched_dom_context=log_unmatched_dom_context,
            inventory_element_refs=getattr(self, "_inventory_element_refs", None),
            verbose=verbose_allow_list_logs,
        )

        if report.unmatched_texts:
            extras_note = ""
            # if merge_cached_extra_translation_sources and extra_n:
            #     extras_note = ", cached menu/DB extras"
            fail_tail = ". See log lines prefixed with 'I18N UNMATCHED' for the full list."
            # if log_unmatched_dom_context:
            #     fail_tail += " DOM hints were logged under 'I18N | dom_context' where available."
            # else:
            #     fail_tail += " Pass log_unmatched_dom_context=${True} to log truncated outerHTML for each unmatched string."
            unmatched_list = "\n".join(f"  - {text}" for text in report.unmatched_texts)
            BuiltIn().fail(
                f"{report.unique_unmatched} unique visible string(s) not found for locale {locale!r}"
                # + (" bundles or merged page i18n" if include_page_i18n else "")
                # + extras_note
                + fail_tail
                + f"\n\nUnmatched strings:\n{unmatched_list}"
            )

    @keyword("Dump Visible Text Check Result As Json")
    def dump_visible_text_check_result_as_json(
        self,
        locale: str,
        visible_texts: Any,
        *,
        bundles_dir: Optional[str] = None,
        include_page_i18n: bool = True,
        skip_numeric_looking: bool = True,
        try_date_suffix_relaxation: bool = True,
        strip_trailing_ratio_time: bool = False,
        ignore_string_patterns: Any = None,
        scope: str = "web",
        strip: bool = True,
        case_sensitive: bool = True,
        dedupe: bool = True,
        merge_cached_extra_translation_sources: bool = True,
        text_whitelist: Any = None,
        text_whitelist_file: str = "",
        merge_cached_text_whitelist: bool = True,
    ) -> str:
        """
        Return JSON diagnostics for visible-text coverage without failing the test.

        Uses the same merge and analysis rules as `Verify Visible Texts Against Locale Bundles`, but
        returns a serialized payload (stats, matched/unmatched lists, bundle warnings).

        | =Arguments= | =Description= |
        | locale | Locale to analyze. |
        | visible_texts | List from `Stop Visible Text Inventory And Return Texts` (pass ``${var}``). |
        | bundles_dir | Optional bundle root override; when omitted, same resolution as Verify. |
        | include_page_i18n | Merge page ``i18n`` when ``True``. Default ``True``. |
        | skip_numeric_looking | Skip digit-heavy strings and whole-string numeric dates when ``True``. Default ``True``. |
        | try_date_suffix_relaxation | Date-suffix relaxation when ``True``. Default ``True``. |
        | strip_trailing_ratio_time | Strip ratio/time suffix when ``True``. Default ``False``. |
        | ignore_string_patterns | Optional regex list (same as Verify). |
        | scope | Bundle scope. Default ``web``. |
        | strip | Strip before compare when ``True``. Default ``True``. |
        | case_sensitive | Case-sensitive when ``True``. Default ``True``. |
        | dedupe | Dedupe visible inputs when ``True``. Default ``True``. |
        | merge_cached_extra_translation_sources | Merge menu/DB cache when ``True``. Default ``True``. |
        | text_whitelist | Optional literal whitelist (same as Verify). |
        | text_whitelist_file | Optional whitelist file path (same as Verify). |
        | merge_cached_text_whitelist | Merge class-level cached whitelist (same as Verify). Default ``True``. |

        The JSON object includes ``unmatched_element_snippets`` when `Stop Visible Text Inventory And Return Texts`
        was used in the same test (map of unmatched string → truncated ``outerHTML`` list).

        | =Returns= | =Description= |
        | str | Pretty-printed JSON (UTF-8, ``ensure_ascii=False``). |

        Examples:
        | ${json}=    Dump Visible Text Check Result As Json    en_US    ${texts}
        | Log    ${json}
        """
        coerced = WebInternationalizationLibrary._coerce_visible_text_list(visible_texts)
        ign = WebInternationalizationLibrary._normalize_ignore_string_patterns(ignore_string_patterns)
        bd = self._resolve_bundles_dir_for_verify(bundles_dir)
        flat = self._get_cached_flat_bundle_load(bd, locale, scope=scope)
        i18n_vals: List[str] = []
        if include_page_i18n:
            try:
                i18n_vals = self.get_page_i18n_string_values()
            except Exception:
                i18n_vals = []
        merged = self._extend_flat_with_strings(flat, i18n_vals) if include_page_i18n else flat
        i18n_distinct = len(dict.fromkeys(i18n_vals)) if i18n_vals else 0
        d_before_extras = count_distinct_values_in_flat_load(merged, strip=strip, case_sensitive=case_sensitive)
        n_before_extras = self._flat_str_entry_count(merged)
        merged, extra_n, extra_raw_n = self._merge_cached_extra_strings_into_load(
            merged, use_extras=merge_cached_extra_translation_sources
        )
        d_after_merge = count_distinct_values_in_flat_load(merged, strip=strip, case_sensitive=case_sensitive)
        n_after_merge = self._flat_str_entry_count(merged)
        net_new_distinct = (d_after_merge - d_before_extras) if extra_n else 0
        extras_overlap_prior = (extra_n - net_new_distinct) if extra_n else 0
        try:
            merged_wl, _, _, _ = self._build_effective_text_whitelist(
                text_whitelist,
                text_whitelist_file,
                merge_cached=merge_cached_text_whitelist,
            )
        except OSError as ex:
            BuiltIn().log(f"I18N | ERROR text_whitelist_file: {ex}", level="ERROR")
            raise
        report = analyze_visible_texts_against_flat_load(
            merged,
            coerced,
            strip=strip,
            case_sensitive=case_sensitive,
            dedupe=dedupe,
            skip_numeric_looking=skip_numeric_looking,
            try_date_suffix_relaxation=try_date_suffix_relaxation,
            include_page_i18n=include_page_i18n,
            page_i18n_distinct_values=i18n_distinct,
            bundle_scope=scope,
            bundles_dir=bd,
            locale=locale,
            strip_trailing_ratio_time=strip_trailing_ratio_time,
            ignore_string_patterns=ign,
            text_whitelist=merged_wl,
        )
        lr = report.load_result
        inv_refs: Dict[str, List[str]] = getattr(self, "_inventory_element_refs", None) or {}
        unmatched_snippets = {
            t: inv_refs[t] for t in report.unmatched_texts if t in inv_refs and inv_refs[t]
        }
        payload = {
            "locale": locale,
            "bundles_dir": bd,
            "scope": scope,
            "include_page_i18n": include_page_i18n,
            "merge_cached_extra_translation_sources": merge_cached_extra_translation_sources,
            "stats": {
                "cached_extra_translation_strings_merged_deduped": extra_n,
                "cached_extra_translation_raw_cache_rows": extra_raw_n,
                "allow_list_composite_before_extras": n_before_extras,
                "allow_list_composite_after_extras": n_after_merge,
                "allow_list_distinct_before_extras": d_before_extras,
                "allow_list_distinct_after_extras": d_after_merge,
                "extras_net_new_distinct_vs_bundles_i18n": net_new_distinct,
                "extras_overlapping_existing_allow_list": extras_overlap_prior,
                "raw_visible": report.total_input_strings,
                "empty_skipped": report.skipped_empty,
                "ratio_suffix_preprocess_changed": report.ratio_suffix_preprocess_changed,
                "numeric_time_and_date_literal_noise_filtered_out": report.numeric_filtered_out,
                "user_regex_filtered_out": report.user_regex_filtered_out,
                "whitelist_skipped": report.whitelist_filtered_out,
                "whitelist_skipped_distinct": len(report.whitelist_skipped_unique_texts),
                "unique_checked": report.unique_checked,
                "unique_matched": report.unique_matched,
                "unique_unmatched": report.unique_unmatched,
                "matched_via_date_suffix_relaxation": report.matched_via_date_suffix_relaxation,
                "known_translation_values": report.known_translation_values,
                "page_i18n_distinct_merged": report.page_i18n_distinct_values,
                "properties_files_loaded": report.bundle_properties_files_loaded,
                "ignore_pattern_errors": report.ignore_pattern_errors,
            },
            "whitelist_skipped_unique_texts": report.whitelist_skipped_unique_texts,
            "unmatched_visible_texts": report.unmatched_texts,
            "unmatched_element_snippets": unmatched_snippets,
            "matched_visible_texts": report.matched_texts,
            "bundle_warnings": list(getattr(lr, "warnings", []) or []),
            "bundle_errors": list(getattr(lr, "errors", []) or []),
            "properties_files": [
                p
                for p in (getattr(lr, "files_loaded", None) or [])
                if isinstance(p, str) and p.lower().endswith(".properties")
            ],
        }
        return json.dumps(payload, ensure_ascii=False, indent=2)
