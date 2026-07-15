/**
 * Shared Sanity / SIT run-type helpers for dashboard pages.
 */
const RUN_TYPE_STORAGE_KEY = "dashboardRunTypeV2";
const RUN_TYPES = {
  sanity: "sanity",
  sit: "sit",
};

if (typeof window !== "undefined") {
  window.RUN_TYPES = RUN_TYPES;
  window.RUN_TYPE_STORAGE_KEY = RUN_TYPE_STORAGE_KEY;
}

const inferRunTypeFromEnvName = (envName) => {
  const normalized = String(envName || "").trim().toUpperCase();
  if (!normalized) {
    return RUN_TYPES.sanity;
  }
  if (normalized.endsWith("_SIT") || normalized.endsWith("-SIT")) {
    return RUN_TYPES.sit;
  }
  return RUN_TYPES.sanity;
};

const getEnvRunType = (envName, environments = {}) => {
  const key = String(envName || "").trim();
  const entry = environments[key] || {};
  return (
    entry.run_type ||
    entry.last_run?.run_type ||
    inferRunTypeFromEnvName(key)
  );
};

const getRunTypeFromUrl = () => {
  if (typeof window === "undefined") {
    return null;
  }
  const param = new URLSearchParams(window.location.search).get("run");
  if (param === RUN_TYPES.sit) {
    return RUN_TYPES.sit;
  }
  if (param === RUN_TYPES.sanity) {
    return RUN_TYPES.sanity;
  }
  return null;
};

const getStoredRunType = () => {
  const fromUrl = getRunTypeFromUrl();
  if (fromUrl) {
    return fromUrl;
  }
  const stored = localStorage.getItem(RUN_TYPE_STORAGE_KEY);
  return stored === RUN_TYPES.sit ? RUN_TYPES.sit : RUN_TYPES.sanity;
};

const setStoredRunType = (runType) => {
  localStorage.setItem(
    RUN_TYPE_STORAGE_KEY,
    runType === RUN_TYPES.sit ? RUN_TYPES.sit : RUN_TYPES.sanity
  );
};

const syncRunTypeToUrl = (runType) => {
  if (typeof window === "undefined") {
    return;
  }
  const url = new URL(window.location.href);
  if (runType === RUN_TYPES.sit) {
    url.searchParams.set("run", RUN_TYPES.sit);
  } else {
    url.searchParams.set("run", RUN_TYPES.sanity);
  }
  window.history.replaceState({}, "", url);
};

const filterEnvironmentMap = (environments, runType, environmentsMeta = environments) => {
  const entries = Object.entries(environments || {}).filter(([name, env]) => {
    const envName = String(env?.env || name || "").trim();
    return getEnvRunType(envName, environmentsMeta) === runType;
  });
  return Object.fromEntries(entries);
};

const filterEnvHistoryByRunType = (envHistory, runType, environmentsMeta = {}) => {
  const envs = envHistory?.environments || {};
  const filtered = Object.fromEntries(
    Object.entries(envs).filter(([name]) => getEnvRunType(name, environmentsMeta) === runType)
  );
  return { ...envHistory, environments: filtered };
};

const normalizeHistoryForRunType = (historyData, runType) => {
  const payload = historyData && typeof historyData === "object" ? historyData : {};
  if (payload.sanity || payload.sit) {
    return {
      updated_at: payload.updated_at || "",
      runs: Array.isArray(payload[runType]?.runs) ? payload[runType].runs : [],
    };
  }
  const runs = Array.isArray(payload.runs) ? payload.runs : [];
  return {
    updated_at: payload.updated_at || "",
    runs: runs.filter((run) => (run?.run_type || RUN_TYPES.sanity) === runType),
  };
};

const bindRunTypeToggle = (onChange) => {
  const buttons = document.querySelectorAll("[data-run-type]");
  if (!buttons.length) {
    return;
  }

  const applyActiveState = (activeType) => {
    buttons.forEach((button) => {
      const isActive = button.dataset.runType === activeType;
      button.classList.toggle("active", isActive);
      button.setAttribute("aria-pressed", isActive ? "true" : "false");
    });
  };

  const initial = getStoredRunType();
  applyActiveState(initial);

  buttons.forEach((button) => {
    button.addEventListener("click", () => {
      const nextType =
        button.dataset.runType === RUN_TYPES.sit ? RUN_TYPES.sit : RUN_TYPES.sanity;
      setStoredRunType(nextType);
      syncRunTypeToUrl(nextType);
      applyActiveState(nextType);
      if (typeof onChange === "function") {
        onChange(nextType);
      }
    });
  });
};
