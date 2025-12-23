<?php

namespace App\Core;

use App\Support\Jwt;
use RuntimeException;

class Auth
{
    public function __construct(private string $secret)
    {
    }

    public function userId(Request $request): int
    {
        $headers = $request->headers;
        $authorization = $headers['Authorization'] ?? $headers['authorization'] ?? '';
        if ($authorization === '') {
            Response::error(401, 'Missing token', 'missing_token');
        }
        $token = str_replace('Bearer ', '', $authorization);
        try {
            $payload = Jwt::decode($token, $this->secret);
            return (int) ($payload['sub'] ?? 0);
        } catch (\Throwable $e) {
            Response::error(401, 'Invalid token', 'invalid_token');
        }
        throw new RuntimeException('Unauthorized');
    }
}
