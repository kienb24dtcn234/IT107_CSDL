DROP DATABASE IF EXISTS online_sales_db;
CREATE DATABASE online_sales_db;
USE online_sales_db;



DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
  customer_id   INT PRIMARY KEY AUTO_INCREMENT,
  customer_name VARCHAR(100) NOT NULL,
  email         VARCHAR(100) NOT NULL UNIQUE,
  phone         VARCHAR(10)  NOT NULL UNIQUE
);


CREATE TABLE categories (
  category_id   INT PRIMARY KEY AUTO_INCREMENT,
  category_name VARCHAR(255) NOT NULL UNIQUE
);


CREATE TABLE products (
  product_id   INT PRIMARY KEY AUTO_INCREMENT,
  product_name VARCHAR(255) NOT NULL UNIQUE,
  price        DECIMAL(10,2) NOT NULL CHECK (price > 0),
  category_id  INT NOT NULL,
  CONSTRAINT fk_products_categories
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE orders (
  order_id     INT PRIMARY KEY AUTO_INCREMENT,
  customer_id  INT NOT NULL,
  order_date   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status       ENUM('Pending','Completed','Cancel') NOT NULL DEFAULT 'Pending',
  CONSTRAINT fk_orders_customers
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);


CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id      INT NOT NULL,
  product_id    INT NOT NULL,
  quantity      INT NOT NULL CHECK (quantity > 0),
  CONSTRAINT fk_orderitems_orders
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_orderitems_products
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);



INSERT INTO categories (category_name) VALUES
('Điện thoại'),
('Laptop'),
('Phụ kiện'),
('Tai nghe'),
('Tablet');


INSERT INTO customers (customer_name, email, phone) VALUES
('Nguyễn An',  'an@gmail.com',  '0900000001'),
('Trần Bình',  'binh@gmail.com','0900000002'),
('Lê Chi',     'chi@gmail.com', '0900000003'),
('Phạm Dũng',  'dung@gmail.com','0900000004'),
('Hoàng Em',   'em@gmail.com',  '0900000005');


INSERT INTO products (product_name, price, category_id) VALUES
('iPhone 15',        2500.00, 1),
('Samsung S24',      2200.00, 1),
('Xiaomi 14',        1500.00, 1),
('MacBook Air M2',   1800.00, 2),
('Dell XPS 13',      2000.00, 2),
('Sạc nhanh 65W',      35.00, 3),
('Cáp USB-C',          10.00, 3),
('AirPods Pro',       249.00, 4),
('Sony WH-1000XM5',   399.00, 4),
('iPad Air',          699.00, 5);


INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2026-01-01 10:00:00', 'Completed'),
(1, '2026-01-02 11:00:00', 'Pending'),
(2, '2026-01-02 09:30:00', 'Completed'),
(3, '2026-01-03 14:20:00', 'Cancel'),
(3, '2026-01-04 08:10:00', 'Completed'),
(4, '2026-01-04 16:45:00', 'Completed');


INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),   -- iPhone 15
(1, 6, 2),   -- sạc
(1, 7, 3),   -- cáp
(2, 3, 1),   -- Xiaomi 14
(2, 8, 1),   -- AirPods
(3, 4, 1),   -- MBA M2
(3, 7, 2),   -- cáp
(4, 2, 1),   -- S24 (order cancel)
(5, 10, 1),  -- iPad Air
(5, 6, 1),   -- sạc
(6, 5, 1),   -- Dell XPS 13
(6, 9, 2);   -- Sony XM5


-- PHẦN A – TRUY VẤN DỮ LIỆU CƠ BẢN


-- A1) Lấy danh sách tất cả danh mục sản phẩm trong hệ thống.
SELECT category_id, category_name
FROM categories;

-- A2) Lấy danh sách đơn hàng có trạng thái là COMPLETED
SELECT order_id, customer_id, order_date, status
FROM orders
WHERE status = 'Completed';

-- A3) Lấy danh sách sản phẩm và sắp xếp theo giá giảm dần
SELECT product_id, product_name, price, category_id
FROM products
ORDER BY price DESC;

-- A4) Lấy 5 sản phẩm có giá cao nhất, bỏ qua 2 sản phẩm đầu tiên
SELECT product_id, product_name, price
FROM products
ORDER BY price DESC
LIMIT 5 OFFSET 2;

-- PHẦN B – TRUY VẤN NÂNG CAO
-- B1) Lấy danh sách sản phẩm kèm tên danh mục
SELECT
  p.product_id,
  p.product_name,
  p.price,
  c.category_name
FROM products p
JOIN categories c ON c.category_id = p.category_id;

-- B2) Lấy danh sách đơn hàng gồm: order_id, order_date, customer_name, status
SELECT
  o.order_id,
  o.order_date,
  cu.customer_name,
  o.status
FROM orders o
JOIN customers cu ON cu.customer_id = o.customer_id;

-- B3) Tính tổng số lượng sản phẩm trong từng đơn hàng
SELECT
  o.order_id,
  SUM(oi.quantity) AS total_quantity
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id;

-- B4) Thống kê số đơn hàng của mỗi khách hàng
SELECT
  cu.customer_id,
  cu.customer_name,
  COUNT(o.order_id) AS total_orders
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.customer_name;

-- B5) Lấy danh sách khách hàng có tổng số đơn hàng ≥ 2
SELECT
  cu.customer_id,
  cu.customer_name,
  COUNT(o.order_id) AS total_orders
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.customer_name
HAVING COUNT(o.order_id) >= 2;

-- B6) Thống kê giá trung bình, thấp nhất và cao nhất của sản phẩm theo danh mục
SELECT
  c.category_id,
  c.category_name,
  AVG(p.price) AS avg_price,
  MIN(p.price) AS min_price,
  MAX(p.price) AS max_price
FROM categories c
JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name;

-- PHẦN C – TRUY VẤN LỒNG (SUBQUERY)

-- C1) Sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm
SELECT product_id, product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- C2) Khách hàng đã từng đặt ít nhất một đơn hàng
SELECT customer_id, customer_name, email, phone
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders);

-- C3) Đơn hàng có tổng số lượng sản phẩm lớn nhất
SELECT
  t.order_id,
  t.total_quantity
FROM (
  SELECT
    order_id,
    SUM(quantity) AS total_quantity
  FROM order_items
  GROUP BY order_id
) t
WHERE t.total_quantity = (
  SELECT MAX(x.total_quantity)
  FROM (
    SELECT SUM(quantity) AS total_quantity
    FROM order_items
    GROUP BY order_id
  ) x
);

-- C4) Tên khách hàng đã mua SP thuộc danh mục có giá trung bình cao nhất
SELECT DISTINCT
  cu.customer_id,
  cu.customer_name
FROM customers cu
JOIN orders o       ON o.customer_id = cu.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
WHERE p.category_id = (
  SELECT category_id
  FROM (
    SELECT category_id, AVG(price) AS avg_price
    FROM products
    GROUP BY category_id
  ) tmp
  ORDER BY avg_price DESC
  LIMIT 1
);

-- C5) Từ bảng tạm (subquery), thống kê tổng số lượng sản phẩm đã mua của từng khách hàng
SELECT
  t.customer_id,
  t.customer_name,
  SUM(t.quantity) AS total_quantity_bought
FROM (
  SELECT
    cu.customer_id,
    cu.customer_name,
    oi.quantity
  FROM customers cu
  JOIN orders o       ON o.customer_id = cu.customer_id
  JOIN order_items oi ON oi.order_id = o.order_id
) t
GROUP BY t.customer_id, t.customer_name;

-- C6) Lấy sản phẩm có giá cao nhất (subquery chỉ trả về 1 giá trị, không lỗi nhiều dòng)
SELECT product_id, product_name, price
FROM products
WHERE price = (SELECT MAX(price) FROM products);

