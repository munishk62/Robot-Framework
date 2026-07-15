# Implementation Summary: User Role Profile Mapping and No-Cache Token Fetching

## Changes Made

### 1. Removed Token Caching (token_client.py)
**File**: `dev_utils/env_config_sync/auth/token_client.py`

**Changes**:
- Removed `TokenCacheEntry` dataclass
- Removed `__init__` method with cache dictionary and TTL
- Removed cache lookup and storage logic from `get_token()`
- Made credentials import lazy (moved inside `get_token()`) to avoid module-level initialization errors
- Removed hardcoded test token return statement

**Result**: Every call to `get_token()` now performs a fresh browser-based login with no caching.

### 2. Added API Provider Import (sync_manager.py)
**File**: `dev_utils/env_config_sync/sync_manager.py`

**Changes**:
- Added import for `ApiProvider` to register it with the `ProviderRegistry`
- Added `# noqa: F401` comment to suppress unused import warning

**Result**: The API provider is now available for use, fixing the "No provider available for data source type: DataSourceType.API" error.

### 3. Implemented User Role Profile Mapping (api.py)
**File**: `dev_utils/env_config_sync/providers/api.py`

**Changes**:
- Added `_load_user_role_profile_mapping()` method to load `user_role_profile_mapping.json`
- Added `_resolve_profile_key()` method to map role names to profile keys
- Modified `_execute_api_query()` to resolve `auth_user_key` through the mapping before token fetching
- Added `self.user_role_profile_mapping` attribute in `__init__()`

**How It Works**:
1. On initialization, loads `user_role_profile_mapping.json`
2. When processing an API query with `auth_user_key: SYSADMIN`:
   - Looks up "SYSADMIN" in the mapping
   - Finds `["SYSADMIN", "CORP"]`
   - Uses the first profile ("SYSADMIN") to fetch credentials
   - If not in mapping, uses the key as-is (backward compatible)

### 4. Created Documentation
**File**: `dev_utils/env_config_sync/README_USER_ROLE_PROFILE_MAPPING.md`

**Content**:
- Comprehensive guide on how the mapping works
- Examples of how to use role names in metadata.yaml
- Troubleshooting guide
- Best practices

## Benefits

### Environment Agnostic
- Use semantic role names ("SYSADMIN", "STORE_MANAGER") in metadata.yaml
- Different environments can have different profile implementations
- Mapping file can be environment-specific if needed

### No Caching Issues
- Fresh token on every request ensures no stale token errors
- No cache invalidation complexity
- No time-based expiry issues

### Backward Compatible
- If `auth_user_key` is not in mapping, it's used directly
- Existing configurations continue to work
- Gradual migration to role-based approach possible

## Usage Example

### metadata.yaml
```yaml
- target: config
  data_source: api
  cache_key: profile_permissions
  query:
    url: /auth/exports/profilepermissionscsv/{0}.rest
    auth_user_key: SYSADMIN  # <- Use role name instead of profile key
    base_url_key: kernel_url
```

### user_role_profile_mapping.json
```json
{
  "SYSADMIN": ["SYSADMIN", "CORP"],
  "STORE_MANAGER": ["STRAD", "STRADMIN", "SM_SAL_SUPER"]
}
```

### Execution Flow
1. API provider reads `auth_user_key: SYSADMIN`
2. Resolves to profile key `"SYSADMIN"` (first in array)
3. Fetches credentials for `"SYSADMIN"` from `USER_CREDENTIALS`
4. Performs fresh browser login (no cache)
5. Uses token for API call

## Testing

To test the implementation:

```bash
# Set up credentials
export USER_CREDENTIALS='{"SYSADMIN": {"username": "admin", "password": "pass"}}'

# Run sync with verbose logging
cd /Users/ap7675/Documents/Work/Git-Checkouts/sws_wfm_test_automation
uv run python -m dev_utils.env_config_sync.cli \
  --env AAP_SB \
  --domain-id SB \
  --login-url https://knlaapsb.reflexisinc.com/kernel/views/authenticate/W/AAP.view \
  --kernel-url https://knlcl12sb.reflexisinc.com/kernel/ \
  --rws4-url https://knlaapsb.reflexisinc.com/RWS4 \
  --owner 121220099 \
  --verbose
```

Look for log messages:
```
Loaded user role profile mapping with 4 roles
Resolved auth_user_key 'SYSADMIN' to profile 'SYSADMIN'
Resolving auth token using user_key=SYSADMIN (resolved from role=SYSADMIN)
Attempting mobile login at: https://...
```

## Files Modified

1. `dev_utils/env_config_sync/auth/token_client.py` - Removed caching
2. `dev_utils/env_config_sync/sync_manager.py` - Added API provider import
3. `dev_utils/env_config_sync/providers/api.py` - Added profile mapping resolution
4. `dev_utils/env_config_sync/README_USER_ROLE_PROFILE_MAPPING.md` - Created documentation

## Files Existing (Not Modified)

- `dev_utils/env_config_sync/user_role_profile_mapping.json` - Mapping configuration
- `dev_utils/env_config_sync/metadata.yaml` - Already uses `auth_user_key` field

## Next Steps

1. Ensure `USER_CREDENTIALS` environment variable contains entries for profile keys in the mapping
2. Update metadata.yaml to use role names consistently
3. Add more role mappings as needed
4. Test across different environments to verify profile availability

