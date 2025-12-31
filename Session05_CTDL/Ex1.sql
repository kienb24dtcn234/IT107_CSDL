USE demo05;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    status ENUM('active', 'inactive') NOT NULL
);


SELECT *
FROM products;


SELECT *
FROM products
WHERE status = 'active';


SELECT *
FROM products
WHERE price > 1000000;


SELECT *
FROM products
WHERE status = 'active'
ORDER BY price ASC;
