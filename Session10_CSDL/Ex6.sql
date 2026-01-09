USE social_network_pro;

CREATE OR REPLACE VIEW view_users_summary AS
SELECT
    u.user_id,
    u.username,
    COUNT(p.post_id) AS total_posts
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
GROUP BY u.user_id, u.username;

SELECT
    user_id,
    username,
    total_posts
FROM view_users_summary
WHERE total_posts > 5;
