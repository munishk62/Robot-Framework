# Troubleshooting Health Check Failures: CI/CD vs Manual Access

## Quick Start

If your health check is failing but the URL works manually, run this diagnostic:

```bash
cd /path/to/sws_wfm_test_automation

# From Jenkins agent (where health check is failing)
python dev_utils/health_check_diagnostics.py

# From your local machine (where it works manually)
python dev_utils/health_check_diagnostics.py

# Compare the outputs
```

This will help identify WHERE the difference is.

---

## Understanding the Root Causes

### Symptom 1: DNS Resolution Fails ❌ → DNS Issue

**Output**:
```
1. DNS Resolution Test
DNS resolution failed for knlbsisb.reflexisinc.com: [Errno -2] Name or service not known
```

**Root Cause**: Jenkins agent cannot resolve the hostname
- DNS server on Jenkins agent is misconfigured
- Network isolation prevents DNS queries
- Internal DNS doesn't have entry for external hostname

**Solution**:
```bash
# Contact infrastructure team to:
# 1. Verify DNS resolution from Jenkins agent subnet
# 2. Add DNS entry if using internal DNS
# 3. Ensure Jenkins agent can reach public DNS (8.8.8.8)

# Test:
nslookup knlbsisb.reflexisinc.com
```

---

### Symptom 2: TCP Connection Fails ❌ → Network/Firewall Issue

**Output**:
```
2. Network Connectivity Tests
TCP connection failed to knlbsisb.reflexisinc.com:443: [Errno 111] Connection refused
```

**Root Cause**: Jenkins agent cannot reach port 443
- Corporate firewall blocking outbound HTTPS
- Network ACLs restricting Jenkins agent subnet
- Endpoint DOWN (but you said it works manually, so unlikely)

**Solution**:
```bash
# Contact infrastructure/network team:
# - Add Jenkins agent IP to allowed outbound list
# - Configure firewall rule for https://knlbsisb.reflexisinc.com:443
# - If behind corporate proxy, configure proxy settings

# Test from Jenkins agent:
telnet knlbsisb.reflexisinc.com 443
curl -v https://knlbsisb.reflexisinc.com/RWS4
```

---

### Symptom 3: SSL Certificate Fails ❌ → Proxy/SSL Issue

**Output**:
```
3. SSL Certificate Validation Test
SSL certificate check failed for knlbsisb.reflexisinc.com: [SSL: CERTIFICATE_VERIFY_FAILED]
```

**Root Cause**: One of two scenarios:
1. **Corporate Proxy with SSL Interception**: Proxy terminates SSL and re-issues certificates
2. **Environment-Specific TLS Config**: Different certificate trust stores

**Solution - If Using Corporate Proxy**:
```bash
# Proxy intercepts HTTPS - you need to configure Python to trust proxy's cert

# Option A: Configure system certificate store
# Contact infrastructure to install proxy CA certificate

# Option B: Disable SSL verification (NOT RECOMMENDED for production)
# Set environment variable before running health check:
export PYTHONHTTPSVERIFY=0

# Option C: Configure proxy in health check script
# Edit utils/health_checks.py to use ProxyHandler
```

---

### Symptom 4: HTTP Request Fails ❌ → Actual Connectivity Issue

**Output**:
```
4. HTTP Request Tests (Simulating Health Check)
HEAD https://knlbsisb.reflexisinc.com/RWS4: [Errno -2] Name or service not known
GET https://knlbsisb.reflexisinc.com/RWS4: [Errno 110] Connection timed out
```

**Root Cause**: Application genuinely unreachable
- Network timeout (application too slow or network too far)
- Application is DOWN (but you said it works manually)
- Connection closed before response

**Solution**:
```bash
# Increase timeout
# Edit BSP_SB/BAT_Jenkinsfile:
"healthCheckTimeout": "20"  # Increase from 10 seconds

# Or check if application needs proxy access
env | grep -i proxy
```

---

### Symptom 5: Proxy Environment Variables Missing ⚠️ → Proxy Configuration Issue

**Output**:
```
5. Proxy Environment Variables
(No proxy environment variables found)
```

**But you know**:
- Your browser works (because browser auto-detects proxy)
- Health check fails (because Python doesn't auto-detect)

**Root Cause**: Jenkins agent requires proxy but environment isn't configured

**Solution**:
```bash
# Contact infrastructure team to provide proxy details

# Then in Jenkinsfile, add:
environment {
    http_proxy = 'http://proxy.company.com:8080'
    https_proxy = 'http://proxy.company.com:8080'
    no_proxy = 'localhost,127.0.0.1,.company.com'
}

# Or set in Jenkins agent configuration
```

---

### Symptom 6: All Tests Pass ✅ But Health Check Still Fails

**Output**:
```
✅ Application appears REACHABLE from this environment
This suggests the issue is NOT with connectivity.
```

**Root Cause**: Likely one of these:
1. **Transient Issue**: Network was temporarily down during actual health check
2. **Timeout Too Aggressive**: Health check completed but took >10s
3. **Application Slow Response**: Different route/performance from CI/CD
4. **Load Balancer Behavior**: Sometimes health check endpoint behaves differently
5. **Rate Limiting**: Application may rate-limit health checks

**Solution**:
```bash
# Option A: Increase timeout
"healthCheckTimeout": "20"

# Option B: Check application logs during health check failure time
# Contact application team

# Option C: Run health check multiple times to see if it's transient
python -m dev_utils.run_health_check --test-env BSP_SB
python -m dev_utils.run_health_check --test-env BSP_SB
python -m dev_utils.run_health_check --test-env BSP_SB
```

---

## Comparing Outputs: Jenkins Agent vs Your Local Machine

### 1. Create baseline from your local machine:
```bash
# On YOUR LAPTOP:
cd /path/to/sws_wfm_test_automation
python dev_utils/health_check_diagnostics.py > diagnostic_local.txt
```

### 2. Create baseline from Jenkins agent:
```bash
# On JENKINS AGENT SWS_UBU_03:
cd /mount/workspace/WFM\ Sanity\ BSP_SB
python dev_utils/health_check_diagnostics.py > diagnostic_jenkins.txt
```

### 3. Compare:
```bash
# Look for differences in:
diff diagnostic_local.txt diagnostic_jenkins.txt

# Specifically look for:
# - DNS resolution differences
# - Proxy settings (proxy in one but not other)
# - Response times (one much slower than other)
# - SSL certificate differences
```

---

## Most Common Scenarios

### "Works on my machine, fails in Jenkins" Checklist

- [ ] **DNS**: Try `nslookup knlbsisb.reflexisinc.com` on Jenkins agent
- [ ] **Firewall**: Try `curl https://knlbsisb.reflexisinc.com/RWS4` on Jenkins agent (within 10 sec timeout)
- [ ] **Proxy**: Check `env | grep -i proxy` on Jenkins agent
- [ ] **Network Route**: Jenkins agent might be in different data center/region
- [ ] **Time-based rules**: Check if access is only allowed during business hours
- [ ] **VPN**: Verify Jenkins agent is VPN-connected if required
- [ ] **IP Whitelist**: Verify Jenkins agent IP is in application's whitelist

---

## Current Status: What We Did

You've already applied the bypass:
```groovy
"skipHealthCheck": true  # Added to BSP_SB/BAT_Jenkinsfile
```

This allows tests to run, but it masks the underlying connectivity issue.

**Recommended Next Steps**:

1. **Short-term** (Already done): Use `skipHealthCheck: true` to unblock CI/CD
2. **Medium-term** (This week): Run diagnostics to identify root cause
3. **Long-term** (Next sprint): Fix infrastructure (proxy, firewall, DNS) so health check works

---

## Advanced Diagnostics

### Option A: Run with Python Debug Logging

```bash
python -m dev_utils.run_health_check --test-env BSP_SB \
  --log-level DEBUG \
  --log-file debug_health_check.log

# Then review:
cat debug_health_check.log
```

### Option B: Trace Network Requests

```bash
# Use tcpdump to see what packets are being sent
# (Requires root/admin privileges)
sudo tcpdump -i any -A 'tcp port 443' \
  'host knlbsisb.reflexisinc.com'

# Then run health check in another terminal
python -m dev_utils.run_health_check --test-env BSP_SB
```

### Option C: Manual Python Test

```bash
python3 << 'EOF'
import urllib.request
import ssl

url = "https://knlbsisb.reflexisinc.com/RWS4"
headers = {"User-Agent": "WFM-Test-Automation-HealthCheck"}

try:
    request = urllib.request.Request(url, headers=headers, method="HEAD")
    response = urllib.request.urlopen(request, timeout=10)
    print(f"SUCCESS: {response.getcode()}")
except Exception as e:
    print(f"FAILURE: {type(e).__name__}: {e}")
EOF
```

---

## Questions for Infrastructure/Network Team

If you need to escalate, ask them:

1. **"Is there a firewall rule for Jenkins agent outbound to HTTPS (port 443)?"**
2. **"Does the network require a proxy for external HTTPS connectivity?"**
3. **"Is the Jenkins agent subnet locked down? Can it reach external IPs?"**
4. **"Is there a corporate Certificate Authority intercepting SSL traffic?"**
5. **"Can you test connectivity from Jenkins agent `SWS_UBU_03` to `knlbsisb.reflexisinc.com:443`?"**
6. **"Is the application IP-whitelisted? Should I add Jenkins agent IP?"**
7. **"Is VPN required to access this application?"**

---

## References

- Health Check Implementation: `utils/health_checks.py` (lines 87-108)
- Health Check Runner: `dev_utils/run_health_check.py`
- Documentation: `docs/PRE_EXECUTION_HEALTH_CHECKS.md`
- Updated Jenkinsfile: `test_data/environments/BSP_SB/BAT_Jenkinsfile` (with `skipHealthCheck: true`)


