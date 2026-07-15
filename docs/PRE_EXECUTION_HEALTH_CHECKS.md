# Pre-Execution Health Checks

This document explains the pre-execution health checks that run as a standalone step before `executor.py` starts Robot Framework suites.

## What Is Checked

Before suite execution starts, the health-check step validates:

1. **Application availability**
   - Checks the configured `base_url`
   - Also probes `<base_url>/reflexisversion.txt`
2. **DB2 connectivity**
   - Validates `DB2_CONNECTION` from runtime environment
   - Performs a lightweight DB2 connect/disconnect

Implementation is in `utils/health_checks.py`, and Jenkins invokes `python -m dev_utils.run_health_check`.

## Default Behavior

Health checks are expected to run as Jenkins step 1. If this step passes, Jenkins starts `executor.py`.

For specialized Jenkins jobs that must bypass the health-check step entirely, set `skipHealthCheck: true` in the environment Jenkinsfile. The shared library maps this to the `SKIP_HEALTH_CHECK` job parameter.

## CLI Controls

Use these options with `python -m dev_utils.run_health_check`:

- `--test-env <ENV>`
  - Required environment name
- `--timeout <seconds>`
  - Sets timeout for health checks
  - Default: `10`
- `--skip-database`
  - Bypasses DB2 and queue checks
  - Useful for targeted troubleshooting
- `--queue-pending-threshold <count>`
  - Fails when `rfx_queue` contains rows with `JOBS_PENDING` above this value
  - Default: `100`

## Failure Behavior

If any health check fails:

- Health-check runner raises/logs a runtime error
- Jenkins fails the health-check step
- Process exits with code `1`
- `executor.py` / Robot/Pabot execution does **not** start
- DB2 failure messages redact credential values before printing

This fail-fast behavior prevents long suite runs against unhealthy environments.

## Log Messages to Expect

On success, you should see logs similar to:

- `Application health check passed: ...`
- `DB2 health check passed: ...`
- followed by `Health checks passed. Safe to start executor.py`

On failure, you should see:

- `Health checks failed: ...`

## Example Commands

```bash
# Standalone health check gate (run this before executor.py)
uv run python -m dev_utils.run_health_check --test-env PBST_SB
```

```bash
# Increase timeout
uv run python -m dev_utils.run_health_check --test-env PBST_SB --timeout 20
```

```bash
# Temporarily bypass DB checks (not recommended for normal runs)
uv run python -m dev_utils.run_health_check --test-env PBST_SB --skip-database
```

```bash
# Use a custom queue pending threshold
uv run python -m dev_utils.run_health_check --test-env PBST_SB --queue-pending-threshold 150
```

## Troubleshooting

### `Application check failed`

- Verify `base_url` in `test_data/environments/<ENV>/config.json`
- Confirm environment endpoint is reachable from runner host
- Increase timeout with `--timeout`

### `Database check failed`

- Verify `DB2_CONNECTION` is present and valid JSON
- Ensure required fields exist: `database`, `hostname`, `port`, `username`, `password`
- Validate network/firewall access from runner to DB2 host/port
- Verify DB2 credentials are correct and not expired

### Checks skipped unexpectedly

- Confirm `--skip-database` is not passed
- Confirm Jenkinsfile/shared-library call is using the health-check step before `executor.py`


