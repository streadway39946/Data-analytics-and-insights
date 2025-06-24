-- Specify hamster database
USE DATABASE hamster;


-- What % of registered (or "known") users had a purchase?
-- Round to one decimal place.
SELECT
    COUNT(DISTINCT O.USER_ID) AS "Users That Made A Purchase",
    COUNT(DISTINCT U.USER_ID) AS "Total Users",
    ROUND(("Users That Made A Purchase" / "Total Users" * 100), 1) AS "% of Users That Made A Purchase"
FROM
    USERS U
LEFT JOIN
    ORDERS O
ON
    U.USER_ID = O.USER_ID;
    


-- Who were our highest-spending customers?
-- Select three.
-- Their “user_id” is acceptable. (The name is not required.)
-- Include all orders in the calculation, even if they were returned or canceled.
SELECT
    DISTINCT(U.USER_ID) AS "User ID",
    SUM(I.SALE_PRICE) OVER (PARTITION BY "User ID") AS "Amount Customer Spent"
FROM
    USERS U
INNER JOIN
    ORDERS O
ON
    U.USER_ID = O.USER_ID
INNER JOIN
    ORDER_ITEMS I
ON
    O.ORDER_ID = I.ORDER_ID
ORDER BY
    "Amount Customer Spent"
DESC
LIMIT
    3;


-- Are males or females spending more per order?
-- Include all orders in the calculation, even if they were returned or canceled.
-- HINT: You will need the "users", "orders", and "order_items" tables.
SELECT 
    U.GENDER,
    COUNT(DISTINCT U.USER_ID) AS USERS,
    COUNT(DISTINCT O.ORDER_ID) AS ORDERS,
    SUM(I.SALE_PRICE) AS SPEND,
    (SPEND / USERS) AS SPEND_PER_USER,
    (SPEND / ORDERS) AS SPEND_PER_ORDER,
    (ORDERS / USERS) AS ORDERS_PER_USER
FROM
	ORDERS O
INNER JOIN 
	ORDER_ITEMS I ON O.ORDER_ID = O.ORDER_ID
INNER JOIN 
	USERS U ON U.USER_ID = O.USER_ID
GROUP BY 
	U.GENDER
ORDER BY 
	SPEND_PER_ORDER DESC;



-- What demographic segments spent the most total money?
-- Choose two.
-- Include all orders in the calculation, even if they were returned or canceled.
SELECT
    DISTINCT(U.GENDER) AS "Gender",
    CASE
        WHEN U.AGE >= 78 THEN 'Silent Generation'
        WHEN U.AGE >= 58 AND U.AGE <= 77 THEN 'Baby Boomer'
        WHEN U.AGE >= 42 AND U.AGE <= 57 THEN 'Generation X'
        WHEN U.AGE >= 26 AND U.AGE <= 41 THEN 'Millennial'
        WHEN U.AGE >= 10 AND U.AGE <= 25 THEN 'Generation Z'
        ELSE 'Generation Alpha'
    END AS "Generation",
    SUM(I.SALE_PRICE) OVER(PARTITION BY "Gender", "Generation") AS "Total Spend"
FROM
    USERS U
INNER JOIN
    ORDERS O
ON
    U.USER_ID = O.USER_ID
INNER JOIN
    ORDER_ITEMS I
ON
    O.ORDER_ID = I.ORDER_ID
ORDER BY
    "Total Spend" DESC;
    


-- What demographic segments have the most orders?
-- Choose two.
-- Include all orders in the calculation, even if they were returned or canceled.
SELECT
    DISTINCT(U.GENDER) AS "Gender",
    CASE
        WHEN U.AGE >= 78 THEN 'Silent Generation'
        WHEN U.AGE >= 58 AND U.AGE <= 77 THEN 'Baby Boomer'
        WHEN U.AGE >= 42 AND U.AGE <= 57 THEN 'Generation X'
        WHEN U.AGE >= 26 AND U.AGE <= 41 THEN 'Millennial'
        WHEN U.AGE >= 10 AND U.AGE <= 25 THEN 'Generation Z'
        ELSE 'Generation Alpha'
    END AS "Generation",
    COUNT(O.ORDER_ID) OVER(PARTITION BY "Gender", "Generation") AS "Order Count"
FROM
    USERS U
INNER JOIN
    ORDERS O
ON
    U.USER_ID = O.USER_ID
ORDER BY
    "Order Count" DESC;


-- Within each segment, which two product categories are most popular?
-- Measure popularity by the number of orders that include that product category.
-- Include all orders in the calculation, even if they were returned or canceled.
SELECT
    DISTINCT(U.GENDER) AS "Gender",
    CASE
        WHEN U.AGE >= 78 THEN 'Silent Generation'
        WHEN U.AGE >= 58 AND U.AGE <= 77 THEN 'Baby Boomer'
        WHEN U.AGE >= 42 AND U.AGE <= 57 THEN 'Generation X'
        WHEN U.AGE >= 26 AND U.AGE <= 41 THEN 'Millennial'
        WHEN U.AGE >= 10 AND U.AGE <= 25 THEN 'Generation Z'
        ELSE 'Generation Alpha'
    END AS "Generation",
    P.CATEGORY AS "Category",
    COUNT(P.CATEGORY) OVER(PARTITION BY "Gender", "Generation", "Category") AS "Order Count by Category"
FROM
    USERS U
INNER JOIN
    ORDERS O
ON
    U.USER_ID = O.USER_ID
INNER JOIN
    ORDER_ITEMS I
ON
    O.ORDER_ID = I.ORDER_ID
INNER JOIN
    PRODUCTS P
ON
    I.PRODUCT_ID = P.PRODUCT_ID
ORDER BY
    "Gender",
    "Generation",
    "Order Count by Category" DESC;


-- Given your understanding of our customers and their purchasing patterns, 
-- how do you recommend we market to different customer segments?

-- Counting orders by individual product for each gender/generation segment
SELECT
    DISTINCT(U.GENDER) AS "Gender",
    CASE
        WHEN U.AGE >= 78 THEN 'Silent Generation'
        WHEN U.AGE >= 58 AND U.AGE <= 77 THEN 'Baby Boomer'
        WHEN U.AGE >= 42 AND U.AGE <= 57 THEN 'Generation X'
        WHEN U.AGE >= 26 AND U.AGE <= 41 THEN 'Millennial'
        WHEN U.AGE >= 10 AND U.AGE <= 25 THEN 'Generation Z'
        ELSE 'Generation Alpha'
    END AS "Generation",
    P.NAME AS "Product Name",
    P.CATEGORY AS "Category",
    COUNT(P.CATEGORY) OVER(PARTITION BY "Gender", "Generation", "Product Name") AS "Order Count by Product Name"
FROM
    USERS U
INNER JOIN
    ORDERS O
ON
    U.USER_ID = O.USER_ID
INNER JOIN
    ORDER_ITEMS I
ON
    O.ORDER_ID = I.ORDER_ID
INNER JOIN
    PRODUCTS P
ON
    I.PRODUCT_ID = P.PRODUCT_ID
ORDER BY
    "Order Count by Product Name" DESC;


-- Wrangler jeans are coming up pretty often for men.
-- How many of the top 10 products purchased by men are a Wrangler jean product?
-- Counting orders by individual product for each gender/generation segment
SELECT
    DISTINCT(U.GENDER) AS "Gender",
    CASE
        WHEN U.AGE >= 78 THEN 'Silent Generation'
        WHEN U.AGE >= 58 AND U.AGE <= 77 THEN 'Baby Boomer'
        WHEN U.AGE >= 42 AND U.AGE <= 57 THEN 'Generation X'
        WHEN U.AGE >= 26 AND U.AGE <= 41 THEN 'Millennial'
        WHEN U.AGE >= 10 AND U.AGE <= 25 THEN 'Generation Z'
        ELSE 'Generation Alpha'
    END AS "Generation",
    P.NAME AS "Product Name",
    P.CATEGORY AS "Category",
    COUNT(P.CATEGORY) OVER(PARTITION BY "Gender", "Generation", "Product Name") AS "Order Count by Product Name",
FROM
    USERS U
INNER JOIN
    ORDERS O
ON
    U.USER_ID = O.USER_ID
INNER JOIN
    ORDER_ITEMS I
ON
    O.ORDER_ID = I.ORDER_ID
INNER JOIN
    PRODUCTS P
ON
    I.PRODUCT_ID = P.PRODUCT_ID
WHERE
    "Gender" = 'M'
ORDER BY
    "Order Count by Product Name" DESC
LIMIT
    10;


-- The top four purchase categories for our segments were women of different generations purchasing intimates.
-- Are there specific products or brands being purchased more frequently, and by specific segments?
SELECT
    DISTINCT(U.GENDER) AS "Gender",
    CASE
        WHEN U.AGE >= 78 THEN 'Silent Generation'
        WHEN U.AGE >= 58 AND U.AGE <= 77 THEN 'Baby Boomer'
        WHEN U.AGE >= 42 AND U.AGE <= 57 THEN 'Generation X'
        WHEN U.AGE >= 26 AND U.AGE <= 41 THEN 'Millennial'
        WHEN U.AGE >= 10 AND U.AGE <= 25 THEN 'Generation Z'
        ELSE 'Generation Alpha'
    END AS "Generation",
    P.NAME AS "Product Name",
    P.CATEGORY AS "Category",
    COUNT(P.CATEGORY) OVER(PARTITION BY "Gender", "Generation", "Product Name") AS "Order Count by Product Name",
FROM
    USERS U
INNER JOIN
    ORDERS O
ON
    U.USER_ID = O.USER_ID
INNER JOIN
    ORDER_ITEMS I
ON
    O.ORDER_ID = I.ORDER_ID
INNER JOIN
    PRODUCTS P
ON
    I.PRODUCT_ID = P.PRODUCT_ID
WHERE
    "Gender" = 'F'
AND
    "Category" = 'Intimates'
ORDER BY
    "Order Count by Product Name" DESC
LIMIT
    25;