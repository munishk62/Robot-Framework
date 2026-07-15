# DB2 Database Connection Details

## Configuration

Database credentials are stored in `.env` file at project root:

```properties
DB2_CONNECTION={"database":"RWS4MT","hostname":"server.com","port":50010,"username":"user","password":"pass","schema":"RWS4MT"}
```

**Format:**
- Single `DB2_CONNECTION` variable contains JSON object with database connection details
- The `schema` parameter sets the `CURRENTSCHEMA` for the DB2 connection
- When `schema` is provided, tables can be queried without explicit schema prefixes
- Update this configuration for the environment you're testing against

**Schema Behavior:**
- **With schema**: `SELECT * FROM RAR_UNIT_D` (schema automatically prepended)
- **Without schema**: Queries use DB2's default schema resolution

## How It Works

```
Test Execution (--test-env QA28_B0)
    ↓
Execute Query And Return Result
    ↓
Connect To DB2 Database
    ↓
Load DB2_CONNECTION from .env
    ↓
Set CURRENTSCHEMA (if schema provided)
    ↓
Execute SQL Query (no schema prefix needed)
    ↓
Return Results (List of Tuples)
    ↓
Disconnect
```

## Usage in Tests

```robotframework
*** Test Cases ***
Query Database
    ${result}=    Execute Query And Return Result    SELECT * FROM RWS_EMPLOYEE WHERE EMPLOYEE_ID = '50000001'
    ${first_row}=    Get From List    ${result}    0
    ${employee_id}=    Get From List    ${first_row}    0
```

Database queries should be maintained in `.py` files under their respective resource locations.
**Example:**  
- If your database query is related to the web clock module, create a file such as `webclock_db_queries.py` in the appropriate resource directory (e.g., `resources/web/clock/webclock_db_queries.py`).
- Define your query as a variable, for example: `GET_ACTIVE_WEB_CLOCK_DEVICE_IDS`.
- Import this variable into your Robot Framework resource file and use it as needed.

## Adding New Environment

Update the `DB2_CONNECTION` in `.env` file with credentials for the environment you want to test:

```properties
DB2_CONNECTION={"database":"NEW_DB","hostname":"newserver.com","port":50010,"username":"newuser","password":"newpass","schema":"NEW_SCHEMA"}
```

## Verification

```bash
# Check if DB2_CONNECTION loads correctly
python -c "from dotenv import load_dotenv; import os, json; load_dotenv(); print(json.loads(os.getenv('DB2_CONNECTION')))"
```

## Key Files

- `.env` - Database credentials (NOT committed to git)
- `resources/web/common/database.resource` - Robot Framework keywords
- `resources/web/common/db2_connection.py` - Python DB2 connection library

## Important Notes

- Results are **list of tuples**, not dictionaries
- Use `Get From List` to extract values
- Connection automatically opens/closes with `Execute Query And Return Result`
- Passwords are masked in logs
- `.env` file is in `.gitignore`

## Troubleshooting

**Error: "DB2_CONNECTION environment variable not found"**
- Add DB2_CONNECTION to .env file with proper JSON format

**Error: "ibm_db module not available"**
- Install: `uv pip install ibm_db`

**Error: "python-dotenv could not parse statement"**
- Ensure DB2_CONNECTION is on a single line (no line breaks in JSON)

