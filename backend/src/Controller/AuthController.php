<?php

namespace App\Controller;

use App\Core\Request;
use App\Core\Response;
use App\Service\AuthService;
use App\Support\Phone;

class AuthController
{
    public function __construct(private AuthService $auth)
    {
    }

    public function register(Request $request): void
    {
        $data = $request->json();
        if ($data === null) {
            Response::error(400, 'Invalid JSON', 'invalid_json');
        }
        $errors = [];
        $phone = Phone::normalize((string) ($data['phone'] ?? ''));
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
            Response::error(422, 'Invalid payload', 'invalid_payload', $errors);
        }
        if (!preg_match('/^[0-9]{10}$/', $phone)) {
            Response::error(422, 'Invalid phone', 'invalid_phone', ['phone' => 'format']);
        }
        try {
            $id = $this->auth->register([
                'first_name' => $data['first_name'],
                'last_name' => $data['last_name'],
                'phone' => $phone,
                'password' => $data['password'],
            ]);
            Response::success(['user_id' => $id]);
        } catch (\Throwable $e) {
            Response::error(409, 'Phone already exists', 'phone_exists');
        }
    }

    public function login(Request $request): void
    {
        $data = $request->json();
        if ($data === null) {
            Response::error(400, 'Invalid JSON', 'invalid_json');
        }
        $errors = [];
        $phone = Phone::normalize((string) ($data['phone'] ?? ''));
        if ($phone === '') {
            $errors['phone'] = 'required';
        }
        if (empty($data['password'])) {
            $errors['password'] = 'required';
        }
        if (!empty($errors)) {
            Response::error(422, 'Invalid payload', 'invalid_payload', $errors);
        }
        if (!preg_match('/^[0-9]{10}$/', $phone)) {
            Response::error(422, 'Invalid phone', 'invalid_phone', ['phone' => 'format']);
        }
        $auth = $this->auth->login($phone, $data['password']);
        if ($auth === null) {
            Response::error(401, 'Invalid credentials', 'invalid_credentials');
        }
        Response::success($auth);
    }
}
