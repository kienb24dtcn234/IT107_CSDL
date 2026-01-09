/* ===============================
   SOCIAL NETWORK MINI - FULL FILE
   =============================== */

DROP DATABASE IF EXISTS social_network_mini;

CREATE DATABASE social_network_mini
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE social_network_mini;

/* ========= TABLES ========= */

CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  gender ENUM('Nam','Nữ') NOT NULL DEFAULT 'Nam',
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  birthdate DATE,
  hometown VARCHAR(100),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
  post_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE comments (
  comment_id INT AUTO_INCREMENT PRIMARY KEY,
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE likes (
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (post_id, user_id),
  FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE friends (
  user_id INT NOT NULL,
  friend_id INT NOT NULL,
  status ENUM('pending','accepted','blocked') DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, friend_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (friend_id) REFERENCES users(user_id)
);

CREATE TABLE messages (
  message_id INT AUTO_INCREMENT PRIMARY KEY,
  sender_id INT NOT NULL,
  receiver_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sender_id) REFERENCES users(user_id),
  FOREIGN KEY (receiver_id) REFERENCES users(user_id)
);

CREATE TABLE notifications (
  notification_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  type VARCHAR(50),
  content VARCHAR(255),
  is_read BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

/* ========= SAMPLE USERS ========= */

INSERT INTO users(username, full_name, gender, email, password, birthdate, hometown) VALUES
('an','Nguyễn Văn An','Nam','an@gmail.com','123','1990-01-01','Hà Nội'),
('binh','Trần Thị Bình','Nữ','binh@gmail.com','123','1992-02-15','TP.HCM'),
('chi','Lê Minh Chi','Nữ','chi@gmail.com','123','1991-03-10','Đà Nẵng'),
('duy','Phạm Quốc Duy','Nam','duy@gmail.com','123','1990-05-20','Hải Phòng'),
('minh','Nguyễn Minh','Nam','minh@gmail.com','123','1990-12-01','Hà Nội');

/* =====================================================
   YÊU CẦU 2: TẠO VIEW USER CÓ HỌ "NGUYỄN"
   ===================================================== */

CREATE OR REPLACE VIEW view_users_firstname AS
SELECT
  user_id,
  username,
  full_name,
  email,
  created_at
FROM users
WHERE full_name LIKE 'Nguyễn %';

/* =====================================================
   YÊU CẦU 3: HIỂN THỊ VIEW
   ===================================================== */

SELECT * FROM view_users_firstname;

/* =====================================================
   YÊU CẦU 4: THÊM USER HỌ NGUYỄN → CHECK VIEW
   ===================================================== */

INSERT INTO users(username, full_name, gender, email, password, birthdate, hometown)
VALUES ('nguyen_test','Nguyễn Test User','Nam','nguyentest@gmail.com','123','1999-09-09','Hà Nội');

SELECT * FROM view_users_firstname;

/* =====================================================
   YÊU CẦU 5: XOÁ USER VỪA THÊM → CHECK VIEW
   ===================================================== */

DELETE FROM users
WHERE username = 'nguyen_test';

SELECT * FROM view_users_firstname;
