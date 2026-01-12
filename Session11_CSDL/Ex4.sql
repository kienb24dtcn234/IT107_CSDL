-- =========================================
-- BÀI: TẠO BÀI VIẾT CÓ KIỂM TRA NỘI DUNG
-- =========================================

-- 1) Sử dụng database
USE social_network_pro;

-- 2) Tạo stored procedure CreatePostWithValidation
DELIMITER $$

CREATE PROCEDURE CreatePostWithValidation(
    IN p_user_id INT,
    IN p_content TEXT,
    OUT result_message VARCHAR(255)
)
BEGIN
    IF CHAR_LENGTH(p_content) < 5 THEN
        SET result_message = 'Nội dung quá ngắn';
    ELSE
        INSERT INTO posts(user_id, content, created_at)
        VALUES (p_user_id, p_content, NOW());

        SET result_message = 'Thêm bài viết thành công';
    END IF;
END $$

DELIMITER ;

-- 3) Gọi thủ tục – test các trường hợp

-- Case 1: Nội dung quá ngắn
CALL CreatePostWithValidation(1, 'Hi', @msg1);
SELECT @msg1 AS KetQuaCase1;

-- Case 2: Nội dung hợp lệ
CALL CreatePostWithValidation(1, 'Hello world nha', @msg2);
SELECT @msg2 AS KetQuaCase2;

-- 4) Kiểm tra kết quả insert
SELECT * FROM posts WHERE user_id = 1 ORDER BY created_at DESC;

-- 5) Xóa stored procedure
DROP PROCEDURE CreatePostWithValidation;
