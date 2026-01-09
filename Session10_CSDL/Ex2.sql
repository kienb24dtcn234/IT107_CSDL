USE social_network_mini;

CREATE OR REPLACE VIEW view_user_post AS
SELECT
    u.user_id,
    COUNT(p.post_id) AS total_user_post
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
GROUP BY u.user_id;

SELECT * FROM view_user_post;

SELECT
    u.full_name,
    v.total_user_post
FROM users u
JOIN view_user_post v
    ON u.user_id = v.user_id
ORDER BY v.total_user_post DESC;
