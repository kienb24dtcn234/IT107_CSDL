-- ==========================================
-- 1. KHỞI TẠO CƠ SỞ DỮ LIỆU
-- ==========================================
CREATE DATABASE IF NOT EXISTS SocialNetworkDB;
USE SocialNetworkDB;

-- ==========================================
-- 2. TẠO CẤU TRÚC BẢNG (TABLES)
-- ==========================================

-- Bảng Người dùng
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Bài viết
CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Bảng Bình luận
CREATE TABLE Comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    user_id INT,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Bảng Bạn bè
CREATE TABLE Friends (
    user_id INT,
    friend_id INT,
    status VARCHAR(20) CHECK (status IN ('pending', 'accepted')),
    PRIMARY KEY (user_id, friend_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (friend_id) REFERENCES Users(user_id)
);

-- Bảng Lượt thích
CREATE TABLE Likes (
    user_id INT,
    post_id INT,
    PRIMARY KEY (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id) ON DELETE CASCADE
);

-- ==========================================
-- 3. TỐI ƯU HÓA TRUY VẤN (INDEX)
-- ==========================================

CREATE INDEX idx_username ON Users(username);
CREATE INDEX idx_post_user_time ON Posts(user_id, created_at DESC);
CREATE INDEX idx_likes_post ON Likes(post_id);

-- ==========================================
-- 4. TRỪU TƯỢNG HÓA DỮ LIỆU (VIEW)
-- ==========================================

-- View hồ sơ công khai
CREATE VIEW vw_public_users AS
SELECT user_id, username, created_at FROM Users;

-- View News Feed trong 7 ngày
CREATE VIEW vw_recent_posts AS
SELECT p.*, u.username 
FROM Posts p 
JOIN Users u ON p.user_id = u.user_id
WHERE p.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- View quản trị (WITH CHECK OPTION)
CREATE VIEW vw_active_users AS
SELECT * FROM Users WHERE status = 'active'
WITH CHECK OPTION;

-- View hiển thị bình luận
CREATE VIEW vw_post_comments AS
SELECT c.post_id, c.content, u.username, c.created_at
FROM Comments c
JOIN Users u ON c.user_id = u.user_id;

-- View thống kê lượt thích
CREATE VIEW vw_post_likes AS
SELECT post_id, COUNT(*) AS total_likes
FROM Likes
GROUP BY post_id;

-- View Top 5 bài viết nhiều tương tác nhất
CREATE VIEW vw_top_posts AS
SELECT p.post_id, p.content, COUNT(l.user_id) as like_count
FROM Posts p
LEFT JOIN Likes l ON p.post_id = l.post_id
GROUP BY p.post_id
ORDER BY like_count DESC
LIMIT 5;

-- ==========================================
-- 5. THỦ TỤC LƯU TRỮ (STORED PROCEDURES)
-- ==========================================

DELIMITER //

-- Thủ tục đăng bài
CREATE PROCEDURE sp_create_post(IN p_user_id INT, IN p_content TEXT)
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
        INSERT INTO Posts(user_id, content) VALUES (p_user_id, p_content);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User không tồn tại';
    END IF;
END //

-- Thủ tục thống kê bài viết (OUT Parameter)
CREATE PROCEDURE sp_count_posts(IN p_user_id INT, OUT p_total INT)
BEGIN
    SELECT COUNT(*) INTO p_total FROM Posts WHERE user_id = p_user_id;
END //

-- Thủ tục kết bạn
CREATE PROCEDURE sp_add_friend(IN p_user_id INT, IN p_friend_id INT)
BEGIN
    IF p_user_id = p_friend_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không thể kết bạn với chính mình';
    ELSE
        INSERT INTO Friends(user_id, friend_id, status) VALUES (p_user_id, p_friend_id, 'pending');
    END IF;
END //

-- Thủ tục thêm bình luận
CREATE PROCEDURE sp_add_comment(IN p_user_id INT, IN p_post_id INT, IN p_content TEXT)
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id) AND 
       EXISTS (SELECT 1 FROM Posts WHERE post_id = p_post_id) THEN
        INSERT INTO Comments(user_id, post_id, content) VALUES (p_user_id, p_post_id, p_content);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dữ liệu không hợp lệ';
    END IF;
END //

-- Thủ tục like bài viết
CREATE PROCEDURE sp_like_post(IN p_user_id INT, IN p_post_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Likes WHERE user_id = p_user_id AND post_id = p_post_id) THEN
        INSERT INTO Likes(user_id, post_id) VALUES (p_user_id, p_post_id);
    END IF;
END //

-- Thủ tục tìm kiếm tổng hợp (IF/ELSE)
CREATE PROCEDURE sp_search_social(IN p_option INT, IN p_keyword VARCHAR(100))
BEGIN
    DECLARE search_pattern VARCHAR(110);
    SET search_pattern = CONCAT('%', p_keyword, '%');
    
    IF p_option = 1 THEN
        SELECT * FROM Users WHERE username LIKE search_pattern;
    ELSEIF p_option = 2 THEN
        SELECT * FROM Posts WHERE content LIKE search_pattern;
    ELSE
        SELECT 'Lựa chọn không hợp lệ (1: User, 2: Post)' AS Message;
    END IF;
END //

-- Thủ tục gợi ý bạn bè đơn giản (WHILE & Logic)
CREATE PROCEDURE sp_suggest_friends(IN p_user_id INT, INOUT p_limit INT)
BEGIN
    DECLARE counter INT DEFAULT 0;
    -- Logic: Lợi dụng p_limit để giới hạn kết quả trả về
    SELECT user_id, username FROM Users 
    WHERE user_id <> p_user_id 
    AND user_id NOT IN (SELECT friend_id FROM Friends WHERE user_id = p_user_id)
    LIMIT p_limit;
END //

DELIMITER ;

-- ==========================================
-- 6. DỮ LIỆU MẪU ĐỂ TEST
-- ==========================================

INSERT INTO Users (username, password, email) VALUES 
('an_nguyen', 'pass123', 'an@example.com'),
('binh_le', 'pass456', 'binh@example.com'),
('cuong_pham', 'pass789', 'cuong@example.com');

CALL sp_create_post(1, 'Học SQL tại trường rất vui!');
CALL sp_create_post(2, 'Làm mini project social network.');

CALL sp_like_post(2, 1);
CALL sp_add_comment(3, 1, 'Bài viết hay quá!');

-- Kiểm tra kết quả
SELECT * FROM vw_public_users;
SELECT * FROM vw_recent_posts;
SELECT * FROM vw_post_likes;