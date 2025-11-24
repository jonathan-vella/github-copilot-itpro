import os
import json
import subprocess

# Worker to validate MI connectivity and DB principal/roles using DSN + sqlcmd

SQLCMD_CANDIDATES = [
    "/opt/mssql-tools18/bin/sqlcmd",
    "/opt/mssql-tools/bin/sqlcmd",
    "sqlcmd",
]

def _find_sqlcmd() -> str:
    for p in SQLCMD_CANDIDATES:
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
        os.environ["ODBCINI"] = odbc_ini_path
    except Exception as e:
        print(json.dumps({"error": f"Failed to write ODBCINI: {str(e)}", "ok": False}))
        return

    query = (
        "SET NOCOUNT ON;"
        "SELECT DB_NAME() AS dbname, SUSER_SNAME() AS login_name, USER_NAME() AS user_name;"
        "SELECT name FROM sys.database_principals WHERE name = USER_NAME();"
        "SELECT r.name FROM sys.database_role_members m"
        " JOIN sys.database_principals r ON m.role_principal_id = r.principal_id"
        " JOIN sys.database_principals u ON m.member_principal_id = u.principal_id"
        " WHERE u.name = USER_NAME();"
    )

    args = [
        sqlcmd,
        "-D",
        "-S", dsn_name,
        "-d", sql_database,
        "-Q", query,
        "-W",
        "-h", "-1",
    ]

    try:
        proc = subprocess.run(args, capture_output=True, text=True, timeout=25)
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
        print(json.dumps({
            "error": stderr[:500] or "sqlcmd returned non-zero exit code",
            "returncode": proc.returncode,
            "ok": False,
        }))
        return

    # We executed 3 SELECTs; parse them naively by splitting lines.
    lines = [l for l in stdout.splitlines() if l.strip()]
    result = {"ok": True, "mode": "sqlcmd-msi-dsn"}
    try:
        # First select: dbname|login_name|user_name (assuming | not present due to -W,
        # but sqlcmd default delimiter is spaces/tabs; we'll split on tabs or multiple spaces)
        first = lines[0].split("\t") if "\t" in lines[0] else lines[0].split()
        if len(first) >= 3:
            result.update({
                "db": first[0],
                "login_name": first[1],
                "user_name": first[2],
            })
        # Next lines may contain the principal row and then role rows; collect roles after first line
        roles = []
        if len(lines) > 1:
            for l in lines[1:]:
                parts = l.split("\t") if "\t" in l else l.split()
                if parts:
                    roles.append(parts[0])
        result["roles"] = roles
    except Exception:
        result["raw"] = stdout[:400]

    print(json.dumps(result))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(json.dumps({"error": str(e), "ok": False}))
