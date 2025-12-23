<?php

namespace App\Repository;

use App\Support\Phone;
use PDO;

class UserRepository
{
    public function __construct(private PDO $pdo)
    {
    }

    public function findById(int $id): ?array
    {
        $stmt = $this->pdo->prepare('SELECT id, first_name, last_name, phone, password, last_seen, appear_offline FROM users WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    public function findByPhone(string $phone): ?array
    {
        $stmt = $this->pdo->prepare('SELECT id, first_name, last_name, phone, password, last_seen, appear_offline FROM users WHERE phone = ?');
        $stmt->execute([$phone]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    public function create(array $data): int
    {
        $stmt = $this->pdo->prepare(
            'INSERT INTO users (first_name, last_name, phone, password)
             VALUES (?, ?, ?, ?)'
        );
        $stmt->execute([
            $data['first_name'],
            $data['last_name'],
            $data['phone'],
            $data['password'],
        ]);
        return (int) $this->pdo->lastInsertId();
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    public function searchByPhonePrefix(string $prefix, int $limit, int $excludeUserId): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT id, first_name, last_name, phone, appear_offline, last_seen
             FROM users
             WHERE phone LIKE :prefix AND id <> :me
             ORDER BY phone ASC, id ASC
             LIMIT :limit'
        );
        $stmt->bindValue(':prefix', $prefix . '%', PDO::PARAM_STR);
        $stmt->bindValue(':me', $excludeUserId, PDO::PARAM_INT);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($rows as &$row) {
            $row['phone_masked'] = Phone::mask($row['phone']);
            unset($row['phone']);
        }
        return $rows ?: [];
    }

    public function updateAppearOffline(int $userId, bool $appearOffline): void
    {
        $stmt = $this->pdo->prepare('UPDATE users SET appear_offline = ?, updated_at = NOW() WHERE id = ?');
        $stmt->execute([$appearOffline ? 1 : 0, $userId]);
    }

    public function updateLastSeen(int $userId): void
    {
        $stmt = $this->pdo->prepare('UPDATE users SET last_seen = NOW() WHERE id = ?');
        $stmt->execute([$userId]);
    }
}
