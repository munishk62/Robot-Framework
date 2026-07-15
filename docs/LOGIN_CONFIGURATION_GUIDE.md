# Login Configuration Guide

## Overview

This guide explains how to configure user credentials for the `Login And Launch WFM Web App` keyword. The keyword supports multiple authentication strategies based on the `DIRECT_LOGIN` configuration flag and user credential attributes.

## Quick Reference Table

| Scenario | `DIRECT_LOGIN` | `username` | `password` | `profile_name` | `switch_store_id` | Behavior |
|----------|----------------|------------|------------|----------------|-------------------|----------|
| 1 | True | ✓ | ✓ | - | - | Direct login with credentials |
| 2 | False | ✓ | empty | ✓ | - | Generate sudo URL for username |
| 3 | False | ✓ | ✓ | ✓ | - | Direct login (fallback) |
| 4 | False | empty | empty | `STRADMN` | ✓ | Sudo as SYSADMIN + switch to store |

**Legend**: ✓ = Required, empty = Must be empty string, - = Optional/Not used

## Table of Contents
- [Configuration Flag](#configuration-flag)
- [Direct Login Flow](#direct-login-flow)
- [Sudo Login Flow](#sudo-login-flow)
- [User Credential Attributes](#user-credential-attributes)
- [Login Scenarios and Required Attributes](#login-scenarios-and-required-attributes)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

---

## Configuration Flag

### `DIRECT_LOGIN`

**Location**: Environment-specific configuration (`test_data/environments/<ENV>/config.json`)

**Purpose**: Determines which authentication flow to use

| Value | Description |
|-------|-------------|
| `True` | Use direct login with username and password |
| `False` | Use sudo login flow (default for most environments) |

---

## Direct Login Flow

### When to Use
- Testing environments where direct username/password authentication is available
- SSO is disabled
- No need for sudo (impersonation) capabilities

### How It Works
1. Opens the WFM application URL (`app_url` from config)
2. Enters username and password on the login form
3. Submits the form
4. User is logged in with their assigned profile and permissions

### Required Attributes
```json
{
  "username": "actual_username",
  "password": "actual_password"
}
```

### Optional Attributes
- `profile_name`: User's profile (informational only for direct login)

---

## Sudo Login Flow

### When to Use
- Production-like environments where sudo (impersonation) is required
- Testing with different user personas without real passwords
- Kernel-based authentication with OTP
- Session caching for faster test execution

### How It Works
1. Checks for cached sudo URL (5-minute cache)
2. If cached URL exists, reuses it (fastest path)
3. If no cache, determines authentication strategy based on user attributes
4. Generates sudo URL via kernel authentication
5. Caches the URL for subsequent tests

### Required Global Configuration

The **SUDO_USER** must be configured in `USER_CREDENTIALS` environment variable:

```json
{
  "SUDO_USER": {
    "username": "sudo_admin_username",
    "password": "sudo_admin_password",
    "secret": "totp_secret_key",
    "issuer": "totp_issuer"
  }
}
```

This user has elevated privileges to generate sudo URLs for impersonating other users.

---

## User Credential Attributes

### Core Attributes

| Attribute | Type | Required For | Description |
|-----------|------|--------------|-------------|
| `username` | String | Direct login, Sudo login (username-only) | Actual username for authentication or sudo impersonation |
| `password` | String | Direct login, Sudo login (username+password) | User's password. If empty, triggers sudo-only flow |
| `profile_name` | String | Store Admin switching | User's profile type (e.g., `STRADMN`, `SYSADMIN`, `ESS`) |
| `switch_store_id` | String | Store Admin switching | Store ID to switch to after sudo login |

### Attribute Combinations

Different combinations of these attributes trigger different login behaviors (see [Login Scenarios](#login-scenarios-and-required-attributes) below).

---

## Login Scenarios and Required Attributes

### Scenario 1: Direct Login with Username and Password

**When `DIRECT_LOGIN = True`**

**Use Case**: Standard login for environments with direct authentication enabled

**Required Attributes**:
```json
{
  "username": "john.doe",
  "password": "SecurePass123"
}
```

**Flow**:
1. Opens `app_url`
2. Fills username and password
3. Clicks login
4. User is authenticated

**Example User Keys**: `ESS1_STORE1`, `SM1_STORE1`, `SYSADMIN` (when direct login enabled)

---

### Scenario 2: Sudo Login with Username Only (No Password)

**When `DIRECT_LOGIN = False`**

**Use Case**: Impersonate user without knowing their password (typical for test automation)

**Required Attributes**:
```json
{
  "username": "john.doe",
  "password": "",
  "profile_name": "ESS"
}
```

**Flow**:
1. Checks cache for existing sudo URL
2. If not cached, generates sudo URL via kernel:
   - Logs into kernel as SUDO_USER (with OTP)
   - Switches to customer domain
   - Creates sudo URL for `john.doe`
   - Caches the URL for 5 minutes
3. Launches WFM with sudo URL

**Example User Keys**: Most automation users like `ESS1_STORE1`, `SM1_STORE1` when passwords are empty

---

### Scenario 3: Sudo Login with Username and Password

**When `DIRECT_LOGIN = False`**

**Use Case**: User has both username and password, but sudo flow is enabled

**Required Attributes**:
```json
{
  "username": "admin.user",
  "password": "AdminPass456",
  "profile_name": "SYSADMIN"
}
```

**Flow**:
1. Checks cache (same as Scenario 2)
2. If not cached, performs **direct login** (fallback to username/password)
   - Opens `app_url`
   - Fills username and password
   - Submits form

**Note**: Even though `DIRECT_LOGIN = False`, having both username and password triggers direct login as a fallback.

**Example User Keys**: `SYSADMIN` (when password is provided)

---

### Scenario 4: Store Admin Switch via Sudo

**When `DIRECT_LOGIN = False`**

**Use Case**: Access a specific store as a Store Admin without direct credentials

**Required Attributes**:
```json
{
  "username": "",
  "password": "",
  "profile_name": "STRADMN",
  "switch_store_id": "STORE001"
}
```

**Flow**:
1. Checks cache (not applicable for this scenario)
2. Generates sudo URL for **SYSADMIN** user
3. Launches WFM with sudo URL
4. Switches to Store Admin profile for `STORE001`

**Example User Keys**: Store-specific admin users configured with `switch_store_id`

---

## Examples

### Example 1: Direct Login Configuration

**Environment Config** (`config.json`):
```json
{
  "DIRECT_LOGIN": "True"
}
```

**User Credentials** (`USER_CREDENTIALS` env variable):
```json
{
  "ESS1_STORE1": {
    "username": "ess.employee",
    "password": "EssPass123",
    "profile_name": "ESS"
  }
}
```

**Test Case**:
```robotframework
*** Test Cases ***
Employee Can View Their Schedule
    Login And Launch WFM Web App    user_key=ESS1_STORE1
    # User is logged in via direct authentication
```

---

### Example 2: Sudo Login with Cached URL

**Environment Config** (`config.json`):
```json
{
  "DIRECT_LOGIN": "False"
}
```

**User Credentials**:
```json
{
  "SUDO_USER": {
    "username": "sudo.admin",
    "password": "SudoPass789",
    "secret": "JBSWY3DPEHPK3PXP",
    "issuer": "WFM-Kernel"
  },
  "SM1_STORE1": {
    "username": "store.manager",
    "password": "",
    "profile_name": "SM"
  }
}
```

**Test Case (First Execution)**:
```robotframework
*** Test Cases ***
Store Manager Approves Timesheet
    Login And Launch WFM Web App    user_key=SM1_STORE1
    # First run: Generates sudo URL via kernel (slower, ~10-15s)
    # Caches URL for 5 minutes
```

**Test Case (Subsequent Execution within 5 minutes)**:
```robotframework
*** Test Cases ***
Store Manager Views Reports
    Login And Launch WFM Web App    user_key=SM1_STORE1
    # Reuses cached sudo URL (fast, ~2-3s)
```

---

### Example 3: Store Admin Switch

**Environment Config** (`config.json`):
```json
{
  "DIRECT_LOGIN": "False"
}
```

**User Credentials**:
```json
{
  "SUDO_USER": {
    "username": "sudo.admin",
    "password": "SudoPass789",
    "secret": "JBSWY3DPEHPK3PXP",
    "issuer": "WFM-Kernel"
  },
  "SYSADMIN": {
    "username": "system.admin",
    "password": "",
    "profile_name": "SYSADMIN"
  },
  "STORE_ADMIN_001": {
    "username": "",
    "password": "",
    "profile_name": "STRADMN",
    "switch_store_id": "STORE001"
  }
}
```

**Test Case**:
```robotframework
*** Test Cases ***
Store Admin Manages Store Configuration
    Login And Launch WFM Web App    user_key=STORE_ADMIN_001
    # 1. Generates sudo URL as SYSADMIN
    # 2. Switches to Store Admin profile for STORE001
```

---

## Troubleshooting

### Error: "Invalid user configuration for key 'USER_X'"

**Cause**: User attributes don't match any supported login scenario

**Solution**: Verify the user has one of these valid combinations:
- **Direct**: `username` + `password`
- **Sudo (username only)**: `username` + empty `password`
- **Store Admin Switch**: empty `username` + empty `password` + `profile_name=STRADMN` + `switch_store_id`

---

### Cached URL Not Working (Error Screen After Login)

**Symptoms**: Login attempt shows error page instead of WFM home

**Causes**:
- Sudo URL expired on server side (before 5-minute cache expiry)
- Session invalidated due to server restart
- Network/proxy issues

**Solution**: 
1. Wait for cache to expire (5 minutes) or clear cache manually
2. Re-run test - new sudo URL will be generated

**Future Enhancement**: Add explicit validation in `Try Launch With Cached Sudo URL` to detect error screens

---

### OTP Authentication Failures

**Symptoms**: Kernel login fails with authentication error

**Causes**:
- Incorrect `secret` or `issuer` in SUDO_USER
- Time synchronization issues (OTP is time-based)

**Solution**:
1. Verify SUDO_USER credentials are correct
2. Check system time is synchronized (NTP)
3. Verify TOTP secret is valid and matches kernel configuration

---

### Direct Login Not Working When Expected

**Symptoms**: Test attempts sudo login even when `DIRECT_LOGIN = True`

**Causes**:
- Environment config not loaded correctly
- Wrong environment selected in test execution

**Solution**:
1. Verify environment sync: `python -m dev_utils.env_config_sync.cli --env <ENV_NAME>`
2. Check `executor.py` is using correct `--test-env` parameter
3. Confirm `config.json` has `"DIRECT_LOGIN": "True"`

---

## Decision Tree

```
┌─────────────────────────────────────────┐
│  Login And Launch WFM Web App           │
│  (user_key provided)                    │
└──────────────┬──────────────────────────┘
               │
               ▼
      ┌────────────────┐
      │ DIRECT_LOGIN?  │
      └────┬───────┬───┘
           │       │
       True│       │False
           │       │
           ▼       ▼
    ┌──────────┐ ┌──────────────────────┐
    │  Direct  │ │  Sudo Flow           │
    │  Login   │ │  (Check Cache First) │
    └──────────┘ └──────┬───────────────┘
                         │
                         ▼
                 ┌───────────────┐
                 │ Cache Hit?    │
                 └───┬───────┬───┘
                     │       │
                  Yes│       │No
                     │       │
                     ▼       ▼
              ┌──────────┐ ┌────────────────────────┐
              │ Launch   │ │ Determine Auth Strategy│
              │ Cached   │ └────────┬───────────────┘
              │ URL      │          │
              └──────────┘          ▼
                         ┌──────────────────────────┐
                         │ username + password?     │
                         └──┬──────────────┬────────┘
                            │              │
                         Yes│              │No
                            │              │
                            ▼              ▼
                     ┌─────────────┐  ┌───────────────┐
                     │   Direct    │  │  username     │
                     │   Login     │  │  only?        │
                     └─────────────┘  └───┬───────┬───┘
                                          │       │
                                       Yes│       │No
                                          │       │
                                          ▼       ▼
                                   ┌────────────┐ ┌──────────────────┐
                                   │Generate    │ │Store Admin       │
                                   │Sudo URL    │ │Switch?           │
                                   │            │ └──┬───────────┬───┘
                                   │Launch App  │    │           │
                                   └────────────┘ Yes│           │No
                                                      │           │
                                                      ▼           ▼
                                              ┌────────────┐ ┌─────────┐
                                              │Sudo as     │ │  ERROR  │
                                              │SYSADMIN +  │ │ Invalid │
                                              │Switch Store│ │ Config  │
                                              └────────────┘ └─────────┘
```

---

## Quick Reference Table

| Scenario | `DIRECT_LOGIN` | `username` | `password` | `profile_name` | `switch_store_id` | Behavior |
|----------|----------------|------------|------------|----------------|-------------------|----------|
| 1 | True | ✓ | ✓ | - | - | Direct login with credentials |
| 2 | False | ✓ | empty | ✓ | - | Generate sudo URL for username |
| 3 | False | ✓ | ✓ | ✓ | - | Direct login (fallback) |
| 4 | False | empty | empty | `STRADMN` | ✓ | Sudo as SYSADMIN + switch to store |

**Legend**: ✓ = Required, empty = Must be empty string, - = Optional/Not used

---

## Best Practices

1. **Use Sudo Login for Most Tests**: Faster with caching, no password management needed
2. **Configure SUDO_USER Once**: Shared across all test environments
3. **Leverage Cache**: Run related tests in same suite to benefit from 5-minute cache
4. **Environment-Specific Config**: Set `DIRECT_LOGIN` per environment, not per user
5. **Clear Naming**: Use descriptive user keys (e.g., `SM1_STORE1`, `ESS_EMPLOYEE_2`)
6. **Document Special Cases**: Add comments for store admin switches or complex setups

---

## Related Keywords

- `Perform Direct Login To WFM Using User Credentials` - Direct login implementation
- `Generate Sudo Login Url For User` - Sudo URL generation logic
- `Try Launch With Cached Sudo URL` - Cache retrieval and launch
- `Perform Login Using Sudo Flow` - Sudo flow orchestrator

---

## Support

For questions or issues:
1. Check this guide first
2. Review `resources/web/authentication/login.resource` for implementation details
3. Verify environment configuration: `test_data/environments/<ENV>/config.json`
4. Contact automation team lead

---

**Document Version**: 1.0  
**Last Updated**: November 19, 2025  
**Maintained By**: WFM Automation Team
