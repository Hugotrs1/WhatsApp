<?php

header('Content-Type: application/json');

$pdo = require __DIR__ . '/../config/database.php';

require_once __DIR__ . '/../src/Auth/Jwt.php';

function normalizePhone(string $phone): string {
    $digits = preg_replace('/\D+/', '', $phone);
    if ($digits === null) {
        return '';
    }
    if (str_starts_with($digits, '0033')) {
        $digits = substr($digits, 2);
    }
    if (str_starts_with($digits, '33')) {
        $rest = substr($digits, 2);
        if (strlen($rest) === 9) {
            return '0' . $rest;
        }
        if (strlen($rest) === 10 && str_starts_with($rest, '0')) {
            return $rest;
        }
    }
    return $digits;
}

function readJsonBody(): ?array {
    $raw = file_get_contents('php://input');
    if ($raw === false) {
        return null;
    }
    $trimmed = trim($raw);
    if ($trimmed === '') {
        return [];
    }
    $data = json_decode($raw, true);
    if ($data === null && json_last_error() !== JSON_ERROR_NONE) {
        return null;
    }
    return is_array($data) ? $data : [];
}

function sendJsonError(
    int $status,
    string $message,
    string $code = '',
    ?array $details = null
): void {
    http_response_code($status);
    $payload = ['error' => $message];
    if ($code !== '') {
        $payload['code'] = $code;
    }
    if ($details !== null) {
        $payload['details'] = $details;
    }
    echo json_encode($payload);
    exit;
}

function authUserId(): int {
    $headers = getallheaders();

    if (empty($headers['Authorization'])) {
        sendJsonError(401, 'Missing token', 'missing_token');
    }

    $token = str_replace('Bearer ', '', $headers['Authorization']);

    try {
        $payload = jwt_decode($token, getenv('JWT_SECRET'));
        return (int) $payload['sub'];
    } catch (Exception $e) {
        sendJsonError(401, 'Invalid token', 'invalid_token');
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
    $data = readJsonBody();
    if ($data === null) {
        sendJsonError(400, 'Invalid JSON', 'invalid_json');
    }
    $phone = normalizePhone((string) ($data['phone'] ?? ''));
    $errors = [];

    if (empty($data['first_name'])) {
        $errors['first_name'] = 'required';
    }
    if (empty($data['last_name'])) {
        $errors['last_name'] = 'required';
    }
    if ($phone === '') {
        $errors['phone'] = 'required';
    }
    if (empty($data['password'])) {
        $errors['password'] = 'required';
    }
    if (!empty($errors)) {
        sendJsonError(422, 'Invalid payload', 'invalid_payload', $errors);
    }

    if (!preg_match('/^[0-9]{10}$/', $phone)) {
        sendJsonError(422, 'Invalid phone', 'invalid_phone', ['phone' => 'format']);
    }

    $stmt = $pdo->prepare('SELECT id FROM users WHERE phone = ?');
    $stmt->execute([$phone]);

    if ($stmt->fetch()) {
        sendJsonError(409, 'Phone already exists', 'phone_exists');
    }

    $stmt = $pdo->prepare(
        'INSERT INTO users (first_name, last_name, phone, password)
         VALUES (?, ?, ?, ?)'
    );

    try {
        $stmt->execute([
            $data['first_name'],
            $data['last_name'],
            $phone,
            password_hash($data['password'], PASSWORD_BCRYPT)
        ]);
    } catch (PDOException $e) {
        sendJsonError(409, 'Phone already exists', 'phone_exists');
    }

    echo json_encode([
        'success' => true,
        'user_id' => $pdo->lastInsertId()
    ]);
    exit;
}

if ($uri === '/api/login' && $method === 'POST') {
    $data = readJsonBody();
    if ($data === null) {
        sendJsonError(400, 'Invalid JSON', 'invalid_json');
    }
    $phone = normalizePhone((string) ($data['phone'] ?? ''));
    $errors = [];

    if ($phone === '') {
        $errors['phone'] = 'required';
    }
    if (empty($data['password'])) {
        $errors['password'] = 'required';
    }
    if (!empty($errors)) {
        sendJsonError(422, 'Invalid payload', 'invalid_payload', $errors);
    }

    if (!preg_match('/^[0-9]{10}$/', $phone)) {
        sendJsonError(422, 'Invalid phone', 'invalid_phone', ['phone' => 'format']);
    }

    $stmt = $pdo->prepare(
        'SELECT id, password FROM users WHERE phone = ?'
    );
    $stmt->execute([$phone]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user || !password_verify($data['password'], $user['password'])) {
        sendJsonError(401, 'Invalid credentials', 'invalid_credentials');
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
        sendJsonError(422, 'Phone required', 'phone_required', ['phone' => 'required']);
    }

    $phone = normalizePhone((string) $_GET['phone']);
    if (!preg_match('/^[0-9]{10}$/', $phone)) {
        sendJsonError(422, 'Invalid phone', 'invalid_phone', ['phone' => 'format']);
    }

    $stmt = $pdo->prepare(
        'SELECT id, first_name, last_name, phone
         FROM users
         WHERE phone = ?'
    );
    $stmt->execute([$phone]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode($user ?: null);
    exit;
}
if ($uri === '/api/messages' && $method === 'POST') {
    $senderId = authUserId();
    $contentType = $_SERVER['CONTENT_TYPE'] ?? '';

    if (str_starts_with($contentType, 'multipart/form-data')) {
        $receiverId = $_POST['receiver_id'] ?? null;
        $caption = isset($_POST['content']) ? trim($_POST['content']) : '';

        if (empty($receiverId) || empty($_FILES['image'])) {
            http_response_code(422);
            echo json_encode(['error' => 'Invalid payload']);
            exit;
        }

        if ($caption !== '' && strlen($caption) > 200) {
            http_response_code(422);
            echo json_encode(['error' => 'Message too long']);
            exit;
        }

        $stmt = $pdo->prepare('SELECT id FROM users WHERE id = ?');
        $stmt->execute([$receiverId]);
        if (!$stmt->fetch()) {
            http_response_code(404);
            echo json_encode(['error' => 'User not found']);
            exit;
        }

        $file = $_FILES['image'];
        if ($file['error'] !== UPLOAD_ERR_OK) {
            http_response_code(422);
            echo json_encode(['error' => 'Upload failed']);
            exit;
        }

        if ($file['size'] > 20 * 1024 * 1024) {
            http_response_code(422);
            echo json_encode(['error' => 'File too large']);
            exit;
        }

        $allowedTypes = [
            'image/jpeg' => 'jpg',
            'image/png' => 'png',
            'image/webp' => 'webp'
        ];
        $mimeType = mime_content_type($file['tmp_name']);
        if (!$mimeType || !isset($allowedTypes[$mimeType])) {
            http_response_code(422);
            echo json_encode(['error' => 'Invalid file type']);
            exit;
        }

        $uploadDir = __DIR__ . '/uploads';
        if (!is_dir($uploadDir) && !mkdir($uploadDir, 0755, true)) {
            http_response_code(500);
            echo json_encode(['error' => 'Upload directory unavailable']);
            exit;
        }

        $fileName = bin2hex(random_bytes(16)) . '.' . $allowedTypes[$mimeType];
        $destination = $uploadDir . '/' . $fileName;
        if (!move_uploaded_file($file['tmp_name'], $destination)) {
            http_response_code(500);
            echo json_encode(['error' => 'Upload failed']);
            exit;
        }

        $mediaUrl = '/uploads/' . $fileName;
        $stmt = $pdo->prepare(
            'INSERT INTO messages (sender_id, receiver_id, content, type, media_url)
             VALUES (?, ?, ?, ?, ?)'
        );
        $stmt->execute([
            $senderId,
            $receiverId,
            $caption === '' ? null : $caption,
            'image',
            $mediaUrl
        ]);

        echo json_encode(['success' => true, 'media_url' => $mediaUrl]);
        exit;
    }

    $data = json_decode(file_get_contents('php://input'), true);
    $content = trim($data['content'] ?? '');

    if (
        empty($data['receiver_id']) ||
        $content === ''
    ) {
        http_response_code(422);
        echo json_encode(['error' => 'Invalid payload']);
        exit;
    }

    if (strlen($content) > 200) {
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
        'INSERT INTO messages (sender_id, receiver_id, content, type, media_url)
         VALUES (?, ?, ?, ?, ?)'
    );
    $stmt->execute([
        $senderId,
        $data['receiver_id'],
        $content,
        'text',
        null
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
        'SELECT id, sender_id, receiver_id, content, type, media_url, created_at
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

if ($uri === '/api/conversations' && $method === 'GET') {
    $userId = authUserId();

    $stmt = $pdo->prepare(
        'SELECT
            u.id AS user_id,
            u.first_name,
            u.last_name,
            u.phone,
            m.id AS message_id,
            m.content,
            m.type,
            m.media_url,
            m.created_at,
            m.sender_id,
            m.receiver_id
         FROM users u
         JOIN (
            SELECT
                CASE
                    WHEN sender_id = :me THEN receiver_id
                    ELSE sender_id
                END AS other_id,
                MAX(id) AS last_message_id
            FROM messages
            WHERE sender_id = :me OR receiver_id = :me
            GROUP BY other_id
         ) conv ON conv.other_id = u.id
         JOIN messages m ON m.id = conv.last_message_id
         ORDER BY m.id DESC'
    );

    $stmt->execute(['me' => $userId]);

    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    exit;
}


http_response_code(404);
echo json_encode(['error' => 'Not found']);
