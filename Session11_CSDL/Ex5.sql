-- =========================================
-- BÀI: TÍNH ĐIỂM HOẠT ĐỘNG USER
-- =========================================

-- 1) Sử dụng database
USE social_network_pro;

-- 2) Tạo stored procedure CalculateUserActivityScore
DELIMITER $$

CREATE PROCEDURE CalculateUserActivityScore(
    IN p_user_id INT,
    OUT activity_score INT,
    OUT activity_level VARCHAR(50)
)
BEGIN
    DECLARE post_count INT DEFAULT 0;
    DECLARE comment_count INT DEFAULT 0;
    DECLARE like_count INT DEFAULT 0;

    -- Đếm số bài viết
    SELECT COUNT(*)
    INTO post_count
    FROM posts
    WHERE user_id = p_user_id;

    -- Đếm số comment
    SELECT COUNT(*)
    INTO comment_count
    FROM comments
    WHERE user_id = p_user_id;

    -- Đếm số like nhận được trên bài viết của user
    SELECT COUNT(*)
    INTO like_count
    FROM likes l
    JOIN posts p ON l.post_id = p.post_id
    WHERE p.user_id = p_user_id;

    -- Tính tổng điểm
    SET activity_score = post_count * 10
                        + comment_count * 5
                        + like_count * 3;

    -- Phân loại mức độ hoạt động
    CASE
        WHEN activity_score > 500 THEN
            SET activity_level = 'Rất tích cực';
        WHEN activity_score BETWEEN 200 AND 500 THEN
            SET activity_level = 'Tích cực';
        ELSE
            SET activity_level = 'Bình thường';
    END CASE;
END $$

DELIMITER ;

-- 3) Gọi thủ tục và xem kết quả
CALL CalculateUserActivityScore(1, @score, @level);

SELECT 
    @score AS ActivityScore,
    @level AS ActivityLevel;

-- 4) Xóa stored procedure
DROP PROCEDURE CalculateUserActivityScore;
