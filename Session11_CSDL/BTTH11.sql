CREATE DATABASE IF NOT EXISTS SocialLab;
USE SocialLab;

DROP TABLE IF EXISTS posts;

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    content TEXT,
    author VARCHAR(255),
    likes_count INT 
);

INSERT INTO posts ( content, author, likes_count) VALUES
('Nội dung bài viết 1', 'Nguyễn Thanh Tùng', '10'),
('Nội dung bài viết 2', 'Trần Thị Khánh Huyền', '9'),
('Nội dung bài viết 3', 'Hà Bích Ngọc', '5'),
('Nội dung bài viết 4', 'Nguyễn Quang Huy', '11'),
('Nội dung bài viết 5', 'Phạm Tiến Đạt', '20'),
('Nội dung bài viết 6', 'Nguyễn Văn Hiếu', '25'),
('Nội dung bài viết 7', 'Nguyễn Khắc Hưng', '33');



-- Task 1: Thêm bài viết mới (Sử dụng IN và OUT)
DELIMITER //
CREATE PROCEDURE sp_CreatePost(
    IN p_content TEXT,
    IN p_author VARCHAR(100),
    OUT p_post_id INT
)
BEGIN
    INSERT INTO posts(content, author) VALUES (p_content, p_author);
    SET p_post_id = LAST_INSERT_ID();
END //

-- Task 2: Tìm kiếm bài viết (Sử dụng IN)
CREATE PROCEDURE sp_SearchPost(IN p_keyword VARCHAR(255))
BEGIN
    SELECT * FROM posts 
    WHERE content LIKE CONCAT('%', p_keyword, '%');
END //

-- Task 3: Tăng Like (Sử dụng INOUT)
CREATE PROCEDURE sp_IncreaseLike(
    IN p_post_id INT,
    INOUT p_likes INT
)
BEGIN
    SET p_likes = p_likes + 1;
    UPDATE posts SET likes_count = p_likes WHERE post_id = p_post_id;
END //

-- Task 4: Xóa bài viết (Sử dụng IN)
CREATE PROCEDURE sp_DeletePost(IN p_post_id INT)
BEGIN
    DELETE FROM posts WHERE post_id = p_post_id;
END //
DELIMITER ;

-- ==========================================
-- 3. KIỂM TRA LOGIC (TESTING)
-- ==========================================

-- A. Tạo 2 bài viết mới và lấy ID trả về
CALL sp_CreatePost('Hello world, this is my first post!', 'Alice', @id1);
CALL sp_CreatePost('Learning MySQL is fun, hello everyone!', 'Bob', @id2);

SELECT 'IDs vừa tạo:' AS Message, @id1, @id2;

-- B. Tìm kiếm bài viết có chữ "hello"
SELECT 'Kết quả tìm kiếm từ khóa "hello":' AS Message;
CALL sp_SearchPost('hello');

-- C. Tăng Like cho bài viết đầu tiên (Dùng biến @ để truyền và nhận từ INOUT)
-- Lấy số like hiện tại nạp vào biến
SELECT likes_count INTO @current_likes FROM posts WHERE post_id = @id1;

-- Gọi thủ tục tăng like
CALL sp_IncreaseLike(@id1, @current_likes);

-- Xem kết quả sau khi tăng
SELECT 'Sau khi tăng like bài 1:' AS Message, @current_likes AS New_Like_Count;
SELECT * FROM posts WHERE post_id = @id1;

-- D. Xóa bài viết thứ hai
CALL sp_DeletePost(@id2);
SELECT 'Danh sách bài viết sau khi xóa bài 2:' AS Message;
SELECT * FROM posts;

-- ==========================================
-- 4. DỌN DẸP (DROP PROCEDURES)
-- ==========================================
-- Hủy các procedure sau khi hoàn thành thực hành
DROP PROCEDURE IF EXISTS sp_CreatePost;
DROP PROCEDURE IF EXISTS sp_SearchPost;
DROP PROCEDURE IF EXISTS sp_IncreaseLike;
DROP PROCEDURE IF EXISTS sp_DeletePost;

SELECT 'Hoàn thành bài thực hành và đã dọn dẹp các Procedure.' AS Status;