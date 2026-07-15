*** Settings ***
Documentation       Database connectivity keywords for WFM Test Automation
...
...                 This resource file provides reusable keywords for connecting to DB2 databases.
...                 Database credentials are loaded from .env file using DB2_CONNECTION variable.
...
...                 **Environment Variable Format:**
...                 DB2_CONNECTION={"database":"...","hostname":"...","port":...,"username":"...","password":"...","schema":"..."}
...
...                 **Schema Configuration:**
...                 The "schema" parameter in DB2_CONNECTION sets the CURRENTSCHEMA for the DB2 connection.
...                 This allows querying tables without explicit schema prefixes (e.g., SELECT * FROM RAR_UNIT_D).
...                 If schema is provided, it will be used as the default schema for unqualified table names.
...
...                 **Example .env configuration:**
...                 DB2_CONNECTION={"database":"RWS4MT","hostname":"server.com","port":50010,"username":"user","password":"pass","schema":"RWS4MT"}
...
...                 **For detailed documentation, see:**
...                 docs/DB2_DATABASE_DETAILS.md

Library             resources.web.common.db2_connection.DB2Connection    AS    DB2Lib
Library             test_data/TestDataLibrary.py


*** Keywords ***
Connect To DB2 Database
    [Documentation]
    ...    Establishes connection to DB2 database using configuration from .env file.
    ...    Connection details are loaded from DB_CONNECTION variable in .env file.
    ...
    ...    Example usage:
    ...    | Connect To DB2 Database
    ...    | ${info}=    Get DB2 Connection Info
    ...    | Log    Connected to: ${info}[database]
    ${connection_info}=    DB2Lib.Connect To Db2 Database
    Log    Successfully connected to DB2 database
    RETURN    ${connection_info}

Disconnect DB2 Database
    [Documentation]
    ...    Closes the connection to DB2 database.
    ...    Example usage:
    ...    | Disconnect DB2 Database
    DB2Lib.Disconnect From Db2 Database
    Log    Disconnected from DB2 database

Get DB2 Connection Info
    [Documentation]
    ...    Returns current database connection information.
    ...
    ...    Returns: Dictionary with connection details
    ...
    ...    Example usage:
    ...    | ${info}=    Get DB2 Connection Info
    ...    | Log    Connected to: ${info}[database]
    ${info}=    DB2Lib.Get Connection Info
    RETURN    ${info}

Execute Query And Return Result
    [Documentation]
    ...    Executes an SQL query and returns the result.
    ...    Automatically handles database connection and disconnection.
    ...    Uses DB2_CONNECTION from .env file for database credentials.
    ...
    ...    **Important:** Results are returned as list of tuples, not dictionaries.
    ...    Use Get From List to extract values from rows.
    ...
    ...    | =Arguments= | =Description= |
    ...    | sql_query    | SQL query to execute |
    ...
    ...    | =Returns= | =Description= |
    ...    | result    | List of tuples containing query results. Example: [('value1', 'value2'), ('value3', 'value4')] |
    ...
    ...    Example usage:
    ...    | ${result}=    Execute Query And Return Result    SELECT * FROM RWS_EMPLOYEE WHERE EMPLOYEE_ID = '50000001'
    ...    | ${first_row}=    Get From List    ${result}    0
    [Arguments]    ${sql_query}
    Connect To DB2 Database
    ${result}=    DB2Lib.Execute Db2 Query    ${sql_query}
    Disconnect DB2 Database
    RETURN    ${result}

Execute Query And Return Result In Dictionary JSON
    [Documentation]    Execute Query And Return Result In Dictionary JSON
    ...    Automatically handles database connection and disconnection.
    ...    Uses DB2_CONNECTION from .env file for database credentials.
    ...    | =Arguments= | =Description= |
    ...    | sql_query    | SQL query to execute |
    ...    | =Returns= | =Description= |
    ...    | json_string    | JSON string representing query results. Example: '[{"column1": "value1", "column2": "value2"}, {"column1": "value3", "column2": "value4"}]' |
    ...    Example usage:
    ...    | Execute Query And Return Result In Dictionary JSON    SELECT * FROM RWS_EMPLOYEE WHERE EMPLOYEE_ID = '50000001'
    [Arguments]    ${sql_query}
    Connect To DB2 Database
    ${result}=    DB2Lib.Execute Db2 Query For Api Pattern    ${sql_query}
    Disconnect DB2 Database
    RETURN    ${result}

Convert DB Results Tuples To JSON String
    [Documentation]    Converts the DB results tuples to JSON string
    ...    | =Arguments=    | =Description=    |
    ...    | db_results    | DB results as tuples.    |
    ...    | column_names    | List of column names corresponding to DB results.    |
    [Arguments]    ${db_results}    ${column_names}
    ${json_array}=    Create List Of Dictionaries From Data    ${column_names}    ${db_results}
    Log    ${json_array}
    # Convert the list of dictionaries to a formatted JSON string
    ${json_string}=    Evaluate    json.dumps(${json_array}, indent=4)    modules=json
    Log    ${json_string}
    RETURN    ${json_string}

Create List Of Dictionaries From Data
    [Documentation]    Creates a list of dictionaries from given keys and list of values
    ...    | =Arguments=    | =Description=    |
    ...    | keys    | List of keys for the dictionaries.    |
    ...    | all_values    | List of lists containing values for each dictionary.    |
    ...    | =Returns=    | List of dictionaries created from keys and values.    |
    [Arguments]    ${keys}    ${all_values}
    VAR    @{list_of_dicts}=    @{EMPTY}
    FOR    ${values}    IN    @{all_values}
        # Use Evaluate to run the Python zip() and dict() functions
        ${new_dict}=    Evaluate    dict(zip($keys, $values))
        ${string_dict}=    Convert Dictionary Values To Strings    ${new_dict}
        Append To List    ${list_of_dicts}    ${string_dict}
    END
    RETURN    ${list_of_dicts}

Convert Dictionary Values To Strings
    [Documentation]    Converts all values in the given dictionary to strings
    ...    | =Arguments=    | =Description=    |
    ...    | dictionary    | Input dictionary with values to convert.    |
    ...    | =Returns=    | New dictionary with all values as strings.    |
    [Arguments]    ${dictionary}
    VAR    &{string_dict}=    &{EMPTY}
    FOR    ${key}    ${value}    IN    &{dictionary}
        ${string_value}=    Convert To String    ${value}    # Convert value to string
        Set To Dictionary    ${string_dict}    ${key}    ${string_value}
    END
    RETURN    ${string_dict}
