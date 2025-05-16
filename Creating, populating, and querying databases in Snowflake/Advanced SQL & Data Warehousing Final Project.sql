-- SQL file for Advanced SQL & Data Warehousing course final project
-- File was originally created in Snowflake

-- Set your role as “sysadmin”.
USE ROLE sysadmin;


-- Create the Database

-- Create a new database called “forum”.
CREATE DATABASE IF NOT EXISTS forum;


-- Create the Warehouses

-- Create separate warehouses for loading and querying data:
   -- forum_loading_wh
   -- forum_query_wh
-- Use the following settings:
   -- Size – small
   -- Auto-Resume – enabled
   -- Auto-Suspend – 5 minutes (not 5 seconds)
CREATE OR REPLACE WAREHOUSE forum_loading_wh WITH
    WAREHOUSE_SIZE='SMALL'
    AUTO_RESUME = TRUE
    AUTO_SUSPEND = 300;

CREATE OR REPLACE WAREHOUSE forum_query_wh WITH
    WAREHOUSE_SIZE='SMALL'
    AUTO_RESUME = TRUE
    AUTO_SUSPEND = 300;


-- Create a Resource Monitor

-- Switch to the "accountadmin" role.
USE ROLE accountadmin;

-- Create a new resource monitor ("forum_rm"):
   -- Include a monthly quota of 100 credits.
   -- Ensure the start timestamp is immediate.
   -- Notify admins at 80% usage.
   -- Suspend but continue existing queries at 95% usage.
   -- Suspend and cancel existing queries at 100% usage.
CREATE OR REPLACE RESOURCE MONITOR forum_rm
WITH CREDIT_QUOTA = 100
     FREQUENCY = monthly
     START_TIMESTAMP = immediately
     TRIGGERS 
        ON 80 PERCENT DO NOTIFY
        ON 95 PERCENT DO SUSPEND
        ON 100 PERCENT DO SUSPEND_IMMEDIATE;

-- Apply the monitor to the "forum_query_wh" warehouse.
ALTER WAREHOUSE forum_query_wh
SET RESOURCE_MONITOR = forum_rm;

-- Set these query timeouts in "forum_query_wh":
   -- statement timeout: 20 minutes
   -- statement queued timeout: 10 minutes
ALTER WAREHOUSE forum_query_wh SET statement_timeout_in_seconds = 1200;

ALTER WAREHOUSE forum_query_wh SET statement_queued_timeout_in_seconds = 600;

-- Run a query to "show" all warehouses. 
-- (Store results in Excel.)
SHOW WAREHOUSES;


-- Create the Tables

-- Set the following context.
   -- role – sysadmin
   -- database – forum.public
   -- warehouse – forum_loading_wh
USE ROLE sysadmin;
USE forum.PUBLIC;
USE WAREHOUSE forum_loading_wh;

-- Create the database tables.
CREATE OR REPLACE TABLE badges (
    badge_id integer,
    user_id integer,
    name string,
    date datetime,
    class string
);

CREATE OR REPLACE TABLE post_history (
    post_history_id integer,
    post_history_type_id integer,
    post_id integer,
    creation_date datetime,
    user_id integer,
    text string,
    comment string
);

CREATE OR REPLACE TABLE post_links (
    post_link_id integer,
    creation_date datetime,
    post_id integer,
    related_post_id integer,
    link_type_id integer
);

CREATE OR REPLACE TABLE posts (
    post_id integer,
    post_type_id integer,
    creation_date datetime,
    score integer,
    view_count integer,
    title string,
    body string,
    owner_user_id integer,
    last_editor_user_id integer,
    last_edit_date datetime,
    last_activity_date datetime,
    tags string,
    answer_count integer,
    comment_count integer,
    accepted_answer_id integer,
    parent_id integer,
    closed_date datetime
);

CREATE OR REPLACE TABLE tags (
    tag_id integer,
    tag_name string,
    count integer,
    excerpt_post_id integer,
    wiki_post_id integer
);

CREATE OR REPLACE TABLE users (
    user_id integer,
    display_name string,
    about_me string,
    reputation integer,
    creation_date datetime,
    last_access_date datetime,
    views integer,
    up_votes integer,
    down_votes integer,
    account_id integer
);

CREATE OR REPLACE TABLE votes (
    vote_id integer,
    post_id integer,
    vote_type_id integer,
    creation_date date
);

CREATE OR REPLACE TABLE comments_json (v variant);


-- Prepare for Data Loading

-- Create a stage to access the data
CREATE OR REPLACE STAGE retrocomputingforum
    url = 's3://retrocomputing-forum/';

-- Then, list the files and properties of the files in staging.
LIST @retrocomputingforum;

DESCRIBE STAGE retrocomputingforum;

-- Create three separate file formats:
   -- forum_csv (comma-delimited)
   -- forum_pipe (pipe-delimited)
   -- forum_tab (tab-delimited)
-- Each file format should do the following:
   -- Skip the header row.
   -- Convert any blanks to SQL nulls.
   -- Note strings could be enclosed in double quotes
CREATE OR REPLACE FILE FORMAT forum_csv
    field_delimiter = ','
    skip_header = 1
    field_optionally_enclosed_by = '"'
    null_if = ('')
;

CREATE OR REPLACE FILE FORMAT forum_pipe
    field_delimiter = '|'
    skip_header = 1
    field_optionally_enclosed_by = '"'
    null_if = ('')
;

CREATE OR REPLACE FILE FORMAT forum_tab
    field_delimiter = '\t'
    skip_header = 1
    field_optionally_enclosed_by = '"'
    null_if = ('')
;


-- Load the Data

-- Load these tables using their respective files:
-- posts (comma-delimited)
COPY INTO posts
  FROM @retrocomputingforum/posts
  file_format = forum_csv;

-- post_history (comma-delimited)
COPY INTO post_history
  FROM @retrocomputingforum/post_history
  file_format = forum_csv;
  
-- post_links (comma-delimited)
COPY INTO post_links
  FROM @retrocomputingforum/post_links
  file_format = forum_csv;
   
-- tags (tab-delimited)
COPY INTO tags
  FROM @retrocomputingforum/tags_tab
  file_format = forum_tab;
  
-- users (comma-delimited)
COPY INTO users
  FROM @retrocomputingforum/users
  file_format = forum_csv;
  
-- votes (pipe-delimited)
COPY INTO votes
  FROM @retrocomputingforum/votes_pipe
  file_format = forum_pipe;

-- Load the badges table.
   -- Use the "badges.csv" file, which is comma-delimited.
   -- Reorder the columns, if necessary.
   -- Transform the badge classes using this list:
      -- 1 = 'Gold'
      -- 2 = 'Silver'
      -- 3 = 'Bronze'
COPY INTO badges
FROM (
    SELECT
    $1,
    $2,
    $3,
    $4,
    CASE
        WHEN $5 = '1' THEN 'Gold'
        WHEN $5 = '2' THEN 'Silver'
        WHEN $5 = '3' THEN 'Bronze'
        ELSE 'Unknown'
    END AS badge_classes,
    FROM @retrocomputingforum/badges.csv (file_format => forum_csv)
);

-- Then, query the entire table, but filter for gold badges.
-- (Store results in Excel.)
SELECT * FROM badges
WHERE class = 'Gold';

-- Load the comments file (JSON) into the "comments_json" table.
COPY INTO comments_json
  FROM @retrocomputingforum/comments
  file_format = (type = json strip_outer_array = true);

-- Then, create a view that structures this comments data, so it can be queried.
CREATE OR REPLACE VIEW comments_view AS
SELECT
    v:comment_id::int AS comment_id,
    v:creation_date::string AS creation_date,
    v:post_id::int AS post_id,
    v:score::int AS score,
    v:text::string AS text,
    v:user_id::int as user_id
FROM
    comments_json;

-- Counting the number of rows in the view
SELECT COUNT(*) FROM comments_view;

-- Previewing/checking 10 rows of the view
SELECT * FROM comments_view LIMIT 10;


-- Transform Data (After Loading)

-- Create a field called "years_of_activity" in the users table.
-- Create a clone of the users table. Call it "users_dev".
CREATE OR REPLACE TABLE users_dev 
CLONE users;

-- Add the column (an integer) to the development table.
ALTER TABLE users_dev
ADD COLUMN years_of_activity integer;

-- Populate the column using the calculation below.
-- TIMESTAMPDIFF(YEAR, creation_date, last_access_date)
UPDATE users_dev
SET years_of_activity = TIMESTAMPDIFF(YEAR, creation_date, last_access_date);
   
-- Move the development table to production.
ALTER TABLE users 
SWAP WITH users_dev;

-- Then, delete the development table.
DROP TABLE users_dev;

-- Then, query the updated users table.
   -- Only select users with ≥ 7 years of activity.
-- (Store the results in Excel.)
SELECT * FROM users
WHERE years_of_activity >= 7;


-- Create a New Role

-- Switch to the "useradmin" role.
USE ROLE useradmin;

-- Create a new role called "forum_query_role".
CREATE OR REPLACE ROLE forum_query_role;

-- Then, add this role to your account.
SET my_user = CURRENT_USER();
GRANT ROLE forum_query_role TO USER identifier($my_user);

-- Switch to the "securityadmin" role.
USE ROLE securityadmin;

-- Grant the following privileges to this new role:
-- Use and operate this warehouse: forum_query_wh
GRANT OPERATE, USAGE ON WAREHOUSE forum_query_wh TO ROLE forum_query_role;

-- Use this database and its schemas: forum
GRANT USAGE ON DATABASE forum TO ROLE forum_query_role;
GRANT USAGE ON ALL SCHEMAS IN DATABASE forum TO ROLE forum_query_role;

-- Read from all tables and views in that database *
GRANT SELECT ON ALL TABLES IN SCHEMA forum.public TO ROLE forum_query_role;
GRANT SELECT ON ALL VIEWS IN SCHEMA forum.public TO ROLE forum_query_role;

-- List all roles using the "show" function. 
-- (Store results in Excel.)
SHOW ROLES;

-- Switch to the new role and the “forum_query_wh” warehouse.
USE ROLE forum_query_role;
USE WAREHOUSE forum_query_wh;


-- Answer Business Questions

-- "What is the date range of forum posts?"
SELECT
    MIN(creation_date) AS "Earliest Post",
    MAX(creation_date) AS "Most Recent Post"
FROM
    posts;

-- "How many users do we have?"
SELECT
    COUNT(user_id) AS "Number of Users"
FROM
    users;

-- "Who are the top 5 users in terms of reputation?"
SELECT
    user_id,
    display_name,
    reputation
FROM
    users
ORDER BY
    reputation DESC
LIMIT
    5;

-- "Are we seeing a growth in the number of users year-over-year?" 
-- (Store results in Excel.)
SELECT
    YEAR(creation_date) AS "Year",
    COUNT(*) AS "Current Year User Registrations",
    LAG("Current Year User Registrations") OVER (ORDER BY "Year") AS "Previous Year User Registrations",
    "Current Year User Registrations" - "Previous Year User Registrations" AS "User Growth Year-Over-Year"
FROM
    users
GROUP BY
    "Year"
ORDER BY
    "Year";

-- "What % of users accessed the site recently?" 
-- (i.e. On or after 1/1/2023.)
WITH total_user_count AS (
    -- Get a total count of users, over the forum history
    SELECT 
        COUNT(*) AS total_num_of_users
    FROM 
        users
),
recent_user_count AS (
    SELECT
        COUNT(*) AS recent_user_num
    FROM
        users
    WHERE
        YEAR(last_access_date) >= 2023
),
recent_access_calc AS (
    SELECT
        ((r.recent_user_num / t.total_num_of_users) * 100) AS "Percentage of Users That Accessed The Site On or After 1/1/2023"
    FROM
        total_user_count t,
        recent_user_count r
)

SELECT * from recent_access_calc;

-- "What gold badge was earned the most?" 
-- (Store results in Excel.)
SELECT
    name AS "Badge Name",
    COUNT(*) AS "Earned Count"
FROM
    badges
WHERE
    class = 'Gold'
GROUP BY
    "Badge Name"
ORDER BY
    "Earned Count" DESC;

-- "Which 10 users earned the most badges?" 
-- (Store results in Excel.)
SELECT
    b.user_id AS "User ID",
    u.display_name AS "Username",
    COUNT(b.user_id) AS "User Badge Earned Count"
FROM
    badges b
INNER JOIN
    users u
ON
    b.user_id = u.user_id
GROUP BY
    "User ID",
    "Username"
ORDER BY
    "User Badge Earned Count" DESC LIMIT 10;

-- "How many posts were created per year?" 
-- (Store results in Excel.)
SELECT
    YEAR(creation_date) AS "Posted Year",
    COUNT(*) AS "Post Count"
FROM
    posts
GROUP BY
    "Posted Year";

-- "What % of posts have an accepted answer?"
   -- Posts with accepted answers have an "accepted_answer_id".
   -- Only consider posts with a "post_type_id" of 1 (i.e. questions).
SELECT
    COUNT(CASE WHEN accepted_answer_id IS NOT NULL THEN 1 ELSE NULL END) AS "Accepted Answer Post Count",
    COUNT(*) AS "Questions Post Count",
    (("Accepted Answer Post Count" / "Questions Post Count") * 100) AS "Percentage of Posts That Have An Accepted Answer"
FROM
    posts
WHERE
    post_type_id = 1;

-- "What % of posts received no answers?"
   -- Posts without answers have an "answer_count" of 0.
   -- Only consider posts with a "post_type_id" of 1 (i.e. questions).
SELECT
    COUNT(CASE WHEN answer_count = 0 THEN 1 ELSE NULL END) AS "Unanswered Post Count",
    COUNT(*) AS "Questions Post Count",
    (("Unanswered Post Count" / "Questions Post Count") * 100) AS "Percentage of Posts That Received No Answers"
FROM
    posts
WHERE
    post_type_id = 1;

-- "Which posts received the most updates?"
   -- You will need the "posts" and "post_history" tables.
   -- Only include posts with a non-null title.
   -- Only include the top 50 posts.
   -- (Store results in Excel.)

-- The updates can be found using a count of each post_id in post_history
-- Comment column in post history table serves as notes for these updates
SELECT
    h.post_id AS "Post ID",
    p.title AS "Post Title",
    COUNT(h.post_id) AS "Number of Updates"
FROM
    posts p
INNER JOIN
    post_history h
ON
    p.post_id = h.post_id
WHERE
    p.title IS NOT NULL
GROUP BY
    "Post ID",
    "Post Title"
ORDER BY
    "Number of Updates" DESC
LIMIT
    50;

-- "Which users contributed the most comments?"
   -- Only include the top 10 users with the most comments.
   -- (Store results in Excel.)
SELECT
    c.user_id AS "User ID",
    u.display_name AS "Username",
    COUNT(c.user_id) AS "Number of Comments Made by Account"
FROM
    comments_view c
INNER JOIN
    users u
ON
    c.user_id = u.user_id
GROUP BY
    "User ID",
    "Username"
ORDER BY
    "Number of Comments Made by Account" DESC
LIMIT
    10;

-- "How many distinct posts received a vote of 'spam' or 'offensive'?"
   -- "spam" is a vote_type_id of 12
   -- "offensive" is a vote_type_id of 4
SELECT
    COUNT(CASE WHEN vote_type_id = 12 THEN 1 ELSE NULL END) AS "Number of Spam Posts",
    COUNT(CASE WHEN vote_type_id = 4 THEN 1 ELSE NULL END) AS "Number of Offensive Posts",
FROM
    votes;