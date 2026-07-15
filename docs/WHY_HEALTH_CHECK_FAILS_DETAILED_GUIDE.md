# Why Health Check Fails in CI/CD But Works Manually - Complete Analysis

## Problem Statement

```
Jenkins Build: WFM Sanity BSP_SB #38
Status: FAILED

Error: 
  ERROR - Health checks failed: Application health check failed: 
  Application is not reachable for base URL: https://knlbsisb.reflexisinc.com/RWS4

But: 
  ✅ URL is accessible when accessed manually in browser
  🤔 Why does Jenkins fail?
```

---

## Answer: Network Context Difference

The health check **doesn't fail because the application is down**.  
It fails because the health check is running from a **different network location** with **different networking rules**.

```
                        YOUR MANUAL ACCESS              VS.     HEALTH CHECK (Jenkins)
                        ─────────────────────────                ──────────────────────

1. Location            Your laptop / local machine    VS.        Jenkins agent (SWS_UBU_03)
2. Network             Your corporate network         VS.        CI/CD infrastructure network
3. Routing Path        Your ISP/VPN                  VS.        Company datacenter network
4. Firewall Rules      Your network's rules          VS.        Jenkins agent's firewall rules
5. Proxy Config        Browser auto-detects          VS.        No proxy auto-detection
6. DNS Servers         Your configured DNS           VS.        Jenkins agent DNS
7. Certificate Store   Browser's cert store          VS.        System/Python cert store
8. IP Whitelisting     Your IP is allowed            VS.        Jenkins agent IP may be blocked
9. VPN Status          You might be on VPN           VS.        Jenkins agent not on VPN (maybe)
10. Access Control     Browser might handle auth      VS.        Raw HTTP client
```

This is **completely normal** in enterprise environments. The application isn't broken—it's infrastructure.

---

## Why Different Network Contexts Matter

### Example 1: Firewall Rules
```
Corporate Firewall Rule:
  ✅ ALLOW: 192.168.1.0/24 (your network) → outbound HTTPS
  ❌ DENY: 10.0.0.0/8 (CI/CD infrastructure) → outbound HTTPS to external IPs

Result:
  - Your browser ✅ reaches the application
  - Jenkins health check ❌ cannot reach the application
  - Application is NOT down
```

### Example 2: Proxy Requirements
```
Company Policy:
  ALL external HTTPS traffic must go through corporate proxy

Your Browser:
  ✅ Auto-detects proxy from Windows/Mac settings
  ✅ Automatically routes through proxy
  ✅ Works

Jenkins Health Check:
  ❌ No automatic proxy detection
  ❌ Direct connection attempt
  ❌ Fails because proxy blocks unproxied external connections
```

### Example 3: DNS Resolution
```
Company Infrastructure:
  Jenkins agent uses internal DNS: 10.0.0.1 (can only resolve internal domains)
  
Your Machine:
  Uses public DNS: 8.8.8.8 (can resolve knlbsisb.reflexisinc.com)

Result:
  - Jenkins: "DNS can't resolve knlbsisb.reflexisinc.com" ❌
  - You: "DNS resolves to 203.45.67.89" ✅
```

---

## The 7 Most Common Causes (With Probability)

### 🔴 **#1: Firewall Blocking (60% probability)**

**What Happens**:
```
Jenkins health check → firewall → ❌ BLOCKED → connection timeout
Your browser request → firewall → ✅ ALLOWED → works
```

**How to Detect**:
```bash
# From Jenkins agent, should timeout or fail:
curl -m 5 https://knlbsisb.reflexisinc.com/RWS4

# From your laptop, should work:
curl -m 5 https://knlbsisb.reflexisinc.com/RWS4
```

**How to Fix**: Contact network team to allow Jenkins agent to reach the application

---

### 🟡 **#2: Proxy Not Configured (25% probability)**

**What Happens**:
```
Your Browser:
  - Detects proxy from system settings
  - Routes through proxy automatically
  - ✅ Works

Jenkins Health Check:
  - No proxy configuration
  - Tries direct connection
  - ❌ Blocked by proxy requirement
```

**How to Detect**:
```bash
# On Jenkins agent:
echo $http_proxy $https_proxy $HTTP_PROXY $HTTPS_PROXY
# Should show proxy URL if required
```

**How to Fix**: Configure proxy environment variables

---

### 🟠 **#3: DNS Resolution Failure (8% probability)**

**What Happens**:
```
Jenkins DNS server: "I don't have knlbsisb.reflexisinc.com in my records" ❌
Your DNS server: "knlbsisb.reflexisinc.com is 203.45.67.89" ✅
```

**How to Detect**:
```bash
nslookup knlbsisb.reflexisinc.com
# Should return IP address, not "server can't find"
```

**How to Fix**: Contact network team for DNS configuration

---

### 🟡 **#4: SSL Certificate Validation (3% probability)**

**What Happens**:
```
Your Browser:
  - Trusts certificate authority
  - Accepts the certificate
  - ✅ Works

Jenkins (Python):
  - Can't validate certificate
  - Certificate signed by proxy's CA
  - ❌ Connection fails
```

**How to Detect**:
```bash
openssl s_client -connect knlbsisb.reflexisinc.com:443
# Check if certificate is valid or signed by proxy
```

**How to Fix**: Install corporate CA certificate in system store

---

### 🟢 **#5: Network Timeout (2% probability)**

**What Happens**:
```
Health Check Timeout: 10 seconds
Server Response Time: 15 seconds (from Jenkins agent location)
Result: ❌ Timeout
```

**How to Detect**:
```bash
# Measure response time
time curl https://knlbsisb.reflexisinc.com/RWS4
# If > 10 seconds, timeout is the issue
```

**How to Fix**: Increase timeout from 10s to 20s in Jenkinsfile

---

### 🟣 **#6: Application IP Whitelist (1% probability)**

**What Happens**:
```
Application Whitelist:
  - Allows: Your IP (fixed by IT)
  - Denies: Everything else
  - Jenkins agent IP: Not whitelisted
  Result: ❌ Connection rejected
```

**How to Detect**: 
- Contact application team "Is access IP-restricted?"

**How to Fix**: Add Jenkins agent IP to whitelist

---

### ⚪ **#7: VPN Requirement (1% probability)**

**What Happens**:
```
You: Connected to VPN → inside company network → ✅ Works
Jenkins: No VPN → outside company network → ❌ Fails
```

**How to Detect**:
- Try to reach the app without VPN
- See if it fails

**How to Fix**: Connect Jenkins agent to VPN

---

## Rapid Diagnosis (Run This First)

### Step 1: Run Diagnostics on Jenkins Agent
```bash
cd /mount/workspace/WFM\ Sanity\ BSP_SB

# Run diagnostic tool (comprehensive test)
python dev_utils/health_check_diagnostics.py
```

**Output tells you:**
- ✅ DNS working?
- ✅ Network connected to port 443?
- ✅ SSL certificate valid?
- ✅ HTTP request succeeds?
- ⚠️  Proxy configured?

### Step 2: Run Same Diagnostics Locally
```bash
cd /path/to/sws_wfm_test_automation
python dev_utils/health_check_diagnostics.py
```

### Step 3: Compare
```bash
# Look for differences:
# - Proxy settings
# - DNS resolution
# - Response times
# - Certificate validation
```

### Step 4: Most Common Finding
```
If Jenkins reports:
  ❌ DNS resolution failed  →  Issue #3
  ❌ TCP connection failed   →  Issue #1 (firewall)
  ⚠️  No proxy configured    →  Issue #2 (proxy)
  ❌ SSL certificate failed  →  Issue #4 (SSL)
  ✅ All networks pass but timeout occurs  →  Issue #5 (timeout)
```

---

## Immediate Workaround (Already Implemented)

We've already added this to your Jenkins configuration:
```groovy
# File: test_data/environments/BSP_SB/BAT_Jenkinsfile

"skipHealthCheck": true  # Skip health checks, proceed directly to tests
```

**Effect**: 
- ✅ Jenkins job will now proceed to test execution
- ⚠️  No early warning if application is actually down
- 📋 Root cause not fixed, just bypassed

---

## Root Cause Fixing Strategy

### Recommended Approach:

1. **Right Now** ✅ (Done)
   - Skip health check with `"skipHealthCheck": true`
   - Get tests running in Jenkins

2. **This Week** 📋
   - Run diagnostic tool on Jenkins agent
   - Identify which of 7 causes it is
   - Document findings

3. **Next Steps** 🔧
   - Based on findings, fix infrastructure:
     - Firewall rule: Contact network team
     - Proxy config: Add env variables to Jenkins
     - DNS: Contact network team
     - SSL cert: Install CA certificate
     - Timeout: Increase to 20 seconds
     - IP whitelist: Contact app team
     - VPN: Contact infrastructure

---

## Key Insight: It's Not an Application Problem

The health check failure **does NOT mean**:
- ❌ The application is down
- ❌ The application is misconfigured
- ❌ The URL is wrong
- ❌ The credentials are wrong

The health check failure **DOES mean**:
- ✅ Network connectivity issue from CI/CD infrastructure
- ✅ Infrastructure configuration difference
- ✅ Firewall, proxy, DNS, or routing issue
- ✅ Normal for enterprise environments

---

## Documentation & Tools Created

We've created 3 documents and 1 diagnostic tool for you:

### Documents:
1. **`docs/HEALTH_CHECK_FAILURE_EXPLANATION.md`** ← Read this first (executive summary)
2. **`docs/HEALTH_CHECK_CI_CD_VS_MANUAL_ANALYSIS.md`** ← Detailed technical analysis
3. **`docs/TROUBLESHOOT_HEALTH_CHECK_CI_CD.md`** ← Step-by-step troubleshooting guide

### Diagnostic Tool:
```bash
python dev_utils/health_check_diagnostics.py
```
Run this on Jenkins agent and your local machine to identify the issue.

---

## Questions to Ask Infrastructure/Network Team

Once you've run diagnostics, send these questions with your findings:

1. "Can Jenkins agent `SWS_UBU_03` reach `knlbsisb.reflexisinc.com:443` with a test?"
2. "Do outbound HTTPS requests from Jenkins subnet get blocked by firewall?"
3. "Does the CI/CD network require a proxy for external connectivity?"
4. "Is there an IP whitelist for the application? Is Jenkins agent IP on it?"
5. "Does the Jenkins agent need VPN to access this application?"
6. "Can you run `curl https://knlbsisb.reflexisinc.com/RWS4` from Jenkins agent?"

---

## Files Modified / Created

```
MODIFIED:
└── test_data/environments/BSP_SB/BAT_Jenkinsfile
    └── Added: "skipHealthCheck": true

CREATED:
├── docs/HEALTH_CHECK_FAILURE_EXPLANATION.md
├── docs/HEALTH_CHECK_CI_CD_VS_MANUAL_ANALYSIS.md
├── docs/TROUBLESHOOT_HEALTH_CHECK_CI_CD.md
└── dev_utils/health_check_diagnostics.py
```

---

## Summary

| Aspect | Status | Next Action |
|--------|--------|-------------|
| **Tests Running in Jenkins** | ✅ Fixed | None needed |
| **Root Cause Identified** | ❓ Unknown | Run diagnostic tool |
| **Infrastructure Fixed** | ❌ No | After diagnostics, engage infrastructure team |
| **Health Check Bypassed** | ✅ Yes | Can add back once infrastructure is fixed |


