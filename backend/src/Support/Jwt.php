<?php

namespace App\Support;

use RuntimeException;

class Jwt
{
    public static function encode(array $payload, string $secret): string
    {
        $header = ['alg' => 'HS256', 'typ' => 'JWT'];
        $segments = [];
        $segments[] = self::base64urlEncode(json_encode($header));
        $segments[] = self::base64urlEncode(json_encode($payload));
        $signingInput = implode('.', $segments);
        $signature = hash_hmac('sha256', $signingInput, $secret, true);
        $segments[] = self::base64urlEncode($signature);
        return implode('.', $segments);
    }

    /**
     * @return array<string,mixed>
     */
    public static function decode(string $jwt, string $secret): array
    {
        [$h, $p, $s] = explode('.', $jwt);
        $valid = self::base64urlEncode(
            hash_hmac('sha256', "$h.$p", $secret, true)
        );
        if (!hash_equals($valid, $s)) {
            throw new RuntimeException('Invalid token');
        }
        $payload = json_decode(base64_decode(strtr($p, '-_', '+/')), true);
        return is_array($payload) ? $payload : [];
    }

    private static function base64urlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
}
