"""
DB2 Database Connection Library for Robot Framework Tests.

This library provides keywords for connecting to and querying DB2 databases
in Robot Framework tests. It uses configuration from DB2_CONNECTION environment
variable loaded into the process environment.

Example environment value:
DB2_CONNECTION={"database":"RWS4MT","hostname":"server.com","port":50010,"username":"user","password":"pass","schema":"RWS4MT"}
"""

import os
import sys
import json
import logging
from dotenv import load_dotenv
from typing import Dict, Any, List

# Configure logging
logger = logging.getLogger(__name__)

# Try to add IBM DB2 CLI driver path if on Windows
if sys.platform == "win32":
    try:
        import site

        # Look for clidriver in site-packages
        for site_dir in site.getsitepackages():
            clidriver_path = os.path.join(site_dir, "clidriver", "bin")
            if os.path.exists(clidriver_path):
                os.add_dll_directory(clidriver_path)
                logger.info(f"Added DLL directory: {clidriver_path}")
                break
    except Exception as e:
        logger.warning(f"Could not add clidriver DLL directory: {e}")

# Try to import IBM DB2 library
try:
    import ibm_db
    import ibm_db_dbi

    HAS_IBM_DB = True
    logger.info("IBM DB2 driver loaded successfully")
except ImportError as e:
    HAS_IBM_DB = False
    logger.warning(
        f"ibm_db module not available: {e}. DB2 functionality will be limited."
    )


class DB2Connection:
    """
    Robot Framework library for DB2 database connectivity.

    This library provides keywords to connect to DB2 databases using
    configuration from environment variables.
    """

    ROBOT_LIBRARY_SCOPE = "SUITE"
    ROBOT_LIBRARY_VERSION = "1.0"

    def __init__(self):
        """Initialize the DB2 connection library."""
        self.connection = None
        self.cursor = None
        self.connection_config = None

    def connect_to_db2_database(self) -> Dict[str, Any]:
        """
        Connect to DB2 database using configuration from environment variables.

        Returns:
            Dictionary containing connection information

        Raises:
            ImportError: If ibm_db library is not installed
            Exception: If connection fails
        """
        if not HAS_IBM_DB:
            raise ImportError(
                "IBM DB2 driver (ibm_db) is not installed. "
                "Please install it using: pip install ibm_db"
            )

        self.connection_config = self._load_connection_config()

        # Build connection string
        conn_string = self._build_connection_string()

        try:
            logger.info("Connecting to DB2 database")
            logger.info(f"Database: {self.connection_config['database']}")
            logger.info(f"Host: {self.connection_config['hostname']}")
            logger.info(f"Port: {self.connection_config['port']}")
            logger.info(f"User: {self.connection_config['username']}")

            # Establish connection
            conn = ibm_db.connect(conn_string, "", "")
            self.connection = ibm_db_dbi.Connection(conn)
            self.cursor = self.connection.cursor()

            logger.info("Successfully connected to DB2 database")

            return {
                "status": "connected",
                "database": self.connection_config["database"],
                "hostname": self.connection_config["hostname"],
                "port": self.connection_config["port"],
            }

        except Exception as e:
            conn_info = f"{self.connection_config['hostname']}:{self.connection_config['port']}/{self.connection_config['database']}, User: {self.connection_config['username']}"
            logger.error(f"Failed to connect to DB2 database: {str(e)}")
            logger.error(f"Connection details: {conn_info}")
            raise Exception(f"DB2 connection failed: {str(e)}")

    def disconnect_from_db2_database(self):
        """
        Disconnect from DB2 database and clean up resources.
        """
        try:
            if self.cursor:
                self.cursor.close()
                logger.info("Closed database cursor")

            if self.connection:
                self.connection.close()
                logger.info("Disconnected from DB2 database")

        except Exception as e:
            logger.warning(f"Error during disconnect: {str(e)}")
        finally:
            self.connection = None
            self.cursor = None

    def execute_db2_query(self, query: str) -> List[tuple]:
        """
        Execute a SQL query on the connected DB2 database.

        Args:
            query: SQL query to execute

        Returns:
            List of tuples containing query results

        Raises:
            Exception: If no connection exists or query fails
        """
        if not self.connection or not self.cursor:
            raise Exception(
                "Not connected to database. Call 'Connect To DB2 Database' first."
            )

        try:
            logger.info(f"Executing query: {query[:100]}...")
            self.cursor.execute(query)

            # Fetch results if it's a SELECT query
            if self.cursor.description:
                results = self.cursor.fetchall()
                logger.info(f"Query returned {len(results)} rows")
                return results
            else:
                logger.info("Query executed successfully (no results)")
                return []

        except Exception as e:
            logger.error(f"Query execution failed: {str(e)}")
            raise Exception(f"Query execution failed: {str(e)}")

    def execute_db2_query_for_api_pattern(
        self, query: str
    ) -> List[Dict[str, Any]]:
        """
        Execute a SQL query and return results as a list of dictionaries.

        This is useful for API testing where results should be returned
        in a structured format with column names as dictionary keys.

        Args:
            query: SQL query to execute

        Returns:
            List of dictionaries containing query results, where each
            dictionary represents a row with column names as keys

        Raises:
            Exception: If no connection exists or query fails
        """
        if not self.connection or not self.cursor:
            raise Exception(
                "Not connected to database. Call 'Connect To DB2 Database' first."
            )

        try:
            logger.info(f"Executing query: {query[:100]}...")
            self.cursor.execute(query)

            if self.cursor.description:
                columns = [col[0] for col in self.cursor.description]
                rows = self.cursor.fetchall()
                results = [dict(zip(columns, row)) for row in rows]
                logger.info(f"Query returned {len(results)} rows")
                return results

            logger.info("Query executed successfully (no results)")
            return []

        except Exception as e:
            logger.error(f"Query execution failed: {str(e)}")
            raise Exception(f"Query execution failed: {str(e)}")

    def get_connection_info(self) -> Dict[str, Any]:
        """
        Get current connection information.

        Returns:
            Dictionary with connection details or None if not connected
        """
        if not self.connection_config:
            return {"status": "not_connected"}

        return {
            "status": "connected" if self.connection else "disconnected",
            "database": self.connection_config.get("database"),
            "hostname": self.connection_config.get("hostname"),
            "port": self.connection_config.get("port"),
            "schema": self.connection_config.get("schema"),
        }

    def _load_connection_config(self) -> Dict[str, Any]:
        """
        Load database connection configuration from environment variables.

        Returns:
            Dictionary with connection parameters

        Raises:
            ValueError: If DB2_CONNECTION not found or invalid
        """
        load_dotenv()

        # Load DB2_CONNECTION JSON from environment
        credentials_json = os.environ.get("DB2_CONNECTION")

        if not credentials_json:
            raise ValueError(
                "DB2_CONNECTION environment variable not found. "
                'Please add: DB2_CONNECTION={"database":"...","hostname":"...","port":...,"username":"...","password":"...","schema":"..."}'
            )

        try:
            config = json.loads(credentials_json)
        except json.JSONDecodeError as e:
            raise ValueError(f"Failed to parse DB2_CONNECTION JSON: {e}")

        logger.info("Loaded DB2 credentials from environment variable DB2_CONNECTION")

        return config

    def _build_connection_string(self) -> str:
        """
        Build IBM DB2 connection string from configuration.

        Sets CURRENTSCHEMA if schema parameter is provided in DB2_CONNECTION.
        This allows querying tables without explicit schema prefixes.

        Returns:
            Connection string for ibm_db.connect()
        """
        config = self.connection_config

        conn_string = (
            f"DATABASE={config['database']};"
            f"HOSTNAME={config['hostname']};"
            f"PORT={config['port']};"
            f"PROTOCOL=TCPIP;"
            f"UID={config['username']};"
            f"PWD={config['password']};"
            f"AUTHENTICATION=SERVER;"
        )

        # Add CURRENTSCHEMA if schema is provided in configuration
        # This sets the default schema for unqualified table names in queries
        if "schema" in config and config["schema"]:
            schema_value = str(config["schema"]).strip()
            if schema_value:
                conn_string += f"CURRENTSCHEMA={schema_value};"
                logger.info(f"Setting CURRENTSCHEMA to: {schema_value}")

        # Log connection string (without password) for debugging
        debug_string = conn_string.replace(f"PWD={config['password']};", "PWD=***;")
        logger.info(f"Connection string: {debug_string}")

        return conn_string
