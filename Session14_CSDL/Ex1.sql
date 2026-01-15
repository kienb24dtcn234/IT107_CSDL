DROP DATABASE IF EXISTS BankDB;
CREATE DATABASE BankDB;
USE BankDB;

CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    account_name VARCHAR(100) NOT NULL,
    balance DECIMAL(10,2) NOT NULL CHECK (balance >= 0)
);

INSERT INTO accounts (account_name, balance) VALUES
('Nguyễn Văn An', 1000.00),
('Trần Thị Bảy', 500.00);

DELIMITER $$

CREATE PROCEDURE sp_TransferMoney(
    IN from_account INT,
    IN to_account INT,
    IN amount DECIMAL(10,2)
)
BEGIN
    DECLARE from_balance DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT balance INTO from_balance
    FROM accounts
    WHERE account_id = from_account
    FOR UPDATE;

    IF from_balance >= amount THEN
        UPDATE accounts
        SET balance = balance - amount
        WHERE account_id = from_account;

        UPDATE accounts
        SET balance = balance + amount
        WHERE account_id = to_account;

        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
END$$

DELIMITER ;

CALL sp_TransferMoney(1, 2, 200.00);
