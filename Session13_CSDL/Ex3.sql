DELIMITER $$

DROP TRIGGER IF EXISTS before_like_insert$$
DROP TRIGGER IF EXISTS after_like_insert$$
DROP TRIGGER IF EXISTS after_like_delete$$
DROP TRIGGER IF EXISTS after_like_update$$

CREATE TRIGGER before_like_insert
BEFORE INSERT ON likes
FOR EACH ROW
BEGIN
    DECLARE post_owner INT;

    SELECT user_id INTO post_owner
    FROM posts
    WHERE post_id = NEW.post_id;

    IF post_owner = NEW.user_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Khong the like bai dang cua chinh minh';
    END IF;
END$$

CREATE TRIGGER after_like_insert
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count + 1
    WHERE post_id = NEW.post_id;
END$$

CREATE TRIGGER after_like_delete
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count - 1
    WHERE post_id = OLD.post_id;
END$$

CREATE TRIGGER after_like_update
AFTER UPDATE ON likes
FOR EACH ROW
BEGIN
    IF OLD.post_id <> NEW.post_id THEN
        UPDATE posts
        SET like_count = like_count - 1
        WHERE post_id = OLD.post_id;

        UPDATE posts
        SET like_count = like_count + 1
        WHERE post_id = NEW.post_id;
    END IF;
END$$

DELIMITER ;

INSERT INTO likes (user_id, post_id) VALUES (1, 1);

INSERT INTO likes (user_id, post_id) VALUES (2, 2);

SELECT post_id, like_count FROM posts;

UPDATE likes
SET post_id = 3
WHERE like_id = (
    SELECT like_id FROM likes ORDER BY like_id DESC LIMIT 1
);

SELECT post_id, like_count FROM posts;

DELETE FROM likes
ORDER BY like_id DESC
LIMIT 1;

SELECT post_id, like_count FROM posts;

SELECT * FROM user_statistics;
