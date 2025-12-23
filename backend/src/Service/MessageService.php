<?php

namespace App\Service;

use App\Repository\ConversationRepository;
use App\Repository\MessageRepository;
use App\Repository\UserRepository;
use RuntimeException;

class MessageService
{
    public function __construct(
        private MessageRepository $messages,
        private UserRepository $users,
        private ConversationRepository $conversations
    ) {
    }

    public function sendText(int $senderId, int $receiverId, string $content): void
    {
        if ($senderId === $receiverId) {
            throw new RuntimeException('Invalid recipient');
        }
        $this->ensureUserExists($receiverId);
        $this->messages->insert($senderId, $receiverId, $content, 'text', null);
        $this->conversations->unhide($senderId, $receiverId);
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    public function fetch(int $userId, int $otherId, int $after): array
    {
        $this->ensureUserExists($otherId);
        $this->conversations->unhide($userId, $otherId);
        return $this->messages->fetchBetween($userId, $otherId, $after);
    }

    private function ensureUserExists(int $userId): void
    {
        $user = $this->users->findById($userId);
        if (!$user) {
            throw new RuntimeException('User not found');
        }
    }
}
