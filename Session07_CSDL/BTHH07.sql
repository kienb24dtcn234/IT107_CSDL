-- 1. Tạo Database
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- 2. Xóa bảng nếu đã tồn tại (để chạy lại nhiều lần)
DROP TABLE IF EXISTS CHI_TIET_DON_HANG;
DROP TABLE IF EXISTS DON_HANG;
DROP TABLE IF EXISTS SAN_PHAM;
DROP TABLE IF EXISTS KHACH_HANG;

-- 3. Tạo bảng KHACH_HANG
CREATE TABLE KHACH_HANG (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50)
);

-- 4. Tạo bảng SAN_PHAM
CREATE TABLE SAN_PHAM (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(12,2)
);

-- 5. Tạo bảng DON_HANG
CREATE TABLE DON_HANG (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES KHACH_HANG(customer_id)
);

-- 6. Tạo bảng CHI_TIET_DON_HANG
CREATE TABLE CHI_TIET_DON_HANG (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES DON_HANG(order_id),
    FOREIGN KEY (product_id) REFERENCES SAN_PHAM(product_id)
);

-- 7. Dữ liệu mẫu KHACH_HANG
INSERT INTO KHACH_HANG VALUES
(1, 'Nguyen Van A', 'Ha Noi'),
(2, 'Tran Thi B', 'Da Nang'),
(3, 'Le Van C', 'HCM'),
(4, 'Pham Thi D', 'Ha Noi'),
(5, 'Hoang Van E', 'Can Tho');

-- 8. Dữ liệu mẫu SAN_PHAM
INSERT INTO SAN_PHAM VALUES
(101, 'Laptop Dell', 'Electronics', 20000000),
(102, 'iPhone 14', 'Electronics', 25000000),
(103, 'Tai nghe Bluetooth', 'Accessories', 1500000),
(104, 'Ban phim co', 'Accessories', 2000000),
(105, 'Man hinh 27 inch', 'Electronics', 7000000),
(106, 'Chuot khong day', 'Accessories', 800000);

-- 9. Dữ liệu mẫu DON_HANG
INSERT INTO DON_HANG VALUES
(1001, 1, '2024-01-10'),
(1002, 2, '2024-01-12'),
(1003, 1, '2024-01-15'),
(1004, 3, '2024-01-18'),
(1005, 4, '2024-01-20'),
(1006, 5, '2024-01-22');

-- 10. Dữ liệu mẫu CHI_TIET_DON_HANG
INSERT INTO CHI_TIET_DON_HANG VALUES
(1001, 101, 1),
(1001, 103, 2),

(1002, 102, 1),

(1003, 104, 1),
(1003, 103, 1),

(1004, 101, 1),
(1004, 106, 2),

(1005, 105, 1),

(1006, 103, 3),
(1006, 106, 1);


select * from san_pham sp1
where price > (select avg(price) `avg_price`from san_pham sp2);


select * from chi_tiet_don_hang
where quantity <(select avg(quantity) from chi_tiet_don_hang);


select b1.*,sum(b3.quantity*b4.price) `total`  from khach_hang b1
join don_hang b2 on b1.customer_id=b2.customer_id 
join chi_tiet_don_hang b3 on b2.order_id=b3.order_id
join san_pham b4 on b3.product_id=b4.product_id
group by b1.customer_id
order by total desc
limit 1;

select * from khach_hang b1
where (select * from don_hang b2 
where b1.customer_id=b2.customer_id );
;