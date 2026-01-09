USE social_network_pro;

EXPLAIN ANALYZE
SELECT post_id, content, created_at
FROM posts
WHERE user_id = 1
  AND YEAR(created_at) = 2026;

CREATE INDEX idx_created_at_user_id
ON posts(created_at, user_id);

EXPLAIN ANALYZE
SELECT post_id, content, created_at
FROM posts
WHERE user_id = 1
  AND YEAR(created_at) = 2026;

EXPLAIN ANALYZE
SELECT user_id, username, email
FROM users
WHERE email = 'an@gmail.com';

CREATE UNIQUE INDEX idx_email
ON users(email);

EXPLAIN ANALYZE
SELECT user_id, username, email
FROM users
WHERE email = 'an@gmail.com';

DROP INDEX idx_created_at_user_id
ON posts;

DROP INDEX idx_email
ON users;
