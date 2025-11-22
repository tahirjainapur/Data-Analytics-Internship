CREATE DATABASE sales_db;
USE sales_db;

CREATE TABLE online_sales (
    order_id INT,
    order_date DATE,
    amount DECIMAL(10,2),
    product_id INT
);

SELECT * FROM online_sales
limit 5;

SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(amount) AS monthly_revenue,
    COUNT(DISTINCT order_id) AS order_volume
FROM online_sales
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY year, month;

SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(amount) AS monthly_revenue,
    COUNT(DISTINCT order_id) AS order_volume
FROM online_sales
WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY year, month
ORDER BY year, month;

SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(amount) AS monthly_revenue
FROM online_sales
GROUP BY year, month
ORDER BY monthly_revenue DESC
LIMIT 3;

