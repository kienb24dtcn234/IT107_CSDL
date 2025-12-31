USE demo05;

ALTER TABLE products
ADD sold_quantity INT NOT NULL;

SELECT *
FROM products
ORDER BY sold_quantity DESC
LIMIT 10;

SELECT *
FROM products
ORDER BY sold_quantity DESC
LIMIT 5 OFFSET 10;

SELECT *
FROM products
WHERE price < 2000000
ORDER BY sold_quantity DESC;
