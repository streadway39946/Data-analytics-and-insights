-- Specify hamster database
USE DATABASE hamster;


-- How many known users do we have?
SELECT
    COUNT(DISTINCT USER_ID)
FROM users;


-- In what country do we have the most known users?
SELECT
    DISTINCT COUNTRY AS "Country",
    COUNT(*) OVER (PARTITION BY "Country") AS "User Count for Country"
FROM
    users
ORDER BY
    "User Count for Country"
DESC;


-- What % of all known users are from that particular country?
-- Round to one decimal place.
SELECT
    COUNT(CASE WHEN COUNTRY = 'China' THEN 1 END) AS "Users from China",
    COUNT(DISTINCT USER_ID) AS "Total Users",
    ROUND(("Users from China" / "Total Users" * 100), 1) AS "Percentage of Users from China"
FROM
    users;


-- What % of known US users are from Wisconsin?
-- Round to one decimal place.
SELECT
    COUNT(CASE WHEN COUNTRY = 'United States' AND STATE = 'Wisconsin' THEN 1 END) AS "Users from Wisconsin",
    COUNT(CASE WHEN COUNTRY = 'United States' THEN 1 END) AS "Users from the United States",
    ROUND(("Users from Wisconsin" / "Users from the United States" * 100), 1) AS "Percentage of US Users from Wisconsin"
FROM
    users;


-- What is the average age of our known users?
-- Round to one decimal place.
SELECT
    ROUND(AVG(AGE), 1) AS "Average Age of Our Known Users"
FROM
    users;


-- What % of our known users are female?
-- Round to one decimal place.
SELECT
    COUNT(CASE WHEN GENDER = 'F' THEN 1 END) AS "Female User Count",
    COUNT(DISTINCT USER_ID) AS "Total User Count",
    ROUND(("Female User Count" / "Total User Count" * 100), 1) AS "Percentage of Users That Are Female"
FROM
    users;
    

-- What was the largest traffic source of known users?
SELECT
    DISTINCT TRAFFIC_SOURCE AS "Traffic Source",
    COUNT(*) OVER (PARTITION BY "Traffic Source") AS "Count for Traffic Source"
FROM
    users
ORDER BY
    "Count for Traffic Source"
DESC;


-- How many new users registered in 2023?
SELECT
    DISTINCT YEAR(CREATED_AT) AS "Year",
    COUNT(*) OVER (PARTITION BY "Year") AS "# of New Users Registered for Year"
FROM
    users
WHERE
    "Year" = 2023
ORDER BY
    "Year";