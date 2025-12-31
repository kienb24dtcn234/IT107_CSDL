USE demo05;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    city VARCHAR(255),
    status ENUM('active', 'inactive') NOT NULL
);


SELECT *
FROM customers;


SELECT *
FROM customers
WHERE city = 'TP.HCM';


SELECT *
FROM customers
WHERE status = 'active' AND city = 'Hà Nội';


SELECT *
FROM customers
ORDER BY full_name ASC;
