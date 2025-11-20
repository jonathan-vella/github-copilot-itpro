<#
.SYNOPSIS
    Generates API documentation using GitHub Copilot.

.DESCRIPTION
    Scans Azure App Services, Function Apps, or Container Apps to generate a structured
    prompt for GitHub Copilot Chat to create comprehensive API documentation with
    endpoints, authentication, examples, and client SDKs.
    
    Demonstrates how Copilot reduces API documentation from 4 hours to 30 minutes (88% faster).

.PARAMETER ResourceGroupName
    Name of the resource group containing the API resources.

.PARAMETER OutputPath
    Directory path for generated prompt. Default: current directory.

.PARAMETER IncludeAuthentication
    Include authentication and authorization documentation.

.PARAMETER IncludeExamples
    Include code examples for common operations.

.PARAMETER IncludeSDKs
    Include client SDK generation examples.

.PARAMETER CopyToClipboard
    Copy the generated Copilot prompt to clipboard.

.EXAMPLE
    New-APIDocumentation -ResourceGroupName "rg-production" -OutputPath ".\output" -IncludeAuthentication -IncludeExamples -CopyToClipboard

.NOTES
    Author: Generated with GitHub Copilot
    Time Savings: 4 hours → 30 minutes (88% faster)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".",

    [Parameter(Mandatory = $false)]
    [switch]$IncludeAuthentication,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeExamples,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeSDKs,

    [Parameter(Mandatory = $false)]
    [switch]$CopyToClipboard
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = 'Info')
    $colors = @{ 'Info' = 'Cyan'; 'Success' = 'Green'; 'Warning' = 'Yellow'; 'Error' = 'Red' }
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor $colors[$Level]
}

Write-Log "Starting API documentation prompt generation..." -Level Info

# Check Azure authentication
$context = Get-AzContext
if (-not $context) {
    throw "Not authenticated to Azure. Run 'Connect-AzAccount' first."
}

Write-Log "Connected to subscription: $($context.Subscription.Name)" -Level Success

# Get resource inventory
Write-Log "Discovering API resources in '$ResourceGroupName'..."
$resources = Get-AzResource -ResourceGroupName $ResourceGroupName -ExpandProperties

if ($resources.Count -eq 0) {
    Write-Log "No resources found in resource group." -Level Warning
    return
}

Write-Log "Found $($resources.Count) resource(s)" -Level Success

# Identify API-related resources
$webApps = $resources | Where-Object { $_.ResourceType -eq 'Microsoft.Web/sites' }
$functionApps = $resources | Where-Object { $_.ResourceType -eq 'Microsoft.Web/sites' -and $_.Kind -match 'functionapp' }
$containerApps = $resources | Where-Object { $_.ResourceType -eq 'Microsoft.App/containerApps' }
$apiManagement = $resources | Where-Object { $_.ResourceType -eq 'Microsoft.ApiManagement/service' }
$appInsights = $resources | Where-Object { $_.ResourceType -eq 'Microsoft.Insights/components' }
$keyVaults = $resources | Where-Object { $_.ResourceType -eq 'Microsoft.KeyVault/vaults' }

# Build API inventory
$apiSummary = ""
$apiSummary += "## API Services`n"

if ($webApps.Count -gt 0) {
    $apiSummary += "`n### App Services ($(@($webApps).Count))`n"
    foreach ($app in $webApps) {
        $apiSummary += "- **Name**: ``$($app.Name)``"
        if ($app.Properties.defaultHostName) {
            $apiSummary += " - **URL**: ``https://$($app.Properties.defaultHostName)``"
        }
        if ($app.Properties.httpsOnly) {
            $apiSummary += " - **HTTPS Only**: Yes"
        }
        $apiSummary += "`n"
    }
}

if ($functionApps.Count -gt 0) {
    $apiSummary += "`n### Function Apps ($(@($functionApps).Count))`n"
    foreach ($app in $functionApps) {
        $apiSummary += "- **Name**: ``$($app.Name)``"
        if ($app.Properties.defaultHostName) {
            $apiSummary += " - **URL**: ``https://$($app.Properties.defaultHostName)``"
        }
        $apiSummary += "`n"
    }
}

if ($containerApps.Count -gt 0) {
    $apiSummary += "`n### Container Apps ($(@($containerApps).Count))`n"
    foreach ($app in $containerApps) {
        $apiSummary += "- **Name**: ``$($app.Name)``"
        $apiSummary += "`n"
    }
}

if ($apiManagement.Count -gt 0) {
    $apiSummary += "`n### API Management ($(@($apiManagement).Count))`n"
    foreach ($apim in $apiManagement) {
        $apiSummary += "- **Name**: ``$($apim.Name)``"
        if ($apim.Properties.gatewayUrl) {
            $apiSummary += " - **Gateway URL**: ``$($apim.Properties.gatewayUrl)``"
        }
        $apiSummary += "`n"
    }
}

$apiSummary += "`n## Supporting Services`n"

if ($appInsights.Count -gt 0) {
    $apiSummary += "- **Application Insights**: ``$($appInsights[0].Name)`` (for telemetry and monitoring)`n"
}

if ($keyVaults.Count -gt 0) {
    $apiSummary += "- **Key Vault**: ``$($keyVaults[0].Name)`` (for secrets management)`n"
}

# Build Copilot prompt
$prompt = @"
# Generate API Documentation

Please create comprehensive **API Documentation** for the following Azure API services in resource group **$ResourceGroupName**:

## Deployed API Resources

$apiSummary

## Required Documentation Sections

### 1. API Overview

- **Purpose**: What does this API do? What business problem does it solve?
- **Version**: API version (e.g., v1, v2)
- **Base URL**: Primary endpoint URL
- **Architecture**: REST API, GraphQL, WebSockets, etc.
- **Data Format**: JSON, XML, etc.
- **Rate Limiting**: Requests per minute/hour limits (if applicable)

### 2. Getting Started

#### Prerequisites
- Azure subscription or API key
- Development environment (Node.js, Python, .NET, etc.)
- Required tools (Postman, curl, HTTP client)

#### Quick Start
Provide a simple "Hello World" example:

**Using curl:**
``````bash
curl -X GET "https://<api-url>/api/health" \
  -H "Content-Type: application/json"
``````

**Expected Response:**
``````json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2025-01-20T12:00:00Z"
}
``````

"@

if ($IncludeAuthentication) {
    $prompt += @"


### 3. Authentication & Authorization

Document authentication mechanisms:

#### 3.1 Authentication Methods

**Supported Methods:**
- **Azure AD (Entra ID)**: OAuth 2.0 / OpenID Connect
- **API Key**: Header-based authentication
- **Managed Identity**: For Azure service-to-service calls
- **Bearer Token**: JWT token in Authorization header

#### 3.2 Obtaining Access Tokens

**Azure AD Authentication Flow:**

1. **Register Application** in Azure AD
2. **Request Token**:
``````bash
curl -X POST "https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=<client-id>" \
  -d "client_secret=<client-secret>" \
  -d "grant_type=client_credentials" \
  -d "scope=https://<api-url>/.default"
``````

3. **Use Token** in API requests:
``````bash
curl -X GET "https://<api-url>/api/resource" \
  -H "Authorization: Bearer <access-token>"
``````

#### 3.3 API Key Authentication

**Using API Key:**
``````bash
curl -X GET "https://<api-url>/api/resource" \
  -H "X-API-Key: <your-api-key>"
``````

#### 3.4 Authorization Scopes

Document required permissions/scopes:

| Scope | Description | Required For |
|-------|-------------|--------------|
| ``api.read`` | Read access to resources | GET operations |
| ``api.write`` | Write access to resources | POST, PUT operations |
| ``api.delete`` | Delete resources | DELETE operations |
| ``api.admin`` | Full administrative access | All operations |

#### 3.5 Error Responses

**401 Unauthorized:**
``````json
{
  "error": "unauthorized",
  "message": "Missing or invalid authentication token"
}
``````

**403 Forbidden:**
``````json
{
  "error": "forbidden",
  "message": "Insufficient permissions to access this resource"
}
``````

"@
}

$prompt += @"


### 4. API Endpoints

For each major endpoint, provide:
- HTTP Method (GET, POST, PUT, DELETE)
- Path with parameters
- Request headers
- Request body (with JSON schema)
- Response codes
- Response body (with examples)

#### Example Endpoint Documentation:

##### GET /api/patients

**Description**: Retrieve list of patients

**Request:**
``````http
GET /api/patients?page=1&pageSize=20 HTTP/1.1
Host: <api-url>
Authorization: Bearer <token>
Content-Type: application/json
``````

**Query Parameters:**

| Parameter | Type | Required | Description | Default |
|-----------|------|----------|-------------|---------|
| ``page`` | integer | No | Page number | 1 |
| ``pageSize`` | integer | No | Items per page | 20 |
| ``status`` | string | No | Filter by status | all |

**Response (200 OK):**
``````json
{
  "data": [
    {
      "id": "12345",
      "firstName": "John",
      "lastName": "Doe",
      "dateOfBirth": "1990-01-15",
      "status": "active"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalItems": 150,
    "totalPages": 8
  }
}
``````

**Response (400 Bad Request):**
``````json
{
  "error": "invalid_parameter",
  "message": "pageSize must be between 1 and 100"
}
``````

**Response (404 Not Found):**
``````json
{
  "error": "not_found",
  "message": "No patients found"
}
``````

---

##### POST /api/patients

**Description**: Create a new patient record

**Request:**
``````http
POST /api/patients HTTP/1.1
Host: <api-url>
Authorization: Bearer <token>
Content-Type: application/json

{
  "firstName": "Jane",
  "lastName": "Smith",
  "dateOfBirth": "1985-03-20",
  "email": "jane.smith@example.com",
  "phone": "+1-555-0123"
}
``````

**Request Body Schema:**

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| ``firstName`` | string | Yes | Max 50 chars | Patient first name |
| ``lastName`` | string | Yes | Max 50 chars | Patient last name |
| ``dateOfBirth`` | string | Yes | ISO 8601 date | Date of birth |
| ``email`` | string | No | Valid email | Contact email |
| ``phone`` | string | No | E.164 format | Contact phone |

**Response (201 Created):**
``````json
{
  "id": "67890",
  "firstName": "Jane",
  "lastName": "Smith",
  "dateOfBirth": "1985-03-20",
  "email": "jane.smith@example.com",
  "phone": "+1-555-0123",
  "status": "active",
  "createdAt": "2025-01-20T12:00:00Z"
}
``````

**Response (409 Conflict):**
``````json
{
  "error": "duplicate_record",
  "message": "Patient with this email already exists"
}
``````

---

*Repeat this pattern for all major endpoints (GET, POST, PUT, DELETE for each resource)*

"@

if ($IncludeExamples) {
    $prompt += @"


### 5. Code Examples

Provide code examples in multiple languages:

#### 5.1 JavaScript/TypeScript (Node.js)

``````javascript
const axios = require('axios');

const API_BASE_URL = 'https://<api-url>';
const ACCESS_TOKEN = '<your-access-token>';

// GET request example
async function getPatients() {
  try {
    const response = await axios.get(API_BASE_URL + '/api/patients', {
      headers: {
        'Authorization': 'Bearer ' + ACCESS_TOKEN,
        'Content-Type': 'application/json'
      },
      params: {
        page: 1,
        pageSize: 20
      }
    });
    
    console.log('Patients:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error:', error.response.data);
    throw error;
  }
}

// POST request example
async function createPatient(patientData) {
  try {
    const response = await axios.post(API_BASE_URL + '/api/patients', patientData, {
      headers: {
        'Authorization': 'Bearer ' + ACCESS_TOKEN,
        'Content-Type': 'application/json'
      }
    });
    
    console.log('Patient created:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error:', error.response.data);
    throw error;
  }
}

// Usage
getPatients();
createPatient({
  firstName: 'Jane',
  lastName: 'Smith',
  dateOfBirth: '1985-03-20',
  email: 'jane.smith@example.com'
});
``````

#### 5.2 Python

``````python
import requests
import json

API_BASE_URL = 'https://<api-url>'
ACCESS_TOKEN = '<your-access-token>'

headers = {
    'Authorization': f'Bearer {ACCESS_TOKEN}',
    'Content-Type': 'application/json'
}

# GET request example
def get_patients(page=1, page_size=20):
    response = requests.get(
        f'{API_BASE_URL}/api/patients',
        headers=headers,
        params={'page': page, 'pageSize': page_size}
    )
    
    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f'Error: {response.status_code} - {response.text}')

# POST request example
def create_patient(patient_data):
    response = requests.post(
        f'{API_BASE_URL}/api/patients',
        headers=headers,
        data=json.dumps(patient_data)
    )
    
    if response.status_code == 201:
        return response.json()
    else:
        raise Exception(f'Error: {response.status_code} - {response.text}')

# Usage
patients = get_patients()
print('Patients:', patients)

new_patient = create_patient({
    'firstName': 'Jane',
    'lastName': 'Smith',
    'dateOfBirth': '1985-03-20',
    'email': 'jane.smith@example.com'
})
print('Patient created:', new_patient)
``````

#### 5.3 C# (.NET)

``````csharp
using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

public class ApiClient
{
    private readonly HttpClient _httpClient;
    private const string API_BASE_URL = "https://<api-url>";
    private const string ACCESS_TOKEN = "<your-access-token>";

    public ApiClient()
    {
        _httpClient = new HttpClient();
        _httpClient.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", ACCESS_TOKEN);
        _httpClient.DefaultRequestHeaders.Accept.Add(
            new MediaTypeWithQualityHeaderValue("application/json"));
    }

    // GET request example
    public async Task<string> GetPatientsAsync(int page = 1, int pageSize = 20)
    {
        var response = await _httpClient.GetAsync(
            API_BASE_URL + "/api/patients?page=" + page + "&pageSize=" + pageSize
        );
        
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadAsStringAsync();
    }

    // POST request example
    public async Task<string> CreatePatientAsync(object patientData)
    {
        var json = JsonSerializer.Serialize(patientData);
        var content = new StringContent(json, Encoding.UTF8, "application/json");
        
        var response = await _httpClient.PostAsync(
            API_BASE_URL + "/api/patients",
            content
        );
        
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadAsStringAsync();
    }
}

// Usage
var client = new ApiClient();
var patients = await client.GetPatientsAsync();
Console.WriteLine("Patients: " + patients);

var newPatient = await client.CreatePatientAsync(new
{
    firstName = "Jane",
    lastName = "Smith",
    dateOfBirth = "1985-03-20",
    email = "jane.smith@example.com"
});
Console.WriteLine("Patient created: " + newPatient);
``````

#### 5.4 PowerShell

``````powershell
$API_BASE_URL = "https://<api-url>"
$ACCESS_TOKEN = "<your-access-token>"

$headers = @{
    "Authorization" = "Bearer $ACCESS_TOKEN"
    "Content-Type" = "application/json"
}

# GET request example
$patients = Invoke-RestMethod -Uri "$API_BASE_URL/api/patients?page=1&pageSize=20" `
    -Method GET `
    -Headers $headers

Write-Output "Patients: $($patients | ConvertTo-Json)"

# POST request example
$patientData = @{
    firstName = "Jane"
    lastName = "Smith"
    dateOfBirth = "1985-03-20"
    email = "jane.smith@example.com"
} | ConvertTo-Json

$newPatient = Invoke-RestMethod -Uri "$API_BASE_URL/api/patients" `
    -Method POST `
    -Headers $headers `
    -Body $patientData

Write-Output "Patient created: $($newPatient | ConvertTo-Json)"
``````

"@
}

if ($IncludeSDKs) {
    $prompt += @"


### 6. Client SDK Generation

Provide guidance for generating type-safe client SDKs:

#### 6.1 OpenAPI/Swagger Specification

If your API has an OpenAPI spec, reference it:

``````yaml
openapi: 3.0.0
info:
  title: Patient Portal API
  version: 1.0.0
  description: API for managing patient records
servers:
  - url: https://<api-url>
paths:
  /api/patients:
    get:
      summary: List patients
      # ... (full spec)
``````

#### 6.2 Generating Client SDKs

**TypeScript SDK (using openapi-generator):**
``````bash
npm install @openapitools/openapi-generator-cli -g
openapi-generator-cli generate -i swagger.json -g typescript-axios -o ./sdk
``````

**Python SDK (using openapi-generator):**
``````bash
openapi-generator-cli generate -i swagger.json -g python -o ./sdk
``````

**C# SDK (using NSwag):**
``````bash
nswag openapi2csclient /input:swagger.json /output:ApiClient.cs
``````

"@
}

$prompt += @"


### 7. Error Handling

#### Standard Error Response Format

All errors follow this structure:

``````json
{
  "error": "error_code",
  "message": "Human-readable error message",
  "details": {
    "field": "validation error details"
  },
  "timestamp": "2025-01-20T12:00:00Z",
  "requestId": "abc-123-def-456"
}
``````

#### HTTP Status Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST (resource created) |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid input, validation errors |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate resource, concurrency conflict |
| 422 | Unprocessable Entity | Semantic validation errors |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected server error |
| 503 | Service Unavailable | Temporary maintenance or overload |

#### Common Error Codes

| Error Code | HTTP Status | Description | Resolution |
|------------|-------------|-------------|------------|
| ``invalid_parameter`` | 400 | Invalid query/body parameter | Check parameter format |
| ``validation_error`` | 422 | Failed business validation | Review validation rules |
| ``unauthorized`` | 401 | Missing/invalid token | Obtain valid access token |
| ``forbidden`` | 403 | Insufficient permissions | Request appropriate scope |
| ``not_found`` | 404 | Resource not found | Verify resource ID |
| ``duplicate_record`` | 409 | Record already exists | Use PUT to update |
| ``rate_limit_exceeded`` | 429 | Too many requests | Wait and retry with backoff |

### 8. Rate Limiting

- **Rate Limit**: 1000 requests per hour per API key
- **Rate Limit Headers**:
  - ``X-RateLimit-Limit``: Maximum requests allowed
  - ``X-RateLimit-Remaining``: Requests remaining in current window
  - ``X-RateLimit-Reset``: Unix timestamp when limit resets

**Example Response Headers:**
``````
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 850
X-RateLimit-Reset: 1705766400
``````

**Rate Limit Exceeded Response (429):**
``````json
{
  "error": "rate_limit_exceeded",
  "message": "Rate limit exceeded. Retry after 2025-01-20T13:00:00Z",
  "retryAfter": "2025-01-20T13:00:00Z"
}
``````

### 9. Pagination

List endpoints use cursor-based pagination:

**Request:**
``````
GET /api/patients?page=2&pageSize=50
``````

**Response:**
``````json
{
  "data": [...],
  "pagination": {
    "page": 2,
    "pageSize": 50,
    "totalItems": 500,
    "totalPages": 10,
    "hasNextPage": true,
    "hasPreviousPage": true
  }
}
``````

### 10. Versioning

- **Current Version**: v1
- **Version Header**: ``API-Version: 2025-01-20`` (date-based)
- **Breaking Changes**: New major version (v2)
- **Deprecation Policy**: 6 months advance notice

### 11. Support & Resources

- **API Base URL**: ``https://<api-url>``
- **OpenAPI Spec**: ``https://<api-url>/swagger.json``
- **Swagger UI**: ``https://<api-url>/swagger``
- **Support Email**: api-support@example.com
- **Issue Tracker**: [GitHub Issues Link]
- **Changelog**: [Link to API changelog]
- **Status Page**: https://status.azure.com/

## Output Format

- Use **Markdown** with clear headers and sections
- Include **HTTP request/response examples** in code blocks
- Provide **JSON schemas** for all request/response bodies
- Use **tables** for parameters, error codes, status codes
- Include **code samples** in multiple languages (JavaScript, Python, C#, PowerShell)
- Make examples **copy-paste ready** (use placeholders clearly marked)
- Add **language-specific syntax highlighting** to code blocks

## Additional Guidelines

- Assume the audience is **developers integrating with the API**
- Provide **complete, working examples** (not pseudocode)
- Include **error handling** in all examples
- Document **authentication clearly** (most common pain point)
- Add **rate limiting details** (prevents support tickets)
- Include **pagination examples** for list endpoints
- Reference **real resource names and URLs** from the inventory above
- Make it **practical and actionable**

---

Please generate comprehensive API documentation following this structure. Make it developer-friendly, complete, and ready for publication.
"@

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

# Save prompt to file
$promptFile = Join-Path $OutputPath "api-documentation-prompt.txt"
$prompt | Out-File -FilePath $promptFile -Encoding UTF8

Write-Log "`n========================================" -Level Success
Write-Log "API Documentation Prompt Generated!" -Level Success
Write-Log "========================================`n" -Level Success
Write-Log "Prompt file: $promptFile" -Level Success
Write-Log "API Services Found:" -Level Success
Write-Log "  - App Services: $(@($webApps).Count)" -Level Info
Write-Log "  - Function Apps: $(@($functionApps).Count)" -Level Info
Write-Log "  - Container Apps: $(@($containerApps).Count)" -Level Info
Write-Log "  - API Management: $(@($apiManagement).Count)" -Level Info

# Copy to clipboard if requested
if ($CopyToClipboard) {
    try {
        if ($IsWindows -or $env:OS -match "Windows") {
            $prompt | Set-Clipboard
            Write-Log "✅ Prompt copied to clipboard!" -Level Success
        } elseif ($IsLinux) {
            $prompt | xclip -selection clipboard 2>$null
            if ($?) {
                Write-Log "✅ Prompt copied to clipboard (xclip)!" -Level Success
            } else {
                Write-Log "⚠️  xclip not available. Install with: sudo apt install xclip" -Level Warning
            }
        } elseif ($IsMacOS) {
            $prompt | pbcopy
            Write-Log "✅ Prompt copied to clipboard!" -Level Success
        }
    } catch {
        Write-Log "⚠️  Failed to copy to clipboard: $_" -Level Warning
    }
}

Write-Log "`n📋 Next Steps:" -Level Info
Write-Log "1. Open GitHub Copilot Chat in VS Code (Ctrl+Shift+I or Cmd+Shift+I)" -Level Info
Write-Log "2. Paste the prompt from: $promptFile" -Level Info
Write-Log "3. Review and customize the generated API documentation" -Level Info
Write-Log "4. Save to: $(Join-Path $OutputPath 'api-documentation.md')" -Level Info

Write-Log "`n⏱️  Time Savings: 3hrs 30min (88% faster than manual creation)" -Level Success

return [PSCustomObject]@{
    ResourceGroupName = $ResourceGroupName
    AppServices = @($webApps).Count
    FunctionApps = @($functionApps).Count
    ContainerApps = @($containerApps).Count
    APIManagement = @($apiManagement).Count
    PromptFile = $promptFile
    OutputPath = $OutputPath
    Timestamp = Get-Date
    CopiedToClipboard = $CopyToClipboard.IsPresent
}
