-- ==========================================
-- SOCIAL NETWORK DATABASE - FULL 14 BÀI
-- ==========================================

DROP DATABASE IF EXISTS social_network;
CREATE DATABASE social_network;
USE social_network;

-- ==========================================
-- BÀI 1: USERS
-- ==========================================
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Users(username,password,email) VALUES
('an123','123','an@gmail.com'),
('binh','123','binh@gmail.com'),
('chi','123','chi@gmail.com'),
('dat','123','dat@gmail.com'),
('em','123','em@gmail.com');

SELECT * FROM Users;

-- ==========================================
-- BÀI 2: VIEW PUBLIC USERS
-- ==========================================
CREATE VIEW vw_public_users AS
SELECT user_id, username, created_at FROM Users;

SELECT * FROM vw_public_users;

-- ==========================================
-- BÀI 3: INDEX USERNAME
-- ==========================================
CREATE INDEX idx_users_username ON Users(username);

SELECT * FROM Users WHERE username LIKE '%an%';

-- ==========================================
-- BÀI 4: POSTS + PROCEDURE ĐĂNG BÀI
-- ==========================================
CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

INSERT INTO Posts(user_id,content) VALUES
(1,'Hoc SQL kha la met'),
(2,'Database rat quan trong'),
(3,'MySQL Stored Procedure hoi khoai'),
(1,'View giup bao mat'),
(4,'Index lam truy van nhanh hon');

DELIMITER $$
CREATE PROCEDURE sp_create_post(
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
        INSERT INTO Posts(user_id,content)
        VALUES (p_user_id,p_content);
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User khong ton tai';
    END IF;
END$$
DELIMITER ;

CALL sp_create_post(1,'Bai viet moi bang procedure');

-- ==========================================
-- BÀI 5: VIEW NEWS FEED 7 NGÀY
-- ==========================================
CREATE VIEW vw_recent_posts AS
SELECT * FROM Posts
WHERE created_at >= NOW() - INTERVAL 7 DAY;

SELECT * FROM vw_recent_posts;

-- ==========================================
-- BÀI 6: INDEX POSTS
-- ==========================================
CREATE INDEX idx_posts_user ON Posts(user_id);
CREATE INDEX idx_posts_user_time ON Posts(user_id, created_at);

SELECT * FROM Posts
WHERE user_id = 1
ORDER BY created_at DESC;

-- ==========================================
-- BÀI 7: THỐNG KÊ SỐ BÀI VIẾT
-- ==========================================
DELIMITER $$
CREATE PROCEDURE sp_count_posts(
    IN p_user_id INT,
    OUT p_total INT
)
BEGIN
    SELECT COUNT(*) INTO p_total
    FROM Posts WHERE user_id = p_user_id;
END$$
DELIMITER ;

SET @total = 0;
CALL sp_count_posts(1,@total);
SELECT @total AS total_posts;

-- ==========================================
-- BÀI 8: VIEW WITH CHECK OPTION
-- ==========================================
CREATE VIEW vw_active_users AS
SELECT * FROM Users
WHERE username IS NOT NULL
WITH CHECK OPTION;

-- ==========================================
-- BÀI 9: FRIENDS + PROCEDURE
-- ==========================================
CREATE TABLE Friends (
    user_id INT,
    friend_id INT,
    status VARCHAR(20),
    CHECK (status IN ('pending','accepted')),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (friend_id) REFERENCES Users(user_id)
);

INSERT INTO Friends VALUES
(1,2,'accepted'),
(1,3,'pending'),
(2,4,'accepted');

DELIMITER $$
CREATE PROCEDURE sp_add_friend(
    IN p_user_id INT,
    IN p_friend_id INT
)
BEGIN
    IF p_user_id = p_friend_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Khong the ket ban voi chinh minh';
    ELSE
        INSERT INTO Friends VALUES (p_user_id,p_friend_id,'pending');
    END IF;
END$$
DELIMITER ;

CALL sp_add_friend(3,5);

-- ==========================================
-- BÀI 10: GỢI Ý BẠN BÈ
-- ==========================================
DELIMITER $$
CREATE PROCEDURE sp_suggest_friends(
    IN p_user_id INT,
    INOUT p_limit INT
)
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < p_limit DO
        SELECT user_id, username
        FROM Users
        WHERE user_id != p_user_id
        LIMIT 1;
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

SET @lim = 2;
CALL sp_suggest_friends(1,@lim);

-- ==========================================
-- BÀI 11: LIKES + TOP POSTS
-- ==========================================
CREATE TABLE Likes (
    user_id INT,
    post_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (post_id) REFERENCES Posts(post_id)
);

INSERT INTO Likes VALUES
(1,1),(2,1),(3,1),
(2,2),(3,2),
(1,3),(4,3),
(5,4);

CREATE INDEX idx_likes_post ON Likes(post_id);

CREATE VIEW vw_top_posts AS
SELECT post_id, COUNT(*) AS total_likes
FROM Likes
GROUP BY post_id
ORDER BY total_likes DESC
LIMIT 5;

SELECT * FROM vw_top_posts;

-- ==========================================
-- BÀI 12: COMMENTS + PROCEDURE
-- ==========================================
CREATE TABLE Comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    user_id INT,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

INSERT INTO Comments(user_id,post_id,content) VALUES
(2,1,'Dung roi'),
(3,1,'Kho that'),
(4,2,'Database chan ai'),
(5,3,'Hoc mai moi quen');

DELIMITER $$
CREATE PROCEDURE sp_add_comment(
    IN p_user_id INT,
    IN p_post_id INT,
    IN p_content TEXT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='User khong ton tai';
    ELSEIF NOT EXISTS (SELECT 1 FROM Posts WHERE post_id = p_post_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Post khong ton tai';
    ELSE
        INSERT INTO Comments(user_id,post_id,content)
        VALUES (p_user_id,p_post_id,p_content);
    END IF;
END$$
DELIMITER ;

CALL sp_add_comment(1,1,'Comment bang procedure');

CREATE VIEW vw_post_comments AS
SELECT c.content, u.username, c.created_at
FROM Comments c
JOIN Users u ON c.user_id = u.user_id;

SELECT * FROM vw_post_comments;

-- ==========================================
-- BÀI 13: LIKE POST PROCEDURE
-- ==========================================
DELIMITER $$
CREATE PROCEDURE sp_like_post(
    IN p_user_id INT,
    IN p_post_id INT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM Likes
        WHERE user_id=p_user_id AND post_id=p_post_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Da like roi';
    ELSE
        INSERT INTO Likes VALUES (p_user_id,p_post_id);
    END IF;
END$$
DELIMITER ;

CALL sp_like_post(1,2);

CREATE VIEW vw_post_likes AS
SELECT post_id, COUNT(*) AS total_likes
FROM Likes
GROUP BY post_id;

-- ==========================================
-- BÀI 14: SEARCH USER & POST
-- ==========================================
DELIMITER $$
CREATE PROCEDURE sp_search_social(
    IN p_option INT,
    IN p_keyword VARCHAR(100)
)
BEGIN
    IF p_option = 1 THEN
        SELECT * FROM Users
        WHERE username LIKE CONCAT('%',p_keyword,'%');
    ELSEIF p_option = 2 THEN
        SELECT * FROM Posts
        WHERE content LIKE CONCAT('%',p_keyword,'%');
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Option khong hop le';
    END IF;
END$$
DELIMITER ;

CALL sp_search_social(1,'an');
CALL sp_search_social(2,'Database');