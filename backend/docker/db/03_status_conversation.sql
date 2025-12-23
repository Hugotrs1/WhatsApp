-- docker/db/03_status_conversation.sql
USE whatsapp;

ALTER TABLE users
    ADD COLUMN appear_offline TINYINT(1) NOT NULL DEFAULT 0 AFTER last_seen;

CREATE TABLE IF NOT EXISTS conversation_user (
    user_id BIGINT UNSIGNED NOT NULL,
    other_user_id BIGINT UNSIGNED NOT NULL,
    hidden_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, other_user_id),
    CONSTRAINT fk_conv_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_conv_other FOREIGN KEY (other_user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
