USE social_network_pro;

CREATE INDEX idx_user_gender
ON users(gender);

CREATE OR REPLACE VIEW view_highly_interactive_users AS
SELECT
    u.user_id,
    u.username,
    COUNT(c.comment_id) AS comment_count
FROM users u
JOIN comments c
    ON u.user_id = c.user_id
GROUP BY u.user_id, u.username
HAVING COUNT(c.comment_id) > 5;

SELECT *
FROM view_highly_interactive_users;

SELECT
    v.username,
    COUNT(c.comment_id) AS sum_comment_user
FROM view_highly_interactive_users v
JOIN comments c
    ON v.user_id = c.user_id
JOIN posts p
    ON c.post_id = p.post_id
GROUP BY v.username
ORDER BY sum_comment_user DESC;
