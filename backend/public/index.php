<?php

header('Content-Type: application/json');

$pdo = require __DIR__ . '/../config/database.php';

$method = $_SERVER['REQUEST_METHOD'];
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if ($uri === '/api/register' && $method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);

    if (
        empty($data['first_name']) ||
        empty($data['last_name']) ||
        empty($data['phone']) ||
        empty($data['password'])
    ) {
        http_response_code(422);
        echo json_encode(['error' => 'Invalid payload']);
        exit;
    }

    if (!preg_match('/^[0-9]{10}$/', $data['phone'])) {
        http_response_code(422);
        echo json_encode(['error' => 'Invalid phone']);
        exit;
    }

    $stmt = $pdo->prepare('SELECT id FROM users WHERE phone = ?');
    $stmt->execute([$data['phone']]);

    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode(['error' => 'Phone already exists']);
        exit;
    }

    $stmt = $pdo->prepare(
        'INSERT INTO users (first_name, last_name, phone, password)
         VALUES (?, ?, ?, ?)'
    );

    try {
        $stmt->execute([
            $data['first_name'],
            $data['last_name'],
            $data['phone'],
            password_hash($data['password'], PASSWORD_BCRYPT)
        ]);
    } catch (PDOException $e) {
        http_response_code(409);
        echo json_encode(['error' => 'Phone already exists']);
        exit;
    }

    echo json_encode([
        'success' => true,
        'user_id' => $pdo->lastInsertId()
    ]);
    exit;
}

http_response_code(404);
echo json_encode(['error' => 'Not found']);
