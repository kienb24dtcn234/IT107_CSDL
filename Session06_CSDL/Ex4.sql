CREATE DATABASE product_stat_demo;
USE product_stat_demo;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO products VALUES
(1, 'Laptop', 20000000),
(2, 'Phone', 10000000),
(3, 'Tablet', 8000000),
(4, 'Headphone', 1500000),
(5, 'Mouse', 500000);

INSERT INTO orders VALUES
(101, '2025-01-01'),
(102, '2025-01-02'),
(103, '2025-01-03'),
(104, '2025-01-04'),
(105, '2025-01-05');

INSERT INTO order_items VALUES
(101, 1, 1),
(101, 4, 2),
(102, 2, 1),
(103, 3, 1),
(103, 5, 3),
(104, 1, 1),
(105, 2, 2);

SELECT p.product_id, p.product_name,
       SUM(oi.quantity) AS total_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

SELECT p.product_id, p.product_name,
       SUM(oi.quantity * p.price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

SELECT p.product_id, p.product_name,
       SUM(oi.quantity * p.price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity * p.price) > 5000000;



