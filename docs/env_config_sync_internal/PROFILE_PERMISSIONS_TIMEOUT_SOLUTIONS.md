# Profile Permissions API Timeout - Solutions

## Problem
The profile permissions CSV export API (`/auth/exports/profilepermissionscsv/{domain}.rest`) can return very large responses (38,000+ permission rows for 23 profiles), which can cause:
- "Response ended prematurely" errors
- Connection timeouts
- Incomplete data transfer

## Solutions Implemented

### 1. **Improved API Request Handling** (Automatic)
The following improvements have been made to `dev_utils/env_config_sync/providers/api.py`:

- ✅ **Increased timeout**: 180 seconds (3 minutes) for CSV endpoints
- ✅ **Streaming responses**: Large CSV files are read in chunks to avoid memory issues
- ✅ **Retry logic**: Up to 3 attempts with exponential backoff (2s, 4s, 6s delays)
- ✅ **Connection pooling**: HTTP session with proper adapter configuration
- ✅ **Better error handling**: Graceful fallback to cached data if API fails

### 2. **Cached Profile Permissions** (Fallback)
If the API call fails, the system automatically checks for a cached file:
- Location: `test_data/environments/{ENV_NAME}/profile_permissions_cache.json`
- The sync will use this cached data if the API times out
- Cache is automatically created on first successful API call

### 3. **Manual Profile Permissions Fetcher** (Emergency Tool)
If the API continues to timeout, use the standalone fetcher script:

```bash
# Fetch profile permissions separately (with longer timeout and retries)
uv run python -m dev_utils.env_config_sync.fetch_profile_permissions \
    --env HNM_DRYRUN \
    --domain-id HNM \
    --login-url https://hmdryrun02.reflexisinc.co.uk/kernel/views/authenticate/W/HNM.view \
    --kernel-url https://hmdryrun02.reflexisinc.co.uk/kernel/ \
    --timeout 300 \
    --max-retries 5
```

This will:
- Make multiple retry attempts with longer timeouts
- Save the result to `test_data/environments/HNM_DRYRUN/profile_permissions_cache.json`
- Show download progress for large files

Then run the regular sync:
```bash
uv run python -m dev_utils.env_config_sync.cli \
    --env HNM_DRYRUN \
    --domain-id HNM \
    --login-url https://hmdryrun02.reflexisinc.co.uk/kernel/views/authenticate/W/HNM.view \
    --kernel-url https://hmdryrun02.reflexisinc.co.uk/kernel/ \
    --rws4-url https://hmdryrun02.reflexisinc.co.uk/RWS4/ \
    --owner 121890099
```

The sync will now use the cached profile permissions file automatically.

## Configuration Changes

### metadata.yaml
The profile permissions query now has an explicit 180-second timeout:
```yaml
- target: config
  data_source: api
  cached_only: true
  source_group: core_config
  description: Profile permissions grouped by SYSADMIN
  cache_key: profile_permissions
  query:
    url: /auth/exports/profilepermissionscsv/{0}.rest
    method: POST
    path_params: ["$config.domainId"]
    base_url_key: kernel_url
    auth_user_key: SYSADMIN
    response_type: csv
    request_timeout: 180  # 3 minutes
    fallback_value: {}
```

## Troubleshooting

### If you still see "Response ended prematurely":

1. **Use the manual fetcher** (see above)
2. **Check network connectivity** to the environment
3. **Check if server is under load** - try again later
4. **Use an existing environment's cache** as a template (if similar configuration)

### Check if cache is being used:
Look for these log messages:
```
INFO - Found cached profile permissions file: ...
INFO - Loaded X profiles from cache
```

### Verify cache file:
```bash
cat test_data/environments/HNM_DRYRUN/profile_permissions_cache.json | jq 'keys'
```

Should show profile names like: `["SYSADMIN", "STRAD", "ASSOCIATE", ...]`

## Why This Works

1. **Streaming**: Instead of loading entire response into memory, we read it in 8KB chunks
2. **Retries**: Network issues are temporary - retrying with delays often succeeds
3. **Longer timeout**: Large files need more time to transfer completely
4. **Cached fallback**: Once you have a valid cache, you can work even if API is down
5. **Connection pooling**: Reuses TCP connections for better reliability

## Environment-Specific Notes

- **HNM_DRYRUN**: Known to have 38,950+ permission rows
- **Large clients**: Production environments with many profiles may take 60-120 seconds
- **Small clients**: Demo/sandbox environments typically complete in 10-20 seconds

