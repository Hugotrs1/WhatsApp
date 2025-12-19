<?php

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if ($uri === '/api/health' && $method === 'GET') {
    echo json_encode([
        'status' => 'ok',
        'service' => 'api',
        'time' => date('c')
    ]);
    exit;
}

if ($uri === '/api/echo' && $method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);

    echo json_encode([
        'received' => $input
    ]);
    exit;
}

http_response_code(404);
echo json_encode([
    'error' => 'Not found'
]);
