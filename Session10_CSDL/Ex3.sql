USE social_network_pro;

EXPLAIN ANALYZE
SELECT *
FROM users
WHERE hometown = 'Hà Nội';

CREATE INDEX idx_hometown
ON users(hometown);

EXPLAIN ANALYZE
SELECT *
FROM users
WHERE hometown = 'Hà Nội';

DROP INDEX idx_hometown
ON users;
