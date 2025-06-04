-- Specify hamster database
USE DATABASE hamster;


-- Preview data from each table
SELECT * FROM distribution_centers LIMIT 10;
SELECT * FROM events LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM order_items LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM users LIMIT 100;


-- Which table has information about customer returns?
-- Within that table, which column(s) can help us identify returns?
SELECT *
FROM orders
WHERE status = 'Returned'
LIMIT 10;


-- How many years of orders are in this data?
-- (Use the "created_at" date. Round to the nearest whole year.)
SELECT 
    MAX(CREATED_AT) AS "Most Recent Date",
    MIN(CREATED_AT) AS "Earliest Date",
    DATEDIFF(year, "Earliest Date", "Most Recent Date") AS "Years of Orders"
FROM
    orders;


-- How many orders are in the data?
SELECT COUNT (DISTINCT ORDER_ID)
FROM orders;


-- Are there any duplicate order IDs?
SELECT COUNT(ORDER_ID)
FROM orders;


-- What were our orders and cumulative orders by year and month?
-- Enter ONLY the cumulative orders by the end of 2019 below.
SELECT
    DISTINCT MONTH(CREATED_AT) AS "Month",
    YEAR(CREATED_AT) AS "Year",
    COUNT(*) OVER (PARTITION BY "Month") AS "Monthly Count",
    COUNT(*) OVER (ORDER BY "Month") AS "Cumulative Count for 2019"
FROM
    orders
WHERE
    "Year" = '2019'
ORDER BY
    "Month",
    "Year";


-- How many unique users had an order?
-- (It won't be every user in the users table.)
SELECT COUNT(DISTINCT USER_ID)
FROM orders;


-- How many orders were returned?
SELECT COUNT(DISTINCT ORDER_ID)
FROM orders
WHERE status = 'Returned';


-- What are the order "statuses" in the data?
-- (“Processing” is one example of a status.)
SELECT DISTINCT STATUS
FROM orders
ORDER BY STATUS;


-- What are the counts of orders within each "status"?
-- (Enter ONLY the count of "cancelled" orders below.)
SELECT
    DISTINCT STATUS,
    COUNT(ORDER_ID) OVER (PARTITION BY STATUS) AS "Order Count With Status"
FROM
    orders
ORDER BY
    STATUS;


-- Do any orders have a return date that is before their shipment date?
-- (This could indicate a data quality issue!)
SELECT *
FROM
    orders
WHERE
    DATEDIFF(day, returned_at, shipped_at) > 0;