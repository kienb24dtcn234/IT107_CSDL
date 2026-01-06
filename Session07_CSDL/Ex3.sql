USE ecommerce_db;

INSERT INTO orders VALUES
(8, 1, '2025-02-01', 400000),
(9, 2, '2025-02-03', 900000),
(10, 3, '2025-02-05', 1200000),
(11, 4, '2025-02-07', 300000),
(12, 5, '2025-02-10', 2000000);

SELECT *
FROM orders
WHERE total_amount > (
    SELECT AVG(total_amount)
    FROM orders
);
