USE social_network_pro;

CREATE OR REPLACE VIEW view_user_activity_status AS
SELECT
    u.user_id,
    u.username,
    u.gender,
    u.created_at,
    CASE
        WHEN COUNT(DISTINCT p.post_id) > 0
          OR COUNT(DISTINCT c.comment_id) > 0
        THEN 'Active'
        ELSE 'Inactive'
    END AS status
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
LEFT JOIN comments c
    ON u.user_id = c.user_id
GROUP BY
    u.user_id,
    u.username,
    u.gender,
    u.created_at;

SELECT *
FROM view_user_activity_status;

SELECT
    status,
    COUNT(*) AS user_count
FROM view_user_activity_status
GROUP BY status
ORDER BY user_count DESC;
