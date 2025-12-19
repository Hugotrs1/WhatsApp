<?php

header('Content-Type: application/json');

$pdo = require __DIR__ . '/../config/database.php';

require_once __DIR__ . '/../src/Auth/Jwt.php';

function authUserId(): int {
    $headers = getallheaders();

    if (empty($headers['Authorization'])) {
        http_response_code(401);
        echo json_encode(['error' => 'Missing token']);
        exit;
    }

    $token = str_replace('Bearer ', '', $headers['Authorization']);

    try {
        $payload = jwt_decode($token, getenv('JWT_SECRET'));
        return (int) $payload['sub'];
    } catch (Exception $e) {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid token']);
        exit;
    }
}

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

if ($uri === '/api/login' && $method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);

    if (empty($data['phone']) || empty($data['password'])) {
        http_response_code(422);
        echo json_encode(['error' => 'Invalid payload']);
        exit;
    }

    $stmt = $pdo->prepare(
        'SELECT id, password FROM users WHERE phone = ?'
    );
    $stmt->execute([$data['phone']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user || !password_verify($data['password'], $user['password'])) {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid credentials']);
        exit;
    }

    $token = jwt_encode(
        [
            'sub' => $user['id'],
            'iat' => time(),
            'exp' => time() + 3600
        ],
        getenv('JWT_SECRET')
    );

    $pdo->prepare(
        'UPDATE users SET last_seen = NOW() WHERE id = ?'
    )->execute([$user['id']]);

    echo json_encode([
        'token' => $token
    ]);
    exit;
}

if ($uri === '/api/users/search' && $method === 'GET') {
    $userId = authUserId();

    if (empty($_GET['phone'])) {
        http_response_code(422);
        echo json_encode(['error' => 'Phone required']);
        exit;
    }

    $stmt = $pdo->prepare(
        'SELECT id, first_name, last_name, phone
         FROM users
         WHERE phone = ?'
    );
    $stmt->execute([$_GET['phone']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode($user ?: null);
    exit;
}
if ($uri === '/api/messages' && $method === 'POST') {
    $senderId = authUserId();
    $data = json_decode(file_get_contents('php://input'), true);

    if (
        empty($data['receiver_id']) ||
        empty($data['content'])
    ) {
        http_response_code(422);
        echo json_encode(['error' => 'Invalid payload']);
        exit;
    }

    if (strlen($data['content']) > 200) {
        http_response_code(422);
        echo json_encode(['error' => 'Message too long']);
        exit;
    }

    $stmt = $pdo->prepare('SELECT id FROM users WHERE id = ?');
    $stmt->execute([$data['receiver_id']]);
    if (!$stmt->fetch()) {
        http_response_code(404);
        echo json_encode(['error' => 'User not found']);
        exit;
    }

    $stmt = $pdo->prepare(
        'INSERT INTO messages (sender_id, receiver_id, content)
         VALUES (?, ?, ?)'
    );
    $stmt->execute([
        $senderId,
        $data['receiver_id'],
        $data['content']
    ]);

    echo json_encode(['success' => true]);
    exit;
}
if ($uri === '/api/messages' && $method === 'GET') {
    $userId = authUserId();

    if (empty($_GET['with']) || !isset($_GET['after'])) {
        http_response_code(422);
        echo json_encode(['error' => 'Missing params']);
        exit;
    }

    $stmt = $pdo->prepare(
        'SELECT id, sender_id, receiver_id, content, created_at
         FROM messages
         WHERE
            ((sender_id = :me AND receiver_id = :other)
             OR
             (sender_id = :other AND receiver_id = :me))
         AND id > :after
         ORDER BY id ASC'
    );

    $stmt->execute([
        'me' => $userId,
        'other' => $_GET['with'],
        'after' => $_GET['after']
    ]);

    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    exit;
}


http_response_code(404);
echo json_encode(['error' => 'Not found']);
