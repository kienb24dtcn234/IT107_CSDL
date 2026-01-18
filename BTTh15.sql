-- ==========================================
-- 1. KHỞI TẠO CƠ SỞ DỮ LIỆU
-- ==========================================
CREATE DATABASE IF NOT EXISTS MiniSocialNetwork;
USE MiniSocialNetwork;

-- ==========================================
-- 2. TẠO CẤU TRÚC BẢNG (TABLES)
-- ==========================================

-- Bảng Người dùng
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Bài viết
CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT NOT NULL,
    like_count INT DEFAULT 0, -- Cập nhật tự động qua Trigger
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

-- Bảng Lượt thích
CREATE TABLE Likes (
    user_id INT,
    post_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id) ON DELETE CASCADE
);

-- Bảng Bạn bè
CREATE TABLE Friends (
    user_id INT,
    friend_id INT,
    status VARCHAR(20) CHECK (status IN ('pending', 'accepted')) DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, friend_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (friend_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Bảng Nhật ký hệ thống (System Logs)
CREATE TABLE System_Logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(255),
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 3. CÁC TRIGGER TỰ ĐỘNG (TRIGGERS)
-- ==========================================
DELIMITER //

-- Trigger: Ghi log khi đăng ký (Bài 1)
CREATE TRIGGER trg_after_user_register
AFTER INSERT ON Users
FOR EACH ROW
BEGIN
    INSERT INTO System_Logs(user_id, action) 
    VALUES (NEW.user_id, 'Đăng ký tài khoản mới');
END //

-- Trigger: Ghi log khi đăng bài (Bài 2)
CREATE TRIGGER trg_after_post_create
AFTER INSERT ON Posts
FOR EACH ROW
BEGIN
    INSERT INTO System_Logs(user_id, action) 
    VALUES (NEW.user_id, CONCAT('Đăng bài viết mới, ID: ', NEW.post_id));
END //

-- Trigger: Cập nhật số lượt thích khi LIKE (Bài 3)
CREATE TRIGGER trg_after_like_insert
AFTER INSERT ON Likes
FOR EACH ROW
BEGIN
    UPDATE Posts SET like_count = like_count + 1 WHERE post_id = NEW.post_id;
    INSERT INTO System_Logs(user_id, action) VALUES (NEW.user_id, CONCAT('Thích bài viết ID: ', NEW.post_id));
END //

-- Trigger: Cập nhật số lượt thích khi UNLIKE (Bài 3)
CREATE TRIGGER trg_after_like_delete
AFTER DELETE ON Likes
FOR EACH ROW
BEGIN
    UPDATE Posts SET like_count = like_count - 1 WHERE post_id = OLD.post_id;
    INSERT INTO System_Logs(user_id, action) VALUES (OLD.user_id, CONCAT('Bỏ thích bài viết ID: ', OLD.post_id));
END //

-- Trigger: Tự động tạo quan hệ đối xứng khi chấp nhận kết bạn (Bài 5)
CREATE TRIGGER trg_after_friend_accept
AFTER UPDATE ON Friends
FOR EACH ROW
BEGIN
    IF NEW.status = 'accepted' AND OLD.status = 'pending' THEN
        -- Nếu chưa có bản ghi ngược lại thì tạo mới để đảm bảo A bạn B => B bạn A
        IF NOT EXISTS (SELECT 1 FROM Friends WHERE user_id = NEW.friend_id AND friend_id = NEW.user_id) THEN
            INSERT INTO Friends(user_id, friend_id, status) VALUES (NEW.friend_id, NEW.user_id, 'accepted');
        END IF;
    END IF;
END //

DELIMITER ;

-- ==========================================
-- 4. THỦ TỤC LƯU TRỮ & GIAO DỊCH (PROCEDURES & TRANSACTIONS)
-- ==========================================
DELIMITER //

-- Thủ tục Đăng ký (Bài 1)
CREATE PROCEDURE sp_register_user(
    IN p_username VARCHAR(50), 
    IN p_password VARCHAR(255), 
    IN p_email VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Tên đăng nhập hoặc Email đã tồn tại!';
    END;

    START TRANSACTION;
        INSERT INTO Users(username, password, email) VALUES (p_username, p_password, p_email);
    COMMIT;
END //

-- Thủ tục Gửi lời mời kết bạn (Bài 4)
CREATE PROCEDURE sp_send_friend_request(IN p_sender_id INT, IN p_receiver_id INT)
BEGIN
    IF p_sender_id = p_receiver_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không thể tự kết bạn với chính mình!';
    ELSE
        INSERT INTO Friends(user_id, friend_id, status) VALUES (p_sender_id, p_receiver_id, 'pending');
    END IF;
END //

-- Thủ tục Xóa bài viết an toàn (Bài 7 - Transaction)
CREATE PROCEDURE sp_delete_post(IN p_post_id INT, IN p_user_id INT)
BEGIN
    DECLARE v_owner INT;
    SELECT user_id INTO v_owner FROM Posts WHERE post_id = p_post_id;

    IF v_owner IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bài viết không tồn tại';
    ELSEIF v_owner <> p_user_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bạn không có quyền xóa bài viết của người khác';
    ELSE
        START TRANSACTION;
            DELETE FROM Posts WHERE post_id = p_post_id;
        COMMIT;
    END IF;
END //

-- Thủ tục Xóa tài khoản (Bài 8 - Transaction)
CREATE PROCEDURE sp_delete_user(IN p_user_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Xóa user (Các bảng khác tự xóa nhờ ON DELETE CASCADE)
        DELETE FROM Users WHERE user_id = p_user_id;
        INSERT INTO System_Logs(user_id, action) VALUES (p_user_id, 'Tài khoản đã bị xóa toàn bộ dữ liệu');
    COMMIT;
END //

-- Thủ tục Tìm kiếm (F14)
CREATE PROCEDURE sp_search_social(IN p_option INT, IN p_keyword VARCHAR(100))
BEGIN
    IF p_option = 1 THEN
        SELECT user_id, username, email FROM Users WHERE username LIKE CONCAT('%', p_keyword, '%');
    ELSEIF p_option = 2 THEN
        SELECT * FROM Posts WHERE content LIKE CONCAT('%', p_keyword, '%');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lựa chọn tìm kiếm không hợp lệ';
    END IF;
END //

DELIMITER ;

-- ==========================================
-- 5. KỊCH BẢN KIỂM TRA (TEST SCRIPT)
-- ==========================================

-- 1. Đăng ký thành viên
CALL sp_register_user('nguyen_an', 'pass123', 'an@gmail.com');
CALL sp_register_user('le_binh', 'pass456', 'binh@gmail.com');
CALL sp_register_user('tran_cuong', 'pass789', 'cuong@example.com');

-- 2. Đăng bài viết
INSERT INTO Posts(user_id, content) VALUES (1, 'Chào cả nhà, mình là An!');
INSERT INTO Posts(user_id, content) VALUES (2, 'Hôm nay học SQL thật thú vị.');

-- 3. Kiểm tra Like (Like_count tự tăng)
INSERT INTO Likes(user_id, post_id) VALUES (2, 1);
INSERT INTO Likes(user_id, post_id) VALUES (3, 1);
SELECT post_id, content, like_count FROM Posts;

-- 4. Kiểm tra Kết bạn
CALL sp_send_friend_request(1, 2);
UPDATE Friends SET status = 'accepted' WHERE user_id = 1 AND friend_id = 2;
SELECT * FROM Friends; -- Kiểm tra tính đối xứng (sẽ có 2 dòng)

-- 5. Xem Log hệ thống
SELECT * FROM System_Logs;

-- 6. Xóa tài khoản (Kiểm tra Transaction)
CALL sp_delete_user(3);
SELECT * FROM Users; -- User 3 và các like của họ sẽ biến mất hoàn toàn