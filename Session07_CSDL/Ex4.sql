USE ecommerce_db;

INSERT INTO customers VALUES
(8, 'Minh', 'minh@gmail.com'),
(9, 'Ngọc', 'ngoc@gmail.com'),
(10, 'Phúc', 'phuc@gmail.com'),
(11, 'Trang', 'trang@gmail.com'),
(12, 'Tuấn', 'tuan@gmail.com');

INSERT INTO orders VALUES
(13, 8, '2025-03-01', 500000),
(14, 8, '2025-03-02', 700000),
(15, 9, '2025-03-03', 300000),
(16, 10, '2025-03-04', 900000),
(17, 10, '2025-03-05', 1200000);

SELECT
    name,
    (
        SELECT COUNT(*)
        FROM orders
        WHERE orders.customer_id = customers.id
    ) AS total_orders
FROM customers;
