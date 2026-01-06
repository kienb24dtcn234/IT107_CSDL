
CREATE DATABASE ecommerce_db;
USE ecommerce_db;


CREATE TABLE customers (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);


CREATE TABLE orders (
    id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2)
);


INSERT INTO customers VALUES
(1, 'An', 'an@gmail.com'),
(2, 'Bình', 'binh@gmail.com'),
(3, 'Chi', 'chi@gmail.com'),
(4, 'Dũng', 'dung@gmail.com'),
(5, 'Hà', 'ha@gmail.com'),
(6, 'Khoa', 'khoa@gmail.com'),
(7, 'Linh', 'linh@gmail.com');


INSERT INTO orders VALUES
(1, 1, '2025-01-01', 500000),
(2, 2, '2025-01-03', 1200000),
(3, 1, '2025-01-05', 300000),
(4, 3, '2025-01-07', 800000),
(5, 5, '2025-01-10', 450000),
(6, 2, '2025-01-12', 950000),
(7, 6, '2025-01-15', 600000);


SELECT *
FROM customers
WHERE id IN (
    SELECT customer_id
    FROM orders
);
