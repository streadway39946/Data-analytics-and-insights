-- Specify hamster database
USE DATABASE hamster;

-- Load these product reviews in the hamster database.
-- Put them in a table called "product_reviews_sample". (This was done through Snowflake.)


-- Query 5 rows of the data, to see what it looks like
SELECT
    *
FROM
    PRODUCT_REVIEWS_SAMPLE
LIMIT
    5;
    

-- Create a field to store a translation of the reviews into English.
ALTER TABLE 
    PRODUCT_REVIEWS_SAMPLE
ADD COLUMN 
    TRANSLATION VARCHAR(16777216);


-- Translate the fields from the appropriate language into English.
-- Store the results of the translation in the new field.
-- First, translate the Spanish language reviews.
UPDATE
    PRODUCT_REVIEWS_SAMPLE
SET
    TRANSLATION = SNOWFLAKE.CORTEX.TRANSLATE(REVIEW, 'es', 'en')
WHERE
    LANGUAGE = 'Spanish';


-- Then, translate the Korean language reviews.
UPDATE
    PRODUCT_REVIEWS_SAMPLE
SET
    TRANSLATION = SNOWFLAKE.CORTEX.TRANSLATE(REVIEW, 'ko', 'en')
WHERE
    LANGUAGE = 'Korean';


-- Check the entries in the translation field
SELECT * FROM PRODUCT_REVIEWS_SAMPLE;


-- Create a field to store a sentiment score for each review.
ALTER TABLE 
    PRODUCT_REVIEWS_SAMPLE
ADD COLUMN 
    SENTIMENT FLOAT;


-- Calculate the sentiment scores for each review.
-- Store the results of the sentiment in the new field.
UPDATE
    PRODUCT_REVIEWS_SAMPLE
SET
    SENTIMENT = SNOWFLAKE.CORTEX.SENTIMENT(TRANSLATION);


-- Check the entries in the sentiment field
-- This queries the entire updated product_reviews_sample table
SELECT * FROM PRODUCT_REVIEWS_SAMPLE;


-- Summarize reviews with negative feedback.
-- In other words, what are the common issues?
  -- Numerous mentions of the color being different from what was expected
  -- Several mentions of the zipper, either malfunctioning or being uncomfortable
  -- A couple of reviews mention size, one says it was too small, the other says it was too large
  -- One review wished it had more pockets
  -- Nearly all of the negative feedback came from Spanish language reviews
    -- Why?

-- How would you describe the pilot to the team?
  -- I used AI to translate reviews for a men's zip fleece, and analyzed the English language results.

-- Was the pilot a success?
  -- I think it was a success. The translations made sense, they were informative, and they generally correlated with the sentiment score.
  
-- Should they attempt this with other products?
  -- Yes, I believe they should.

-- If so, how should they go about doing so?
  -- Start by looking for trends in the untranslated reviews, like a particularly high number of reviews in a specific language.
  -- Generally, look for anything anomalous or noteworthy.