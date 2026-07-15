/**
 * Customer-facing labels, test name parsing, and executive health helpers.
 */
const CUSTOMER_LABELS_URL = "data/customer-labels.json";

let customerLabelsCache = null;

const defaultCustomerLabels = () => ({
  environments: {},
  runTypes: {
    sanity: {
      toggleLabel: "BAT",
      customerLabel: "BAT (Build acceptance)",
      scope: "Core build acceptance and regression tests",
      internalName: "Sanity",
    },
    sit: {
      toggleLabel: "Release validation",
      customerLabel: "Release validation (SIT)",
      scope: "System integration and release validation",
      internalName: "SIT",
    },
  },
  metrics: {
    successRate: {
      label: "Success rate",
      definition: "Success rate = (passed + skipped) ÷ total tests.",
    },
    passRate: {
      label: "Pass rate",
      definition: "Pass rate = passed ÷ (total − skipped).",
    },
    skipRate: {
      label: "Skip rate",
      definition: "Skip rate = skipped ÷ total tests.",
    },
  },
  thresholds: { good: 90, watch: 85 },
});

const loadCustomerLabels = async () => {
  if (customerLabelsCache) {
    return customerLabelsCache;
  }
  try {
    const response = await fetch(CUSTOMER_LABELS_URL);
    if (response.ok) {
      customerLabelsCache = { ...defaultCustomerLabels(), ...(await response.json()) };
      return customerLabelsCache;
    }
  } catch (error) {
    console.warn("Could not load customer-labels.json, using defaults.", error);
  }
  customerLabelsCache = defaultCustomerLabels();
  return customerLabelsCache;
};

const getCustomerLabels = () => customerLabelsCache || defaultCustomerLabels();

const getRunTypeCustomerMeta = (runType) => {
  const key = runType === RUN_TYPES.sit ? "sit" : "sanity";
  return getCustomerLabels().runTypes[key] || defaultCustomerLabels().runTypes[key];
};

const getEnvCustomerMeta = (envCode) => {
  const key = String(envCode || "").trim();
  const entry = getCustomerLabels().environments[key];
  if (entry) {
    return entry;
  }
  if (key.endsWith("_SIT") || key.endsWith("-SIT")) {
    return {
      displayName: key.replace(/_SIT$/i, "").replace(/-SIT$/i, "") + " — Release validation",
      region: key.split("_")[0],
      purpose: "System integration (SIT)",
    };
  }
  return {
    displayName: key.replace(/_/g, " "),
    region: key.split("_")[0] || key,
    purpose: "Build acceptance (BAT)",
  };
};

const getEnvDisplayName = (envCode) => getEnvCustomerMeta(envCode).displayName;

const getEnvDisplayWithCode = (envCode) => {
  const meta = getEnvCustomerMeta(envCode);
  if (meta.displayName === envCode) {
    return envCode;
  }
  return `${meta.displayName} (${envCode})`;
};

const parseTestDisplayName = (rawName) => {
  const name = String(rawName || "").trim();
  const idMatch = name.match(/^((?:BAT|SIT)TC\d+):\s*(.+)$/i);
  if (idMatch) {
    return {
      id: idMatch[1].toUpperCase(),
      title: idMatch[2].trim(),
      module: inferModuleFromTestName(idMatch[2]),
      full: name,
    };
  }
  return {
    id: "",
    title: name,
    module: inferModuleFromTestName(name),
    full: name,
  };
};

const inferModuleFromTestName = (text) => {
  const lowered = String(text || "").toLowerCase();
  if (lowered.includes("payroll")) return "Payroll";
  if (lowered.includes("timekeeping") || lowered.includes("clock")) return "Timekeeping";
  if (lowered.includes("schedule")) return "Scheduling";
  if (lowered.includes("ta ") || lowered.includes("time and attendance")) return "Time & Attendance";
  return "";
};

const applyRunTypeToggleLabels = () => {
  const sanityMeta = getRunTypeCustomerMeta(RUN_TYPES.sanity);
  const sitMeta = getRunTypeCustomerMeta(RUN_TYPES.sit);
  const sanityBtn = document.querySelector('[data-run-type="sanity"]');
  const sitBtn = document.querySelector('[data-run-type="sit"]');
  if (sanityBtn) {
    sanityBtn.textContent = sanityMeta.toggleLabel;
    sanityBtn.title = `${sanityMeta.customerLabel} — ${sanityMeta.scope}`;
  }
  if (sitBtn) {
    sitBtn.textContent = sitMeta.toggleLabel;
    sitBtn.title = `${sitMeta.customerLabel} — ${sitMeta.scope}`;
  }
  const runTypeBarLabel = document.querySelector(".run-type-bar__label");
  if (runTypeBarLabel) {
    runTypeBarLabel.textContent = "Test scope";
  }
};

const getMetricDefinition = (rateMode) => {
  const metrics = getCustomerLabels().metrics;
  if (rateMode === "pass") {
    return metrics.passRate;
  }
  return metrics.successRate;
};

const resolvePrimaryBuildVersion = (environments) => {
  const versions = Object.values(environments || {})
    .map((env) => env?.last_run?.app_version || env?.app_version || "")
    .filter((v) => v && v !== "Unknown");
  if (!versions.length) {
    return "Not available";
  }
  const counts = versions.reduce((acc, v) => {
    acc[v] = (acc[v] || 0) + 1;
    return acc;
  }, {});
  return Object.entries(counts).sort((a, b) => b[1] - a[1])[0][0];
};

const computeExecutiveHealth = (environments, rateMode) => {
  const thresholds = getCustomerLabels().thresholds || { good: 90, watch: 85 };
  const entries = Object.values(environments || {});
  const rates = entries.map((env) => {
    const lastRun = env.last_run || {};
    if (rateMode === "pass") {
      if (Number.isFinite(lastRun.pass_rate)) {
        return Number(lastRun.pass_rate);
      }
      const active = Number(lastRun.total || 0) - Number(lastRun.skipped || 0);
      return active > 0 ? (Number(lastRun.passed || 0) / active) * 100 : 0;
    }
    if (Number.isFinite(lastRun.success_rate)) {
      return Number(lastRun.success_rate);
    }
    const total = Number(lastRun.total || 0);
    return total > 0
      ? ((Number(lastRun.passed || 0) + Number(lastRun.skipped || 0)) / total) * 100
      : 0;
  });
  const failedTotal = entries.reduce((sum, env) => sum + Number(env?.last_run?.failed || 0), 0);
  const avgRate = rates.length ? rates.reduce((a, b) => a + b, 0) / rates.length : 0;
  const belowGood = rates.filter((r) => r < thresholds.good).length;
  const belowWatch = rates.filter((r) => r < thresholds.watch).length;

  let status = "healthy";
  if (belowWatch > 0) {
    status = "critical";
  } else if (belowGood > 0 || avgRate < thresholds.good) {
    status = "watch";
  }

  const rateLabel = rateMode === "pass" ? "pass" : "success";
  const envCount = entries.length;
  let headline = "";
  let detail = "";

  if (status === "healthy") {
    headline = `Healthy — ${avgRate.toFixed(1)}% average ${rateLabel} rate`;
    detail = `All ${envCount} environment${envCount === 1 ? "" : "s"} meet the ${thresholds.good}% quality target.`;
  } else if (status === "watch") {
    headline = `Watch — ${avgRate.toFixed(1)}% average ${rateLabel} rate`;
    detail =
      belowGood > 0
        ? `${belowGood} environment${belowGood === 1 ? "" : "s"} below ${thresholds.good}% ${rateLabel} rate. Review before release.`
        : `Overall ${rateLabel} rate is below the ${thresholds.good}% target.`;
  } else {
    headline = `At risk — ${avgRate.toFixed(1)}% average ${rateLabel} rate`;
    detail =
      belowWatch > 0
        ? `${belowWatch} environment${belowWatch === 1 ? "" : "s"} below ${thresholds.watch}%. ${failedTotal} failed test${failedTotal === 1 ? "" : "s"} in latest run.`
        : `${failedTotal} failed test${failedTotal === 1 ? "" : "s"} require attention.`;
  }

  return {
    status,
    headline,
    detail,
    avgRate,
    belowGood,
    belowWatch,
    failedTotal,
    envCount,
    rateLabel,
  };
};
