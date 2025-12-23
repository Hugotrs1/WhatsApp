<?php

namespace App\Controller;

use App\Core\Auth;
use App\Core\Request;
use App\Core\Response;
use App\Service\UserService;
use App\Support\Phone;

class UserController
{
    public function __construct(
        private UserService $users,
        private Auth $auth
    ) {
    }

    public function search(Request $request): void
    {
        $userId = $this->auth->userId($request);
        $query = $request->query();
        $rawPrefix = (string) ($query['phonePrefix'] ?? $query['phone'] ?? '');
        $prefix = Phone::normalizePrefix($rawPrefix);
        $limit = isset($query['limit']) ? (int) $query['limit'] : 10;
        if ($limit < 1) {
            $limit = 10;
        }
        if ($limit > 20) {
            $limit = 20;
        }
        if (strlen($prefix) < 2) {
            Response::error(422, 'Phone prefix required', 'phone_prefix_required', ['phonePrefix' => 'required']);
        }
        if (!preg_match('/^[0-9]+$/', $prefix)) {
            Response::error(422, 'Invalid phone prefix', 'invalid_phone', ['phonePrefix' => 'format']);
        }
        $results = $this->users->searchByPhonePrefix($prefix, $limit, $userId);
        Response::success($results);
    }

    public function profile(Request $request, int $id): void
    {
        $currentUserId = $this->auth->userId($request);
        $profile = $this->users->getProfile($currentUserId, $id);
        if (!$profile) {
            Response::error(404, 'User not found', 'user_not_found');
        }
        Response::success($profile);
    }

    public function updateStatus(Request $request): void
    {
        $userId = $this->auth->userId($request);
        $data = $request->json();
        if ($data === null || !array_key_exists('appear_offline', $data)) {
            Response::error(422, 'Invalid payload', 'invalid_payload', ['appear_offline' => 'required']);
        }
        $this->users->updateAppearOffline($userId, (bool) $data['appear_offline']);
        Response::success(['appear_offline' => (bool) $data['appear_offline']]);
    }

    public function getStatus(Request $request, int $id): void
    {
        $this->auth->userId($request); // ensure authenticated
        $status = $this->users->getStatus($id);
        if (!$status) {
            Response::error(404, 'User not found', 'user_not_found');
        }
        Response::success($status);
    }
}
