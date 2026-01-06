USE ecommerce_db;

INSERT INTO customers VALUES
(13, 'Hùng', 'hung@gmail.com'),
(14, 'Lan', 'lan@gmail.com'),
(15, 'Quân', 'quan@gmail.com'),
(16, 'Mai', 'mai@gmail.com'),
(17, 'Sơn', 'son@gmail.com');

INSERT INTO orders VALUES
(18, 13, '2025-04-01', 500000),
(19, 13, '2025-04-03', 1500000),
(20, 14, '2025-04-05', 800000),
(21, 15, '2025-04-07', 2000000),
(22, 15, '2025-04-09', 1000000),
(23, 16, '2025-04-11', 600000),
(24, 17, '2025-04-13', 400000);

SELECT *
FROM customers
WHERE id = (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING SUM(total_amount) = (
        SELECT MAX(total_spent)
        FROM (
            SELECT SUM(total_amount) AS total_spent
            FROM orders
            GROUP BY customer_id
        ) AS temp
    )
);
