/**
 * WST Test Results Dashboard - Detailed View
 * 
 * This dashboard shows individual test results across all environments
 * with a history of the last 3 runs displayed as colored boxes.
 */

// Global variables
let gridApi;
let testResultsData = {};
let environmentsList = [];
let environmentMeta = {};
let activeRunType = RUN_TYPES.sanity;

// ===== FEATURE FLAGS =====
const FEATURES = {
  ENABLE_TREND_SPARKLINES: true,  // Toggle mini sparklines showing test trends (latest vs previous run)
};
// ======================

/**
 * Custom cell renderer for test name with tags as capsules
 */
class TestNameRenderer {
  init(params) {
    this.eGui = document.createElement('div');
    this.eGui.className = 'test-name-container';
    
    const testName = params.data.testName;
    const testData = testResultsData[testName];
    const parsed = parseTestDisplayName(testName);
    
    const titleRow = document.createElement('div');
    titleRow.className = 'test-name-row';

    if (parsed.id) {
      const idEl = document.createElement('span');
      idEl.className = 'test-id';
      idEl.textContent = parsed.id;
      idEl.title = 'Internal test case ID';
      titleRow.appendChild(idEl);
    }

    const nameEl = document.createElement('span');
    nameEl.className = 'test-name';
    nameEl.textContent = parsed.title;
    nameEl.title = parsed.full;
    titleRow.appendChild(nameEl);
    this.eGui.appendChild(titleRow);

    if (parsed.module) {
      const moduleEl = document.createElement('span');
      moduleEl.className = 'test-module';
      moduleEl.textContent = parsed.module;
      this.eGui.appendChild(moduleEl);
    }
    
    // Collect unique tags (excluding missing-user-key tags)
    const tagsSet = new Set();
    if (testData) {
      Object.values(testData).forEach(envData => {
        if (envData?.details?.tags && Array.isArray(envData.details.tags)) {
          envData.details.tags.forEach(tag => {
            if (tag && !tag.startsWith('missing-user-key')) {
              tagsSet.add(tag);
            }
          });
        }
      });
    }
    
    // Add tags as clickable capsules
    if (tagsSet.size > 0) {
      const tagsContainer = document.createElement('div');
      tagsContainer.className = 'tags-capsules';
      
      tagsSet.forEach(tag => {
        const capsule = document.createElement('span');
        capsule.className = 'tag-capsule';
        capsule.textContent = tag;
        capsule.title = `Click to filter by tag: ${tag}`;
        capsule.style.cursor = 'pointer';
        
        // Add click handler to filter by this tag
        capsule.addEventListener('click', (e) => {
          e.stopPropagation();
          const tagFilterInput = document.getElementById('tag-filter');
          if (tagFilterInput) {
            tagFilterInput.value = tag;
            // Trigger filter
            if (gridApi) {
              filterByTag(tag);
            }
          }
        });
        
        tagsContainer.appendChild(capsule);
      });
      
      this.eGui.appendChild(tagsContainer);
    }
  }
  
  getGui() {
    return this.eGui;
  }
  
  refresh() {
    return false;
  }
}

/**
 * Custom cell renderer for test history sparkline
 * Renders latest run prominently with mini history indicators
 */
class HistorySparklineRenderer {
  init(params) {
    this.eGui = document.createElement('div');
    this.eGui.className = 'history-sparkline';
    
    const envName = params.colDef.field;
    const testName = params.data.testName;
    
    // Get history and details for this test and environment
    const envData = testResultsData[testName]?.[envName];
    
    if (!envData || !envData.history || envData.history.length === 0) {
      this.eGui.innerHTML = '<span class="no-data">—</span>';
      return;
    }
    
    const history = envData.history;
    const details = envData.details || {};
    
    // Create container for main status and history (side-by-side layout)
    const mainContainer = document.createElement('div');
    mainContainer.className = 'status-main-container';
    
    // Latest run (most recent) - main box
    const latestStatus = history[history.length - 1];
    const mainBox = document.createElement('div');
    mainBox.className = `status-box-main ${this.getStatusClass(latestStatus)}`;
    mainBox.title = this.getTooltip(latestStatus, details, true);
    
    // Add status label inside main box
    const statusLabel = document.createElement('span');
    statusLabel.className = 'status-label';
    statusLabel.textContent = this.getStatusLabel(latestStatus);
    mainBox.appendChild(statusLabel);
    
    mainContainer.appendChild(mainBox);
    
    // Create mini history indicators for previous runs (if they exist)
    if (history.length > 1) {
      const miniContainer = document.createElement('div');
      miniContainer.className = 'status-mini-container';
      
      // Show previous runs from oldest to newest (left to right for side-by-side layout)
      for (let i = 0; i < history.length - 1; i++) {
        const status = history[i];
        const miniBox = document.createElement('span');
        miniBox.className = `status-box-mini ${this.getStatusClass(status)}`;
        miniBox.title = `Previous run ${i + 1}: ${this.getStatusLabel(status)}`;
        miniContainer.appendChild(miniBox);
      }
      
      mainContainer.appendChild(miniContainer);
    }
    
    this.eGui.appendChild(mainContainer);
    
    // Add click handler to open build URL
    if (details.url) {
      this.eGui.style.cursor = 'pointer';
      this.eGui.addEventListener('click', (e) => {
        e.stopPropagation();
        window.open(details.url, '_blank');
      });
    }
  }
  
  getStatusClass(status) {
    switch (status) {
      case 1: return 'status-pass';
      case 0: return 'status-fail';
      case 2: return 'status-skip';
      default: return 'status-empty';
    }
  }
  
  getStatusLabel(status) {
    switch (status) {
      case 1: return 'PASS';
      case 0: return 'FAIL';
      case 2: return 'SKIP';
      default: return 'UNKNOWN';
    }
  }
  
  getTooltip(status, details, isLatest) {
    let tooltip = `Status: ${this.getStatusLabel(status)}`;
    
    if (isLatest && details) {
      if (details.duration_ms) {
        const durationSec = (details.duration_ms / 1000).toFixed(2);
        tooltip += `\nDuration: ${durationSec}s`;
      }
      
      if (details.msg) {
        tooltip += `\n\nMessage:\n${details.msg}`;
      }
      
      if (details.url) {
        tooltip += `\n\nClick to open build`;
      }
    }
    
    return tooltip;
  }
  
  getGui() {
    return this.eGui;
  }
  
  refresh() {
    return false;
  }
}

/**
 * Custom cell renderer for test statistics across all environments
 * Shows: Pass percentage with mini stacked bar (green/red/orange)
 */
class TestStatsRenderer {
  init(params) {
    this.eGui = document.createElement('div');
    this.eGui.className = 'test-stats-container';
    
    const testName = params.data.testName;
    const testData = testResultsData[testName];
    
    if (!testData) {
      this.eGui.innerHTML = '<span class="no-data">—</span>';
      return;
    }
    
    // Calculate stats across all environments for LATEST run
    let passCount = 0;
    let failCount = 0;
    let skipCount = 0;
    const envResults = {};
    
    Object.entries(testData).forEach(([envName, envData]) => {
      if (envData && envData.history && envData.history.length > 0) {
        const latestStatus = envData.history[envData.history.length - 1];
        envResults[envName] = latestStatus;
        if (latestStatus === 1) passCount++;
        else if (latestStatus === 0) failCount++;
        else if (latestStatus === 2) skipCount++;
      }
    });
    
    const totalRuns = passCount + failCount + skipCount;
    if (totalRuns === 0) {
      this.eGui.innerHTML = '<span class="no-data">—</span>';
      return;
    }
    
   
    const passPercentage = Math.round((passCount / totalRuns) * 100);
    const failPercentage = Math.round((failCount / totalRuns) * 100);
    const skipPercentage = Math.round((skipCount / totalRuns) * 100);
    
    // Create stats display
    const statsDisplay = document.createElement('div');
    statsDisplay.className = 'stats-display';
    
    // Percentage text
    const percentageText = document.createElement('div');
    percentageText.className = 'stats-percentage';
    percentageText.textContent = `${passPercentage}%`;
    percentageText.title = `${passCount}P / ${failCount}F / ${skipCount}S`;
    
    // Mini stacked bar
    const barContainer = document.createElement('div');
    barContainer.className = 'stats-mini-bar';
    barContainer.title = `Passed: ${passCount} (${passPercentage}%) | Failed: ${failCount} (${failPercentage}%) | Skipped: ${skipCount} (${skipPercentage}%)`;
    
    if (passCount > 0) {
      const passBar = document.createElement('span');
      passBar.className = 'stats-bar-segment stats-bar-pass';
      passBar.style.width = `${(passCount / totalRuns) * 100}%`;
      barContainer.appendChild(passBar);
    }
    
    if (failCount > 0) {
      const failBar = document.createElement('span');
      failBar.className = 'stats-bar-segment stats-bar-fail';
      failBar.style.width = `${(failCount / totalRuns) * 100}%`;
      barContainer.appendChild(failBar);
    }
    
    if (skipCount > 0) {
      const skipBar = document.createElement('span');
      skipBar.className = 'stats-bar-segment stats-bar-skip';
      skipBar.style.width = `${(skipCount / totalRuns) * 100}%`;
      barContainer.appendChild(skipBar);
    }
    
    statsDisplay.appendChild(percentageText);
    statsDisplay.appendChild(barContainer);
    this.eGui.appendChild(statsDisplay);
    
    // Add text delta showing trend from first run to latest (if enabled)
    if (FEATURES.ENABLE_TREND_SPARKLINES) {
      const textDelta = this.createTextDelta(testData, passPercentage);
      if (textDelta) {
        this.eGui.appendChild(textDelta);
      }
    }
  }
  
  createTextDelta(testData, currentPassPercentage) {
    // Calculate pass % for first run (oldest) vs latest
    let maxHistoryDepth = 0;
    Object.values(testData).forEach(envData => {
      if (envData && envData.history) {
        maxHistoryDepth = Math.max(maxHistoryDepth, envData.history.length);
      }
    });
    
    if (maxHistoryDepth < 2) {
      return null;  // No historical data for comparison
    }
    
    // Calculate pass % for first run (index 0)
    let firstRunPassCount = 0, firstRunTotalCount = 0;
    Object.values(testData).forEach(envData => {
      if (envData && envData.history && envData.history.length > 0) {
        firstRunTotalCount++;
        if (envData.history[0] === 1) {
          firstRunPassCount++;
        }
      }
    });
    
    if (firstRunTotalCount === 0) {
      return null;
    }
    
    const firstRunPercentage = Math.round((firstRunPassCount / firstRunTotalCount) * 100);
    
    // Determine trend
    const delta = currentPassPercentage - firstRunPercentage;
    let trend = '→';  // stable
    let trendColor = '#6b7280';  // gray
    
    if (delta > 0) {
      trend = '↑';  // improving
      trendColor = '#10b981';  // green
    } else if (delta < 0) {
      trend = '↓';  // degrading
      trendColor = '#ef4444';  // red
    }
    
    // Create container
    const container = document.createElement('div');
    container.className = 'trend-text-delta';
    container.style.color = trendColor;
    container.title = `Started at ${firstRunPercentage}%, now ${currentPassPercentage}% (${delta > 0 ? '+' : ''}${delta}%)`;
    
    // Format: "↑ from 90%" - build safely using DOM elements
    const trendSpan = document.createElement('span');
    trendSpan.style.fontWeight = '700';
    trendSpan.textContent = trend;
    container.appendChild(trendSpan);
    
    const textNode = document.createTextNode(` from ${firstRunPercentage}%`);
    container.appendChild(textNode);
    
    return container;
  }
  
  getGui() {
    return this.eGui;
  }
  
  refresh() {
    return false;
  }
}

/**
 * Load environment metadata (run type) from environments.json
 */
async function loadEnvironmentMeta() {
  try {
    const response = await fetch('data/environments.json');
    if (!response.ok) {
      return {};
    }
    const payload = await response.json();
    environmentMeta = payload.environments || {};
    return environmentMeta;
  } catch (error) {
    console.warn('Could not load environments.json for run-type filtering:', error);
    return {};
  }
}

/**
 * Load test results data from JSON file
 */
async function loadTestResults() {
  try {
    const response = await fetch('data/test_results.json');
    if (!response.ok) {
      throw new Error(`Failed to load test results: ${response.status}`);
    }
    testResultsData = await response.json();
    return testResultsData;
  } catch (error) {
    console.error('Error loading test results:', error);
    showError('Failed to load test results. Please check if data/test_results.json exists.');
    return {};
  }
}

/**
 * Extract unique environments from test results data
 */
function extractEnvironments(data, runType = activeRunType) {
  const envSet = new Set();
  
  Object.values(data).forEach(testData => {
    Object.keys(testData).forEach(env => {
      if (getEnvRunType(env, environmentMeta) === runType) {
        envSet.add(env);
      }
    });
  });
  
  return Array.from(envSet).sort();
}

function refreshGridForRunType(runType) {
  activeRunType = runType === RUN_TYPES.sit ? RUN_TYPES.sit : RUN_TYPES.sanity;
  environmentsList = extractEnvironments(testResultsData, activeRunType);
  const rowData = transformDataForGrid(testResultsData);

  if (gridApi) {
    gridApi.setGridOption('columnDefs', createColumnDefs());
    gridApi.setGridOption('rowData', rowData);
    gridApi.setGridOption('quickFilterText', '');
    gridApi.refreshHeader();
  } else {
    initializeGrid(rowData);
  }

  const quickFilterInput = document.getElementById('quick-filter');
  if (quickFilterInput) {
    quickFilterInput.value = '';
  }
  const tagFilterInput = document.getElementById('tag-filter');
  if (tagFilterInput) {
    tagFilterInput.value = '';
  }

  updateStatistics();
  updateRunTypeStatus();
}

/**
 * Transform test results data into AG Grid row format
 */
function transformDataForGrid(data) {
  const rows = [];
  
  Object.keys(data).forEach(testName => {
    const row = { testName };
    
    // Calculate pass percentage for sorting
    let passCount = 0, failCount = 0, skipCount = 0, totalRuns = 0;
    environmentsList.forEach(env => {
      const envData = data[testName][env];
      if (envData && envData.history && envData.history.length > 0) {
        const latestStatus = envData.history[envData.history.length - 1];
        totalRuns++;
        if (latestStatus === 1) passCount++;
        else if (latestStatus === 0) failCount++;
        else skipCount++;
      }
    });
    row.passPercentage = totalRuns > 0 ? Math.round((passCount / totalRuns) * 100) : 0;
    
    // Add environment data for each test
    environmentsList.forEach(env => {
      row[env] = data[testName][env] || null;
    });
    
    rows.push(row);
  });
  
  return rows;
}

/**
 * Create AG Grid column definitions
 */
function createColumnDefs() {
  const columns = [
    {
      field: 'testName',
      headerName: 'Test',
      pinned: 'left',
      width: 550,
      minWidth: 350,
      filter: 'agTextColumnFilter',
      filterParams: {
        buttons: ['reset', 'apply'],
        debounceMs: 200,
      },
      sortable: true,
      resizable: true,
      cellRenderer: TestNameRenderer,
      tooltipValueGetter: (params) => params.data?.testName || '',
      comparator: (valueA, valueB) => {
        const titleA = parseTestDisplayName(valueA).title.toLowerCase();
        const titleB = parseTestDisplayName(valueB).title.toLowerCase();
        return titleA.localeCompare(titleB);
      },
      wrapText: true,
      autoHeight: true,
      cellStyle: { 
        fontFamily: 'IBM Plex Sans, sans-serif',
        fontSize: '13px',
        lineHeight: '1.3',
      },
    },
    {
      field: 'testStats',
      headerName: 'Stats',
      pinned: 'left',
      width: 140,
      minWidth: 130,
      cellRenderer: TestStatsRenderer,
      sortable: true,
      comparator: (aPass, bPass) => bPass - aPass,
      valueGetter: (params) => params.data.passPercentage,
      filter: false,
      resizable: true,
      cellStyle: { 
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        paddingRight: '8px',
      },
    },
  ];
  
  // Add column for each environment
  environmentsList.forEach(env => {
    const meta = getEnvCustomerMeta(env);
    columns.push({
      field: env,
      headerName: meta.displayName,
      headerTooltip: `${env} — ${meta.region} · ${meta.purpose}`,
      width: 120,
      minWidth: 110,
      cellRenderer: HistorySparklineRenderer,
      sortable: false,
      filter: false,
      resizable: true,
      cellStyle: { 
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
      },
    });
  });
  
  return columns;
}

/**
 * Initialize AG Grid
 */
function initializeGrid(rowData) {
  const gridOptions = {
    columnDefs: createColumnDefs(),
    rowData: rowData,
    defaultColDef: {
      sortable: true,
      resizable: true,
    },
    enableCellTextSelection: true,
    suppressRowClickSelection: true,
    pagination: false,
    // Enable proper scrolling with fixed container
    domLayout: 'normal',
    // Ensure header stays visible during scroll
    suppressHorizontalScroll: false,
    suppressVerticalScroll: false,
  };
  
  const gridDiv = document.querySelector('#testResultsGrid');
  gridApi = agGrid.createGrid(gridDiv, gridOptions);
  
  // Set up filter changed event listener
  gridApi.addEventListener('filterChanged', updateTestCount);
}

/**
 * Update summary statistics
 */
function updateStatistics() {
  const totalTests = Object.keys(testResultsData).length;
  const totalEnvs = environmentsList.length;
  
  document.getElementById('total-env-count').textContent = totalEnvs;
  updateRunTypeStatus();
  
  // Update total tests count (will be set to filtered count when filters applied)
  updateTestCount();
}

function updateRunTypeStatus() {
  const status = document.getElementById('run-type-status');
  if (!status) {
    return;
  }
  const runMeta = getRunTypeCustomerMeta(activeRunType);
  status.textContent =
    environmentsList.length === 0
      ? `No ${runMeta.toggleLabel} environments in test results data`
      : `Showing ${environmentsList.length} ${runMeta.toggleLabel} environment${environmentsList.length === 1 ? '' : 's'}`;
}

/**
 * Update test count - shows total when no filters, shows filtered count when filters applied
 */
function updateTestCount() {
  const hasFilters = hasActiveFilters();
  const countElement = document.getElementById('total-tests-count');
  
  if (hasFilters && gridApi) {
    // Get filtered row count
    let visibleCount = 0;
    gridApi.forEachNodeAfterFilterAndSort((node) => {
      if (node.data) visibleCount++;
    });
    countElement.textContent = visibleCount;
  } else {
    // Show total count
    const totalTests = Object.keys(testResultsData).length;
    countElement.textContent = totalTests;
  }
}

/**
 * Check if any filters are currently active
 */
function hasActiveFilters() {
  if (!gridApi) return false;
  
  // Check if quick filter is active
  const quickFilter = gridApi.getGridOption('quickFilterText');
  if (quickFilter && quickFilter.trim() !== '') return true;
  
  // Check if tag filter is active
  const tagFilterInput = document.getElementById('tag-filter');
  if (tagFilterInput && tagFilterInput.value.trim() !== '') return true;
  
  // Check if external filter is active (failed tests, etc)
  const externalFilterPresent = gridApi.getGridOption('isExternalFilterPresent');
  if (externalFilterPresent && externalFilterPresent()) return true;
  
  return false;
}

/**
 * Show error message to user
 */
function showError(message) {
  const main = document.querySelector('.content');
  const errorDiv = document.createElement('div');
  errorDiv.className = 'error-message';
  
  // Create heading safely using createElement and textContent
  const heading = document.createElement('h3');
  heading.textContent = 'Error';
  errorDiv.appendChild(heading);
  
  // Create paragraph safely using createElement and textContent to prevent XSS
  const paragraph = document.createElement('p');
  paragraph.textContent = message;
  errorDiv.appendChild(paragraph);
  
  main.insertBefore(errorDiv, main.firstChild);
}

/**
 * Filter to show only tests with failures
 */
function filterFailedTests() {
  if (!gridApi) {
    console.error('Grid API not initialized');
    return;
  }
  
  // Get all tests that have at least one failure in any environment
  const failedTests = new Set();
  Object.keys(testResultsData).forEach(testName => {
    Object.values(testResultsData[testName]).forEach(envData => {
      if (envData && envData.history && envData.history.includes(0)) {
        failedTests.add(testName);
      }
    });
  });
  
  if (failedTests.size === 0) {
    alert('No failed tests found!');
    return;
  }
  
  // Use external filter to show only failed tests
  gridApi.setGridOption('isExternalFilterPresent', () => true);
  gridApi.setGridOption('doesExternalFilterPass', (node) => {
    return failedTests.has(node.data.testName);
  });
  
  gridApi.onFilterChanged();
}

/**
 * Filter tests by tag (case-insensitive partial match)
 */
function filterByTag(tagFilter) {
  if (!gridApi) {
    console.error('Grid API not initialized');
    return;
  }
  
  if (!tagFilter || tagFilter.trim() === '') {
    // Clear tag filter
    gridApi.setGridOption('isExternalFilterPresent', () => false);
    gridApi.setGridOption('doesExternalFilterPass', () => true);
  } else {
    // Apply tag filter
    const searchTerm = tagFilter.toLowerCase().trim();
    gridApi.setGridOption('isExternalFilterPresent', () => true);
    gridApi.setGridOption('doesExternalFilterPass', (node) => {
      const testName = node.data.testName;
      // Check all environments for tags matching the filter
      const envDataEntries = testResultsData[testName] || {};
      for (const envData of Object.values(envDataEntries)) {
        if (envData?.details?.tags) {
          const hasTags = envData.details.tags.some(tag =>
            tag.toLowerCase().includes(searchTerm)
          );
          if (hasTags) {
            return true;
          }
        }
      }
      return false;
    });
  }
  
  gridApi.onFilterChanged();
}

/**
 * Clear all filters
 */
function clearFilters() {
  if (!gridApi) {
    console.error('Grid API not initialized');
    return;
  }
  
  // Clear column filters
  gridApi.setFilterModel(null);
  
  // Clear external filter
  gridApi.setGridOption('isExternalFilterPresent', () => false);
  gridApi.setGridOption('doesExternalFilterPass', () => true);
  
  // Clear quick filter
  const quickFilterInput = document.getElementById('quick-filter');
  if (quickFilterInput) {
    quickFilterInput.value = '';
    gridApi.setGridOption('quickFilterText', '');
  }
  
  gridApi.onFilterChanged();
}

/**
 * Export grid data to Excel with two sheets
 * Sheet 1: Current Status (latest run only)
 * Sheet 2: History Trends (all 3 runs)
 */
function exportToExcel() {
  try {
    // Sheet 1: Current Status - Latest run only
    const currentStatusData = [];
    gridApi.forEachNodeAfterFilterAndSort((node) => {
      const row = { 'Test Name': node.data.testName };
      
      environmentsList.forEach(env => {
        const envData = testResultsData[node.data.testName]?.[env];
        if (envData && envData.history && envData.history.length > 0) {
          // Get only the latest run status
          const latestStatus = envData.history[envData.history.length - 1];
          row[env] = latestStatus === 1 ? 'PASS' : latestStatus === 0 ? 'FAIL' : 'SKIP';
        } else {
          row[env] = '—';
        }
      });
      
      currentStatusData.push(row);
    });
    
    // Sheet 2: History Trends - All 3 runs
    const historyTrendsData = [];
    gridApi.forEachNodeAfterFilterAndSort((node) => {
      const row = { 'Test Name': node.data.testName };
      
      environmentsList.forEach(env => {
        const envData = testResultsData[node.data.testName]?.[env];
        if (envData && envData.history) {
          // Convert history to readable format (oldest → newest)
          const historyStr = envData.history
            .map(s => s === 1 ? 'P' : s === 0 ? 'F' : 'S')
            .join(' → ');
          row[env] = historyStr;
        } else {
          row[env] = '—';
        }
      });
      
      historyTrendsData.push(row);
    });
    
    // Create workbook with 2 sheets
    const wb = XLSX.utils.book_new();
    
    const ws1 = XLSX.utils.json_to_sheet(currentStatusData);
    XLSX.utils.book_append_sheet(wb, ws1, 'Current Status');
    
    const ws2 = XLSX.utils.json_to_sheet(historyTrendsData);
    XLSX.utils.book_append_sheet(wb, ws2, 'History Trends');
    
    const timestamp = new Date().toISOString().split('T')[0];
    XLSX.writeFile(wb, `wst-test-results-${timestamp}.xlsx`);
  } catch (error) {
    console.error('Export error:', error);
    alert('Failed to export to Excel. Please check the console for details.');
  }
}

/**
 * Export grid data to PDF with two separate tables
 * Table 1: Current Status (latest run only)
 * Table 2: History Trends (all 3 runs)
 */
function exportToPDF() {
  try {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF('landscape');
    
    // Add title
    doc.setFontSize(16);
    doc.text('WST Test Results Dashboard', 14, 15);
    
    doc.setFontSize(10);
    doc.text(`Generated: ${new Date().toLocaleString()}`, 14, 22);
    doc.text(`Total Tests: ${Object.keys(testResultsData).length} | Environments: ${environmentsList.length}`, 14, 28);
    
    // ===== TABLE 1: Current Status (Latest Run) =====
    doc.setFontSize(12);
    doc.setFont(undefined, 'bold');
    doc.text('Current Status (Latest Run)', 14, 38);
    
    const headers1 = [['Test Name', ...environmentsList]];
    const rows1 = [];
    
    gridApi.forEachNodeAfterFilterAndSort((node) => {
      const row = [node.data.testName];
      
      environmentsList.forEach(env => {
        const envData = testResultsData[node.data.testName]?.[env];
        if (envData && envData.history && envData.history.length > 0) {
          const latestStatus = envData.history[envData.history.length - 1];
          row.push(latestStatus === 1 ? 'PASS' : latestStatus === 0 ? 'FAIL' : 'SKIP');
        } else {
          row.push('—');
        }
      });
      
      rows1.push(row);
    });
    
    const table1Config = {
      head: headers1,
      body: rows1,
      startY: 42,
      styles: { 
        fontSize: 7,
        cellPadding: 1.5,
      },
      headStyles: {
        fillColor: [41, 128, 185],
        textColor: 255,
        fontStyle: 'bold',
      },
      columnStyles: {
        0: { cellWidth: 70 },
      },
      margin: { left: 14, right: 14 },
    };
    
    doc.autoTable(table1Config);
    
    // Get Y position after first table
    let finalY = doc.lastAutoTable.finalY || 42;
    
    // Add spacing
    finalY += 10;
    
    // ===== TABLE 2: History Trends (Last 3 Runs) =====
    doc.setFontSize(12);
    doc.setFont(undefined, 'bold');
    doc.text('History Trends (Last 3 Runs)', 14, finalY);
    
    const headers2 = [['Test Name', ...environmentsList]];
    const rows2 = [];
    
    gridApi.forEachNodeAfterFilterAndSort((node) => {
      const row = [node.data.testName];
      
      environmentsList.forEach(env => {
        const envData = testResultsData[node.data.testName]?.[env];
        if (envData && envData.history) {
          const historyStr = envData.history
            .map(s => s === 1 ? 'P' : s === 0 ? 'F' : 'S')
            .join(' → ');
          row.push(historyStr);
        } else {
          row.push('—');
        }
      });
      
      rows2.push(row);
    });
    
    doc.autoTable({
      head: headers2,
      body: rows2,
      startY: finalY + 4,
      styles: { 
        fontSize: 7,
        cellPadding: 1.5,
      },
      headStyles: {
        fillColor: [142, 68, 173],
        textColor: 255,
        fontStyle: 'bold',
      },
      columnStyles: {
        0: { cellWidth: 70 },
      },
      margin: { left: 14, right: 14 },
    });
    
    const timestamp = new Date().toISOString().split('T')[0];
    doc.save(`wst-test-results-${timestamp}.pdf`);
  } catch (error) {
    console.error('Export error:', error);
    alert('Failed to export to PDF. Please check the console for details.');
  }
}

/**
 * Initialize the dashboard
 */
async function initDashboard() {
  try {
    await loadCustomerLabels();
    applyRunTypeToggleLabels();
    await loadEnvironmentMeta();
    await loadTestResults();
    
    activeRunType = getStoredRunType();
    syncRunTypeToUrl(activeRunType);
    refreshGridForRunType(activeRunType);

    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('filter') === 'failed') {
      const failedBtn = document.getElementById('filter-failed');
      if (failedBtn && failedBtn.textContent.includes('Failed')) {
        filterFailedTests();
        failedBtn.textContent = 'Clear';
        failedBtn.classList.add('active');
      }
    }

    bindRunTypeToggle((nextRunType) => {
      refreshGridForRunType(nextRunType);
      if (environmentsList.length === 0 && activeRunType === RUN_TYPES.sit) {
        alert('No release-validation environment columns in test results. Switch to BAT or publish a SIT Jenkins run first.');
      }
    });
    
    // Setup event listeners
    document.getElementById('filter-failed').addEventListener('click', () => {
      const btn = document.getElementById('filter-failed');
      if (btn.textContent.includes('Failed')) {
        filterFailedTests();
        btn.textContent = 'Clear';
        btn.classList.add('active');
      } else {
        clearFilters();
        btn.textContent = 'Failed only';
        btn.classList.remove('active');
      }
    });
    
    document.getElementById('export-xls').addEventListener('click', exportToExcel);
    document.getElementById('export-pdf').addEventListener('click', exportToPDF);
    
    // Setup quick filter
    const quickFilterInput = document.getElementById('quick-filter');
    quickFilterInput.addEventListener('input', (e) => {
      gridApi.setGridOption('quickFilterText', e.target.value);
    });

    // Setup tag filter
    const tagFilterInput = document.getElementById('tag-filter');
    if (tagFilterInput) {
      tagFilterInput.addEventListener('input', (e) => {
        filterByTag(e.target.value);
      });
    }
    
  } catch (error) {
    console.error('Dashboard initialization error:', error);
    showError('Failed to initialize dashboard. Please check the console for details.');
  }
}

// Start dashboard when DOM is ready
document.addEventListener('DOMContentLoaded', initDashboard);
