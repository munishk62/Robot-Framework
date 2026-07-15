import os
import platform
import site


class db2_utility:
    def __init__(self):
        self.connection = None

    def find_dll_directory(self):
        """Locate the clidriver directory within site-packages."""
        try:
            for site_package in site.getsitepackages():
                for root, dirs, _ in os.walk(site_package):
                    if "clidriver" in dirs:
                        return os.path.join(root, "clidriver", "bin")
            raise RuntimeError("clidriver directory not found in site-packages.")
        except Exception as e:
            raise RuntimeError(f"Error finding DLL directory: {e}")

    def connect_to_db(
        self,
        dsn_hostname,
        dsn_uid,
        dsn_pwd,
        dsn_database,
        dsn_port,
        dsn_protocol,
        dns_schema="RWSUSER",
    ):
        """Connect to the DB2 database with the given parameters."""
        dsn = (
            f"DATABASE={dsn_database};"
            f"HOSTNAME={dsn_hostname};"
            f"PORT={dsn_port};"
            f"PROTOCOL={dsn_protocol};"
            f"UID={dsn_uid};"
            f"PWD={dsn_pwd};"
            "AUTHENTICATION=SERVER;"
        )

        try:
            # Add DLL directory only on Windows
            if platform.system() == "Windows":
                dll_directory = self.find_dll_directory()
                os.add_dll_directory(dll_directory)
                print(f"DLL directory added: {dll_directory}")

            # Import ibm_db after adding DLL path
            import ibm_db

            # Connect to the database
            self.connection = ibm_db.connect(dsn, "", "")
            if self.connection:
                print("Connected to the database successfully!")
                # Set default schema to avoid schema qualification issues
                try:
                    ibm_db.exec_immediate(self.connection, f"SET SCHEMA {dns_schema}")
                    print(f"Default schema set to {dns_schema}")
                except Exception as schema_error:
                    print(
                        f"Warning: Could not set default schema to {dns_schema}: {schema_error}"
                    )
                return self.connection
            else:
                error_msg = ibm_db.conn_errormsg()
                raise RuntimeError(f"Connection failed: {error_msg}")

        except ImportError:
            raise ImportError(
                "ibm_db module is not installed. Run `pip install ibm_db`."
            )
        except Exception as e:
            raise RuntimeError(f"Error connecting to the database: {e}")

    def execute_query(self, query):
        """Execute a query and return results for SELECT or affected rows for other queries."""
        try:
            import ibm_db

            if not self.connection:
                raise RuntimeError(
                    "No active database connection. Please connect first."
                )

            stmt = ibm_db.exec_immediate(self.connection, query)

            # Return results if it's a SELECT query
            if query.strip().upper().startswith("SELECT"):
                results = []
                row = ibm_db.fetch_assoc(stmt)
                while row:
                    results.append(row)
                    row = ibm_db.fetch_assoc(stmt)
                return results

            # Return the number of affected rows for non-SELECT queries
            return ibm_db.num_rows(stmt)

        except ImportError:
            raise ImportError(
                "ibm_db module is not installed. Run `pip install ibm_db`."
            )
        except Exception as e:
            raise RuntimeError(f"Error executing query: {e}")

    def close_connection(self):
        """Close the database connection."""
        try:
            if self.connection:
                import ibm_db

                ibm_db.close(self.connection)
                self.connection = None
                print("Connection closed.")
        except Exception as e:
            raise RuntimeError(f"Error closing connection: {e}")
