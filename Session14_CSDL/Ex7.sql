USE social_network;

CREATE TABLE IF NOT EXISTS followers (
    follower_id INT NOT NULL,
    followed_id INT NOT NULL,
    PRIMARY KEY (follower_id, followed_id),
    FOREIGN KEY (follower_id) REFERENCES users(user_id),
    FOREIGN KEY (followed_id) REFERENCES users(user_id)
);

ALTER TABLE users
ADD COLUMN IF NOT EXISTS following_count INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS followers_count INT DEFAULT 0;

CREATE TABLE IF NOT EXISTS follow_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    follower_id INT,
    followed_id INT,
    error_message VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE PROCEDURE sp_follow_user(
    IN p_follower_id INT,
    IN p_followed_id INT
)
BEGIN
    DECLARE v_count INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count
    FROM users
    WHERE user_id IN (p_follower_id, p_followed_id);

    IF v_count < 2 THEN
        INSERT INTO follow_log (follower_id, followed_id, error_message)
        VALUES (p_follower_id, p_followed_id, 'User không tồn tại');
        ROLLBACK;
    ELSEIF p_follower_id = p_followed_id THEN
        INSERT INTO follow_log (follower_id, followed_id, error_message)
        VALUES (p_follower_id, p_followed_id, 'Không thể tự follow chính mình');
        ROLLBACK;
    ELSE
        SELECT COUNT(*) INTO v_count
        FROM followers
        WHERE follower_id = p_follower_id
          AND followed_id = p_followed_id;

        IF v_count > 0 THEN
            INSERT INTO follow_log (follower_id, followed_id, error_message)
            VALUES (p_follower_id, p_followed_id, 'Đã follow trước đó');
            ROLLBACK;
        ELSE
            INSERT INTO followers (follower_id, followed_id)
            VALUES (p_follower_id, p_followed_id);

            UPDATE users
            SET following_count = following_count + 1
            WHERE user_id = p_follower_id;

            UPDATE users
            SET followers_count = followers_count + 1
            WHERE user_id = p_followed_id;

            COMMIT;
        END IF;
    END IF;
END$$

DELIMITER ;

CALL sp_follow_user(1, 2);
CALL sp_follow_user(1, 1);
CALL sp_follow_user(1, 2);
CALL sp_follow_user(999, 1);
