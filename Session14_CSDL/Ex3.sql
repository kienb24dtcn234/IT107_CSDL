DROP DATABASE IF EXISTS PayrollDB;
CREATE DATABASE PayrollDB;
USE PayrollDB;

CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(100),
    salary DECIMAL(10,2)
);

CREATE TABLE company_funds (
    fund_id INT PRIMARY KEY,
    balance DECIMAL(15,2)
);

CREATE TABLE payroll (
    payroll_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    salary_paid DECIMAL(10,2),
    pay_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO employees (emp_name, salary) VALUES
('Nguyễn Văn A', 800.00),
('Trần Thị B', 1200.00);

INSERT INTO company_funds (fund_id, balance) VALUES
(1, 1500.00);

DELIMITER $$

CREATE PROCEDURE sp_PaySalary(
    IN p_emp_id INT
)
BEGIN
    DECLARE emp_salary DECIMAL(10,2);
    DECLARE fund_balance DECIMAL(15,2);
    DECLARE bank_status INT DEFAULT 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT salary INTO emp_salary
    FROM employees
    WHERE emp_id = p_emp_id;

    SELECT balance INTO fund_balance
    FROM company_funds
    WHERE fund_id = 1
    FOR UPDATE;

    IF fund_balance < emp_salary THEN
        ROLLBACK;
    ELSE
        UPDATE company_funds
        SET balance = balance - emp_salary
        WHERE fund_id = 1;

        INSERT INTO payroll (emp_id, salary_paid)
        VALUES (p_emp_id, emp_salary);

        IF bank_status = 0 THEN
            ROLLBACK;
        ELSE
            COMMIT;
        END IF;
    END IF;
END$$

DELIMITER ;

CALL sp_PaySalary(1);
