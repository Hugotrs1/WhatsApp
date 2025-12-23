<?php

namespace App\Repository;

use PDO;

class ConversationRepository
{
    public function __construct(private PDO $pdo)
    {
    }

    public function hide(int $userId, int $otherId): void
    {
        $stmt = $this->pdo->prepare(
            'INSERT INTO conversation_user (user_id, other_user_id, hidden_at)
             VALUES (?, ?, NOW())
             ON DUPLICATE KEY UPDATE hidden_at = VALUES(hidden_at)'
        );
        $stmt->execute([$userId, $otherId]);
    }

    public function unhide(int $userId, int $otherId): void
    {
        $stmt = $this->pdo->prepare(
            'INSERT INTO conversation_user (user_id, other_user_id, hidden_at)
             VALUES (?, ?, NULL)
             ON DUPLICATE KEY UPDATE hidden_at = NULL'
        );
        $stmt->execute([$userId, $otherId]);
    }

    public function isHidden(int $userId, int $otherId): bool
    {
        $stmt = $this->pdo->prepare(
            'SELECT hidden_at FROM conversation_user WHERE user_id = ? AND other_user_id = ?'
        );
        $stmt->execute([$userId, $otherId]);
        $hiddenAt = $stmt->fetchColumn();
        return !empty($hiddenAt);
    }
}
