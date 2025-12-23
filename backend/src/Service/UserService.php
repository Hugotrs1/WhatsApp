<?php

namespace App\Service;

use App\Repository\FriendRepository;
use App\Repository\UserRepository;
use App\Support\Phone;

class UserService
{
    public function __construct(
        private UserRepository $users,
        private FriendRepository $friends
    ) {
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    public function searchByPhonePrefix(string $prefix, int $limit, int $currentUserId): array
    {
        $normalized = Phone::normalizePrefix($prefix);
        $results = $this->users->searchByPhonePrefix($normalized, $limit, $currentUserId);
        foreach ($results as &$row) {
            $row['is_friend'] = $this->friends->areFriends($currentUserId, (int) $row['id']);
        }
        return $results;
    }

    public function getProfile(int $currentUserId, int $targetUserId): ?array
    {
        $user = $this->users->findById($targetUserId);
        if (!$user) {
            return null;
        }
        $incoming = $this->friends->getRequest($targetUserId, $currentUserId);
        $outgoing = $this->friends->getRequest($currentUserId, $targetUserId);
        return [
            'id' => (int) $user['id'],
            'first_name' => $user['first_name'],
            'last_name' => $user['last_name'],
            'phone_masked' => Phone::mask($user['phone']),
            'last_seen' => $user['last_seen'],
            'appear_offline' => (bool) $user['appear_offline'],
            'relation' => [
                'is_friend' => $this->friends->areFriends($currentUserId, (int) $user['id']),
                'incoming_request' => $incoming ? ['id' => (int) $incoming['id'], 'status' => $incoming['status']] : null,
                'outgoing_request' => $outgoing ? ['id' => (int) $outgoing['id'], 'status' => $outgoing['status']] : null,
            ],
        ];
    }

    public function updateAppearOffline(int $userId, bool $appearOffline): void
    {
        $this->users->updateAppearOffline($userId, $appearOffline);
    }

    public function getStatus(int $userId): ?array
    {
        $user = $this->users->findById($userId);
        if (!$user) {
            return null;
        }
        return [
            'user_id' => (int) $user['id'],
            'appear_offline' => (bool) $user['appear_offline'],
            'last_seen' => $user['last_seen'],
        ];
    }
}
