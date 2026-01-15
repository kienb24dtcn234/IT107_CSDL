
-- Task 1: Viết Stored Procedure sp_create_post
DROP PROCEDURE IF EXISTS sp_create_post;

DELIMITER //

CREATE PROCEDURE sp_create_post(
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    -- Validation
    IF p_content IS NULL OR LENGTH(p_content) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'hehe';
    END IF;

    -- Transaction
    START TRANSACTION;

    -- Declare variables
    DECLARE post_id_var INT;

    -- Insert bài viết vào bảng posts
    INSERT INTO posts (user_id, content) VALUES (p_user_id, p_content);
    SET post_id_var = LAST_INSERT_ID();

    -- Update total_posts của user
    UPDATE users SET total_posts = total_posts + 1 WHERE user_id = p_user_id;

    COMMIT;
END //

DELIMITER ;

-- Task 2: Xử lý lỗi và Rollback
DROP PROCEDURE IF EXISTS sp_create_post;

DELIMITER //

CREATE PROCEDURE sp_create_post(
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    -- Declare exit handler for exceptions
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Validation
    IF p_content IS NULL OR LENGTH(p_content) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Content cannot be empty.';
    END IF;

    -- Transaction
    START TRANSACTION;

    -- Insert bài viết vào bảng posts
    INSERT INTO posts (user_id, content) VALUES (p_user_id, p_content);

    -- Update total_posts của user
    UPDATE users SET total_posts = total_posts + 1 WHERE user_id = p_user_id;

    COMMIT;
END //

DELIMITER ;

-- Task 3: Kiểm thử (Testing)
-- Case 1 (Happy Case): Đăng bài cho user nguyen_van_a với nội dung hợp lệ.
CALL sp_create_post(1, 'Hello, this is a new post from nguyen_van_a.');
SELECT * FROM posts WHERE user_id = 1;
SELECT * FROM users WHERE user_id = 1;

-- Case 2 (Error Case): Đăng bài cho một user_id không tồn tại (ví dụ: 9999).
CALL sp_create_post(9999, 'This post will fail.');
SELECT * FROM posts WHERE user_id = 9999;
SELECT * FROM users;

-- Task 3: Improved Error Handling with specific error messages

DROP PROCEDURE IF EXISTS sp_create_post;

DELIMITER //

CREATE PROCEDURE sp_create_post(
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    -- Declare variables
    DECLARE sql_error BOOLEAN DEFAULT FALSE;

    -- Declare handlers
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_error = TRUE;

    -- Validation
    IF p_content IS NULL OR LENGTH(p_content) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Content cannot be empty.';
    END IF;

    -- Start transaction
    START TRANSACTION;

    -- Insert bài viết
    INSERT INTO posts (user_id, content) VALUES (p_user_id, p_content);

    -- Update total_posts
    UPDATE users SET total_posts = total_posts + 1 WHERE user_id = p_user_id;

    -- Check for errors
    IF sql_error THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An error occurred while creating the post. Transaction rolled back.';
    ELSE
        COMMIT;
    END IF;
END //

DELIMITER ;

-- Case 1 (Happy Case): Đăng bài cho user nguyen_van_a with valid content.
CALL sp_create_post(1, 'Hello, this is a new post from nguyen_van_a.');
SELECT * FROM posts WHERE user_id = 1;
SELECT * FROM users WHERE user_id = 1;

-- Case 2 (Error Case): Đăng bài cho a non-existent user_id (e.g., 9999).
CALL sp_create_post(9999, 'This post will fail.');
SELECT * FROM posts WHERE user_id = 9999;
SELECT * FROM users;

-- 4. Câu hỏi thảo luận
-- Tại sao bước kiểm tra dữ liệu đầu vào (Validation) nên đặt trước lệnh START TRANSACTION?
--  Để tránh việc Transaction phải Rollback khi dữ liệu đầu vào không hợp lệ, giúp giảm tải cho hệ thống. Nếu Validation thất bại, không cần mở Transaction, giúp tối ưu hóa hiệu suất.

-- Nếu không dùng Transaction, điều gì sẽ xảy ra với dữ liệu của user nếu lệnh INSERT thành công nhưng lệnh UPDATE bị lỗi (ví dụ: server sập nguồn đúng lúc đó)?
-- Dữ liệu sẽ không nhất quán. Bài viết sẽ được lưu trong bảng posts, nhưng số lượng bài viết của user trong bảng users sẽ không được cập nhật, dẫn đến sai lệch dữ liệu.

-- Trong Stored Procedure, lệnh nào được dùng để hoàn tác các thay đổi khi gặp lỗi?
-- Lệnh ROLLBACK được dùng để hoàn tác các thay đổi khi gặp lỗi.
