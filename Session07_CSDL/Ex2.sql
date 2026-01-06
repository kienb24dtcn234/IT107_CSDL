-- Tạo CSDL
CREATE DATABASE ecommerce_db2;
USE ecommerce_db2;

-- Tạo bảng products
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2)
);

-- Tạo bảng order_items
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT
);

-- Thêm dữ liệu mẫu cho products (7 sản phẩm)
INSERT INTO products VALUES
(1, 'Laptop', 15000000),
(2, 'Chuột', 200000),
(3, 'Bàn phím', 500000),
(4, 'Tai nghe', 700000),
(5, 'Màn hình', 3000000),
(6, 'USB', 150000),
(7, 'Webcam', 900000);

-- Thêm dữ liệu mẫu cho order_items (7 dòng)
INSERT INTO order_items VALUES
(1, 1, 1),
(1, 2, 2),
(2, 3, 1),
(2, 4, 1),
(3, 1, 1),
(3, 5, 1),
(4, 6, 3);

-- Lấy danh sách sản phẩm đã từng được bán
-- Dùng subquery + IN, KHÔNG dùng JOIN
SELECT *
FROM products
WHERE id IN (
    SELECT product_id
    FROM order_items
);
