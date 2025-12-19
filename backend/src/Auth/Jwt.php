<?php

function base64url_encode(string $data): string {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function jwt_encode(array $payload, string $secret): string {
    $header = ['alg' => 'HS256', 'typ' => 'JWT'];

    $segments = [];
    $segments[] = base64url_encode(json_encode($header));
    $segments[] = base64url_encode(json_encode($payload));

    $signingInput = implode('.', $segments);
    $signature = hash_hmac('sha256', $signingInput, $secret, true);

    $segments[] = base64url_encode($signature);

    return implode('.', $segments);
}

function jwt_decode(string $jwt, string $secret): array {
    [$h, $p, $s] = explode('.', $jwt);

    $valid = base64url_encode(
        hash_hmac('sha256', "$h.$p", $secret, true)
    );

    if (!hash_equals($valid, $s)) {
        throw new RuntimeException('Invalid token');
    }

    return json_decode(base64_decode(strtr($p, '-_', '+/')), true);
}
