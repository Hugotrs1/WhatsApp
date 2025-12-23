<?php

namespace App\Service;

use App\Repository\FriendRepository;
use App\Repository\UserRepository;
use App\Support\Phone;
use RuntimeException;

class FriendService
{
    public function __construct(
        private FriendRepository $friends,
        private UserRepository $users
    ) {
    }

    public function createRequest(int $requesterId, int $recipientId): array
    {
        if ($requesterId === $recipientId) {
            throw new RuntimeException('Cannot add yourself');
        }
        $recipient = $this->users->findById($recipientId);
        if (!$recipient) {
            throw new RuntimeException('User not found');
        }
        if ($this->friends->areFriends($requesterId, $recipientId)) {
            return ['status' => 'ALREADY_FRIENDS'];
        }
        $existing = $this->friends->getRequest($requesterId, $recipientId);
        if ($existing) {
            return ['status' => $existing['status'], 'request_id' => (int) $existing['id']];
        }
        $inverse = $this->friends->getRequest($recipientId, $requesterId);
        if ($inverse && $inverse['status'] === 'PENDING') {
            $this->friends->updateRequestStatus((int) $inverse['id'], 'ACCEPTED');
            $this->friends->ensureFriendship($requesterId, $recipientId);
            return [
                'status' => 'ACCEPTED',
                'request_id' => (int) $inverse['id'],
                'auto_accepted' => true,
            ];
        }
        $id = $this->friends->createRequest($requesterId, $recipientId);
        return ['status' => 'PENDING', 'request_id' => $id];
    }

    public function accept(int $requestId, int $currentUserId): array
    {
        $req = $this->friends->findRequestById($requestId);
        if (!$req || (int) $req['recipient_id'] !== $currentUserId) {
            throw new RuntimeException('Forbidden');
        }
        $status = $req['status'];
        if ($status !== 'ACCEPTED') {
            $this->friends->updateRequestStatus($requestId, 'ACCEPTED');
        }
        $this->friends->ensureFriendship((int) $req['requester_id'], (int) $req['recipient_id']);
        return ['status' => 'ACCEPTED'];
    }

    public function decline(int $requestId, int $currentUserId): array
    {
        $req = $this->friends->findRequestById($requestId);
        if (!$req || (int) $req['recipient_id'] !== $currentUserId || $req['status'] !== 'PENDING') {
            throw new RuntimeException('Forbidden');
        }
        $this->friends->updateRequestStatus($requestId, 'DECLINED');
        return ['status' => 'DECLINED'];
    }

    public function cancel(int $requestId, int $currentUserId): array
    {
        $req = $this->friends->findRequestById($requestId);
        if (!$req || (int) $req['requester_id'] !== $currentUserId || $req['status'] !== 'PENDING') {
            throw new RuntimeException('Forbidden');
        }
        $this->friends->updateRequestStatus($requestId, 'CANCELED');
        return ['status' => 'CANCELED'];
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    public function incoming(int $userId, string $status, int $limit): array
    {
        $rows = $this->friends->listIncoming($userId, $status, $limit);
        foreach ($rows as &$row) {
            $row['requester'] = [
                'id' => (int) $row['requester_id'],
                'first_name' => $row['first_name'],
                'last_name' => $row['last_name'],
                'phone_masked' => Phone::mask($row['phone']),
            ];
            unset($row['phone'], $row['first_name'], $row['last_name']);
        }
        return $rows;
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    public function friends(int $userId): array
    {
        $rows = $this->friends->listFriends($userId);
        foreach ($rows as &$row) {
            $row['phone_masked'] = Phone::mask($row['phone']);
            unset($row['phone']);
        }
        return $rows;
    }
}
