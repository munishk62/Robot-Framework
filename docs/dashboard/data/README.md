# Dashboard Data Directory

This directory contains JSON data files that power the WST Test Automation Dashboards.

## Files

### Summary Dashboard Data
- **environments.json** - Latest test run summary per environment
- **history.json** - Aggregate test metrics over last 7 updates
- **env_history.json** - Per-environment metrics over last 7 runs

### Detailed Test Results Dashboard Data
- **test_results.json** - Individual test execution history (last 3 runs per environment)

## test_results.json Structure

```json
{
  "test_name": {
    "env_name": {
      "history": [1, 0, 2],
      "details": {
        "msg": "Error or skip message",
        "url": "https://jenkins.../build/123",
        "duration_ms": 1234
      },
      "tags": ["tag1", "tag2"]
    }
  }
}
```

### Field Descriptions

**history** (Array of integers):
- Contains last 3 run statuses in chronological order (oldest to newest)
- `1` = PASS
- `0` = FAIL  
- `2` = SKIP
- Example: `[0, 0, 1]` means: Run 1 FAILED, Run 2 FAILED, Run 3 PASSED

**details** (Object):
- Information from the most recent run (last item in history array)
- **msg**: Error message (max 200 chars for FAIL) or skip reason (max 100 chars for SKIP)
- **url**: Jenkins build URL for linking to detailed logs
- **duration_ms**: Test execution time in milliseconds

## Dashboard Visual Representation

The detailed dashboard uses a two-part cell design:

```
┌──────────────────┐
│                  │
│   [MAIN BOX]    │  ← Latest run (history[2])
│                  │    Large, prominent display
│   ▪ ▪           │  ← Previous runs (history[0], history[1])
└──────────────────┘    Small mini-indicators
```

This design:
- **Emphasizes current status** (main box)
- **Provides historical context** (mini indicators below)
- **Enables quick pattern recognition** (scan for red boxes = current failures)

## Example Scenarios

### Scenario 1: Stable Passing Test
```json
"Tests.Web.Login": {
  "QA29_B0": {
    "history": [1, 1, 1],
    "details": {
      "msg": "",
      "url": "https://jenkins.../123",
      "duration_ms": 3456
    }
  }
}
```
**Dashboard shows**: Large green box + 2 green mini-indicators = ✅ Stable test

### Scenario 2: Currently Failing Test
```json
"Tests.Web.CreateEmployee": {
  "QA28": {
    "history": [1, 1, 0],
    "details": {
      "msg": "Database error: Cannot insert duplicate key...",
      "url": "https://jenkins.../124",
      "duration_ms": 8976
    }
  }
}
```
**Dashboard shows**: Large red box + 2 green mini-indicators = 🚨 New failure

### Scenario 3: Flaky Test
```json
"Tests.Web.Schedule": {
  "DEMO05": {
    "history": [0, 1, 0],
    "details": {
      "msg": "Timeout waiting for element...",
      "url": "https://jenkins.../125",
      "duration_ms": 30012
    }
  }
}
```
**Dashboard shows**: Large red box + mixed mini-indicators = ⚠️ Unstable test

### Scenario 4: Consistently Skipped
```json
"Tests.Web.AdvancedFeature": {
  "QA28": {
    "history": [2, 2, 2],
    "details": {
      "msg": "Skipped: Feature not available in this environment version",
      "url": "https://jenkins.../126",
      "duration_ms": 0
    }
  }
}
```
**Dashboard shows**: Large yellow box + 2 yellow mini-indicators = ℹ️ Intentionally skipped

## Updating Data

### Via Jenkins (Automated)
```bash
python dev_utils/test_results_parser.py \
  --output-xml results/output.xml \
  --env-name QA29_B0 \
  --build-url $BUILD_URL \
  --data-dir docs/dashboard/data
```

### Manual Update (Testing)
```bash
# For local development/testing
python dev_utils/test_results_parser.py \
  --output-xml path/to/output.xml \
  --env-name LOCAL_TEST \
  --build-url "https://jenkins.example.com/job/test/123"
```

## Data Retention

- **Summary Data**: Last 7 updates
- **Test Results**: Last 3 runs per test per environment
- **File Size**: ~100KB - 5MB (depends on test count)
- **Recommended Cleanup**: Archive when > 10MB

## Validation

Validate JSON syntax before committing:
```bash
python -m json.tool test_results.json > /dev/null && echo "Valid JSON" || echo "Invalid JSON"
```

## References

- [Test Results Dashboard Documentation](../TEST_RESULTS_DASHBOARD.md)
- [Dashboard Setup Guide](../DASHBOARD_SETUP.md)
- [Parser Documentation](../../dev_utils/DASHBOARD_UTILS_README.md)
