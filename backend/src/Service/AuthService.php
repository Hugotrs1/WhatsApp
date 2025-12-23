<?php

namespace App\Service;

use App\Repository\UserRepository;
use App\Support\Jwt;
use App\Support\Phone;

class AuthService
{
    public function __construct(
        private UserRepository $users,
        private string $jwtSecret,
    ) {
    }

    /**
     * @return array{token:string}|null
     */
    public function login(string $phone, string $password): ?array
    {
        $normalized = Phone::normalize($phone);
        $user = $this->users->findByPhone($normalized);
        if (!$user || !password_verify($password, $user['password'])) {
            return null;
        }
        $this->users->updateLastSeen((int) $user['id']);
        $token = Jwt::encode(
            [
                'sub' => (int) $user['id'],
                'iat' => time(),
                'exp' => time() + 3600,
            ],
            $this->jwtSecret
        );
        return ['token' => $token];
    }

    public function register(array $data): int
    {
        return $this->users->create([
            'first_name' => $data['first_name'],
            'last_name' => $data['last_name'],
            'phone' => Phone::normalize($data['phone']),
            'password' => password_hash($data['password'], PASSWORD_BCRYPT),
        ]);
    }
}
