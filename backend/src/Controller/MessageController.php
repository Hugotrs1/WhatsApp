<?php

namespace App\Controller;

use App\Core\Auth;
use App\Core\Request;
use App\Core\Response;
use App\Repository\MessageRepository;
use App\Service\MessageService;

class MessageController
{
    public function __construct(
        private MessageService $messages,
        private MessageRepository $messageRepo,
        private Auth $auth
    ) {
    }

    public function send(Request $request): void
    {
        $senderId = $this->auth->userId($request);
        $contentType = $_SERVER['CONTENT_TYPE'] ?? '';

        if (str_starts_with($contentType, 'multipart/form-data')) {
            $receiverId = isset($_POST['receiver_id']) ? (int) $_POST['receiver_id'] : 0;
            $caption = isset($_POST['content']) ? trim($_POST['content']) : '';

            if ($receiverId <= 0 || empty($_FILES['image'])) {
                Response::error(422, 'Invalid payload', 'invalid_payload');
            }
            if ($receiverId === $senderId) {
                Response::error(422, 'Invalid recipient', 'invalid_recipient');
            }
            if ($caption !== '' && strlen($caption) > 200) {
                Response::error(422, 'Message too long', 'message_too_long');
            }
            $file = $_FILES['image'];
            if ($file['error'] !== UPLOAD_ERR_OK) {
                Response::error(422, 'Upload failed', 'upload_failed');
            }
            if ($file['size'] > 20 * 1024 * 1024) {
                Response::error(422, 'File too large', 'file_too_large');
            }
            $allowedTypes = [
                'image/jpeg' => 'jpg',
                'image/png' => 'png',
                'image/webp' => 'webp'
            ];
            $mimeType = mime_content_type($file['tmp_name']);
            if (!$mimeType || !isset($allowedTypes[$mimeType])) {
                Response::error(422, 'Invalid file type', 'invalid_file_type');
            }
            $uploadDir = __DIR__ . '/../../public/uploads';
            if (!is_dir($uploadDir) && !mkdir($uploadDir, 0755, true)) {
                Response::error(500, 'Upload directory unavailable', 'upload_dir_unavailable');
            }
            $fileName = bin2hex(random_bytes(16)) . '.' . $allowedTypes[$mimeType];
            $destination = $uploadDir . '/' . $fileName;
            if (!move_uploaded_file($file['tmp_name'], $destination)) {
                Response::error(500, 'Upload failed', 'upload_failed');
            }
            $mediaUrl = '/uploads/' . $fileName;
            $this->messageRepo->insert($senderId, $receiverId, $caption === '' ? null : $caption, 'image', $mediaUrl);
            $this->messages->fetch($senderId, $receiverId, 0); // unhide
            Response::success(['media_url' => $mediaUrl]);
        } else {
            $data = $request->json();
            if ($data === null) {
                Response::error(400, 'Invalid JSON', 'invalid_json');
            }
            $content = trim($data['content'] ?? '');
            $receiverId = isset($data['receiver_id']) ? (int) $data['receiver_id'] : 0;
            if (empty($receiverId) || $content === '') {
                Response::error(422, 'Invalid payload', 'invalid_payload');
            }
            if (strlen($content) > 200) {
                Response::error(422, 'Message too long', 'message_too_long');
            }
            try {
                $this->messages->sendText($senderId, $receiverId, $content);
            } catch (\RuntimeException $e) {
                Response::error($e->getMessage() === 'User not found' ? 404 : 422, $e->getMessage(), 'invalid_recipient');
            }
            Response::success(['success' => true]);
        }
    }

    public function list(Request $request): void
    {
        $userId = $this->auth->userId($request);
        $query = $request->query();
        $otherId = isset($query['with']) ? (int) $query['with'] : 0;
        $afterId = isset($query['after']) ? (int) $query['after'] : 0;
        if ($otherId <= 0) {
            Response::error(422, 'Missing params', 'missing_params');
        }
        try {
            $messages = $this->messages->fetch($userId, $otherId, $afterId);
            Response::success($messages);
        } catch (\RuntimeException $e) {
            Response::error($e->getMessage() === 'User not found' ? 404 : 422, $e->getMessage(), 'invalid_user');
        }
    }
}
