<?php
// API endpoint URL
$apiUrl = getenv('API_URL') ?: 'http://api:8000';
$apiKey = getenv('API_KEY') ?: 'insecure_api_key_12345';

// Get the endpoint path from the request
$endpoint = isset($_GET['endpoint']) ? $_GET['endpoint'] : 'healthcheck';

// Remove leading /api/ if present in the endpoint
if (strpos($endpoint, '/api/') === 0) {
    $endpoint = substr($endpoint, 5);
}

// Special handling for endpoints with path parameters
$pathParam = isset($_GET['pathParam']) ? $_GET['pathParam'] : '';
if (!empty($pathParam)) {
    $endpoint .= '/' . urlencode($pathParam);
    // Remove from query params so it doesn't get added twice
    unset($_GET['pathParam']);
}

// Construct the full API URL
$url = $apiUrl . '/api/' . $endpoint;

// Forward any query parameters
$queryParams = $_GET;
// Remove the endpoint and pathParam parameters since they're part of the URL
unset($queryParams['endpoint']);
unset($queryParams['pathParam']);

// Add query parameters to URL if any exist
if (!empty($queryParams)) {
    $url .= '?' . http_build_query($queryParams);
}

// For debugging (remove in production)
// error_log('Proxying to URL: ' . $url);

// Initialize cURL
$ch = curl_init($url);

// Set cURL options
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, array(
    'X-API-Key: ' . $apiKey,
    'Content-Type: application/json'
));

// Execute the request
$response = curl_exec($ch);

// Check for errors
if (curl_errno($ch)) {
    $error = curl_error($ch);
    echo json_encode(['error' => 'cURL Error: ' . $error]);
    exit;
}

// Close cURL
curl_close($ch);

// Set the content type
header('Content-Type: application/json');

// Output the response
echo $response;
