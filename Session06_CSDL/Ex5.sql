CREATE DATABASE vip_customer_demo;
USE vip_customer_demo;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(255),
    city VARCHAR(255)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers VALUES
(1, 'Nguyen Van An', 'Ha Noi'),
(2, 'Tran Thi Binh', 'Da Nang'),
(3, 'Le Van Cuong', 'Ho Chi Minh'),
(4, 'Pham Thi Dao', 'Ha Noi'),
(5, 'Hoang Van Em', 'Can Tho');

INSERT INTO orders VALUES
(101, 1, '2025-01-01', 5000000),
(102, 1, '2025-01-05', 4000000),
(103, 1, '2025-01-10', 3000000),

(104, 2, '2025-01-02', 2000000),
(105, 2, '2025-01-06', 2500000),

(106, 3, '2025-01-03', 6000000),
(107, 3, '2025-01-07', 7000000),
(108, 3, '2025-01-12', 3000000),

(109, 4, '2025-01-04', 1500000),

(110, 5, '2025-01-08', 8000000),
(111, 5, '2025-01-15', 4000000),
(112, 5, '2025-01-20', 3000000);

SELECT 
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
HAVING 
    COUNT(o.order_id) >= 3
    AND SUM(o.total_amount) > 10000000
ORDER BY total_spent DESC;



