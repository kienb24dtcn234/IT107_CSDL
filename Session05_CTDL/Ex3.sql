USE demo05;

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    order_date DATE NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') NOT NULL
);

SELECT *
FROM orders
WHERE status = 'completed';

SELECT *
FROM orders
WHERE total_amount > 5000000;

SELECT *
FROM orders
ORDER BY order_date DESC
LIMIT 5;

SELECT *
FROM orders
WHERE status = 'completed'
ORDER BY total_amount DESC;
