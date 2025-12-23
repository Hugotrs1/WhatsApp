<?php

namespace App\Controller;

use App\Core\Auth;
use App\Core\Request;
use App\Core\Response;
use App\Service\ConversationService;

class ConversationController
{
    public function __construct(
        private ConversationService $conversations,
        private Auth $auth
    ) {
    }

    public function list(Request $request): void
    {
        $userId = $this->auth->userId($request);
        $rows = $this->conversations->listForUser($userId);
        Response::success($rows);
    }

    public function hide(Request $request, int $otherId): void
    {
        $userId = $this->auth->userId($request);
        try {
          $this->conversations->hide($userId, $otherId);
          Response::success(['hidden' => true]);
        } catch (\RuntimeException $e) {
          Response::error(404, 'User not found', 'user_not_found');
        }
    }

    public function unhide(Request $request, int $otherId): void
    {
        $userId = $this->auth->userId($request);
        try {
          $this->conversations->unhide($userId, $otherId);
          Response::success(['hidden' => false]);
        } catch (\RuntimeException $e) {
          Response::error(404, 'User not found', 'user_not_found');
        }
    }

    public function direct(Request $request): void
    {
        $userId = $this->auth->userId($request);
        $data = $request->json();
        if ($data === null || !isset($data['userId'])) {
            Response::error(422, 'userId required', 'invalid_payload', ['userId' => 'required']);
        }
        $otherId = (int) $data['userId'];
        if ($otherId === $userId) {
            Response::error(422, 'Cannot start conversation with yourself', 'invalid_user');
        }
        $conv = $this->conversations->getOrCreateDirect($userId, $otherId);
        if (!$conv) {
            Response::error(404, 'User not found', 'user_not_found');
        }
        Response::success($conv);
    }
}
