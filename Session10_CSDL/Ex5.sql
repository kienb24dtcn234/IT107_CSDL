USE social_network_pro;

EXPLAIN ANALYZE
SELECT
    u.user_id,
    u.username,
    p.post_id,
    p.content
FROM users u
JOIN posts p
    ON u.user_id = p.user_id
WHERE u.hometown = 'Hà Nội'
ORDER BY u.username DESC
LIMIT 10;

CREATE INDEX idx_hometown
ON users(hometown);

EXPLAIN ANALYZE
SELECT
    u.user_id,
    u.username,
    p.post_id,
    p.content
FROM users u
JOIN posts p
    ON u.user_id = p.user_id
WHERE u.hometown = 'Hà Nội'
ORDER BY u.username DESC
LIMIT 10;
