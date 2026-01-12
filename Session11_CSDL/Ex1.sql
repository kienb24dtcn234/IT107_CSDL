

USE social_network_pro;

-- 2) Tạo stored procedure nhận p_user_id
DELIMITER $$

CREATE PROCEDURE get_posts_by_user(IN p_user_id INT)
BEGIN
    SELECT 
        post_id AS PostID,
        content AS NoiDung,
        created_at AS ThoiGianTao
    FROM posts
    WHERE user_id = p_user_id
    ORDER BY created_at DESC;
END $$

DELIMITER ;

-- 3) Gọi thủ tục với user cụ thể (ví dụ user_id = 1)
CALL get_posts_by_user(1);

-- 4) Xóa thủ tục vừa tạo
DROP PROCEDURE get_posts_by_user;
