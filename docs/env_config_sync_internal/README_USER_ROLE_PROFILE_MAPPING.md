# User Role Profile Mapping

## Overview

The `user_role_profile_mapping.json` file provides a mapping between logical role names and actual system profile keys. This allows metadata.yaml to use semantic role names (like "SYSADMIN", "STORE_MANAGER") instead of hardcoded profile keys, making the configuration more maintainable and environment-agnostic.

## File Location

```
dev_utils/env_config_sync/user_role_profile_mapping.json
```

## Structure

The mapping file is a JSON object where:
- **Keys**: Logical role names used in metadata.yaml (e.g., "SYSADMIN", "STORE_MANAGER")
- **Values**: Arrays of profile keys that have the required permissions for that role

Example:
```json
{
  "SYSADMIN": ["SYSADMIN", "CORP"],
  "COGNOS_SYSADMIN": ["SYSADMIN"],
  "STORE_MANAGER": ["STRAD", "STRADMIN", "SM_SAL_SUPER", "PD_STORE_MGR", "UK_SITE_MGR"],
  "ASSOCIATE": ["ASSOCIATE", "ESS_USER", "TM", "EMPLOYEE", "UK_EMPLOYEE"]
}
```

## How It Works

### 1. In metadata.yaml

When defining an API query in `metadata.yaml`, use the `auth_user_key` field with a logical role name:

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
    auth_user_key: SYSADMIN  # <- Logical role name
    response_type: csv
    request_timeout: 180
```

### 2. Profile Resolution

When the API provider processes this query:

1. It reads the `auth_user_key` value ("SYSADMIN")
2. Looks it up in `user_role_profile_mapping.json`
3. Finds the array: `["SYSADMIN", "CORP"]`
4. Uses the **first profile** in the array ("SYSADMIN")
5. Fetches credentials for that profile key from `USER_CREDENTIALS`
6. Performs authentication using those credentials

### 3. Credential Lookup

The resolved profile key must exist in your `USER_CREDENTIALS` environment variable. For example:

```json
{
  "SYSADMIN": {
    "username": "sysadmin_user",
    "password": "secure_password"
  },
  "STRAD": {
    "username": "store_manager_user", 
    "password": "secure_password"
  }
}
```

## Benefits

### 1. **Environment Agnostic**
Different environments may use different profile keys for the same role. The mapping allows you to maintain environment-specific profile lists without changing metadata.yaml.

### 2. **Fallback Profiles**
Multiple profiles can be listed for a role. If the first profile doesn't exist in credentials, you can manually update the order or add fallback logic.

### 3. **Semantic Clarity**
Using role names like "STORE_MANAGER" is more readable than profile keys like "SM_SAL_SUPER".

### 4. **Backward Compatibility**
If a profile key is used directly in `auth_user_key` (not found in the mapping), it will be used as-is. This ensures existing configurations continue to work.

## Adding New Roles

To add a new role mapping:

1. Identify the logical role name (e.g., "DISTRICT_MANAGER")
2. Find all profile keys that should have this role's permissions
3. Add an entry to `user_role_profile_mapping.json`:

```json
{
  "SYSADMIN": ["SYSADMIN", "CORP"],
  "DISTRICT_MANAGER": ["DIST_SUPER", "DISTRICT_MGR", "AREA_MANAGER"]
}
```

4. Ensure at least one of these profiles has credentials in `USER_CREDENTIALS`
5. Use the role name in metadata.yaml:

```yaml
auth_user_key: DISTRICT_MANAGER
```

## Troubleshooting

### Profile Not Found Error

**Error**: `KeyError: User key 'SYSADMIN' not present in USER_CREDENTIALS`

**Solution**: Ensure the resolved profile key exists in your credentials:
1. Check which profile is being resolved (look for log: `Resolved auth_user_key 'ROLE_NAME' to profile 'PROFILE_KEY'`)
2. Add that profile to your `USER_CREDENTIALS` environment variable

### Mapping File Not Found

**Warning**: `User role profile mapping file not found: .../user_role_profile_mapping.json`

**Solution**: Ensure the mapping file exists at:
```
dev_utils/env_config_sync/user_role_profile_mapping.json
```

If the file doesn't exist, the system will fall back to using `auth_user_key` values directly.

### Empty Profile List

**Warning**: `Role 'ROLE_NAME' has empty profile list in mapping`

**Solution**: Ensure each role has at least one profile key in its array:
```json
{
  "MY_ROLE": ["PROFILE_KEY"]  // At least one profile required
}
```

## Best Practices

1. **Order Matters**: List the most commonly available profile first in the array
2. **Keep It Updated**: When adding new profiles to the system, update the mapping
3. **Document Custom Roles**: Add comments in this README when adding organization-specific roles
4. **Test Across Environments**: Verify that at least one profile from each role's array exists in each environment's credentials

## Logs

To debug profile resolution, enable verbose logging:

```bash
python -m dev_utils.env_config_sync.cli --env QA28 --verbose
```

Look for log messages like:
```
Resolved auth_user_key 'SYSADMIN' to profile 'SYSADMIN'
Resolving auth token using user_key=SYSADMIN (resolved from role=SYSADMIN)
```

