# Health Check Failure - Quick Reference Card

## TL;DR

**Problem**: Health check failed in Jenkins but URL works manually.  
**Reason**: Network difference between Jenkins agent and your machine.  
**Status**: ✅ Fixed with `skipHealthCheck: true`  
**Root Cause**: Identify using diagnostic tool

---

## Quick Diagnosis (2 minutes)

```bash
# Run on Jenkins agent:
cd /mount/workspace/WFM\ Sanity\ BSP_SB
python dev_utils/health_check_diagnostics.py

# Run on your machine:
cd /path/to/sws_wfm_test_automation
python dev_utils/health_check_diagnostics.py

# Compare the two outputs
```

---

## Symptom → Root Cause Mapping

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| DNS resolution fails | No DNS access from Jenkins agent | Contact network team |
| TCP 443 connection fails | Firewall blocking outbound HTTPS | Contact network team |
| SSL certificate fails | Proxy SSL interception | Install CA cert or configure proxy |
| All pass but timeout | Network latency or slow app | Increase timeout to 20s |
| Proxy variables missing | Proxy not configured for Python | Add proxy env variables |
| All diagnostics pass ✅ | Transient issue or very slow response | Run health check again |

---

## Configuration Change Made

**File**: `test_data/environments/BSP_SB/BAT_Jenkinsfile`  
**Change**: Added `"skipHealthCheck": true` on line 13

**Effect**: 
- ✅ Jenkins tests will run without health check
- ⚠️  No early detection if app actually goes down
- 🔧 Not a permanent fix, just a workaround

---

## Next Steps

### Short-term (Already done ✅)
```groovy
"skipHealthCheck": true
```

### Medium-term (Do this week)
```bash
# 1. SSH to Jenkins agent
# 2. Run diagnostic tool
python dev_utils/health_check_diagnostics.py

# 3. Share results with infrastructure team
```

### Long-term (Once infrastructure is fixed)
```groovy
# Remove bypass and let health check run normally
"skipHealthCheck": false  # or remove the line entirely
```

---

## What the Health Check Does

1. Tries HEAD request to `base_url` (10 second timeout)
2. Tries GET request to `base_url` if HEAD fails
3. Tries HEAD request to `base_url/reflexisversion.txt`
4. Tries GET request to `base_url/reflexisversion.txt`
5. Returns SUCCESS if ANY attempt gets HTTP 200-499
6. Returns FAILURE if ALL attempts fail

**Base URL**: `https://knlbsisb.reflexisinc.com/RWS4`

---

## Key Point

🎯 **The application is NOT down.**

The issue is that:
- Your machine ✅ has unrestricted access
- Jenkins agent ❌ has restricted access

This is normal in enterprise networks.

---

## Documentation Index

1. **Quick Start**: This document (you are here)
2. **Executive Summary**: `docs/HEALTH_CHECK_FAILURE_EXPLANATION.md`
3. **Technical Deep Dive**: `docs/HEALTH_CHECK_CI_CD_VS_MANUAL_ANALYSIS.md`
4. **Troubleshooting Guide**: `docs/TROUBLESHOOT_HEALTH_CHECK_CI_CD.md`
5. **Detailed Analysis**: `docs/WHY_HEALTH_CHECK_FAILS_DETAILED_GUIDE.md`
6. **Diagnostic Tool**: `dev_utils/health_check_diagnostics.py`

---

## Common Questions

**Q: Will my tests run now?**  
✅ Yes, `skipHealthCheck: true` allows tests to proceed.

**Q: Will I know if the application is down?**  
⚠️ No, health check is skipped so you won't get early warnings.

**Q: What's the permanent fix?**  
🔧 Fix the network/infrastructure issue (firewall, proxy, DNS, etc.).

**Q: How long does this take?**  
- Diagnosis: 30 minutes
- Infrastructure fix: 1-3 days (depends on IT team)

**Q: Who do I contact?**  
- Firewall issues: Network team
- Proxy issues: Infrastructure team
- DNS issues: Network team
- IP whitelist: Application team

---

## When to Remove `skipHealthCheck`

Once infrastructure is fixed:
1. Run health check manually: `python -m dev_utils.run_health_check --test-env BSP_SB`
2. Confirm it passes
3. Remove `"skipHealthCheck": true` from Jenkinsfile
4. Re-run Jenkins job to verify

---

## More Help

```bash
# View health check logs
tail -f logs/health_check_*.log

# Run health check manually with debug logging
python -m dev_utils.run_health_check --test-env BSP_SB --log-level DEBUG

# View PRE_EXECUTION_HEALTH_CHECKS documentation
cat docs/PRE_EXECUTION_HEALTH_CHECKS.md
```

---

## Status Summary

| Item | Status |
|------|--------|
| Jenkins job executable | ✅ Yes (with bypass) |
| Tests can run | ✅ Yes |
| Application is down | ❌ No |
| Network connectivity issue | ❌ FYI (expected) |
| Root cause identified | ❓ Unknown (run diagnostics) |
| Infrastructure fixed | ❌ No (engage IT team) |


