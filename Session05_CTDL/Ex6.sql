USE demo05;

SELECT *
FROM products
WHERE status = 'active'
  AND price >= 1000000
  AND price <= 3000000
ORDER BY price ASC
LIMIT 10 OFFSET 0;

SELECT *
FROM products
WHERE status = 'active'
  AND price >= 1000000
  AND price <= 3000000
ORDER BY price ASC
LIMIT 10 OFFSET 10;
