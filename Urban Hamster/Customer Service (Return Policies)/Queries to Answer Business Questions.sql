-- Specify hamster database
USE DATABASE hamster;


-- Preview data from each table
SELECT * FROM distribution_centers LIMIT 10;
SELECT * FROM events LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM order_items LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM users LIMIT 100;


-- What % of orders were returned? (This is the "return rate".)
-- Round to one decimal place.
SELECT
    COUNT(CASE WHEN status = 'Returned' THEN 1 END) AS "Returned Orders",
    COUNT(*) AS "All Orders",
    ROUND(("Returned Orders" / "All Orders" * 100), 1) AS "Return Rate"
FROM
    orders;


-- How does this return rate compare to the industry average?
-- (Not found in the database.)


-- Has the return rate increased between 2019 and 2023?
-- Use the "created_at" field to determine the year.
-- Round to one decimal place.
SELECT
    DISTINCT YEAR(created_at) AS "Year",
    COUNT(CASE WHEN status = 'Returned' THEN 1 END) AS "Returned Orders",
    COUNT(*) AS "All Orders",
    ROUND(("Returned Orders" / "All Orders" * 100), 1) AS "Return Rate"
FROM
    orders
GROUP BY
    "Year"
ORDER BY
    "Year";


-- Which three product categories have the highest return rates?
-- Assume that if an order is returned, all the items in the order were returned.
SELECT
    p.category,
    COUNT(CASE WHEN status = 'Returned' THEN 1 END) AS "Returned Orders",
    COUNT(*) AS "All Orders",
    ROUND(("Returned Orders" / "All Orders" * 100), 1) AS "Return Rate"
FROM
    orders o
INNER JOIN
    order_items i
ON 
    o.order_id = i.order_id
INNER JOIN
    products p
ON
    i.product_id = p.product_id
GROUP BY
    p.category
ORDER BY
    "Return Rate" DESC
LIMIT 3;


-- How much revenue was lost on returns?
-- Do not round.
-- When calculating, use the "sale_price" in the order items table.
SELECT
    SUM(i.sale_price) AS "Lost Revenue"
FROM
    orders o
INNER JOIN
    order_items i
ON 
    o.order_id = i.order_id
INNER JOIN
    products p
ON
    i.product_id = p.product_id
WHERE
    o.status = 'Returned';


-- We recognize that we have a strict return policy. How might that policy be
-- impacting our sales, reputation, and return rate? Given those impacts, what
-- changes would you recommend to that policy?
-- (Not found in the database.)