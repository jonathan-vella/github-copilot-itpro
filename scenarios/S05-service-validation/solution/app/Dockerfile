FROM python:3.11-slim-bullseye

WORKDIR /app

# Install ODBC Driver for SQL Server (use 17 for broader stability on Debian 11/App Service)
RUN apt-get update && \
    apt-get install -y curl gnupg unixodbc unixodbc-dev ca-certificates libgssapi-krb5-2 && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 msodbcsql17 mssql-tools18 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

# Use pure-python stack (no uvloop/httptools) to avoid segfaults
ENV UVICORN_WORKERS=1
ENV UVICORN_NO_UVLOOP=1
ENV UVICORN_NO_HTTPTOOLS=1
ENV PYTHONFAULTHANDLER=1
ENV PYTHONUNBUFFERED=1
ENV PATH="${PATH}:/opt/mssql-tools18/bin:/opt/mssql-tools/bin"
CMD ["python", "-X", "faulthandler", "-u", "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--http", "h11", "--loop", "asyncio", "--lifespan", "off"]
