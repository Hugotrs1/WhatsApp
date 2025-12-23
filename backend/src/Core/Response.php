<?php

namespace App\Core;

class Response
{
    public static function json(int $status, mixed $data): void
    {
        http_response_code($status);
        header('Content-Type: application/json');
        echo json_encode($data);
        exit;
    }

    public static function success(mixed $data = null, int $status = 200): void
    {
        self::json($status, ['ok' => true, 'data' => $data ?? new \stdClass(), 'error' => null]);
    }

    public static function error(int $status, string $message, string $code = '', mixed $details = null): void
    {
        $payload = [
            'ok' => false,
            'error' => [
                'code' => $code === '' ? 'error' : $code,
                'message' => $message,
                'details' => $details,
            ],
            'data' => new \stdClass(),
        ];
        self::json($status, $payload);
    }
}
