import os
import socket
import requests
import time
from typing import Optional
import subprocess
import sys
import json
import dns.resolver
import mpmath

from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# Load environment variables if present
load_dotenv()

app = FastAPI(title="SAIF API v2", description="SAIF v2 API using Entra managed identity for Azure SQL")

# EDUCATIONAL VULNERABILITY: Keep permissive CORS for training parity with v1
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

API_KEY = os.getenv("API_KEY")  # optional insecure key retained for parity

SQL_SERVER = os.getenv("SQL_SERVER")
SQL_DATABASE = os.getenv("SQL_DATABASE")

def _get_access_token_bytes() -> bytes:
    # Acquire token for Azure SQL using managed identity
    # Scope for Azure SQL: https://database.windows.net/.default
    # Defer import to avoid potential native lib initialization issues at module import time
    from azure.identity import DefaultAzureCredential
    credential = DefaultAzureCredential()
    token = credential.get_token("https://database.windows.net/.default").token
    return token.encode("utf-16-le")  # pyodbc expects UTF-16LE bytes

def get_db_connection():
    if not all([SQL_SERVER, SQL_DATABASE]):
        raise HTTPException(status_code=500, detail="Database connection info not configured")

    # Use ODBC Driver 17 for SQL Server and token-based auth
    conn_str = (
        f"Driver={{ODBC Driver 17 for SQL Server}};"
        f"Server=tcp:{SQL_SERVER},1433;"
        f"Database={SQL_DATABASE};"
        f"Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
    )
    SQL_COPT_SS_ACCESS_TOKEN = 1256  # from msodbcsql headers
    try:
        import pyodbc  # defer import to avoid startup crashes if driver layer is problematic
        token_bytes = _get_access_token_bytes()
        return pyodbc.connect(conn_str, attrs_before={SQL_COPT_SS_ACCESS_TOKEN: token_bytes})
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")

@app.get("/")
async def root():
    return {"name": "SAIF API v2", "version": "2.0.1-subproc", "description": "Managed identity to Azure SQL"}

@app.get("/api/healthcheck")
async def healthcheck():
    # Align with frontend expectations (status: OK) and include extra context
    return {
        "status": "OK",
        "timestamp": time.time(),
        "version": "2.0.1-subproc",
        "hostname": socket.gethostname(),
    }

@app.get("/api/sqlversion")
async def get_sql_version(x_api_key: Optional[str] = Header(None)):
    # Insecure API key check retained for parity
    if API_KEY and x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API Key")
    # Call worker as a subprocess to isolate potential native segfaults
    try:
        proc = subprocess.run([sys.executable, "db_version_worker.py"], capture_output=True, text=True, timeout=20)
        stdout = (proc.stdout or "").strip()
        stderr = (proc.stderr or "").strip()

        if stdout:
            try:
                data = json.loads(stdout)
            except Exception:
                # Return trimmed outputs when JSON parsing fails
                return {
                    "error": "Invalid worker JSON output",
                    "returncode": proc.returncode,
                    "stdout": stdout[:300],
                    "stderr": stderr[:300],
                }
        elif stderr:
            # No stdout; surface stderr as error text
            return {"error": stderr[:500], "returncode": proc.returncode}
        else:
            return {"error": "No output from worker", "returncode": proc.returncode}

        # Normalize key for UI compatibility
        if isinstance(data, dict) and "sql_version" in data and "version" not in data:
            data["version"] = data["sql_version"]
        return data
    except Exception as e:
        return {"error": str(e)}

@app.get("/api/sqlwhoami")
async def sql_whoami(x_api_key: Optional[str] = Header(None)):
    # Insecure API key check retained for parity
    if API_KEY and x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API Key")
    try:
        proc = subprocess.run([sys.executable, "db_whoami_worker.py"], capture_output=True, text=True, timeout=20)
        stdout = (proc.stdout or "").strip()
        stderr = (proc.stderr or "").strip()

        if stdout:
            try:
                data = json.loads(stdout)
            except Exception:
                return {
                    "error": "Invalid worker JSON output",
                    "returncode": proc.returncode,
                    "stdout": stdout[:300],
                    "stderr": stderr[:300],
                }
        elif stderr:
            return {"error": stderr[:500], "returncode": proc.returncode}
        else:
            return {"error": "No output from worker", "returncode": proc.returncode}

        return data
    except Exception as e:
        return {"error": str(e)}

@app.get("/api/sqlsrcip")
async def get_sql_source_ip(x_api_key: Optional[str] = Header(None)):
    # Insecure API key check retained for parity
    if API_KEY and x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API Key")
    try:
        proc = subprocess.run([sys.executable, "db_sourceip_worker.py"], capture_output=True, text=True, timeout=20)
        stdout = (proc.stdout or "").strip()
        stderr = (proc.stderr or "").strip()

        if stdout:
            try:
                data = json.loads(stdout)
            except Exception:
                return {
                    "error": "Invalid worker JSON output",
                    "returncode": proc.returncode,
                    "stdout": stdout[:300],
                    "stderr": stderr[:300],
                }
        elif stderr:
            return {"error": stderr[:500], "returncode": proc.returncode}
        else:
            return {"error": "No output from worker", "returncode": proc.returncode}

        return data
    except Exception as e:
        return {"error": str(e)}

# SAIF endpoints restored for parity with v1 (deliberately vulnerable for training)

@app.get("/api/dns/{hostname}")
async def resolve_dns(hostname: str):
    """Resolves a DNS name to A/AAAA records"""
    try:
        a_records = dns.resolver.resolve(hostname, 'A')
        aaaa_records = dns.resolver.resolve(hostname, 'AAAA')
        return {
            "hostname": hostname,
            "a_records": [r.address for r in a_records],
            "aaaa_records": [r.address for r in aaaa_records],
        }
    except Exception as e:
        return {"hostname": hostname, "error": str(e)}

@app.get("/api/reversedns/{ip}")
async def reverse_dns(ip: str):
    """Performs reverse DNS lookup"""
    try:
        hostname = socket.gethostbyaddr(ip)[0]
        return {"ip": ip, "hostname": hostname}
    except Exception as e:
        return {"ip": ip, "error": str(e)}

@app.get("/api/curl")
async def curl_url(url: str):
    """Makes an HTTP request to a specified URL - deliberately insecure"""
    try:
        # EDUCATIONAL VULNERABILITY: No URL validation or SSRF protection
        resp = requests.get(url, timeout=5)
        return {
            "url": url,
            "status_code": resp.status_code,
            "content_type": resp.headers.get('Content-Type'),
            "body_preview": resp.text[:500],
        }
    except Exception as e:
        return {"url": url, "error": str(e)}

@app.get("/api/printenv")
async def print_env(x_api_key: Optional[str] = Header(None)):
    """Returns environment variables - deliberately insecure"""
    # Insecure API key check retained for parity
    if API_KEY and x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API Key")
    # INFORMATION DISCLOSURE: Exposes entire environment
    return dict(os.environ)

@app.get("/api/pi")
async def calculate_pi(digits: int = 1000):
    """Calculates PI to test CPU load"""
    try:
        if digits > 100000:
            raise HTTPException(status_code=400, detail="Maximum allowed digits is 100,000")
        mpmath.mp.dps = digits + 2
        pi_value = str(mpmath.mp.pi)[: digits + 2]
        return {"digits": digits, "pi": pi_value, "computation_time": f"{time.time()}"}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        return {"error": str(e)}
@app.get("/api/ip")
async def get_ip_info():
    hostname = socket.gethostname()
    local_ip = socket.gethostbyname(hostname)
    try:
        public_ip = requests.get('https://api.ipify.org', timeout=5).text
    except Exception:
        public_ip = "Unable to determine"
    return {"hostname": hostname, "local_ip": local_ip, "public_ip": public_ip}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app:app", host="0.0.0.0", port=8000, reload=True)
