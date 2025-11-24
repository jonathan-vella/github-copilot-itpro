import os
import json
import subprocess

# This worker runs in a separate process and now shells out to sqlcmd to avoid
# native crashes in pyodbc on App Service. It uses Managed Identity auth.

SQLCMD_PATHS = [
    "/opt/mssql-tools18/bin/sqlcmd",  # preferred (mssql-tools18)
    "/opt/mssql-tools/bin/sqlcmd",    # fallback if older tools are present
    "sqlcmd",                          # last resort, rely on PATH
]


def _find_sqlcmd() -> str:
    for p in SQLCMD_PATHS:
        if os.path.isfile(p) or p == "sqlcmd":
            return p
    return "sqlcmd"


def main():
    sql_server = os.getenv("SQL_SERVER")
    sql_database = os.getenv("SQL_DATABASE")
    if not sql_server or not sql_database:
        print(json.dumps({"error": "Missing SQL env vars", "ok": False}))
        return

    sqlcmd = _find_sqlcmd()
    # Classic sqlcmd doesn't support --authentication-method. Use an ODBC DSN with
    # Authentication=ActiveDirectoryMSI and let Managed Identity provide the token.
    dsn_name = "saifmsi"
    odbc_ini_path = "/tmp/odbc.ini"
    odbc_ini = f"""
[ODBC Data Sources]
{dsn_name}=ODBC Driver 18 for SQL Server

[{dsn_name}]
Driver = ODBC Driver 18 for SQL Server
Server = tcp:{sql_server},1433
Database = {sql_database}
Encrypt = yes
TrustServerCertificate = no
Authentication = ActiveDirectoryMSI
""".strip()
    try:
        with open(odbc_ini_path, "w", encoding="utf-8") as f:
            f.write(odbc_ini + "\n")
        # Point unixODBC to our user DSN file
        os.environ["ODBCINI"] = odbc_ini_path
    except Exception as e:
        print(json.dumps({"error": f"Failed to write ODBCINI: {str(e)}", "ok": False}))
        return

    # -D tells sqlcmd that -S value is a DSN name
    # -Q executes the query and exits; -W trims trailing spaces; -h -1 removes headers
    args = [
        sqlcmd,
        "-D",
        "-S", dsn_name,
        "-d", sql_database,
        "-Q", "SET NOCOUNT ON; SELECT @@VERSION;",
        "-W",
        "-h", "-1",
    ]

    try:
        proc = subprocess.run(args, capture_output=True, text=True, timeout=20)
    except FileNotFoundError:
        print(json.dumps({
            "error": "sqlcmd not found. Ensure mssql-tools18 is installed in the container",
            "ok": False
        }))
        return
    except Exception as e:
        print(json.dumps({"error": str(e), "ok": False}))
        return

    stdout = (proc.stdout or "").strip()
    stderr = (proc.stderr or "").strip()

    if proc.returncode != 0:
        # Surface stderr and command line for diagnostics (trimmed)
        print(json.dumps({
            "error": stderr[:500] or "sqlcmd returned non-zero exit code",
            "returncode": proc.returncode,
            "ok": False,
        }))
        return

    # Parse the first non-empty line as version
    version_line = next((line for line in stdout.splitlines() if line.strip()), "")
    if not version_line:
        print(json.dumps({
            "error": "No output from sqlcmd",
            "stdout": stdout[:300],
            "ok": False
        }))
        return

    print(json.dumps({
        "sql_version": version_line,
        "version": version_line,
        "ok": True,
        "mode": "sqlcmd-msi-dsn"
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        # Ensure a single-line JSON payload on errors
        print(json.dumps({"error": str(e), "ok": False}))
