-- docker/db/02_seed.sql
USE whatsapp;

-- MDP DEV (en clair) :
-- Alice   -> alice123
-- Bob     -> bob123
-- Charlie -> charlie123

START TRANSACTION;

INSERT INTO users (id, first_name, last_name, phone, password, last_seen, created_at, updated_at) VALUES
(1, 'Alice',   'Dupont', '0611111111', '$2y$10$9itrpUfAHcCPQSfY5em11OyMwPqO2Oo0lYZF4uShgwkueMbdRpIOG', NULL, NOW(), NULL),
(2, 'Bob',     'Martin', '0611111112', '$2y$10$/ZzxGQm5uQtvP4r6LEy/eu6GaZSNIYfiBt5ZDrIZt0G8jw/vHGl6y', NULL, NOW(), NULL),
(3, 'Charlie', 'Durand', '0611111113', '$2y$10$wkLcHYP9/MDKG8BdxnkHJOAVUJAmi/TyiT0xerFYckF/jH65j9xwa', NULL, NOW(), NULL)
ON DUPLICATE KEY UPDATE
first_name = VALUES(first_name),
last_name  = VALUES(last_name),
phone      = VALUES(phone),
password   = VALUES(password),
last_seen  = VALUES(last_seen);

INSERT INTO messages (id, sender_id, receiver_id, content, type, media_url, created_at) VALUES
(1, 1, 2, 'Salut Bob', 'text', NULL, '2025-12-19 17:29:29'),
(2, 2, 1, 'Salut Alice', 'text', NULL, '2025-12-19 17:29:29'),
(3, 1, 2, 'Ça va ?', 'text', NULL, '2025-12-19 17:29:29'),
(4, 2, 1, 'Oui tranquille', 'text', NULL, '2025-12-19 17:29:29'),
(5, 1, 3, 'Hey Charlie', 'text', NULL, '2025-12-19 17:29:35'),
(6, 3, 1, 'Yo', 'text', NULL, '2025-12-19 17:29:35'),
(7, 1, 3, 'Tu bosses sur quoi ?', 'text', NULL, '2025-12-19 17:29:35'),
(8, 1, 2, 'Nouveau message test', 'text', NULL, '2025-12-19 17:36:05')
ON DUPLICATE KEY UPDATE
sender_id   = VALUES(sender_id),
receiver_id = VALUES(receiver_id),
content     = VALUES(content),
type        = VALUES(type),
media_url   = VALUES(media_url),
created_at  = VALUES(created_at);

COMMIT;
