CREATE DATABASE order_total_demo;
USE order_total_demo;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(255),
    city VARCHAR(255)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status ENUM('pending','completed','cancelled'),
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

INSERT INTO customers VALUES
(1, 'Nguyen Van An', 'Ha Noi'),
(2, 'Tran Thi Binh', 'Da Nang'),
(3, 'Le Van Cuong', 'Ho Chi Minh'),
(4, 'Pham Thi Dao', 'Ha Noi'),
(5, 'Hoang Van Em', 'Can Tho');

INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
(101, 1, '2025-01-05', 'completed'),
(102, 1, '2025-01-06', 'completed'),
(103, 2, '2025-01-07', 'completed'),
(104, 3, '2025-01-08', 'completed'),
(105, 3, '2025-01-09', 'completed');

INSERT INTO order_items VALUES
(1, 101, 1, 20000000),
(2, 101, 2, 1500000),
(3, 102, 1, 5000000),
(4, 103, 3, 1000000),
(5, 104, 2, 7000000),
(6, 105, 1, 3000000);



SELECT order_date, SUM(total_amount) AS daily_revenue
FROM orders
GROUP BY order_date;

SELECT order_date, COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_date;


SELECT order_date, SUM(total_amount) AS daily_revenue
FROM orders
GROUP BY order_date
HAVING SUM(total_amount) > 10000000;

