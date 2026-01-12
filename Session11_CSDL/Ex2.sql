USE social_network_pro;

-- 2) Tạo stored procedure CalculatePostLikes
DELIMITER $$

CREATE PROCEDURE CalculatePostLikes(
    IN p_post_id INT,
    OUT total_likes INT
)
BEGIN
    SELECT COUNT(*) 
    INTO total_likes
    FROM likes
    WHERE post_id = p_post_id;
END $$

DELIMITER ;

-- 3) Gọi stored procedure với post cụ thể
-- Ví dụ: post_id = 1
CALL CalculatePostLikes(1, @total_likes);

-- Lấy giá trị OUT sau khi gọi thủ tục
SELECT @total_likes AS TongSoLike;

-- 4) Xóa stored procedure
DROP PROCEDURE CalculatePostLikes;