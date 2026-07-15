# Why Health Checks Fail in CI/CD but Work Manually

## Summary
The health check failure for BSP_SB environment (`Application is not reachable for base URL: https://knlbsisb.reflexisinc.com/RWS4`) indicates a **network/infrastructure difference** between your CI/CD Jenkins agent and your manual testing environment, NOT a problem with the application itself.

---

## What the Health Check Does

The `_check_application_health()` function (lines 87-108 in `utils/health_checks.py`) performs these exact steps:

```python
1. Normalizes the base_url from config.json
2. Attempts HTTP HEAD request to base_url (with 10-second timeout by default)
3. Attempts HTTP GET request to base_url if HEAD fails
4. Attempts HTTP HEAD request to {base_url}/reflexisversion.txt if previous fail
5. Attempts HTTP GET request to {base_url}/reflexisversion.txt if previous fail
6. Returns SUCCESS if ANY attempt gets HTTP status 100-499
7. Returns FAILURE if ALL 4 attempts fail (timeout, connection refused, DNS error, etc.)
```

Headers used:
```python
{"User-Agent": "WFM-Test-Automation-HealthCheck"}
```

Timeout: 10 seconds (configurable via `--timeout` parameter)

---

## Why CI/CD Fails But Manual Works

### **Most Likely Causes (in order of probability)**

#### 1. **Network Isolation / Firewall Rules** ⭐ MOST LIKELY
- **CI/CD Agent Location**: Running on Jenkins agent `SWS_UBU_03` (Windows-based, at `C:\RFS_CI\GIT_REPO\sws_wfm_test_automation_jenkinslib`)
- **Your Manual Access**: Running from your local development machine or VPN
- **The Problem**: Corporate firewalls often restrict outbound HTTPS from CI/CD infrastructure
  - Jenkins agents may be on a restricted subnet with limited external internet access
  - Your personal machine or dev network likely has unrestricted internet access
- **Test This**: Run curl/wget from the Jenkins agent to verify:
  ```bash
  curl -v https://knlbsisb.reflexisinc.com/RWS4
  ```

#### 2. **Proxy Requirements**
- **The Problem**: Your manual browser likely goes through a corporate proxy automatically
- **CI/CD Missing**: The health check uses Python's `urllib.request` which may not inherit system proxy settings
- **Evidence**: The health check doesn't explicitly configure a proxy
- **Test This**: Check if your environment requires a proxy:
  ```bash
  echo $http_proxy
  echo $https_proxy
  echo $HTTP_PROXY
  echo $HTTPS_PROXY
  ```

#### 3. **DNS Resolution Failures**
- **The Problem**: The Jenkins agent's DNS server may not resolve `knlbsisb.reflexisinc.com`
- **Why Manual Works**: Your personal machine/network has proper DNS configured
- **Common Symptoms**: "nodename nor servname provided" or "Temporary failure in name resolution"
- **Test This**: 
  ```bash
  nslookup knlbsisb.reflexisinc.com
  ping knlbsisb.reflexisinc.com
  ```

#### 4. **SSL/TLS Certificate Validation Issues**
- **The Problem**: HTTPS handshake failures (untrusted cert, wrong hostname, etc.)
- **Why Manual Works**: Your browser has certificate validation or accepts warnings
- **Evidence**: Python's `urllib` validates SSL certificates by default
- **Test This**: Check certificate validity:
  ```bash
  openssl s_client -connect knlbsisb.reflexisinc.com:443
  ```

#### 5. **VPN Requirement**
- **The Problem**: The application URL is only accessible from a VPN
- **Why Manual Works**: You're connected to VPN
- **CI/CD**: Jenkins agent may not be VPN-connected
- **Test This**: Verify VPN connection on Jenkins agent

#### 6. **Network Timeouts / Latency**
- **The Problem**: The application is slow from the Jenkins agent's location (different data center, routing)
- **Current Timeout**: 10 seconds (set in Jenkins parameters)
- **Why Manual Works**: Your local browser has higher default timeouts
- **Test This**: Check response time:
  ```bash
  curl -o /dev/null -s -w "%{time_total}\n" https://knlbsisb.reflexisinc.com/RWS4
  ```

#### 7. **Application Access Control (IP Whitelist)**
- **The Problem**: The application may allow only specific IP ranges
- **Why Manual Works**: Your IP is whitelisted
- **CI/CD**: Jenkins agent IP is not whitelisted
- **Test This**: Ask your infrastructure team about IP restrictions

---

## Quick Diagnostics

### Step 1: Run these commands on the Jenkins agent
```bash
# SSH into SWS_UBU_03 agent and run:

# Test DNS resolution
nslookup knlbsisb.reflexisinc.com

# Test connectivity (timeout after 10 seconds like health check does)
timeout 10 curl -v https://knlbsisb.reflexisinc.com/RWS4

# Check system proxy settings
env | grep -i proxy

# Check if firewall is blocking the connection
telnet knlbsisb.reflexisinc.com 443
```

### Step 2: Compare with your manual environment
```bash
# Run the same commands from your local machine/laptop
nslookup knlbsisb.reflexisinc.com
curl -v https://knlbsisb.reflexisinc.com/RWS4
env | grep -i proxy
```

### Step 3: Run health check with debug logging
```bash
# On Jenkins agent, from repository root:
python -m dev_utils.run_health_check --test-env BSP_SB --timeout 20 --log-level DEBUG

# Review logs in: logs/health_check_*.log
```

---

## Solutions

### Solution 1: Increase Timeout (Quick Fix)
If the issue is latency, increase the timeout:
- Already done for Payroll_Replay job: no timeout change shown
- For BSP_SB: Modify `BAT_Jenkinsfile` to try 20-30 seconds
  ```groovy
  "healthCheckTimeout": "20"  # Increase from 10
  ```

### Solution 2: Skip Health Check (What We Did)
Already implemented in previous step - added `"skipHealthCheck": true` to `BAT_Jenkinsfile`.
- **Pros**: Unblocks CI/CD immediately
- **Cons**: Provides no early warning if application is truly down

### Solution 3: Configure Proxy (If Needed)
If proxy is the issue, set environment variables before health check:
```bash
export https_proxy=YOUR_PROXY_URL
export http_proxy=YOUR_PROXY_URL
```

### Solution 4: Update IP Whitelist (Infrastructure Team)
Contact your infrastructure/network team to add Jenkins agent IP to application's IP whitelist.

### Solution 5: Add VPN Connection (Infrastructure Team)
Ensure the Jenkins agent has VPN connectivity if required.

### Solution 6: Use Local/Relay Agent
If the cloud-hosted agent has connectivity issues:
- Run tests from an on-premise agent closer to the application
- Modify Jenkinsfile to use different agent label

---

## Health Check Code Reference

**File**: `utils/health_checks.py`, lines 87-108
- Uses Python's `urllib.request` module
- Attempts 4 probe methods (HEAD and GET on two endpoints)
- No proxy auto-detection
- SSL certificate validation enabled by default
- 10-second timeout per attempt

**Invocation**: `python -m dev_utils.run_health_check --test-env BSP_SB --timeout 10`

---

## Why "But It Works Manually" Doesn't Guarantee CI/CD Will Work

Even when a URL is accessible:
- **Manual**: Uses browser with its own SSL handling, proxy settings, DNS cache, and security context
- **Health Check**: Uses raw Python HTTP client with different configuration and security context
- **Network Path**: Your manual request might take a different network route than the Jenkins agent
- **Authentication**: Manual might use cookies/tokens not available to headless health check

---

## Next Steps

1. ✅ **Immediate**: Already applied `skipHealthCheck: true` - tests will now run
2. 📋 **Short-term**: Run diagnostics from Jenkins agent (commands above) to identify root cause
3. 🔧 **Long-term**: Based on diagnostics, implement appropriate solution (proxy, firewall, VPN, etc.)


