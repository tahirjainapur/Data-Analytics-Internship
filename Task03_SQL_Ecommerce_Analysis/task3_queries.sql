SELECT COUNT(*) FROM orders;
SELECT * FROM orders LIMIT 10;

SELECT DISTINCT order_date FROM orders LIMIT 20;


UPDATE orders
SET order_date = STR_TO_DATE(order_date, '%Y-%m-%d %H:%i:%s')
WHERE order_date IS NOT NULL;

SELECT DISTINCT order_date FROM orders LIMIT 20;

CREATE TABLE orders_clean AS
SELECT *
FROM orders
WHERE price IS NOT NULL
  AND quantity IS NOT NULL;
  
  SELECT COUNT(*) FROM orders_clean;
  
  CREATE INDEX idx_oc_customer ON orders_clean(customer_id);
CREATE INDEX idx_oc_product  ON orders_clean(product_id);
CREATE INDEX idx_oc_orderdate ON orders_clean(order_date);
CREATE INDEX idx_oc_category ON orders_clean(category_id);

ALTER TABLE orders_clean
ADD COLUMN order_date_tmp DATETIME;
UPDATE orders_clean
SET order_date_tmp = STR_TO_DATE(order_date, '%Y-%m-%d %H:%i:%s');

ALTER TABLE orders_clean
DROP COLUMN order_date;

ALTER TABLE orders_clean
CHANGE order_date_tmp order_date DATETIME;

CREATE INDEX idx_oc_orderdate ON orders_clean(order_date);

SHOW INDEX FROM orders_clean;


USE task3;

DROP TABLE IF EXISTS customers;
CREATE TABLE customers AS
SELECT DISTINCT
  customer_id,
  COALESCE(gender,'Unknown') AS gender,
  age,
  city
FROM orders_clean;

DROP TABLE IF EXISTS products;
CREATE TABLE products AS
SELECT DISTINCT
  product_id,
  product_name,
  category_id,
  category_name
FROM orders_clean;

SELECT 'customers_sample' AS info; SELECT * FROM customers LIMIT 5;
SELECT 'products_sample' AS info; SELECT * FROM products LIMIT 5;

SELECT ROUND(SUM(quantity * price), 2) AS total_revenue
FROM orders_clean;

SELECT ROUND(AVG(user_total), 2) AS avg_revenue_per_user
FROM (
  SELECT customer_id, SUM(quantity * price) AS user_total
  FROM orders_clean
  GROUP BY customer_id
) AS t;

SELECT DATE_FORMAT(order_date, '%Y-%m') AS year_month,
       ROUND(SUM(quantity * price), 2) AS revenue
FROM orders_clean
GROUP BY year_month
ORDER BY year_month;

SELECT p.product_id, p.product_name, ROUND(SUM(o.quantity * o.price), 2) AS product_revenue
FROM orders_clean o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY product_revenue DESC
LIMIT 10;

SELECT category_id, category_name, ROUND(SUM(quantity * price), 2) AS revenue
FROM orders_clean
GROUP BY category_id, category_name
ORDER BY revenue DESC;

SELECT category_name,
       ROUND(AVG(review_score), 2) AS avg_rating,
       COUNT(review_score) AS rating_count
FROM orders_clean
WHERE review_score IS NOT NULL
GROUP BY category_name
ORDER BY avg_rating DESC;

SELECT customer_id, ROUND(SUM(quantity * price), 2) AS total_spend
FROM orders_clean
GROUP BY customer_id
HAVING total_spend > 500
ORDER BY total_spend DESC;

SELECT o.order_date, o.customer_id, c.city, p.product_name, o.quantity, o.price
FROM orders_clean o
INNER JOIN customers c ON c.customer_id = o.customer_id
INNER JOIN products p ON p.product_id = o.product_id
LIMIT 20;

SELECT c.customer_id, c.city, o.order_date, o.quantity, o.price
FROM customers c
LEFT JOIN orders_clean o ON o.customer_id = c.customer_id
LIMIT 20;

SELECT o.order_date, o.customer_id, o.product_id, p.product_name, o.quantity
FROM orders_clean o
RIGHT JOIN products p ON p.product_id = o.product_id
LIMIT 20;

SELECT customer_id, total_spend
FROM (
  SELECT customer_id, SUM(quantity * price) AS total_spend
  FROM orders_clean
  GROUP BY customer_id
) AS t
WHERE total_spend > (
  SELECT AVG(total_spend) FROM (
    SELECT SUM(quantity * price) AS total_spend
    FROM orders_clean
    GROUP BY customer_id
  ) AS s
);

SELECT p.product_id, p.product_name,
  (
    SELECT COUNT(DISTINCT o2.customer_id)
    FROM orders_clean o2
    WHERE o2.product_id = p.product_id
      AND (o2.quantity * o2.price) > 100
  ) AS big_spenders_count
FROM products p
ORDER BY big_spenders_count DESC
LIMIT 10;

CREATE OR REPLACE VIEW vw_customer_spend AS
SELECT customer_id,
       COUNT(*) AS orders_count,
       ROUND(SUM(quantity * price), 2) AS total_spend,
       ROUND(AVG(quantity * price), 2) AS avg_order_value
FROM orders_clean
GROUP BY customer_id;

SELECT * FROM vw_customer_spend
ORDER BY total_spend DESC
LIMIT 10;

EXPLAIN SELECT p.product_id, p.product_name, ROUND(SUM(o.quantity * o.price), 2) AS product_revenue
FROM orders_clean o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY product_revenue DESC
LIMIT 10;

SELECT customer_id, COALESCE(gender, 'Unknown') AS gender, age, city
FROM customers
LIMIT 10;

SELECT COALESCE(gender,'Unknown') AS gender, COUNT(*) AS cnt
FROM customers
GROUP BY COALESCE(gender,'Unknown')
ORDER BY cnt DESC;

CREATE OR REPLACE VIEW vw_customer_spend AS
SELECT 
    customer_id,
    COUNT(*) AS orders_count,
    ROUND(SUM(quantity * price), 2) AS total_spend,
    ROUND(AVG(quantity * price), 2) AS avg_order_value
FROM orders_clean
GROUP BY customer_id;
