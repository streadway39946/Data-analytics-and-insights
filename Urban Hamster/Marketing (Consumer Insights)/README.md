The analytics work in this folder was performed for Urban Hamster's marketing department, who had the following questions:
- Who are Urban Hamster's VIP customers?
- Which generations are driving sales?
- Once we know who is buying what and how much they are spending, how does Urban Hamster "roll out the red carpet" for them?

Description of files and links in this folder:
- Customer Segmentation Using K-Means Clustering.ipynb - Using Python to cluster Urban Hamster's customers into four different segments, primarily to identify "MVP" customers that spend the most.
- Exploring the Dataset.sql - A set of .sql queries that act as a quick sanity check of the data in the database.
- Queries to Answer Business Questions.sql - The queries run over the Hamster database to find answers for the questions asked by the finance department. A note: not all of their questions could be answered using .sql, so I answered those questions using comment blocks.
- Translating Customer Reviews.sql - Using Snowflake Cortex, I translated a series of customer reviews for a fleece jacket from Korean and Spanish to English and calculated a sentiment score. I then analyzed the more "negative" reviews for common feedback.
