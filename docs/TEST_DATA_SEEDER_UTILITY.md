# Test Data Seeder Utility

Extending the Test Data provider functionality further, we want to auto populate the test environment specific configurations and logical constants. Test cases will be dependent on the configs & logical constants & the seeder will fetch these as a pre step to test execution.

## Environment Configuration Synchronization Tool

### What is it?

The Environment Configuration Synchronization Tool is a utility that helps keep your test environment settings up-to-date and consistent. It automatically fetches important configuration values and logical constants from the database and saves them in easy-to-use JSON files that your tests can read.

Think of it as an automatic translator that takes information from the database and makes it available in a format that our test automation can easily understand and use.

### Why is it useful?

- **Save time**: No need to manually update configuration files when database values change
- **Reduce errors**: Eliminates typos and human error in configuration settings
- **Consistent testing**: Ensures tests always use the latest environment configurations
- **Single source of truth**: Database values are the master source, and files are automatically synchronized

### How to use it

#### Setup DB details by env name
Update web\test_data\environments\db_connections.json with the db details of the environment
```Note
We can use environment variables as well or provide DB_PWD at run time.
```
#### Basic Usage

To synchronize all configuration and constants for an environment, run:

```bash
python -m dev_utils.env_config_sync.cli --env QA28
```

Replace `QA28` with your environment name (like `DEMO05`, `PROD`, etc.).

#### More Options

- **Update only configuration**:
  ```bash
  python -m dev_utils.env_config_sync.cli --env QA28 --config-only
  ```

- **Update only constants**:
  ```bash
  python -m dev_utils.env_config_sync.cli --env QA28 --constants-only
  ```

- **Specify a custom owner ID** (helpful for multi-tenant environments):
  ```bash
  python -m dev_utils.env_config_sync.cli --env QA28 --owner 123456789
  ```

- **See detailed logs**:
  ```bash
  python -m dev_utils.env_config_sync.cli --env QA28 --verbose
  ```

### What happens when it runs?

1. The tool connects to the database for your environment
2. It reads a special "metadata" file that tells it what values to fetch
3. It runs optimized database queries to get those values
4. It updates the configuration files with the new values
5. Your tests can now use the updated values automatically

### Understanding the Metadata

The metadata defines what values to fetch and where to put them. Here's a simple explanation of what each part means:

#### Key Parts of a Metadata Item

- **target**: Where to save the data - either "config" or "constants"
- **path**: Where in the JSON file to put the value (can be nested with multiple levels)
- **data_source**: Where to get the data from (usually "DB" for database). API support will be added in future as required.
- **description**: A human-readable explanation of what this setting is for
- **query**: The database query object to run to get the value

#### Query Settings

- **query**: The actual SQL query to run
- **params**: Any parameters needed for the query (like environment name or owner ID). Currently support env_name and owner_id only. Rest can be hardcoded in the query for specific configs.
- **result_type**: What kind of result to expect (single value, multiple values, or key-value pairs)
- **key_column**: For key-value pairs, which column contains the key
- **value_column**: For key-value pairs, which column contains the value
- **fallback_value**: What to use if the query fails or returns no data

### Example

If we have this metadata:

```
{
    "target": "config",
    "path": ["baseUrl"],
    "data_source": "DB",
    "description": "The base URL for the application",
    "query": {
        "query": "SELECT PARAM_VALUE FROM rfx_config WHERE PARAM_NAME = 'APPURL'",
        "result_type": "SINGLE_VALUE",
        "fallback_value": "https://default-url.example.com"
    }
}
```

When the tool runs, it will:
1. Connect to the database
2. Run the query `SELECT PARAM_VALUE FROM rfx_config WHERE PARAM_NAME = 'APPURL'`
3. Take the result (e.g., "https://qa28.example.com")
4. Save it in the config.json file under the key "baseUrl"
5. If the query fails, it will use "https://default-url.example.com" instead

Now your tests can simply read `config.json` and get the right URL for that environment.

### Special Feature: Direct Root Configuration

Some configuration values can be added directly to the root of the configuration file using an empty path:

```
{
    "target": "config",
    "path": [],  # Empty path means add directly to root
    "data_source": "DB",
    "description": "Application settings",
    "query": {
        "query": "SELECT PARAM_NAME, PARAM_VALUE FROM rfx_config WHERE PARAM_NAME IN ('DATEFORMAT', 'APPURL')",
        "result_type": "KEY_VALUE_MAP",
        "key_column": "PARAM_NAME",
        "value_column": "PARAM_VALUE"
    }
}
```

This will add entries directly to the root of the config.json file, using the database column values as keys.

### Best Practices

1. **Run the synchronization before test execution** to ensure your tests have the latest configuration
2. **Use the verbose flag** when troubleshooting to see what values are being fetched
3. **Set appropriate fallback values** to handle cases where database values might be missing
4. **Group related configuration items** using the source_group field for better organization
