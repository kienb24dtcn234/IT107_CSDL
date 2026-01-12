-- =========================================
-- BÀI: STORED PROCEDURE TÍNH ĐIỂM THƯỞNG USER
-- =========================================

-- 1) Sử dụng database
USE social_network_pro;

-- 2) Tạo stored procedure CalculateBonusPoints
DELIMITER $$

CREATE PROCEDURE CalculateBonusPoints(
    IN p_user_id INT,
    INOUT p_bonus_points INT
)
BEGIN
    DECLARE post_count INT;

    -- Đếm số bài viết của user
    SELECT COUNT(*)
    INTO post_count
    FROM posts
    WHERE user_id = p_user_id;

    -- Cộng điểm theo số bài viết
    IF post_count >= 20 THEN
        SET p_bonus_points = p_bonus_points + 100;
    ELSEIF post_count >= 10 THEN
        SET p_bonus_points = p_bonus_points + 50;
    END IF;
END $$

DELIMITER ;

-- 3) Gọi thủ tục với user cụ thể
-- Ví dụ: user_id = 1, điểm ban đầu = 100
SET @bonus = 100;
CALL CalculateBonusPoints(1, @bonus);

-- 4) Lấy giá trị p_bonus_points sau khi cập nhật
SELECT @bonus AS BonusPointsSauKhiTinh;

-- 5) Xóa stored procedure
DROP PROCEDURE CalculateBonusPoints;
