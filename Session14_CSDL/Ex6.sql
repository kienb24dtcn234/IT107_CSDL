USE social_network;

CREATE TABLE IF NOT EXISTS likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    UNIQUE KEY unique_like (post_id, user_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

ALTER TABLE posts
ADD COLUMN IF NOT EXISTS likes_count INT DEFAULT 0;

START TRANSACTION;

INSERT INTO likes (post_id, user_id)
VALUES (1, 1);

UPDATE posts
SET likes_count = likes_count + 1
WHERE post_id = 1;

COMMIT;

START TRANSACTION;

INSERT INTO likes (post_id, user_id)
VALUES (1, 1);

UPDATE posts
SET likes_count = likes_count + 1
WHERE post_id = 1;

ROLLBACK;
