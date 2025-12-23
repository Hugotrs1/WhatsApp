-- docker/db/01b_friendships.sql
USE whatsapp;

CREATE TABLE IF NOT EXISTS friend_requests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    requester_id BIGINT UNSIGNED NOT NULL,
    recipient_id BIGINT UNSIGNED NOT NULL,
    status ENUM('PENDING', 'ACCEPTED', 'DECLINED', 'CANCELED') NOT NULL DEFAULT 'PENDING',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_request_pair (requester_id, recipient_id),
    INDEX idx_recipient_status (recipient_id, status),

    CONSTRAINT fk_fr_requester FOREIGN KEY (requester_id) REFERENCES users(id),
    CONSTRAINT fk_fr_recipient FOREIGN KEY (recipient_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS friendships (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id_a BIGINT UNSIGNED NOT NULL,
    user_id_b BIGINT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_friend_pair (user_id_a, user_id_b),
    INDEX idx_friend_a (user_id_a),
    INDEX idx_friend_b (user_id_b),

    CONSTRAINT fk_friend_a FOREIGN KEY (user_id_a) REFERENCES users(id),
    CONSTRAINT fk_friend_b FOREIGN KEY (user_id_b) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Phone index to support prefix searches (uses left-most prefix on CHAR(10))
CREATE INDEX idx_users_phone_prefix ON users (phone);
