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

-- (Not found in the database, but answered below in a text block.)

-- According to the National Retail Federation, in 2023 the total return rate for the retail industry as a percentage of sales was 14.5% ("2023 Consumer Returns"). 
-- Urban Hamster's overall return rate is 10.0%, and in 2023 it was 10.3%. 
-- These are both lower than the industry average.


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

-- (Not found in the database, but answered below in a text block.)

-- Urban Hamster's return policy is strict compared to competitors like Abercrombie & Fitch and American Eagle. Urban Hamster's policy says items must be returned within 14 days of receipt. 
-- Abercrombie & Fitch specifies 30 days ("Abercrombie"), while American Eagle states 30 days for a full refund or 60 days for a merchandise credit ("American").

-- A shorter time frame for accepting returns might discourage potential customers from buying Urban Hamster products in the first place, decreasing sales. Customers who do purchase products might also not be aware that Urban Hamster only accepts returns within 14 days, and this may lead to dissatisfaction and a hit to Urban Hamster's reputation. 
-- However, this likely has an influence on the lower return rate compared to the retail market as a whole, which is stated by the National Retail Foundation ("2023 Consumer Returns").

-- I am recommending to extend the time frame of accepting returns from 14 to 30 days, to match those of competitors like Abercrombie & Fitch and American Eagle. 
-- After extending the policy to 30 days, monitor sales, return rates, and customer reviews for changes.
