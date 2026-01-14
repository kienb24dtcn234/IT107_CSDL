DELIMITER $$

DROP TRIGGER IF EXISTS before_user_insert$$
DROP PROCEDURE IF EXISTS add_user$$

CREATE TRIGGER before_user_insert
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    IF NEW.email NOT LIKE '%@%.%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email khong hop le';
    END IF;

    IF NEW.username NOT REGEXP '^[A-Za-z0-9_]+$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username chi duoc chua chu, so va dau gach duoi';
    END IF;
END$$

CREATE PROCEDURE add_user(
    IN p_username VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_created_at DATE
)
BEGIN
    INSERT INTO users (username, email, created_at)
    VALUES (p_username, p_email, p_created_at);
END$$

DELIMITER ;

CALL add_user('valid_user', 'valid_user@gmail.com', '2025-01-20');

CALL add_user('invalid-user', 'invalid@gmail.com', '2025-01-20');

CALL add_user('invalidemail', 'invalidemailgmail.com', '2025-01-20');

SELECT * FROM users;
