# Web Frontend for SAIF

[![PHP](https://img.shields.io/badge/PHP-8.2-777BB4?logo=php&logoColor=white)](https://www.php.net/)
[![Apache](https://img.shields.io/badge/Apache-2.4-D22128?logo=apache&logoColor=white)](https://httpd.apache.org/)
[![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-7952B3?logo=bootstrap&logoColor=white)](https://getbootstrap.com/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](../docker-compose.yml)

PHP-based web interface that provides a user-friendly way to interact with the SAIF API endpoints.

```mermaid
%%{init: {'theme':'neutral'}}%%
graph LR
    User((User)) --> Web[Web Frontend]
    Web --> API[API Backend]
    
    subgraph "Web Components"
        Dashboard[Dashboard]
        Tools[Diagnostic Tools]
        Results[Results Display]
    end
    
    Web --> Dashboard
    Web --> Tools
    Tools --> Results
    
    classDef frontend fill:#4CAF50,stroke:#333,color:white;
    classDef component fill:#2196F3,stroke:#333,color:white;
    classDef user fill:#5C5C5C,stroke:#5C5C5C,color:white;
    class Web frontend;
    class Dashboard,Tools,Results component;
    class User,API user;
```

## Features

The web interface provides access to all API endpoints, including:

- Health check display
- IP information
- SQL Server diagnostics
- DNS and reverse DNS lookup tools
- URL fetch utility
- Environment variable display
- PI calculation tool

## Setup

The web component requires:

- PHP 8.2+
- Apache or other compatible web server

## Environment Variables

- `API_URL` - The URL of the SAIF API service (e.g., http://localhost:8000)
- `API_KEY` - The API key for authenticated endpoints (deliberately insecure)

## Development

For local development:

```bash
# Move to the web directory
cd web

# Start PHP's built-in server
php -S localhost:8080
```

## Docker Development

```bash
# Build the image
docker build -t saif-web .

# Run the container
docker run -p 80:80 -e API_URL=http://api:8000 -e API_KEY=your_api_key saif-web
```

## Security Challenges

This web interface contains deliberate security issues for learning purposes:

1. Lack of input validation
2. Potential XSS vulnerabilities
3. Client-side API key exposure
4. No authentication or authorization controls
