<?php
/**
 * API Proxy Script
 * 
 * This script forwards API requests to the actual API service
 * Works both locally and in Azure by using the API_URL environment variable
 */

// Configuration
$apiUrl = getenv('API_URL') ?: 'http://localhost:8000';
$apiKey = getenv('API_KEY') ?: 'insecure_api_key_12345';

// Get the API path from the request URL
$requestUri = $_SERVER['REQUEST_URI'];

// Debug logging
error_log("Proxy request: " . $requestUri);
error_log("API URL: " . $apiUrl);

if (strpos($requestUri, '/api/') === 0) {
    $apiPath = substr($requestUri, 4); // Remove the '/api' prefix
    
    // Construct the full API endpoint URL
    $fullApiUrl = rtrim($apiUrl, '/') . $apiPath;
    
    // Copy the query string if any
    if (!empty($_SERVER['QUERY_STRING'])) {
        $fullApiUrl .= '?' . $_SERVER['QUERY_STRING'];
    }
    
    // Initialize cURL session
    $ch = curl_init($fullApiUrl);
    
    // Set cURL options
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HEADER, true);
    
    // Forward the API key header if present
    $headers = ['X-API-Key: ' . $apiKey];
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    
    // Execute the request
    $response = curl_exec($ch);
    
    // Get status code and content
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    $responseBody = substr($response, $headerSize);
    
    // Close the cURL session
    curl_close($ch);
    
    // Forward the HTTP status code
    http_response_code($httpCode);
    
    // Forward the content type
    header('Content-Type: application/json');
    
    // Return the API response
    echo $responseBody;
    exit;
}

// If we get here, it's not an API request
http_response_code(404);
echo json_encode(['error' => 'Not Found']);
?>
