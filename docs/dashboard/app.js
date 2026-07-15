const ENVIRONMENTS_URL = "data/environments.json";
const HISTORY_URL = "data/history.json";
const ENV_HISTORY_URL = "data/env_history.json";
const TEST_RESULTS_URL = "data/test_results.json";
const EXCLUDED_ENVS_URL = "excluded_envs.json";

const RATE_MODE_KEY = "rateMode";
const getSummarySelectionKey = (runType) =>
  `summarySelectedEnvironments:${runType === RUN_TYPES.sit ? RUN_TYPES.sit : RUN_TYPES.sanity}`;
const SUMMARY_SELECTION_KEY = "summarySelectedEnvironments";
const RATE_MODES = {
  success: "success",
  pass: "pass",
};

const showToast = (message, type = "info", duration = 4000) => {
  const container = document.getElementById("toast-container");
  if (!container) {
    return;
  }

  const toast = document.createElement("div");
  toast.className = `toast ${type}`;

  const icons = {
    info: "ℹ️",
    warning: "⚠️",
    error: "❌",
    success: "✅",
  };

  toast.innerHTML = `
    <span class="toast-icon">${icons[type] || icons.info}</span>
    <div class="toast-message">${message}</div>
    <button class="toast-close" aria-label="Close">×</button>
  `;

  container.appendChild(toast);

  const closeBtn = toast.querySelector(".toast-close");
  const closeToast = () => {
    toast.style.animation = "slideIn 0.3s ease reverse";
    setTimeout(() => {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast);
      }
    }, 300);
  };

  closeBtn.addEventListener("click", closeToast);

  if (duration > 0) {
    setTimeout(closeToast, duration);
  }
};

const formatNumber = (value) => {
  const numeric = Number(value);
  if (!Number.isFinite(numeric)) {
    return "-";
  }
  return numeric.toLocaleString("en-US");
};

const formatPercent = (value) => {
  const numeric = Number(value);
  if (!Number.isFinite(numeric)) {
    return "-";
  }
  return `${numeric.toFixed(1)}%`;
};

const formatAppVersion = (value) => {
  const raw = String(value || "").trim();
  if (!raw) {
    return "-";
  }
  const parts = raw.split(".");
  if (parts.length <= 1) {
    return raw;
  }
  return parts.slice(0, -1).join(".");
};

const computeRate = (numerator, denominator) => {
  const total = Number(denominator || 0);
  if (!total) {
    return 0;
  }
  return (Number(numerator || 0) / total) * 100;
};

const computePassFailRate = (numerator, total, skipped) => {
  // Pass/Fail rate excludes skipped tests: rate = value / (total - skipped)
  const activeTests = Number(total || 0) - Number(skipped || 0);
  if (activeTests <= 0) {
    return 0;
  }
  return (Number(numerator || 0) / activeTests) * 100;
};

const computeSuccessRate = (passed, skipped, total) =>
  computeRate(Number(passed || 0) + Number(skipped || 0), total);

const deriveSuccessRateFromRates = (passRate, skipRate) => {
  const pass = Number(passRate || 0);
  const skip = Number(skipRate || 0);
  if (!Number.isFinite(pass) || !Number.isFinite(skip)) {
    return 0;
  }
  return pass * (1 - skip / 100) + skip;
};

const formatTimestamp = (value, options = {}) => {
  if (!value) {
    return "Unknown";
  }
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return value;
  }
  
  // Default format includes timezone for consistency
  const defaultOptions = {
    month: "short",
    day: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    timeZoneName: "short",
  };
  
  return date.toLocaleString("en-US", { ...defaultOptions, ...options });
};

const safeList = (value) => (Array.isArray(value) ? value : []);

const safeObject = (value) => (value && typeof value === "object" ? value : {});

const normalizeEnvName = (value) => String(value || "").trim();

const getRateMode = () => localStorage.getItem(RATE_MODE_KEY) || RATE_MODES.success;

const setRateMode = (mode) => {
  localStorage.setItem(RATE_MODE_KEY, mode);
};

const getStoredSummarySelection = (runType = RUN_TYPES.sanity) => {
  const storageKey = getSummarySelectionKey(runType);
  const stored = localStorage.getItem(storageKey) ?? localStorage.getItem(SUMMARY_SELECTION_KEY);
  if (!stored) {
    return null;
  }
  try {
    const parsed = JSON.parse(stored);
    return Array.isArray(parsed) ? parsed : null;
  } catch (error) {
    return null;
  }
};

const setStoredSummarySelection = (envs, runType = RUN_TYPES.sanity) => {
  const payload = JSON.stringify(envs);
  localStorage.setItem(getSummarySelectionKey(runType), payload);
  localStorage.setItem(SUMMARY_SELECTION_KEY, payload);
};

const getPassRateFromRun = (run) =>
  Number.isFinite(run.pass_rate)
    ? Number(run.pass_rate)
    : computePassFailRate(run.passed, run.total, run.skipped);

const getFailRateFromRun = (run) =>
  Number.isFinite(run.fail_rate)
    ? Number(run.fail_rate)
    : computePassFailRate(run.failed, run.total, run.skipped);

const getSkipRateFromRun = (run) =>
  Number.isFinite(run.skip_rate)
    ? Number(run.skip_rate)
    : computeRate(run.skipped, run.total);

const getSuccessRateFromRun = (run) => {
  if (Number.isFinite(run.success_rate)) {
    return Number(run.success_rate);
  }
  if (run.total !== undefined) {
    return computeSuccessRate(run.passed, run.skipped, run.total);
  }
  const passRate = getPassRateFromRun(run);
  const skipRate = getSkipRateFromRun(run);
  return deriveSuccessRateFromRates(passRate, skipRate);
};

const getPrimaryRateFromRun = (run, rateMode) =>
  rateMode === RATE_MODES.success ? getSuccessRateFromRun(run) : getPassRateFromRun(run);

const filterEnvironments = (environments, excludedEnvs) => {
  const entries = Object.entries(safeObject(environments)).filter(
    ([name, env]) => {
      const envName = normalizeEnvName(env.env || name);
      return !excludedEnvs.has(envName);
    }
  );
  return Object.fromEntries(entries);
};

const filterEnvHistory = (envHistory, excludedEnvs) => {
  const envs = safeObject(envHistory.environments);
  const filtered = Object.fromEntries(
    Object.entries(envs).filter(([name]) => !excludedEnvs.has(normalizeEnvName(name)))
  );
  return { ...envHistory, environments: filtered };
};

const filterEnvironmentsBySelection = (environments, selectedEnvs) => {
  const entries = Object.entries(safeObject(environments)).filter(([name, env]) => {
    const envName = normalizeEnvName(env.env || name);
    return selectedEnvs.has(envName);
  });
  return Object.fromEntries(entries);
};

const filterEnvHistoryBySelection = (envHistory, selectedEnvs) => {
  const envs = safeObject(envHistory.environments);
  const filtered = Object.fromEntries(
    Object.entries(envs).filter(([name]) => selectedEnvs.has(normalizeEnvName(name)))
  );
  return { ...envHistory, environments: filtered };
};

const getEnvironmentNames = (environments) => {
  const names = Object.entries(safeObject(environments))
    .map(([name, env]) => normalizeEnvName(env.env || name))
    .filter(Boolean);
  return Array.from(new Set(names)).sort();
};

const resolveSummarySelection = (environments, excludedEnvs, runType = RUN_TYPES.sanity) => {
  const envNames = getEnvironmentNames(environments);
  const stored = getStoredSummarySelection(runType);
  if (stored === null) {
    const defaultSelection = envNames.filter((name) => !excludedEnvs.has(name));
    setStoredSummarySelection(defaultSelection, runType);
    return defaultSelection;
  }

  const allowed = new Set(envNames);
  const normalized = stored
    .map((name) => normalizeEnvName(name))
    .filter((name) => name && allowed.has(name));
  const uniqueSelection =
    normalized.length > 0
      ? Array.from(new Set(normalized))
      : envNames.filter((name) => !excludedEnvs.has(name));
  setStoredSummarySelection(uniqueSelection, runType);
  return uniqueSelection;
};

const calculate7RunAverages = (runs) => {
  // Get the last 7 runs
  const last7Runs = safeList(runs).slice(-7);
  if (last7Runs.length === 0) {
    return {
      passRate: 0,
      failRate: 0,
      skipRate: 0,
      successRate: 0,
    };
  }

  let totalPass = 0;
  let totalFail = 0;
  let totalSkip = 0;
  let totalSuccess = 0;

  last7Runs.forEach((run) => {
    totalPass += getPassRateFromRun(run);
    totalFail += getFailRateFromRun(run);
    totalSkip += getSkipRateFromRun(run);
    totalSuccess += getSuccessRateFromRun(run);
  });

  return {
    passRate: totalPass / last7Runs.length,
    failRate: totalFail / last7Runs.length,
    skipRate: totalSkip / last7Runs.length,
    successRate: totalSuccess / last7Runs.length,
  };
};

const findBestWorstEnvironments = (environments, metricType) => {
  // metricType: 'pass_rate', 'fail_rate', 'skip_rate'
  let bestEnv = null;
  let bestValue = -Infinity;
  let worstEnv = null;
  let worstValue = Infinity;

  Object.values(environments).forEach((env) => {
    const lastRun = env.last_run || {};
    let value = 0;
    if (metricType === "success_rate") {
      value = getSuccessRateFromRun(lastRun);
    } else if (metricType === "pass_rate") {
      value = getPassRateFromRun(lastRun);
    } else if (metricType === "fail_rate") {
      value = getFailRateFromRun(lastRun);
    } else if (metricType === "skip_rate") {
      value = getSkipRateFromRun(lastRun);
    } else {
      value = Number(lastRun[metricType] || 0);
    }

    if (value > bestValue) {
      bestValue = value;
      bestEnv = env.env || "Unknown";
    }
    if (value < worstValue) {
      worstValue = value;
      worstEnv = env.env || "Unknown";
    }
  });

  return {
    best: { env: bestEnv, value: bestValue },
    worst: { env: worstEnv, value: worstValue },
  };
};

const aggregateLatest = (environments) => {
  const totals = {
    total: 0,
    passed: 0,
    failed: 0,
    skipped: 0,
  };
  let envCount = 0;

  Object.values(environments).forEach((env) => {
    const lastRun = env.last_run || {};
    if (lastRun.total !== undefined) {
      envCount += 1;
    }
    totals.total += Number(lastRun.total || 0);
    totals.passed += Number(lastRun.passed || 0);
    totals.failed += Number(lastRun.failed || 0);
    totals.skipped += Number(lastRun.skipped || 0);
  });

  const passRate = computePassFailRate(totals.passed, totals.total, totals.skipped);
  const failRate = computePassFailRate(totals.failed, totals.total, totals.skipped);
  const skipRate = computeRate(totals.skipped, totals.total);
  const successRate = computeSuccessRate(totals.passed, totals.skipped, totals.total);

  return {
    ...totals,
    envCount,
    passRate,
    failRate,
    skipRate,
    successRate,
  };
};

const setText = (id, value) => {
  const target = document.getElementById(id);
  if (target) {
    target.textContent = value;
  }
};

const chartEnvLabel = (envCode) => getEnvDisplayName(envCode);

const createEnvNameCell = (envCode) => {
  const td = document.createElement("td");
  td.className = "env-name-cell";
  const meta = getEnvCustomerMeta(envCode);
  const primary = document.createElement("span");
  primary.className = "env-name-cell__primary";
  primary.textContent = meta.displayName;
  td.appendChild(primary);
  if (meta.displayName !== envCode) {
    const code = document.createElement("span");
    code.className = "env-name-cell__code";
    code.textContent = envCode;
    td.title = `${meta.region} · ${meta.purpose}`;
    td.appendChild(code);
  }
  return td;
};

const renderMetricDefinitionBar = (rateMode) => {
  const metric = getMetricDefinition(rateMode);
  setText("metric-mode-label", metric.label);
  setText("metric-definition-text", metric.definition);
  const toggleLabel = document.getElementById("rate-toggle-label");
  if (toggleLabel) {
    toggleLabel.textContent = metric.label;
  }
};

const formatOptionalPercent = (value) =>
  Number.isFinite(value) ? formatPercent(value) : "—";

const renderSummary = (environments, updatedAt, summaryMeta = {}, testResults = {}) => {
  const aggregate = aggregateLatest(environments);
  const platform = aggregatePlatformMetrics(testResults, environments);
  const runMeta = getRunTypeCustomerMeta(summaryMeta.runType);
  let envLabel = `Across ${aggregate.envCount} environment${aggregate.envCount === 1 ? "" : "s"} (${runMeta.toggleLabel})`;
  const selectedCount = Number(summaryMeta.selectedEnvCount);
  const totalCount = Number(summaryMeta.totalEnvCount);
  if (Number.isFinite(selectedCount) && Number.isFinite(totalCount) && totalCount > 0) {
    envLabel = selectedCount === totalCount
      ? `Across ${totalCount} environment${totalCount === 1 ? "" : "s"} (${runMeta.toggleLabel})`
      : `Across ${selectedCount} of ${totalCount} environments (${runMeta.toggleLabel})`;
  }

  setText("total-tests", formatNumber(aggregate.total));
  setText("passed-tests", formatNumber(aggregate.passed));
  setText("failed-tests", formatNumber(aggregate.failed));
  setText("skipped-tests", formatNumber(aggregate.skipped));
  setText("avg-pass-rate", formatPercent(aggregate.passRate));
  setText("avg-success-rate", formatPercent(aggregate.successRate));
  setText("avg-success-rate-web", formatOptionalPercent(platform.web.successRate));
  setText("avg-success-rate-mobile", formatOptionalPercent(platform.mobile.successRate));
  setText("avg-fail-rate", formatPercent(aggregate.failRate));
  setText("avg-skip-rate", formatPercent(aggregate.skipRate));
  setText("avg-skip-rate-web", formatOptionalPercent(platform.web.skipRate));
  setText("avg-skip-rate-mobile", formatOptionalPercent(platform.mobile.skipRate));
  setText("last-updated", formatTimestamp(updatedAt));
  setText("total-sub", envLabel);
};

const setTrend = (id, delta) => {
  const target = document.getElementById(id);
  if (!target || !Number.isFinite(delta)) {
    return;
  }
  
  let displayText;
  if (delta === 0) {
    displayText = "→ 0.0%";
  } else {
    const direction = delta > 0 ? "up" : "down";
    const value = Math.abs(delta).toFixed(1);
    displayText = `${direction} ${value}%`;
  }
  
  target.textContent = displayText;
  target.classList.remove("up", "down");
  
  if (delta > 0) {
    target.classList.add("up");
  } else if (delta < 0) {
    target.classList.add("down");
  }
};

const ENV_TREND_METRIC_KEY = "envTrendMetric";
const ENV_TREND_METRICS = {
  primary: "primary",
  fail: "fail",
  skip: "skip",
};

const envTrendRenderContext = {
  envHistory: { environments: {} },
  rateMode: RATE_MODES.success,
  runType: RUN_TYPES.sanity,
};

const getActiveEnvTrendMetric = () => {
  const stored = localStorage.getItem(ENV_TREND_METRIC_KEY);
  if (stored === ENV_TREND_METRICS.fail || stored === ENV_TREND_METRICS.skip) {
    return stored;
  }
  return ENV_TREND_METRICS.primary;
};

const setActiveEnvTrendMetric = (metric) => {
  localStorage.setItem(ENV_TREND_METRIC_KEY, metric);
};

const updateEnvMetricTabLabels = (rateMode) => {
  const primaryTab = document.getElementById("env-metric-primary");
  const failTab = document.getElementById("env-metric-fail");
  const skipTab = document.getElementById("env-metric-skip");

  if (primaryTab) {
    primaryTab.textContent = rateMode === RATE_MODES.success ? "Success" : "Pass";
  }
  if (failTab) {
    const hideFail = rateMode === RATE_MODES.success;
    failTab.classList.toggle("is-hidden", hideFail);
    if (hideFail && getActiveEnvTrendMetric() === ENV_TREND_METRICS.fail) {
      setActiveEnvTrendMetric(ENV_TREND_METRICS.primary);
      document
        .querySelectorAll("[data-env-metric]")
        .forEach((button) => {
          const isPrimary = button.dataset.envMetric === ENV_TREND_METRICS.primary;
          button.classList.toggle("active", isPrimary);
          button.setAttribute("aria-selected", isPrimary ? "true" : "false");
        });
    }
  }
  if (skipTab) {
    skipTab.textContent = "Skip";
  }

  const activeMetric = getActiveEnvTrendMetric();
  document.querySelectorAll("[data-env-metric]").forEach((button) => {
    if (button.classList.contains("is-hidden")) {
      return;
    }
    const isActive = button.dataset.envMetric === activeMetric;
    button.classList.toggle("active", isActive);
    button.setAttribute("aria-selected", isActive ? "true" : "false");
  });
};

let envMetricTabsBound = false;

const bindEnvMetricTabs = () => {
  if (envMetricTabsBound) {
    return;
  }

  const tabs = document.querySelectorAll("[data-env-metric]");
  if (!tabs.length) {
    return;
  }

  envMetricTabsBound = true;
  tabs.forEach((tab) => {
    tab.addEventListener("click", () => {
      const metric = tab.dataset.envMetric;
      if (!metric) {
        return;
      }

      setActiveEnvTrendMetric(metric);
      tabs.forEach((button) => {
        const isActive = button.dataset.envMetric === metric;
        button.classList.toggle("active", isActive);
        button.setAttribute("aria-selected", isActive ? "true" : "false");
      });

      const { envHistory, rateMode, runType } = envTrendRenderContext;
      renderEnvironmentTrends(envHistory, rateMode, runType);
    });
  });
};

const createTrendCountsChart = (labels, series) => {
  const ctx = document.getElementById("trend-counts");
  if (!ctx) {
    return;
  }

  if (window.trendCountsChart) {
    window.trendCountsChart.destroy();
  }

  const datasets = [
    buildStackedBarDataset(
      "Passed",
      series.passed,
      CHART_COLORS.passDark,
      CHART_COLORS.passLight
    ),
    buildStackedBarDataset(
      "Failed",
      series.failed,
      CHART_COLORS.failDark,
      CHART_COLORS.failLight
    ),
    buildStackedBarDataset(
      "Skipped",
      series.skipped,
      CHART_COLORS.skipDark,
      CHART_COLORS.skipLight
    ),
  ];

  window.trendCountsChart = new Chart(ctx, {
    type: "bar",
    data: {
      labels,
      datasets,
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      interaction: getChartInteractionDefaults(),
      plugins: {
        legend: getChartLegendDefaults("top"),
        tooltip: {
          callbacks: {
            label: getCountTooltipLabel,
          },
        },
      },
      scales: {
        y: getValueScaleDefaults({ stacked: true }),
        x: {
          ...getCategoryScaleDefaults(),
          stacked: true,
        },
      },
    },
  });
};

const createEnvironmentRankingChart = (rows, rateMode) => {
  const ctx = document.getElementById("env-ranking");
  if (!ctx || !rows.length) {
    return;
  }

  if (window.envRankingChart) {
    window.envRankingChart.destroy();
    window.envRankingChart = null;
  }

  const metricLabel = rateMode === RATE_MODES.success ? "Success Rate" : "Pass Rate";
  const labels = rows.map((row) => chartEnvLabel(row.env));
  const values = rows.map((row) => row.rate);
  const barHeight = 34;
  const chartHeight = Math.max(280, rows.length * barHeight);
  ctx.height = chartHeight;

  window.envRankingChart = new Chart(ctx, {
    type: "bar",
    data: {
      labels,
      datasets: [
        {
          label: metricLabel,
          data: values,
          borderRadius: 10,
          borderSkipped: false,
          borderWidth: 0,
          backgroundColor: (context) => {
            const { chart, dataIndex } = context;
            const { ctx: canvasCtx, chartArea } = chart;
            const rate = dataIndex === undefined ? 0 : values[dataIndex];
            const tierColor = getRateTierColor(rate);
            if (!chartArea) {
              return tierColor;
            }
            const dark =
              tierColor === CHART_COLORS.pass
                ? CHART_COLORS.passDark
                : tierColor === CHART_COLORS.skip
                  ? CHART_COLORS.skipDark
                  : CHART_COLORS.failDark;
            const light =
              tierColor === CHART_COLORS.pass
                ? CHART_COLORS.passLight
                : tierColor === CHART_COLORS.skip
                  ? CHART_COLORS.skipLight
                  : CHART_COLORS.failLight;
            return createHorizontalBarGradient(canvasCtx, chartArea, dark, light);
          },
          hoverBackgroundColor: values.map((rate) => getRateTierColor(rate)),
        },
      ],
    },
    options: {
      indexAxis: "y",
      responsive: true,
      maintainAspectRatio: false,
      interaction: getChartInteractionDefaults(),
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            label: getPercentTooltipLabel,
            afterBody: getRankingTooltipAfterBody(rows),
          },
        },
      },
      scales: {
        x: getValueScaleDefaults({ percentage: true, max: 100 }),
        y: getCategoryScaleDefaults(),
      },
    },
  });
};

const createEnvironmentStackedChart = (labels, series) => {
  const ctx = document.getElementById("env-stacked");
  if (!ctx) {
    return;
  }

  if (window.envStackedChart) {
    window.envStackedChart.destroy();
    window.envStackedChart = null;
  }

  const numEnvs = labels.length;
  const barHeight = 36;
  const chartHeight = Math.max(320, numEnvs * barHeight);
  ctx.height = chartHeight;

  const datasets = [
    buildStackedBarDataset(
      "Passed",
      series.passed,
      CHART_COLORS.passDark,
      CHART_COLORS.passLight
    ),
    buildStackedBarDataset(
      "Failed",
      series.failed,
      CHART_COLORS.failDark,
      CHART_COLORS.failLight
    ),
    buildStackedBarDataset(
      "Skipped",
      series.skipped,
      CHART_COLORS.skipDark,
      CHART_COLORS.skipLight
    ),
  ];

  window.envStackedChart = new Chart(ctx, {
    type: "bar",
    data: {
      labels,
      datasets,
    },
    options: {
      indexAxis: "y",
      responsive: true,
      maintainAspectRatio: false,
      interaction: getChartInteractionDefaults(),
      plugins: {
        legend: getChartLegendDefaults("top"),
        tooltip: {
          callbacks: {
            label: getCountTooltipLabel,
          },
        },
      },
      scales: {
        x: {
          ...getValueScaleDefaults({ stacked: true }),
          stacked: true,
        },
        y: getCategoryScaleDefaults(),
      },
    },
  });
};

const createEnvironmentTrendChart = (labels, datasets, chartOptions = {}) => {
  const ctx = document.getElementById("env-trend");
  if (!ctx) {
    return;
  }

  if (window.envTrendChart) {
    window.envTrendChart.destroy();
  }

  const { useThreshold = true } = chartOptions;

  window.envTrendChart = new Chart(ctx, {
    type: "line",
    data: {
      labels,
      datasets,
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      interaction: getChartInteractionDefaults(),
      plugins: {
        legend: getChartLegendDefaults("bottom"),
        ...(useThreshold ? { thresholdShading: getThresholdPluginOptions() } : {}),
        tooltip: {
          callbacks: {
            label: getPercentTooltipLabel,
          },
        },
      },
      scales: {
        y: getValueScaleDefaults({ percentage: true, max: 100 }),
        x: getCategoryScaleDefaults(),
      },
    },
  });
};

const buildEnvironmentRows = (environments, testResults = {}) => {
  const rows = Object.entries(environments).map(([name, env]) => {
    const lastRun = env.last_run || {};
    const envName = normalizeEnvName(env.env || name) || "Unknown";
    const passRate = getPassRateFromRun(lastRun);
    const failRate = getFailRateFromRun(lastRun);
    const skipRate = getSkipRateFromRun(lastRun);
    const successRate = getSuccessRateFromRun(lastRun);
    const appVersion = lastRun.app_version || env.app_version || "";
    const platformRates = computePlatformSuccessRates(testResults, envName);

    return {
      env: envName,
      appVersion,
      appVersionDisplay: formatAppVersion(appVersion),
      lastRun: formatTimestamp(lastRun.timestamp),
      total: Number(lastRun.total || 0),
      passed: Number(lastRun.passed || 0),
      failed: Number(lastRun.failed || 0),
      skipped: Number(lastRun.skipped || 0),
      passRate,
      failRate,
      skipRate,
      successRate,
      webSuccessRate: platformRates.webSuccessRate,
      mobileSuccessRate: platformRates.mobileSuccessRate,
      webTestCount: platformRates.webTestCount,
      mobileTestCount: platformRates.mobileTestCount,
    };
  });

  rows.sort((a, b) => a.env.localeCompare(b.env));
  return rows;
};

const getRateDeltaForEnv = (envHistory, envName, rateMode) => {
  const runs = safeList(safeObject(envHistory.environments)[envName]);
  if (runs.length < 2) {
    return null;
  }

  const sorted = runs
    .filter((run) => run.timestamp)
    .slice()
    .sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
  if (sorted.length < 2) {
    return null;
  }

  const latest = sorted[sorted.length - 1];
  const previous = sorted[sorted.length - 2];
  return getPrimaryRateFromRun(latest, rateMode) - getPrimaryRateFromRun(previous, rateMode);
};

const classifyTestPlatform = (tags) => {
  const normalized = new Set(
    safeList(tags)
      .map((tag) => String(tag || "").trim().toLowerCase())
      .filter(Boolean)
  );
  if (normalized.has("mobile")) {
    return "mobile";
  }
  return "web";
};

const accumulatePlatformBucket = (bucket, statusCode) => {
  bucket.total += 1;
  if (statusCode === 1) {
    bucket.passed += 1;
  } else if (statusCode === 2) {
    bucket.skipped += 1;
  } else {
    bucket.failed += 1;
  }
};

const aggregatePlatformMetrics = (testResults, environments) => {
  const envNames = new Set(getEnvironmentNames(environments));
  const buckets = {
    web: { passed: 0, failed: 0, skipped: 0, total: 0 },
    mobile: { passed: 0, failed: 0, skipped: 0, total: 0 },
  };

  Object.values(safeObject(testResults)).forEach((envMap) => {
    Object.entries(safeObject(envMap)).forEach(([envName, envData]) => {
      if (!envNames.has(normalizeEnvName(envName))) {
        return;
      }
      const history = safeList(envData?.history);
      if (!history.length) {
        return;
      }
      const statusCode = Number(history[history.length - 1]);
      const platform = classifyTestPlatform(envData?.details?.tags || []);
      accumulatePlatformBucket(buckets[platform], statusCode);
    });
  });

  const toRates = (bucket) => ({
    successRate:
      bucket.total > 0
        ? computeSuccessRate(bucket.passed, bucket.skipped, bucket.total)
        : null,
    skipRate: bucket.total > 0 ? computeRate(bucket.skipped, bucket.total) : null,
  });

  return {
    web: toRates(buckets.web),
    mobile: toRates(buckets.mobile),
  };
};

const computePlatformSuccessRates = (testResults, envName) => {
  const buckets = {
    web: { passed: 0, failed: 0, skipped: 0, total: 0 },
    mobile: { passed: 0, failed: 0, skipped: 0, total: 0 },
  };

  Object.values(safeObject(testResults)).forEach((envMap) => {
    const envData = safeObject(envMap)[envName];
    const history = safeList(envData?.history);
    if (!history.length) {
      return;
    }

    const statusCode = Number(history[history.length - 1]);
    const tags = envData?.details?.tags || [];
    const platform = classifyTestPlatform(tags);
    accumulatePlatformBucket(buckets[platform], statusCode);
  });

  const toSuccessRate = (bucket) =>
    bucket.total > 0
      ? computeSuccessRate(bucket.passed, bucket.skipped, bucket.total)
      : null;

  return {
    webSuccessRate: toSuccessRate(buckets.web),
    mobileSuccessRate: toSuccessRate(buckets.mobile),
    webTestCount: buckets.web.total,
    mobileTestCount: buckets.mobile.total,
  };
};

const formatPlatformRateCell = (rate, count, platformLabel) => {
  if (!count || !Number.isFinite(rate)) {
    return { text: "—", title: `No ${platformLabel} tests in latest run` };
  }
  return {
    text: formatPercent(rate),
    title: `${count} ${platformLabel} test${count === 1 ? "" : "s"} · success rate = (passed + skipped) ÷ total`,
  };
};

const renderEnvironmentTable = (
  environments,
  envHistory,
  rateMode,
  summarySelection,
  onSelectionChange,
  testResults = {}
) => {
  const tbody = document.getElementById("env-table");
  if (!tbody) {
    return;
  }

  const rows = buildEnvironmentRows(environments, testResults).map((row) => {
    const primaryRate = rateMode === RATE_MODES.success ? row.successRate : row.passRate;
    const delta = getRateDeltaForEnv(envHistory, row.env, rateMode);
    return {
      ...row,
      primaryRate,
      primaryDelta: delta,
    };
  });

  const rateHeader = document.getElementById("rate-header");
  if (rateHeader && rateHeader.firstChild) {
    rateHeader.firstChild.textContent =
      rateMode === RATE_MODES.success ? "Success Rate " : "Pass Rate ";
  }

  // Store rows for sorting
  let sortedRows = [...rows];
  let currentSort = { column: null, direction: "asc" };

  const renderRows = () => {
    tbody.innerHTML = "";

    sortedRows.forEach((row) => {
      const tr = document.createElement("tr");

      const selectionCell = document.createElement("td");
      selectionCell.className = "summary-select";

      const checkbox = document.createElement("input");
      checkbox.type = "checkbox";
      checkbox.checked = summarySelection.has(row.env);
      checkbox.setAttribute("aria-label", `Include ${row.env} in summary`);
      checkbox.addEventListener("change", () => {
        if (checkbox.checked) {
          summarySelection.add(row.env);
        } else {
          summarySelection.delete(row.env);
        }
        if (typeof onSelectionChange === "function") {
          onSelectionChange(Array.from(summarySelection));
        }
      });

      selectionCell.appendChild(checkbox);
      tr.appendChild(selectionCell);

      const createCell = (text, className = "") => {
        const td = document.createElement("td");
        td.textContent = text;
        if (className) {
          td.className = className;
        }
        return td;
      };

      tr.appendChild(createEnvNameCell(row.env));
      tr.appendChild(createCell(row.appVersionDisplay));
      tr.appendChild(createCell(row.lastRun));
      tr.appendChild(createCell(formatNumber(row.total)));
      tr.appendChild(createCell(formatNumber(row.passed), "success"));
      tr.appendChild(createCell(formatNumber(row.failed), "danger"));
      tr.appendChild(createCell(formatNumber(row.skipped), "warning"));
      const rateCell = document.createElement("td");
      rateCell.className = "rate-cell";
      rateCell.textContent = formatPercent(row.primaryRate);

      const deltaValue = row.primaryDelta;
      if (Number.isFinite(deltaValue)) {
        const deltaSpan = document.createElement("span");
        const direction = deltaValue > 0 ? "up" : deltaValue < 0 ? "down" : "flat";
        const arrow = deltaValue > 0 ? "▲" : deltaValue < 0 ? "▼" : "→";
        deltaSpan.className = `rate-delta ${direction}`;
        deltaSpan.textContent = `${arrow} ${Math.abs(deltaValue).toFixed(1)}%`;
        rateCell.appendChild(deltaSpan);
      } else {
        const deltaSpan = document.createElement("span");
        deltaSpan.className = "rate-delta muted";
        deltaSpan.textContent = "--";
        rateCell.appendChild(deltaSpan);
      }

      tr.appendChild(rateCell);

      const webRate = formatPlatformRateCell(row.webSuccessRate, row.webTestCount, "web");
      const webCell = document.createElement("td");
      webCell.className = "rate-cell platform-rate";
      webCell.textContent = webRate.text;
      webCell.title = webRate.title;
      tr.appendChild(webCell);

      const mobileRate = formatPlatformRateCell(
        row.mobileSuccessRate,
        row.mobileTestCount,
        "mobile"
      );
      const mobileCell = document.createElement("td");
      mobileCell.className = "rate-cell platform-rate";
      mobileCell.textContent = mobileRate.text;
      mobileCell.title = mobileRate.title;
      tr.appendChild(mobileCell);

      tbody.appendChild(tr);
    });
  };

  const sortTable = (column) => {
    const isNumeric = [
      "total",
      "passed",
      "failed",
      "skipped",
      "primaryRate",
      "webSuccessRate",
      "mobileSuccessRate",
    ].includes(column);

    if (currentSort.column === column) {
      currentSort.direction = currentSort.direction === "asc" ? "desc" : "asc";
    } else {
      currentSort.column = column;
      currentSort.direction = "asc";
    }

    sortedRows.sort((a, b) => {
      let aVal = a[column];
      let bVal = b[column];

      if (isNumeric) {
        aVal = Number(aVal) || 0;
        bVal = Number(bVal) || 0;
      } else if (column === "lastRun") {
        // Sort by timestamp for dates
        const aTime = new Date(a.lastRun).getTime();
        const bTime = new Date(b.lastRun).getTime();
        aVal = isNaN(aTime) ? 0 : aTime;
        bVal = isNaN(bTime) ? 0 : bTime;
      } else {
        aVal = String(aVal).toLowerCase();
        bVal = String(bVal).toLowerCase();
      }

      if (aVal < bVal) return currentSort.direction === "asc" ? -1 : 1;
      if (aVal > bVal) return currentSort.direction === "asc" ? 1 : -1;
      return 0;
    });

    // Update sort indicators
    document.querySelectorAll(".table-wrap th").forEach((th) => {
      th.classList.remove("sorted-asc", "sorted-desc");
    });

    const sortedHeader = document.querySelector(`.table-wrap th[data-sort="${column}"]`);
    if (sortedHeader) {
      sortedHeader.classList.add(`sorted-${currentSort.direction}`);
    }

    renderRows();
  };

  // Add click handlers to table headers
  document.querySelectorAll(".table-wrap th[data-sort]").forEach((th) => {
    th.addEventListener("click", () => {
      const column = th.getAttribute("data-sort");
      sortTable(column);
    });
  });

  renderRows();
};

const renderTrendCountsForEnv = (envHistory, envName) => {
  const envs = safeObject(envHistory.environments);
  const runs = safeList(envs[envName]);
  if (!runs.length) {
    return;
  }

  const last7Runs = runs.slice(-7);
  const labels = last7Runs.map((run) => formatTimestamp(run.timestamp));
  const series = {
    total: last7Runs.map((run) => Number(run.total || 0)),
    passed: last7Runs.map((run) => Number(run.passed || 0)),
    failed: last7Runs.map((run) => Number(run.failed || 0)),
    skipped: last7Runs.map((run) => Number(run.skipped || 0)),
  };

  createTrendCountsChart(labels, series);
};

const renderEnvironmentRanking = (environments, envHistory, rateMode) => {
  const rows = buildEnvironmentRows(environments)
    .map((row) => ({
      env: row.env,
      rate: rateMode === RATE_MODES.success ? row.successRate : row.passRate,
      passed: row.passed,
      failed: row.failed,
      total: row.total,
      delta: getRateDeltaForEnv(envHistory, row.env, rateMode),
    }))
    .sort((a, b) => b.rate - a.rate);

  createEnvironmentRankingChart(rows, rateMode);
};

const renderTrendIndicators = (history, rateMode) => {
  const runs = safeList(history.runs);
  if (runs.length < 2) {
    return;
  }

  const latest = runs[runs.length - 1];
  const previous = runs[runs.length - 2];

  const latestPass = getPassRateFromRun(latest);
  const previousPass = getPassRateFromRun(previous);
  const latestFail = getFailRateFromRun(latest);
  const previousFail = getFailRateFromRun(previous);
  const latestSkip = getSkipRateFromRun(latest);
  const previousSkip = getSkipRateFromRun(previous);
  const latestSuccess = getSuccessRateFromRun(latest);
  const previousSuccess = getSuccessRateFromRun(previous);

  const passDelta = latestPass - previousPass;
  const failDelta = latestFail - previousFail;
  const skipDelta = latestSkip - previousSkip;
  const successDelta = latestSuccess - previousSuccess;

  if (rateMode === RATE_MODES.success) {
    return;
  }

  setTrend("avg-pass-rate-trend", passDelta);
  setTrend("avg-fail-rate-trend", failDelta);
};

const renderDetailedMetrics = (history, environments, rateMode) => {
  const passCard = document.getElementById("pass-card");
  const platformRatesCard = document.getElementById("platform-rates-card");
  const successBlock = document.getElementById("success-card");
  const failCard = document.getElementById("fail-card");

  if (rateMode === RATE_MODES.success) {
    if (passCard) passCard.classList.add("is-hidden");
    if (failCard) failCard.classList.add("is-hidden");
    if (platformRatesCard) {
      platformRatesCard.classList.remove("is-hidden");
      platformRatesCard.classList.remove("summary-card--platform-solo");
    }
    if (successBlock) successBlock.classList.remove("is-hidden");
    return;
  }

  const runs = safeList(history.runs);
  const avg7Run = calculate7RunAverages(runs);

  setText("avg-pass-rate-7day", `7-run avg: ${formatPercent(avg7Run.passRate)}`);
  setText("avg-fail-rate-7day", `7-run avg: ${formatPercent(avg7Run.failRate)}`);

  const passEnvs = findBestWorstEnvironments(environments, "pass_rate");
  setText(
    "avg-pass-rate-best",
    `Best: ${getEnvDisplayName(passEnvs.best.env)} (${formatPercent(passEnvs.best.value)})`
  );
  setText(
    "avg-pass-rate-worst",
    `Worst: ${getEnvDisplayName(passEnvs.worst.env)} (${formatPercent(passEnvs.worst.value)})`
  );

  const failEnvs = findBestWorstEnvironments(environments, "fail_rate");
  setText(
    "avg-fail-rate-best",
    `Best: ${getEnvDisplayName(failEnvs.worst.env)} (${formatPercent(failEnvs.worst.value)})`
  );
  setText(
    "avg-fail-rate-worst",
    `Worst: ${getEnvDisplayName(failEnvs.best.env)} (${formatPercent(failEnvs.best.value)})`
  );

  if (passCard) passCard.classList.remove("is-hidden");
  if (failCard) failCard.classList.remove("is-hidden");
  if (platformRatesCard) {
    platformRatesCard.classList.remove("is-hidden");
    platformRatesCard.classList.add("summary-card--platform-solo");
  }
  if (successBlock) successBlock.classList.add("is-hidden");
};

const renderEnvironmentChart = (environments) => {
  const labels = [];
  const series = {
    passed: [],
    failed: [],
    skipped: [],
  };

  const rows = Object.values(environments).slice();
  rows.sort((a, b) => (a.env || "").localeCompare(b.env || ""));

  rows.forEach((env) => {
    const lastRun = env.last_run || {};
    labels.push(chartEnvLabel(env.env || "Unknown"));
    series.passed.push(Number(lastRun.passed || 0));
    series.failed.push(Number(lastRun.failed || 0));
    series.skipped.push(Number(lastRun.skipped || 0));
  });

  createEnvironmentStackedChart(labels, series);
};

const updateRateCopy = (rateMode) => {
  document.body.classList.toggle("rate-mode-success", rateMode === RATE_MODES.success);
  renderMetricDefinitionBar(rateMode);

  const toggle = document.getElementById("rate-toggle");
  if (toggle) {
    toggle.checked = rateMode === RATE_MODES.pass;
    const metric = getMetricDefinition(rateMode);
    toggle.setAttribute("aria-label", `Switch to ${rateMode === RATE_MODES.pass ? "success" : "pass"} rate`);
    toggle.setAttribute("title", metric.definition);
  }

  const passMetric = getCustomerLabels().metrics.passRate;
  setText("pass-rate-sub", passMetric.definition);
  setText("fail-rate-sub", "Fail rate = failed ÷ (total − skipped)");

  const rankingTitle = document.getElementById("env-ranking-title");
  const rankingDesc = document.getElementById("env-ranking-desc");
  if (rankingTitle) {
    rankingTitle.textContent =
      rateMode === RATE_MODES.success
        ? "Environment success rate ranking"
        : "Environment pass rate ranking";
  }
  if (rankingDesc) {
    const thresholds = getCustomerLabels().thresholds || { good: 90, watch: 85 };
    rankingDesc.textContent =
      `Latest run per environment, sorted best to worst. Green ≥${thresholds.good}%, amber ${thresholds.watch}–${thresholds.good}%, red <${thresholds.watch}%.`;
  }

  const envTitle = document.getElementById("env-rate-title");
  const envDesc = document.getElementById("env-rate-desc");
  if (envTitle) {
    envTitle.textContent = "Rate History by Environment";
  }
  if (envDesc) {
    envDesc.textContent =
      rateMode === RATE_MODES.success
        ? "Track success or skip rate over time for selected environments."
        : "Track pass, fail, or skip rate over time for selected environments.";
  }

  updateEnvMetricTabLabels(rateMode);
  bindEnvMetricTabs();
};

const applyRateMode = (state) => {
  if (!state) {
    return;
  }
  const rateMode = getRateMode();
  updateRateCopy(rateMode);
  renderSummary(state.summaryEnvironments, state.updatedAt, {
    selectedEnvCount: state.summarySelection.size,
    totalEnvCount: state.totalEnvCount,
    runType: state.runType,
  }, state.testResults);
  renderEnvironmentRanking(state.environments, state.envHistory, rateMode);
  renderTrendIndicators(state.summaryRateHistory, rateMode);
  renderDetailedMetrics(state.summaryRateHistory, state.summaryEnvironments, rateMode);
  renderEnvironmentTrends(state.envHistory, rateMode, state.runType);
  renderEnvironmentTable(
    state.environments,
    state.envHistory,
    rateMode,
    state.summarySelection,
    (nextSelection) => updateSummarySelection(state, nextSelection),
    state.testResults
  );
  updateRunTypeStatus(state);
};

const bindRateToggle = (state) => {
  const toggle = document.getElementById("rate-toggle");
  if (!toggle) {
    return;
  }

  toggle.addEventListener("change", () => {
    const next = toggle.checked ? RATE_MODES.pass : RATE_MODES.success;
    setRateMode(next);
    applyRateMode(state);
  });
};

const updateSummarySelection = (state, nextSelection) => {
  const normalized = safeList(nextSelection)
    .map((name) => normalizeEnvName(name))
    .filter(Boolean);
  setStoredSummarySelection(normalized, state.runType || RUN_TYPES.sanity);
  state.summarySelection = new Set(normalized);
  state.summaryEnvironments = filterEnvironmentsBySelection(
    state.environments,
    state.summarySelection
  );

  const summaryEnvHistory = filterEnvHistoryBySelection(
    state.envHistory,
    state.summarySelection
  );
  const summaryRateHistory = buildAverageRateHistoryWithAnchors(
    state.historyData,
    summaryEnvHistory
  );
  state.summaryRateHistory = summaryRateHistory.runs.length
    ? summaryRateHistory
    : state.historyData;

  renderSummary(state.summaryEnvironments, state.updatedAt, {
    selectedEnvCount: state.summarySelection.size,
    totalEnvCount: state.totalEnvCount,
    runType: state.runType,
  }, state.testResults);
  renderTrendIndicators(state.summaryRateHistory, getRateMode());
  renderDetailedMetrics(state.summaryRateHistory, state.summaryEnvironments, getRateMode());
  updateRunTypeStatus(state);
};

const getEnvTrendSelectionKey = (runType) =>
  `selectedEnvironments:${runType === RUN_TYPES.sit ? RUN_TYPES.sit : RUN_TYPES.sanity}`;

const getSelectedEnvironments = (runType = RUN_TYPES.sanity) => {
  const storageKey = getEnvTrendSelectionKey(runType);
  const stored = localStorage.getItem(storageKey);
  if (stored) {
    return JSON.parse(stored);
  }
  const legacy = localStorage.getItem("selectedEnvironments");
  if (legacy && runType === RUN_TYPES.sanity) {
    try {
      return JSON.parse(legacy);
    } catch (error) {
      return [];
    }
  }
  return [];
};

const setSelectedEnvironments = (envs, runType = RUN_TYPES.sanity) => {
  localStorage.setItem(getEnvTrendSelectionKey(runType), JSON.stringify(envs));
};

const envSelectorContext = {
  envHistory: { environments: {} },
  runType: RUN_TYPES.sanity,
};

const resolveEnvTrendSelection = (envHistory, runType) => {
  const envs = safeObject(envHistory.environments);
  const envNames = Object.keys(envs);
  let selectedEnvs = getSelectedEnvironments(runType).filter((name) => envNames.includes(name));
  if (selectedEnvs.length === 0 && envNames.length > 0) {
    const envData = Object.entries(envs).map(([name, runs]) => {
      const lastRun = safeList(runs).slice(-1)[0] || {};
      return {
        name,
        primaryRate: getPrimaryRateFromRun(lastRun, getRateMode()),
      };
    });
    envData.sort((a, b) => b.primaryRate - a.primaryRate);
    selectedEnvs = envData.slice(0, Math.min(3, envData.length)).map((entry) => entry.name);
    setSelectedEnvironments(selectedEnvs, runType);
  }
  return selectedEnvs;
};

const renderEnvSelectorList = (filter = "") => {
  const envList = document.getElementById("env-list");
  if (!envList) {
    return;
  }

  const { envHistory, runType } = envSelectorContext;
  const envs = safeObject(envHistory.environments);
  const envNames = Object.keys(envs).sort();
  const selectedEnvs = resolveEnvTrendSelection(envHistory, runType);

  envList.innerHTML = "";
  const filteredEnvs = envNames.filter((name) =>
    name.toLowerCase().includes(filter.toLowerCase())
  );

  filteredEnvs.forEach((envName) => {
    const item = document.createElement("div");
    item.className = "env-item";
    if (selectedEnvs.includes(envName)) {
      item.classList.add("selected");
    }

    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.id = `env-${envName}`;
    checkbox.checked = selectedEnvs.includes(envName);

    const label = document.createElement("label");
    label.htmlFor = `env-${envName}`;
    const meta = getEnvCustomerMeta(envName);
    label.textContent = meta.displayName;
    label.title = `${envName} — ${meta.region} · ${meta.purpose}`;

    item.appendChild(checkbox);
    item.appendChild(label);

    item.addEventListener("click", (e) => {
      const currentSelection = getSelectedEnvironments(runType).filter((name) =>
        envNames.includes(name)
      );
      if (e.target.tagName !== "INPUT") {
        checkbox.checked = !checkbox.checked;
      }

      let nextSelection = [...currentSelection];
      if (checkbox.checked) {
        if (nextSelection.length >= 3) {
          checkbox.checked = false;
          showToast("Please select up to 3 environments for better readability.", "warning");
          return;
        }
        nextSelection.push(envName);
        item.classList.add("selected");
      } else {
        nextSelection = nextSelection.filter((name) => name !== envName);
        item.classList.remove("selected");
      }

      setSelectedEnvironments(nextSelection, runType);
      renderEnvironmentTrends(envHistory, getRateMode(), runType);
    });

    envList.appendChild(item);
  });

  if (filteredEnvs.length === 0) {
    envList.innerHTML =
      '<div style="padding: 12px; color: var(--muted); text-align: center;">No environments found</div>';
  }
};

let envSelectorControlsBound = false;

const bindEnvironmentSelectorControls = () => {
  if (envSelectorControlsBound) {
    return;
  }

  const searchInput = document.getElementById("env-search");
  const clearBtn = document.getElementById("env-select-clear");
  const top3Btn = document.getElementById("env-select-top3");

  if (!searchInput) {
    return;
  }

  envSelectorControlsBound = true;

  searchInput.addEventListener("input", (e) => {
    renderEnvSelectorList(e.target.value);
  });

  if (clearBtn) {
    clearBtn.addEventListener("click", () => {
      const { envHistory, runType } = envSelectorContext;
      setSelectedEnvironments([], runType);
      renderEnvSelectorList(searchInput.value);
      renderEnvironmentTrends(envHistory, getRateMode(), runType);
      showToast("All selections cleared", "info", 2000);
    });
  }

  if (top3Btn) {
    top3Btn.addEventListener("click", () => {
      const { envHistory, runType } = envSelectorContext;
      const envs = safeObject(envHistory.environments);
      const envData = Object.entries(envs).map(([name, runs]) => {
        const lastRun = safeList(runs).slice(-1)[0] || {};
        return {
          name,
          primaryRate: getPrimaryRateFromRun(lastRun, getRateMode()),
        };
      });
      envData.sort((a, b) => b.primaryRate - a.primaryRate);
      const selectedEnvs = envData.slice(0, Math.min(3, envData.length)).map((entry) => entry.name);
      setSelectedEnvironments(selectedEnvs, runType);
      renderEnvSelectorList(searchInput.value);
      renderEnvironmentTrends(envHistory, getRateMode(), runType);
      showToast(`Selected top 3 environments: ${selectedEnvs.join(", ")}`, "success", 3000);
    });
  }
};

const populateEnvironmentSelector = (envHistory, runType = RUN_TYPES.sanity) => {
  envSelectorContext.envHistory = envHistory;
  envSelectorContext.runType = runType;
  bindEnvironmentSelectorControls();
  renderEnvSelectorList(document.getElementById("env-search")?.value || "");
  renderEnvironmentTrends(envHistory, getRateMode(), runType);
};

const renderEnvironmentTrends = (envHistory, rateMode, runType = RUN_TYPES.sanity) => {
  envTrendRenderContext.envHistory = envHistory;
  envTrendRenderContext.rateMode = rateMode;
  envTrendRenderContext.runType = runType;
  bindEnvMetricTabs();
  updateEnvMetricTabLabels(rateMode);

  const envs = safeObject(envHistory.environments);
  const selectedEnvs = getSelectedEnvironments(runType);
  const activeMetric = getActiveEnvTrendMetric();
  const filteredEnvs = selectedEnvs.length > 0
    ? Object.fromEntries(Object.entries(envs).filter(([name]) => selectedEnvs.includes(name)))
    : envs;

  const allTimestamps = new Set();

  Object.values(filteredEnvs).forEach((runs) => {
    safeList(runs).forEach((run) => {
      if (run.timestamp) {
        allTimestamps.add(run.timestamp);
      }
    });
  });

  const sortedTimestamps = Array.from(allTimestamps).sort();
  if (!sortedTimestamps.length) {
    return;
  }

  const labels = sortedTimestamps.map((timestamp) =>
    formatTimestamp(timestamp, { year: undefined, timeZoneName: undefined })
  );

  const metricResolver = (run) => {
    if (activeMetric === ENV_TREND_METRICS.skip) {
      return getSkipRateFromRun(run);
    }
    if (activeMetric === ENV_TREND_METRICS.fail) {
      return getFailRateFromRun(run);
    }
    return getPrimaryRateFromRun(run, rateMode);
  };

  const useThreshold = activeMetric === ENV_TREND_METRICS.primary;
  const datasets = [];

  Object.entries(filteredEnvs).forEach(([envName, runs], index) => {
    const color = ENV_CHART_PALETTE[index % ENV_CHART_PALETTE.length];
    const lookup = new Map(
      safeList(runs).map((run) => [run.timestamp, metricResolver(run)])
    );
    const data = sortedTimestamps.map((timestamp) =>
      lookup.has(timestamp) ? lookup.get(timestamp) : null
    );

    datasets.push(
      buildAreaLineDataset(chartEnvLabel(envName), data, color, {
        showArea: true,
        dashed: activeMetric !== ENV_TREND_METRICS.primary,
      })
    );
  });

  createEnvironmentTrendChart(labels, datasets, { useThreshold });
};

const getRunTrendEnvironmentKey = (runType) =>
  `runTrendEnvironment:${runType === RUN_TYPES.sit ? RUN_TYPES.sit : RUN_TYPES.sanity}`;

const getRunTrendEnvironment = (runType = RUN_TYPES.sanity) =>
  localStorage.getItem(getRunTrendEnvironmentKey(runType)) || "";

const setRunTrendEnvironment = (envName, runType = RUN_TYPES.sanity) => {
  localStorage.setItem(getRunTrendEnvironmentKey(runType), envName || "");
};

const runTrendSelectorContext = {
  envHistory: { environments: {} },
  runType: RUN_TYPES.sanity,
};

let runTrendSelectorBound = false;

const bindRunTrendSelector = () => {
  if (runTrendSelectorBound) {
    return;
  }

  const select = document.getElementById("run-trend-env");
  if (!select) {
    return;
  }

  runTrendSelectorBound = true;
  select.addEventListener("change", () => {
    const selected = select.value;
    const { envHistory, runType } = runTrendSelectorContext;
    setRunTrendEnvironment(selected, runType);
    renderTrendCountsForEnv(envHistory, selected);
  });
};

const populateRunTrendSelector = (envHistory, runType = RUN_TYPES.sanity) => {
  const select = document.getElementById("run-trend-env");
  if (!select) {
    return;
  }

  runTrendSelectorContext.envHistory = envHistory;
  runTrendSelectorContext.runType = runType;
  bindRunTrendSelector();

  const envNames = Object.keys(safeObject(envHistory.environments)).sort();
  select.innerHTML = "";

  envNames.forEach((envName) => {
    const option = document.createElement("option");
    option.value = envName;
    option.textContent = getEnvDisplayWithCode(envName);
    select.appendChild(option);
  });

  const stored = getRunTrendEnvironment(runType);
  const defaultEnv = envNames.includes(stored) ? stored : envNames[0];
  if (defaultEnv) {
    select.value = defaultEnv;
    setRunTrendEnvironment(defaultEnv, runType);
    renderTrendCountsForEnv(envHistory, defaultEnv);
  }
};

const buildAverageRateHistoryFromEnvHistory = (envHistory) => {
  const envs = safeObject(envHistory.environments);
  const totalsByTimestamp = new Map();

  Object.values(envs).forEach((runs) => {
    safeList(runs).forEach((run) => {
      const timestamp = run.timestamp;
      if (!timestamp) {
        return;
      }
      const entry = totalsByTimestamp.get(timestamp) || {
        timestamp,
        env_count: 0,
        pass_rate_sum: 0,
        fail_rate_sum: 0,
        skip_rate_sum: 0,
        success_rate_sum: 0,
      };
      const passRate = getPassRateFromRun(run);
      const failRate = getFailRateFromRun(run);
      const skipRate = getSkipRateFromRun(run);
      const successRate = getSuccessRateFromRun(run);

      entry.env_count += 1;
      entry.pass_rate_sum += passRate;
      entry.fail_rate_sum += failRate;
      entry.skip_rate_sum += skipRate;
      entry.success_rate_sum += successRate;
      totalsByTimestamp.set(timestamp, entry);
    });
  });

  const snapshots = Array.from(totalsByTimestamp.values()).sort((a, b) => {
    const aTime = new Date(a.timestamp).getTime();
    const bTime = new Date(b.timestamp).getTime();
    return (Number.isNaN(aTime) ? 0 : aTime) - (Number.isNaN(bTime) ? 0 : bTime);
  });

  const runs = snapshots.map((entry) => {
    const divisor = entry.env_count || 1;
    return {
      timestamp: entry.timestamp,
      env_count: entry.env_count,
      pass_rate: entry.pass_rate_sum / divisor,
      fail_rate: entry.fail_rate_sum / divisor,
      skip_rate: entry.skip_rate_sum / divisor,
      success_rate: entry.success_rate_sum / divisor,
    };
  });

  return {
    updated_at: envHistory.updated_at || "",
    runs: runs.slice(-7),
  };
};

const buildAverageRateHistoryWithAnchors = (anchorHistory, envHistory) => {
  const anchors = safeList(anchorHistory.runs);
  const envs = safeObject(envHistory.environments);
  if (!anchors.length) {
    return buildAverageRateHistoryFromEnvHistory(envHistory);
  }

  const envRunCache = new Map(
    Object.entries(envs).map(([envName, runs]) => [
      envName,
      safeList(runs)
        .filter((run) => run.timestamp)
        .sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp)),
    ])
  );

  const runs = anchors.map((anchor) => {
    const anchorTime = new Date(anchor.timestamp).getTime();
    const totals = {
      total: 0,
      passed: 0,
      failed: 0,
      skipped: 0,
    };
    let envCount = 0;

    envRunCache.forEach((envRuns) => {
      const latest = envRuns
        .filter((run) => new Date(run.timestamp).getTime() <= anchorTime)
        .slice(-1)[0];
      if (!latest) {
        return;
      }
      envCount += 1;
      totals.total += Number(latest.total || 0);
      totals.passed += Number(latest.passed || 0);
      totals.failed += Number(latest.failed || 0);
      totals.skipped += Number(latest.skipped || 0);
    });

    return {
      timestamp: anchor.timestamp,
      env_count: envCount,
      total: totals.total,
      passed: totals.passed,
      failed: totals.failed,
      skipped: totals.skipped,
      pass_rate: computePassFailRate(totals.passed, totals.total, totals.skipped),
      fail_rate: computePassFailRate(totals.failed, totals.total, totals.skipped),
      skip_rate: computeRate(totals.skipped, totals.total),
      success_rate: computeSuccessRate(totals.passed, totals.skipped, totals.total),
    };
  });

  return {
    updated_at: envHistory.updated_at || "",
    runs: runs.slice(-7),
  };
};

const buildSummaryExportRows = (environments, updatedAt, rateMode) => {
  const aggregate = aggregateLatest(environments);
  const averages = rateMode === RATE_MODES.success
    ? [
        ["Avg Success Rate", formatPercent(aggregate.successRate)],
        ["Avg Skip Rate", formatPercent(aggregate.skipRate)],
      ]
    : [
        ["Avg Pass Rate", formatPercent(aggregate.passRate)],
        ["Avg Fail Rate", formatPercent(aggregate.failRate)],
        ["Avg Skip Rate", formatPercent(aggregate.skipRate)],
      ];
  return {
    header: ["WFM Test Automation Dashboard", ""],
    metadata: [
      ["Last Updated", formatTimestamp(updatedAt)],
      ["Environments", String(aggregate.envCount)],
    ],
    totals: [
      ["Total Tests", String(aggregate.total)],
      ["Passed", String(aggregate.passed)],
      ["Failed", String(aggregate.failed)],
      ["Skipped", String(aggregate.skipped)],
    ],
    averages,
  };
};

const exportToXls = (environments, updatedAt) => {
  if (!window.XLSX) {
    console.error("XLSX library not available.");
    return;
  }

  const rateMode = getRateMode();
  const summary = buildSummaryExportRows(environments, updatedAt, rateMode);
  const envRows = buildEnvironmentRows(environments);
  const primaryRateLabel = rateMode === RATE_MODES.success ? "Success Rate" : "Pass Rate";
  const includeFailRate = rateMode !== RATE_MODES.success;

  const sheetRows = [
    summary.header,
    [""],
    ...summary.metadata,
    [""],
    ["Totals", ""],
    ...summary.totals,
    [""],
    ["Average Rates", ""],
    ...summary.averages,
    [""],
    [
      "Environment",
      "Version",
      "Last Run",
      "Total",
      "Passed",
      "Failed",
      "Skipped",
      primaryRateLabel,
      ...(includeFailRate ? ["Fail Rate"] : []),
      "Skip Rate",
    ],
    ...envRows.map((row) => [
      row.env,
      row.appVersionDisplay,
      row.lastRun,
      row.total,
      row.passed,
      row.failed,
      row.skipped,
      formatPercent(rateMode === RATE_MODES.success ? row.successRate : row.passRate),
      ...(includeFailRate ? [formatPercent(row.failRate)] : []),
      formatPercent(row.skipRate),
    ]),
  ];

  const workbook = XLSX.utils.book_new();
  const worksheet = XLSX.utils.aoa_to_sheet(sheetRows);
  XLSX.utils.book_append_sheet(workbook, worksheet, "Dashboard");
  XLSX.writeFile(workbook, "wfm-dashboard-export.xlsx");
};

const exportToPdf = (environments, updatedAt) => {
  const jspdfNamespace = window.jspdf || {};
  const jsPDF = jspdfNamespace.jsPDF;
  if (!jsPDF) {
    console.error("jsPDF library not available.");
    return;
  }

  const rateMode = getRateMode();
  const summary = buildSummaryExportRows(environments, updatedAt, rateMode);
  const primaryRateLabel = rateMode === RATE_MODES.success ? "Success Rate" : "Pass Rate";
  const includeFailRate = rateMode !== RATE_MODES.success;
  const envRows = buildEnvironmentRows(environments).map((row) => [
    row.env,
    row.appVersionDisplay,
    row.lastRun,
    formatNumber(row.total),
    formatNumber(row.passed),
    formatNumber(row.failed),
    formatNumber(row.skipped),
    formatPercent(rateMode === RATE_MODES.success ? row.successRate : row.passRate),
    ...(includeFailRate ? [formatPercent(row.failRate)] : []),
    formatPercent(row.skipRate),
  ]);

  const doc = new jsPDF({ orientation: "landscape", unit: "pt", format: "a4" });
  doc.setFontSize(16);
  doc.text("WFM Test Automation Dashboard", 40, 40);
  doc.setFontSize(10);
  doc.text(`Last Updated: ${summary.metadata[0][1]}`, 40, 58);

  doc.autoTable({
    startY: 80,
    head: [["Metric", "Value"]],
    body: [...summary.totals],
    theme: "grid",
    styles: { fontSize: 9 },
  });

  doc.autoTable({
    startY: doc.lastAutoTable.finalY + 10,
    head: [["Average Rates", "Value"]],
    body: [...summary.averages],
    theme: "grid",
    styles: { fontSize: 9 },
  });

  doc.autoTable({
    startY: doc.lastAutoTable.finalY + 14,
    head: [[
      "Environment",
      "Version",
      "Last Run",
      "Total",
      "Passed",
      "Failed",
      "Skipped",
      primaryRateLabel,
      ...(includeFailRate ? ["Fail Rate"] : []),
      "Skip Rate",
    ]],
    body: envRows,
    theme: "grid",
    styles: { fontSize: 8 },
    headStyles: { fillColor: [15, 140, 151] },
  });

  doc.save("wfm-dashboard-export.pdf");
};

const bindExportButtons = (environments, updatedAt) => {
  const xlsButton = document.getElementById("export-xls");
  const pdfButton = document.getElementById("export-pdf");

  if (xlsButton) {
    xlsButton.addEventListener("click", () => exportToXls(environments, updatedAt));
  }

  if (pdfButton) {
    pdfButton.addEventListener("click", () => exportToPdf(environments, updatedAt));
  }
};

const updateRunTypeStatus = (state) => {
  const status = document.getElementById("run-type-status");
  if (!status || !state) {
    return;
  }
  const runMeta = getRunTypeCustomerMeta(state.runType);
  const count = state.totalEnvCount || 0;
  status.textContent =
    count === 0
      ? `No ${runMeta.toggleLabel} environments in dashboard data`
      : `Showing ${count} ${runMeta.toggleLabel} environment${count === 1 ? "" : "s"}`;
};

const applyRunTypeToState = (state, runType) => {
  const activeRunType = runType === RUN_TYPES.sit ? RUN_TYPES.sit : RUN_TYPES.sanity;
  const environments = filterEnvironmentMap(
    state.rawEnvironments,
    activeRunType,
    state.rawEnvironments
  );
  const envHistory = filterEnvHistoryByRunType(
    state.rawEnvHistory,
    activeRunType,
    state.rawEnvironments
  );
  const historyData = normalizeHistoryForRunType(state.rawHistoryData, activeRunType);

  state.runType = activeRunType;
  state.environments = environments;
  state.envHistory = envHistory;
  state.historyData = historyData;
  state.totalEnvCount = getEnvironmentNames(environments).length;

  const summarySelection = resolveSummarySelection(
    environments,
    state.excludedEnvs,
    activeRunType
  );
  state.summarySelection = new Set(summarySelection);
  state.summaryEnvironments = filterEnvironmentsBySelection(
    environments,
    state.summarySelection
  );

  const summaryEnvHistory = filterEnvHistoryBySelection(
    envHistory,
    state.summarySelection
  );
  const summaryRateHistory = buildAverageRateHistoryWithAnchors(
    historyData,
    summaryEnvHistory
  );
  state.summaryRateHistory = summaryRateHistory.runs.length
    ? summaryRateHistory
    : historyData;

  const averageRateHistory = buildAverageRateHistoryWithAnchors(
    historyData,
    envHistory
  );
  state.rateHistoryForRender = averageRateHistory.runs.length
    ? averageRateHistory
    : historyData;
};

const renderDashboardState = (state) => {
  populateEnvironmentSelector(state.envHistory, state.runType);
  populateRunTrendSelector(state.envHistory, state.runType);
  bindExportButtons(state.environments, state.updatedAt);
  applyRateMode(state);
  updateRunTypeStatus(state);
};

const refreshDashboardForRunType = (state) => {
  renderDashboardState(state);
  try {
    renderEnvironmentChart(state.environments);
  } catch (error) {
    console.error("Failed to refresh environment chart", error);
  }
};

const loadDashboard = async () => {
  try {
    await loadCustomerLabels();
    applyRunTypeToggleLabels();

    const [envResponse, historyResponse, envHistoryResponse, excludedResponse, testResultsResponse] =
      await Promise.all([
      fetch(ENVIRONMENTS_URL),
      fetch(HISTORY_URL),
      fetch(ENV_HISTORY_URL),
      fetch(EXCLUDED_ENVS_URL),
      fetch(TEST_RESULTS_URL),
    ]);

    const envData = safeObject(await envResponse.json());
    const historyData = safeObject(await historyResponse.json());
    const envHistoryData = envHistoryResponse.ok
      ? safeObject(await envHistoryResponse.json())
      : {};
    const excludedData = excludedResponse.ok
      ? safeObject(await excludedResponse.json())
      : {};
    const excludedEnvs = new Set(
      safeList(excludedData.excluded).map(normalizeEnvName).filter(Boolean)
    );
    const environments = safeObject(envData.environments);
    const testResults = testResultsResponse.ok
      ? safeObject(await testResultsResponse.json())
      : {};

    const dashboardState = {
      rawEnvironments: environments,
      rawEnvHistory: envHistoryData,
      rawHistoryData: historyData,
      excludedEnvs,
      updatedAt: envData.updated_at,
      testResults,
    };

    applyRunTypeToState(dashboardState, getStoredRunType());

    if (
      dashboardState.totalEnvCount === 0 &&
      dashboardState.runType === RUN_TYPES.sit
    ) {
      showToast(
        "No release-validation environments in local data. Showing BAT instead.",
        "warning"
      );
      setStoredRunType(RUN_TYPES.sanity);
      applyRunTypeToState(dashboardState, RUN_TYPES.sanity);
      document.querySelectorAll('[data-run-type="sanity"]').forEach((button) => {
        button.classList.add("active");
        button.setAttribute("aria-pressed", "true");
      });
      document.querySelectorAll('[data-run-type="sit"]').forEach((button) => {
        button.classList.remove("active");
        button.setAttribute("aria-pressed", "false");
      });
    }

    syncRunTypeToUrl(dashboardState.runType);
    refreshDashboardForRunType(dashboardState);
    bindRateToggle(dashboardState);

    bindRunTypeToggle((nextRunType) => {
      applyRunTypeToState(dashboardState, nextRunType);
      if (
        dashboardState.totalEnvCount === 0 &&
        dashboardState.runType === RUN_TYPES.sit
      ) {
        showToast("No release-validation environments in dashboard data for this view.", "info");
      }
      refreshDashboardForRunType(dashboardState);
    });
  } catch (error) {
    setText("last-updated", "Failed to load data");
    console.error("Failed to load dashboard data", error);
  }
};

loadDashboard();
