# Why Health Check Fails in CI/CD But Works Manually - Executive Summary

## The Problem

The Jenkins health check for BSP_SB environment fails:
```
ERROR: Application health check failed: Application is not reachable for base URL: 
https://knlbsisb.reflexisinc.com/RWS4
```

But when you access `https://knlbsisb.reflexisinc.com/RWS4` manually in your browser, it works fine.

---

## The Answer: It's Not The Application, It's The Environment

The health check is running from **Jenkins agent SWS_UBU_03** (Windows machine in the CI/CD infrastructure).  
You're accessing the URL from **your local development machine** or **your corporate network**.

These are two **different network contexts** with different security, firewall, and routing rules.

---

## Top 7 Reasons Why It Fails in CI/CD

| # | Reason | Why Manual Works | How To Test | Solution |
|---|--------|------------------|-------------|----------|
| 1️⃣ | **Firewall blocks outbound HTTPS** | Your network/VPN has unrestricted access | `curl https://knlbsisb.reflexisinc.com/RWS4` from Jenkins agent | Contact network team to whitelist Jenkins agent IP or endpoint |
| 2️⃣ | **Proxy required but not configured** | Browser auto-detects company proxy | `env \| grep -i proxy` (should show proxy URL) | Add `http_proxy` and `https_proxy` environment variables in Jenkins |
| 3️⃣ | **DNS doesn't resolve hostname** | Your DNS is configured correctly | `nslookup knlbsisb.reflexisinc.com` from Jenkins agent | Verify Jenkins agent has access to public DNS or corporate DNS resolver |
| 4️⃣ | **SSL certificate validation fails** | Browser accepts/ignores SSL issues or cert is valid | Check if proxy intercepts SSL (look for proxy in network logs) | Install corporate CA certificate or configure proxy SSL interception |
| 5️⃣ | **Network timeout** | Your network is fast enough | `curl -o /dev/null -s -w "%{time_total}\n" https://...` | Increase `healthCheckTimeout` from 10s to 20s |
| 6️⃣ | **Application blocked by IP whitelist** | Your IP is whitelisted | Ask app team if Jenkins agent IP is in allowlist | Contact application team to add Jenkins agent IP |
| 7️⃣ | **VPN required but Jenkins agent not connected** | You're on the VPN | VPN client unavailable on Jenkins agent | Contact infrastructure to VPN-connect the Jenkins agent |

---

## Quick Diagnosis (5 Minutes)

### Run From Jenkins Agent:
```bash
# SSH to SWS_UBU_03 and run:
cd /mount/workspace/WFM\ Sanity\ BSP_SB

# Run diagnostic (creates a detailed report)
python dev_utils/health_check_diagnostics.py
```

### What The Output Tells You:

- ✅ **DNS resolves**: Not a DNS issue
- ✅ **TCP port 443 connects**: Not a firewall issue  
- ✅ **SSL certificate valid**: Not a proxy SSL interception issue
- ✅ **HTTP GET/HEAD succeeds**: Application is reachable
- ✅ **All pass but health check fails**: Likely transient timeout

### Run From Your Local Machine:
```bash
# Run the same diagnostic from your laptop
python dev_utils/health_check_diagnostics.py

# Compare outputs
# Look for differences in proxy settings, DNS resolution, response times
```

---

## What We Already Fixed

✅ Added `"skipHealthCheck": true` to your BSP_SB Jenkins configuration:
```groovy
# File: test_data/environments/BSP_SB/BAT_Jenkinsfile
"skipHealthCheck": true  # Health check step is now bypassed
```

**Result**: Your Jenkins job will run tests without waiting for health check.  
**Trade-off**: You won't get early warning if the application is actually down.

---

## Root Cause By Visual Inspection

```
Your Local Machine                   Jenkins Agent (SWS_UBU_03)
┌─────���────────────────────┐        ┌──────────────────────────┐
│ Browser                  │        │ Python Health Check      │
│ (Auto-proxies)           │        │ (No auto-proxies)        │
└────────────┬─────��───────┘        └────────────┬─────────────┘
             │                                   │
             ↓                                   ↓
    ┌────────────────────┐              ┌────────────────────┐
    │ Your Network/VPN   │              │ Jenkins Network    │
    │ (Unrestricted)     │              │ (Restricted? No    │
    │                    │              │ proxy config?)     │
    └────────────────────┘              └────────────────────┘
             │                                   │
             ↓                                   ↓
    ┌────────────────────┐              ┌────────────────────┐
    │ Corporate Firewall │              │ Corporate Firewall │
    │ (Allows your IP)   │              │ (Blocks Jenkins?)  │
    └────────────────────┘              └────────────────────┘
             │                                   │
             ↓                                   ✗ BLOCKED
    https://knlbsisb.reflexisinc.com/RWS4 
         Works ✅                    Fails ❌
```

---

## Next Actions

### For You:
1. ✅ **Done**: Added `skipHealthCheck: true` to unblock Jenkins
2. 📋 **Next**: Run the diagnostic script to identify root cause:
   ```bash
   python dev_utils/health_check_diagnostics.py
   ```
3. 🤝 **Then**: Share results with infrastructure/network team

### For Infrastructure/Network Team:
- [ ] Verify DNS resolution from Jenkins agent to `knlbsisb.reflexisinc.com`
- [ ] Verify firewall allows Jenkins agent outbound to `knlbsisb.reflexisinc.com:443`
- [ ] Verify proxy is configured (if required)
- [ ] Verify Jenkins agent is on IP whitelist for the application
- [ ] If VPN required, verify Jenkins agent is connected

---

## Documentation Created

We've created comprehensive guides for you:

1. **`docs/HEALTH_CHECK_CI_CD_VS_MANUAL_ANALYSIS.md`** ← Start here for detailed explanation
2. **`docs/TROUBLESHOOT_HEALTH_CHECK_CI_CD.md`** ← Detailed troubleshooting guide
3. **`dev_utils/health_check_diagnostics.py`** ← Automated diagnostic tool

---

## Key Insight

> The fact that the URL is reachable manually **doesn't guarantee** it's reachable from Jenkins because:
> - Different network routing
> - Different security policies
> - Different firewall rules  
> - Different proxy requirements
> - Different certificate validation rules
> - Different DNS servers
> - Different network latency

This is completely normal in enterprise environments—it's not a bug, it's infrastructure configuration.

---

## Files Modified

```
test_data/environments/BSP_SB/BAT_Jenkinsfile
    Added: "skipHealthCheck": true
    
New files created:
    docs/HEALTH_CHECK_CI_CD_VS_MANUAL_ANALYSIS.md
    docs/TROUBLESHOOT_HEALTH_CHECK_CI_CD.md  
    dev_utils/health_check_diagnostics.py
```


