<?php

namespace App\Controller;

use App\Core\Auth;
use App\Core\Request;
use App\Core\Response;
use App\Service\FriendService;
use App\Service\UserService;

class FriendController
{
    public function __construct(
        private FriendService $friends,
        private UserService $users,
        private Auth $auth
    ) {
    }

    public function create(Request $request): void
    {
        $userId = $this->auth->userId($request);
        $data = $request->json();
        if ($data === null) {
            Response::error(400, 'Invalid JSON', 'invalid_json');
        }
        $recipientId = isset($data['recipientId']) ? (int) $data['recipientId'] : 0;
        if ($recipientId <= 0) {
            Response::error(422, 'Recipient required', 'invalid_payload', ['recipientId' => 'required']);
        }
        try {
            $result = $this->friends->createRequest($userId, $recipientId);
            $profile = $this->users->getProfile($userId, $recipientId);
            $result['relation'] = $profile['relation'] ?? null;
            Response::success($result);
        } catch (\RuntimeException $e) {
            $status = $e->getMessage() === 'User not found' ? 404 : 422;
            Response::error($status, $e->getMessage(), $status === 404 ? 'user_not_found' : 'invalid_recipient');
        }
    }

    public function incoming(Request $request): void
    {
        $userId = $this->auth->userId($request);
        $query = $request->query();
        $status = strtoupper((string) ($query['status'] ?? 'PENDING'));
        $allowed = ['PENDING', 'ACCEPTED', 'DECLINED', 'CANCELED'];
        if (!in_array($status, $allowed, true)) {
            Response::error(422, 'Invalid status', 'invalid_status');
        }
        $limit = isset($query['limit']) ? (int) $query['limit'] : 20;
        if ($limit < 1) {
            $limit = 20;
        }
        if ($limit > 50) {
            $limit = 50;
        }
        $rows = $this->friends->incoming($userId, $status, $limit);
        Response::success($rows);
    }

    public function accept(Request $request, int $id): void
    {
        $userId = $this->auth->userId($request);
        $result = $this->friends->accept($id, $userId);
        Response::success($result);
    }

    public function decline(Request $request, int $id): void
    {
        $userId = $this->auth->userId($request);
        $result = $this->friends->decline($id, $userId);
        Response::success($result);
    }

    public function cancel(Request $request, int $id): void
    {
        $userId = $this->auth->userId($request);
        $result = $this->friends->cancel($id, $userId);
        Response::success($result);
    }

    public function listFriends(Request $request): void
    {
        $userId = $this->auth->userId($request);
        Response::success($this->friends->friends($userId));
    }
}
