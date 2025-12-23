<?php

namespace App\Service;

use App\Repository\ConversationRepository;
use App\Repository\MessageRepository;
use App\Repository\UserRepository;
use App\Support\Phone;

class ConversationService
{
    public function __construct(
        private MessageRepository $messages,
        private ConversationRepository $conversations,
        private UserRepository $users,
    ) {
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    public function listForUser(int $userId): array
    {
        $rows = $this->messages->fetchLastMessagesForUser($userId);
        $filtered = [];
        foreach ($rows as $row) {
            if ($this->conversations->isHidden($userId, (int) $row['user_id'])) {
                continue;
            }
            $filtered[] = $this->mapConversationRow($row);
        }
        return $filtered;
    }

    public function hide(int $userId, int $otherId): void
    {
        $this->ensureUserExists($otherId);
        $this->conversations->hide($userId, $otherId);
    }

    public function unhide(int $userId, int $otherId): void
    {
        $this->ensureUserExists($otherId);
        $this->conversations->unhide($userId, $otherId);
    }

    public function getOrCreateDirect(int $userId, int $otherId): ?array
    {
        $user = $this->users->findById($otherId);
        if (!$user) {
            return null;
        }
        $this->conversations->unhide($userId, $otherId);
        $last = $this->messages->fetchLastMessage($userId, $otherId);
        return [
            'user_id' => (int) $user['id'],
            'first_name' => $user['first_name'],
            'last_name' => $user['last_name'],
            'phone_masked' => Phone::mask($user['phone']),
            'appear_offline' => (bool) $user['appear_offline'],
            'last_seen' => $user['last_seen'],
            'last_message' => $last,
        ];
    }

    private function ensureUserExists(int $userId): void
    {
        $user = $this->users->findById($userId);
        if (!$user) {
            throw new \RuntimeException('User not found');
        }
    }

    private function mapConversationRow(array $row): array
    {
        return [
            'user_id' => (int) $row['user_id'],
            'first_name' => $row['first_name'],
            'last_name' => $row['last_name'],
            'phone' => $row['phone'],
            'phone_masked' => Phone::mask($row['phone']),
            'appear_offline' => (bool) $row['appear_offline'],
            'last_seen' => $row['last_seen'],
            'message_id' => (int) $row['message_id'],
            'content' => $row['content'],
            'type' => $row['type'],
            'media_url' => $row['media_url'],
            'created_at' => $row['created_at'],
            'sender_id' => (int) $row['sender_id'],
            'receiver_id' => (int) $row['receiver_id'],
        ];
    }
}
