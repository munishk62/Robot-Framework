/**
 * Shared Chart.js theme for the WST automation dashboard.
 */
const CHART_COLORS = {
  pass: "#1f9d55",
  passLight: "#4ade80",
  passDark: "#15803d",
  fail: "#d64545",
  failLight: "#f87171",
  failDark: "#b91c1c",
  skip: "#f59f0b",
  skipLight: "#fbbf24",
  skipDark: "#d97706",
  accent: "#0f8c97",
  accentLight: "#2dd4bf",
  ink: "#15202b",
  muted: "#5b6b76",
  grid: "rgba(21, 32, 43, 0.08)",
  gridStrong: "rgba(21, 32, 43, 0.14)",
  surface: "#ffffff",
};

const CHART_FONTS = {
  family: "'IBM Plex Sans', sans-serif",
  titleFamily: "'Space Grotesk', sans-serif",
  size: 12,
  legendSize: 11,
};

const CHART_THRESHOLD = {
  warning: 90,
  target: 95,
};

/** Tier breaks for Environment Success Rate Ranking (latest run per env). */
const CHART_RANKING_THRESHOLD = {
  good: 90,
  watch: 85,
};

const CHART_ANIMATION = {
  duration: 800,
  easing: "easeOutQuart",
};

const ENV_CHART_PALETTE = [
  "#0f8c97",
  "#3b82f6",
  "#7c3aed",
  "#ec4899",
  "#f97316",
  "#10b981",
  "#6366f1",
  "#14b8a6",
  "#e11d48",
  "#84cc16",
];

const thresholdBandPlugin = {
  id: "thresholdShading",
  beforeDatasetsDraw(chart, _args, options) {
    const { ctx, chartArea, scales } = chart;
    if (!chartArea || !scales?.y) {
      return;
    }

    const yScale = scales.y;
    const warning = options?.warning ?? CHART_THRESHOLD.warning;
    const target = options?.target ?? CHART_THRESHOLD.target;
    const width = chartArea.right - chartArea.left;

    const yZero = yScale.getPixelForValue(0);
    const yWarning = yScale.getPixelForValue(warning);
    const yTarget = yScale.getPixelForValue(target);
    const yTop = chartArea.top;

    ctx.save();

    ctx.fillStyle = "rgba(214, 69, 69, 0.09)";
    ctx.fillRect(chartArea.left, yWarning, width, yZero - yWarning);

    ctx.fillStyle = "rgba(245, 159, 11, 0.07)";
    ctx.fillRect(chartArea.left, yTarget, width, yWarning - yTarget);

    ctx.fillStyle = "rgba(31, 157, 85, 0.05)";
    ctx.fillRect(chartArea.left, yTop, width, yTarget - yTop);

    ctx.strokeStyle = "rgba(31, 157, 85, 0.35)";
    ctx.setLineDash([6, 4]);
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(chartArea.left, yTarget);
    ctx.lineTo(chartArea.right, yTarget);
    ctx.stroke();

    ctx.strokeStyle = "rgba(214, 69, 69, 0.3)";
    ctx.beginPath();
    ctx.moveTo(chartArea.left, yWarning);
    ctx.lineTo(chartArea.right, yWarning);
    ctx.stroke();

    ctx.restore();
  },
};

const registerChartTheme = () => {
  if (typeof Chart === "undefined") {
    return;
  }

  Chart.register(thresholdBandPlugin);
  Chart.register(rankingTargetPlugin);
  Chart.register(barValueLabelPlugin);

  Chart.defaults.font.family = CHART_FONTS.family;
  Chart.defaults.font.size = CHART_FONTS.size;
  Chart.defaults.color = CHART_COLORS.muted;
  Chart.defaults.animation.duration = CHART_ANIMATION.duration;
  Chart.defaults.animation.easing = CHART_ANIMATION.easing;
  Chart.defaults.plugins.legend.labels.usePointStyle = true;
  Chart.defaults.plugins.legend.labels.pointStyle = "circle";
  Chart.defaults.plugins.legend.labels.boxWidth = 8;
  Chart.defaults.plugins.legend.labels.padding = 16;
  Chart.defaults.plugins.tooltip.backgroundColor = "rgba(21, 32, 43, 0.92)";
  Chart.defaults.plugins.tooltip.titleFont = {
    family: CHART_FONTS.titleFamily,
    size: 13,
    weight: "600",
  };
  Chart.defaults.plugins.tooltip.bodyFont = {
    family: CHART_FONTS.family,
    size: 12,
  };
  Chart.defaults.plugins.tooltip.padding = 12;
  Chart.defaults.plugins.tooltip.cornerRadius = 10;
  Chart.defaults.plugins.tooltip.displayColors = true;
};

const createVerticalBarGradient = (ctx, chartArea, bottomColor, topColor) => {
  if (!chartArea) {
    return bottomColor;
  }
  const gradient = ctx.createLinearGradient(0, chartArea.bottom, 0, chartArea.top);
  gradient.addColorStop(0, bottomColor);
  gradient.addColorStop(1, topColor);
  return gradient;
};

const createHorizontalBarGradient = (ctx, chartArea, startColor, endColor) => {
  if (!chartArea) {
    return startColor;
  }
  const gradient = ctx.createLinearGradient(chartArea.left, 0, chartArea.right, 0);
  gradient.addColorStop(0, startColor);
  gradient.addColorStop(1, endColor);
  return gradient;
};

const createLineAreaGradient = (ctx, chartArea, color, peakOpacity = 0.28) => {
  if (!chartArea) {
    return hexToRgba(color, peakOpacity);
  }
  const gradient = ctx.createLinearGradient(0, chartArea.top, 0, chartArea.bottom);
  if (color.startsWith("#")) {
    gradient.addColorStop(0, hexToRgba(color, peakOpacity));
    gradient.addColorStop(1, hexToRgba(color, 0.02));
    return gradient;
  }
  gradient.addColorStop(0, color);
  gradient.addColorStop(1, "rgba(255, 255, 255, 0)");
  return gradient;
};

const hexToRgba = (hex, alpha) => {
  const normalized = hex.replace("#", "");
  const r = parseInt(normalized.slice(0, 2), 16);
  const g = parseInt(normalized.slice(2, 4), 16);
  const b = parseInt(normalized.slice(4, 6), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
};

const buildStackedBarDataset = (label, data, darkColor, lightColor, stack = "results") => ({
  label,
  data,
  stack,
  borderRadius: 8,
  borderSkipped: false,
  borderWidth: 0,
  backgroundColor: (context) => {
    const { chart } = context;
    const { ctx, chartArea } = chart;
    if (!chartArea) {
      return lightColor;
    }
    const isHorizontal = chart.config.options?.indexAxis === "y";
    return isHorizontal
      ? createHorizontalBarGradient(ctx, chartArea, darkColor, lightColor)
      : createVerticalBarGradient(ctx, chartArea, darkColor, lightColor);
  },
  hoverBackgroundColor: lightColor,
});

const buildAreaLineDataset = (label, data, color, options = {}) => {
  const { fill = true, dashed = false, showArea = true } = options;
  return {
    label,
    data,
    borderColor: color,
    backgroundColor: (context) => {
      if (!showArea) {
        return "transparent";
      }
      const { chart } = context;
      const { ctx, chartArea } = chart;
      return createLineAreaGradient(ctx, chartArea, color, 0.22);
    },
    fill,
    tension: 0.35,
    borderWidth: 2.5,
    pointRadius: 3,
    pointHoverRadius: 6,
    pointBackgroundColor: CHART_COLORS.surface,
    pointBorderColor: color,
    pointBorderWidth: 2,
    borderDash: dashed ? [6, 4] : [],
    spanGaps: true,
  };
};

const getCategoryScaleDefaults = () => ({
  grid: {
    display: false,
    drawBorder: false,
  },
  ticks: {
    color: CHART_COLORS.muted,
    font: {
      family: CHART_FONTS.family,
      size: 11,
    },
    maxRotation: 0,
    autoSkip: true,
    maxTicksLimit: 8,
  },
  border: {
    display: false,
  },
});

const getValueScaleDefaults = (options = {}) => {
  const { percentage = false, stacked = false, beginAtZero = true, max } = options;
  return {
    stacked,
    beginAtZero,
    ...(max !== undefined ? { max } : {}),
    grid: {
      color: CHART_COLORS.grid,
      drawBorder: false,
    },
    ticks: {
      color: CHART_COLORS.muted,
      font: {
        family: CHART_FONTS.family,
        size: 11,
      },
      precision: percentage ? 0 : undefined,
      callback: percentage ? (value) => `${value}%` : undefined,
    },
    border: {
      display: false,
    },
  };
};

const getChartLegendDefaults = (position = "top") => ({
  position,
  align: "center",
  labels: {
    color: CHART_COLORS.ink,
    font: {
      family: CHART_FONTS.family,
      size: CHART_FONTS.legendSize,
      weight: "500",
    },
    padding: 18,
  },
});

const getChartInteractionDefaults = () => ({
  mode: "index",
  intersect: false,
});

const getThresholdPluginOptions = () => ({
  warning: CHART_THRESHOLD.warning,
  target: CHART_THRESHOLD.target,
});

const getCountTooltipLabel = (context) => {
  const label = context.dataset.label || "";
  const value = context.parsed.y ?? context.parsed.x ?? 0;
  return `${label}: ${value.toLocaleString()}`;
};

const getRateTierColor = (rate) => {
  const value = Number(rate) || 0;
  if (value >= CHART_RANKING_THRESHOLD.good) {
    return CHART_COLORS.pass;
  }
  if (value >= CHART_RANKING_THRESHOLD.watch) {
    return CHART_COLORS.skip;
  }
  return CHART_COLORS.fail;
};

const getRateTierLabel = (rate) => {
  const value = Number(rate) || 0;
  if (value >= CHART_RANKING_THRESHOLD.good) {
    return "On target";
  }
  if (value >= CHART_RANKING_THRESHOLD.watch) {
    return "Watch";
  }
  return "At risk";
};

const rankingTargetPlugin = {
  id: "rankingTargets",
  beforeDatasetsDraw(chart) {
    const { ctx, chartArea, scales } = chart;
    const xScale = scales.x;
    if (!chartArea || !xScale) {
      return;
    }

    const xWatch = xScale.getPixelForValue(CHART_RANKING_THRESHOLD.watch);
    const xGood = xScale.getPixelForValue(CHART_RANKING_THRESHOLD.good);

    ctx.save();
    ctx.setLineDash([5, 4]);
    ctx.lineWidth = 1;

    ctx.strokeStyle = "rgba(214, 69, 69, 0.35)";
    ctx.beginPath();
    ctx.moveTo(xWatch, chartArea.top);
    ctx.lineTo(xWatch, chartArea.bottom);
    ctx.stroke();

    ctx.strokeStyle = "rgba(31, 157, 85, 0.4)";
    ctx.beginPath();
    ctx.moveTo(xGood, chartArea.top);
    ctx.lineTo(xGood, chartArea.bottom);
    ctx.stroke();

    ctx.fillStyle = CHART_COLORS.muted;
    ctx.font = `600 10px ${CHART_FONTS.family}`;
    ctx.fillText(`${CHART_RANKING_THRESHOLD.watch}%`, xWatch + 4, chartArea.top + 12);
    ctx.fillText(`${CHART_RANKING_THRESHOLD.good}%`, xGood + 4, chartArea.top + 12);
    ctx.restore();
  },
};

const barValueLabelPlugin = {
  id: "barValueLabels",
  afterDatasetsDraw(chart) {
    const { ctx } = chart;
    const dataset = chart.data.datasets[0];
    if (!dataset) {
      return;
    }

    const meta = chart.getDatasetMeta(0);
    ctx.save();
    ctx.fillStyle = CHART_COLORS.ink;
    ctx.font = `600 11px ${CHART_FONTS.family}`;
    ctx.textBaseline = "middle";

    meta.data.forEach((bar, index) => {
      const value = Number(dataset.data[index] || 0);
      const label = `${value.toFixed(1)}%`;
      const x = Math.min(bar.x + 8, chart.chartArea.right - 36);
      ctx.fillText(label, x, bar.y);
    });
    ctx.restore();
  },
};

const getPercentTooltipLabel = (context) => {
  const label = context.dataset.label || "";
  const value = context.parsed.x ?? context.parsed.y ?? 0;
  return `${label}: ${Number(value).toFixed(1)}%`;
};

const getRankingTooltipAfterBody = (rows) => (items) => {
  const index = items[0]?.dataIndex;
  if (index === undefined || !rows[index]) {
    return [];
  }
  const row = rows[index];
  const lines = [
    `Tier: ${getRateTierLabel(row.rate)}`,
    `Tests: ${row.passed.toLocaleString()} passed / ${row.total.toLocaleString()} total`,
  ];
  if (row.failed > 0) {
    lines.push(`Failures: ${row.failed.toLocaleString()}`);
  }
  if (Number.isFinite(row.delta)) {
    const sign = row.delta > 0 ? "+" : "";
    lines.push(`Change vs prior run: ${sign}${row.delta.toFixed(1)}%`);
  }
  return lines;
};

registerChartTheme();
