DROP DATABASE IF EXISTS ShopDB;
CREATE DATABASE ShopDB;
USE ShopDB;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    stock INT NOT NULL
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    quantity INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (product_name, stock) VALUES
('Bàn phím cơ', 10),
('Chuột gaming', 5);

DELIMITER $$

CREATE PROCEDURE sp_PlaceOrder(
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE current_stock INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT stock INTO current_stock
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;

    IF current_stock < p_quantity THEN
        ROLLBACK;
    ELSE
        INSERT INTO orders (product_id, quantity)
        VALUES (p_product_id, p_quantity);

        UPDATE products
        SET stock = stock - p_quantity
        WHERE product_id = p_product_id;

        COMMIT;
    END IF;
END$$

DELIMITER ;

CALL sp_PlaceOrder(1, 3);
