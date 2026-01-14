CREATE TABLE post_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    old_content TEXT,
    new_content TEXT,
    changed_at DATETIME,
    changed_by_user_id INT,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);

DELIMITER $$

DROP TRIGGER IF EXISTS before_post_update$$
DROP TRIGGER IF EXISTS after_post_delete$$

CREATE TRIGGER before_post_update
BEFORE UPDATE ON posts
FOR EACH ROW
BEGIN
    IF OLD.content <> NEW.content THEN
        INSERT INTO post_history (
            post_id,
            old_content,
            new_content,
            changed_at,
            changed_by_user_id
        ) VALUES (
            OLD.post_id,
            OLD.content,
            NEW.content,
            NOW(),
            OLD.user_id
        );
    END IF;
END$$

CREATE TRIGGER after_post_delete
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
    INSERT INTO post_history (
        post_id,
        old_content,
        new_content,
        changed_at,
        changed_by_user_id
    ) VALUES (
        OLD.post_id,
        OLD.content,
        NULL,
        NOW(),
        OLD.user_id
    );
END$$

DELIMITER ;

UPDATE posts
SET content = 'Alice updated her first post'
WHERE post_id = 1;

UPDATE posts
SET content = 'Bob edited his post content'
WHERE post_id = 3;

SELECT * FROM post_history;

SELECT post_id, like_count FROM posts;

SELECT * FROM user_statistics;
