<?php

namespace App\Repository;

use PDO;

class FriendRepository
{
    public function __construct(private PDO $pdo)
    {
    }

    public function areFriends(int $a, int $b): bool
    {
        if ($a === $b) {
            return false;
        }
        [$x, $y] = $a < $b ? [$a, $b] : [$b, $a];
        $stmt = $this->pdo->prepare('SELECT 1 FROM friendships WHERE user_id_a = ? AND user_id_b = ?');
        $stmt->execute([$x, $y]);
        return (bool) $stmt->fetchColumn();
    }

    public function ensureFriendship(int $a, int $b): void
    {
        if ($a === $b) {
            return;
        }
        [$x, $y] = $a < $b ? [$a, $b] : [$b, $a];
        $stmt = $this->pdo->prepare('INSERT IGNORE INTO friendships (user_id_a, user_id_b) VALUES (?, ?)');
        $stmt->execute([$x, $y]);
    }

    public function getRequest(int $requesterId, int $recipientId): ?array
    {
        $stmt = $this->pdo->prepare('SELECT * FROM friend_requests WHERE requester_id = ? AND recipient_id = ?');
        $stmt->execute([$requesterId, $recipientId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    public function findRequestById(int $id): ?array
    {
        $stmt = $this->pdo->prepare('SELECT * FROM friend_requests WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    public function createRequest(int $requesterId, int $recipientId): int
    {
        $stmt = $this->pdo->prepare(
            'INSERT INTO friend_requests (requester_id, recipient_id, status)
             VALUES (?, ?, "PENDING")'
        );
        $stmt->execute([$requesterId, $recipientId]);
        return (int) $this->pdo->lastInsertId();
    }

    public function updateRequestStatus(int $id, string $status): void
    {
        $stmt = $this->pdo->prepare('UPDATE friend_requests SET status = ?, updated_at = NOW() WHERE id = ?');
        $stmt->execute([$status, $id]);
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    public function listIncoming(int $userId, string $status, int $limit): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT fr.id, fr.requester_id, fr.status, fr.created_at, u.first_name, u.last_name, u.phone
             FROM friend_requests fr
             JOIN users u ON u.id = fr.requester_id
             WHERE fr.recipient_id = :me AND fr.status = :status
             ORDER BY fr.created_at DESC
             LIMIT :limit'
        );
        $stmt->bindValue(':me', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':status', $status, PDO::PARAM_STR);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    public function listFriends(int $userId): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT u.id, u.first_name, u.last_name, u.phone, u.last_seen, u.appear_offline
             FROM friendships f
             JOIN users u ON u.id = CASE WHEN f.user_id_a = :me THEN f.user_id_b ELSE f.user_id_a END
             WHERE f.user_id_a = :me OR f.user_id_b = :me
             ORDER BY u.first_name ASC, u.last_name ASC'
        );
        $stmt->execute(['me' => $userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }
}
