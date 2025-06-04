-- Create a new database.
CREATE DATABASE IF NOT EXISTS hamster;
USE DATABASE hamster;

-- Create tables to store our data.
CREATE OR REPLACE TABLE distribution_centers (
  id integer,
  name string,
  latitude float,
  longitude float  
);

CREATE OR REPLACE TABLE events (
  event_id integer,
  event_type string,
  session_id string,
  session_sequence integer,
  timestamp string,
  user_id integer,
  ip_address string,
  browser string,
  traffic_source string,
  uri string,
  city string,
  state string
);

CREATE OR REPLACE TABLE orders (
  order_id integer,
  user_id integer,
  status string,
  created_at timestamp,
  returned_at timestamp,
  shipped_at timestamp,
  delivered_at timestamp
);

CREATE OR REPLACE TABLE order_items (
  order_item_id integer,
  order_id integer,
  product_id integer,
  inventory_item_id integer,
  sale_price float
);

CREATE OR REPLACE TABLE products (
  product_id integer,
  category string,
  brand string,
  name string,
  department string,
  retail_price float,
  unit_cost float,
  sku string,
  distribution_center_id integer
);

CREATE OR REPLACE TABLE users (
  user_id integer,
  first_name string,
  last_name string,
  email string,
  age integer,
  gender string,
  street_adress string,
  city string,
  state string,
  country string,
  postal_code string,
  latitude float,
  longitude float,
  traffic_source string,
  created_at timestamp
);

-- Create a file format that reflects our files.
CREATE OR REPLACE FILE FORMAT hamster_csv
  type = 'CSV'
  skip_header = 1
  field_optionally_enclosed_by = '"'
  timestamp_format = 'YYYY-MM-DD HH24:MI:SS "UTC"';

-- Create a stage to identify the S3 bucket.
CREATE OR REPLACE STAGE hamster_stage
  url = 's3://urban-hamster/';

-- Copy data from files into the table.
COPY INTO distribution_centers
  FROM @hamster_stage/distribution_centers
  file_format = hamster_csv;

COPY INTO events
  FROM @hamster_stage/events
  file_format = hamster_csv;

COPY INTO orders
  FROM @hamster_stage/orders
  file_format = hamster_csv;

COPY INTO order_items
  FROM @hamster_stage/order_items
  file_format = hamster_csv;
  
COPY INTO products
  FROM @hamster_stage/products
  file_format = hamster_csv;

COPY INTO users
  FROM @hamster_stage/users
  file_format = hamster_csv;

-- Preview the table data.
SELECT * FROM distribution_centers LIMIT 10;
SELECT * FROM events LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM order_items LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM users LIMIT 100;
