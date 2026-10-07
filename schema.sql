CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  phone VARCHAR(20) UNIQUE NOT NULL,
  password TEXT NOT NULL,
  last_seen TIMESTAMP,
  appear_offline BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE friend_requests (
  id SERIAL PRIMARY KEY,
  requester_id INT NOT NULL REFERENCES users(id),
  recipient_id INT NOT NULL REFERENCES users(id),
  status VARCHAR(12) NOT NULL CHECK (status IN ('PENDING','ACCEPTED','DECLINED','CANCELED')),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE friendships (
  user_id_a INT NOT NULL REFERENCES users(id),
  user_id_b INT NOT NULL REFERENCES users(id),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id_a, user_id_b),
  CHECK (user_id_a < user_id_b)
);

CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  sender_id INT NOT NULL REFERENCES users(id),
  receiver_id INT NOT NULL REFERENCES users(id),
  content TEXT,
  type VARCHAR(20) NOT NULL DEFAULT 'text',
  media_url TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE conversation_reads (
  user_id INT NOT NULL REFERENCES users(id),
  other_user_id INT NOT NULL REFERENCES users(id),
  last_read_message_id INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, other_user_id)
);
