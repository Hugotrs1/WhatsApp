<?php

namespace App\Repository;

use PDO;

class MessageRepository
{
    public function __construct(private PDO $pdo)
    {
    }

    public function insert(int $senderId, int $receiverId, ?string $content, string $type, ?string $mediaUrl): void
    {
        $stmt = $this->pdo->prepare(
            'INSERT INTO messages (sender_id, receiver_id, content, type, media_url)
             VALUES (?, ?, ?, ?, ?)'
        );
        $stmt->execute([$senderId, $receiverId, $content, $type, $mediaUrl]);
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    public function fetchBetween(int $userId, int $otherId, int $afterId): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT id, sender_id, receiver_id, content, type, media_url, created_at
             FROM messages
             WHERE
                ((sender_id = :me AND receiver_id = :other)
                 OR
                 (sender_id = :other AND receiver_id = :me))
             AND id > :after
             ORDER BY id ASC'
        );
        $stmt->execute(['me' => $userId, 'other' => $otherId, 'after' => $afterId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    public function fetchLastMessagesForUser(int $userId): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT
                u.id AS user_id,
                u.first_name,
                u.last_name,
                u.phone,
                u.appear_offline,
                u.last_seen,
                m.id AS message_id,
                m.content,
                m.type,
                m.media_url,
                m.created_at,
                m.sender_id,
                m.receiver_id
             FROM users u
             JOIN (
                SELECT
                    CASE
                        WHEN sender_id = :me THEN receiver_id
                        ELSE sender_id
                    END AS other_id,
                    MAX(id) AS last_message_id
                FROM messages
                WHERE sender_id = :me OR receiver_id = :me
                GROUP BY other_id
             ) conv ON conv.other_id = u.id
             JOIN messages m ON m.id = conv.last_message_id
             ORDER BY m.id DESC'
        );
        $stmt->execute(['me' => $userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }

    public function fetchLastMessage(int $userId, int $otherId): ?array
    {
        $stmt = $this->pdo->prepare(
            'SELECT id, sender_id, receiver_id, content, type, media_url, created_at
             FROM messages
             WHERE
                ((sender_id = :me AND receiver_id = :other)
                 OR
                 (sender_id = :other AND receiver_id = :me))
             ORDER BY id DESC
             LIMIT 1'
        );
        $stmt->execute(['me' => $userId, 'other' => $otherId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }
}
