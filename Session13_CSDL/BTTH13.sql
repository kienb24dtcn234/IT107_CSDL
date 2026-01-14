-- =====================================================
-- SOCIAL NETWORK DB - TRIGGER FULL LAB (ONE FILE)
-- =====================================================

-- 1. RESET DATABASE
DROP DATABASE IF EXISTS SocialNetworkDB;
CREATE DATABASE SocialNetworkDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE SocialNetworkDB;

-- =====================================================
-- 2. CREATE TABLES
-- =====================================================

-- USERS
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    total_posts INT DEFAULT 0
);

-- POSTS
CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- POST AUDITS
CREATE TABLE post_audits (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    old_content TEXT,
    new_content TEXT,
    changed_at DATETIME
);

-- =====================================================
-- 3. TRIGGERS
-- =====================================================

DELIMITER $$

-- Task 1: BEFORE INSERT - CHECK CONTENT
CREATE TRIGGER tg_CheckPostContent
BEFORE INSERT ON posts
FOR EACH ROW
BEGIN
    IF NEW.content IS NULL OR TRIM(NEW.content) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nội dung bài viết không được để trống!';
    END IF;
END$$

-- Task 2: AFTER INSERT - UPDATE TOTAL POSTS
CREATE TRIGGER tg_UpdatePostCountAfterInsert
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    UPDATE users
    SET total_posts = total_posts + 1
    WHERE user_id = NEW.user_id;
END$$

-- Task 3: AFTER UPDATE - LOG POST CHANGES
CREATE TRIGGER tg_LogPostChanges
AFTER UPDATE ON posts
FOR EACH ROW
BEGIN
    IF OLD.content <> NEW.content THEN
        INSERT INTO post_audits (
            post_id,
            old_content,
            new_content,
            changed_at
        )
        VALUES (
            OLD.post_id,
            OLD.content,
            NEW.content,
            NOW()
        );
    END IF;
END$$

-- Task 4: AFTER DELETE - UPDATE TOTAL POSTS
CREATE TRIGGER tg_UpdatePostCountAfterDelete
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
    UPDATE users
    SET total_posts = total_posts - 1
    WHERE user_id = OLD.user_id;
END$$

DELIMITER ;

-- =====================================================
-- 4. TESTING
-- =====================================================

-- Create user
INSERT INTO users (username) VALUES ('huydev');

-- Insert valid post
INSERT INTO posts (user_id, content)
VALUES (1, 'Bài viết đầu tiên của tôi');

-- Check total_posts (expect = 1)
SELECT * FROM users;

-- Insert invalid post (should FAIL)
-- INSERT INTO posts (user_id, content) VALUES (1, '   ');

-- Update post
UPDATE posts
SET content = 'Nội dung đã được chỉnh sửa'
WHERE post_id = 1;

-- Check audit log
SELECT * FROM post_audits;

-- Delete post
DELETE FROM posts WHERE post_id = 1;

-- Check total_posts (expect = 0)
SELECT * FROM users;

-- =====================================================
-- 5. CLEANUP
-- =====================================================

DROP TRIGGER IF EXISTS tg_CheckPostContent;
DROP TRIGGER IF EXISTS tg_UpdatePostCountAfterInsert;
DROP TRIGGER IF EXISTS tg_LogPostChanges;
DROP TRIGGER IF EXISTS tg_UpdatePostCountAfterDelete;

-- =====================================================
-- END FILE
-- =====================================================
