# Create a new database 
CREATE DATABASE IF NOT EXISTS playstore_db;

# Use the database
USE playstore_db; 

CREATE TABLE playstore(
App VARCHAR(255),
Category VARCHAR(100),
Rating FLOAT,
Reviews INT,
Size VARCHAR(50),
Installs BIGINT,
Type VARCHAR(20),
Price FLOAT,
Content_Rating VARCHAR(50),
Genres VARCHAR(100),
Last_Updated VARCHAR(50),
Current_Ver VARCHAR(50),
Android_Ver VARCHAR(50),
Size_in_bytes FLOAT,
Size_MB FLOAT,
Installs_category VARCHAR(50)
);

# Create reviews table 
CREATE TABLE reviews( 
App VARCHAR(255),
Translated_Review TEXT,
Sentiment VARCHAR(20),
Sentiment_Polarity FLOAT,
Sentiment_Subjectivity float
);

#Verify tables created 
SHOW TABLES;
USE playstore_db;

SET GLOBAL local_infile =1; 
SET GLOBAL max_allowed_packet = 1073741824;


# Check row counts
SELECT COUNT(*) FROM playstore;
SELECT COUNT(*)  FROM reviews;

# Preview both tables 
SELECT * FROM playstore LIMIT 5;
SELECT * FROM reviews LIMIT 5;


#Top 10 Categories by Number of Apps
SELECT Category,
COUNT(*) AS Total_Apps
FROM playstore
GROUP BY Category
ORDER BY Total_Apps DESC
LIMIT 10; 


#Top 0 Categories by Total Installs
SELECT Category,
	   SUM(Installs) AS Total_Installs
FROM playstore 
GROUP BY Category
ORDER BY Total_Installs DESC
LIMIT 10;


#Top 10 Most Reviewed Apps 
SELECT App,
 Category,
 Reviews,
 Installs,
 Rating
 FROM playstore
 ORDER BY Reviews DESC
 LIMIT 10;


# Top 10 Most Reviewed Apps with Sentiment
SELECT p.App,
       p.Category,
       p.Reviews,
	   p.Rating,
       COUNT(r.Sentiment) AS Total_Sentiments,
       SUM(CASE WHEN r.Sentiment = 'Positive' THEN 1 ELSE 0 END),
       SUM(CASE WHEN r.Sentiment = 'Negative' THEN 1 ELSE 0 END),
       SUM(CASE WHEN r.Sentiment = 'Neutral' THEN 1 ELSE 0 END) 
FROM playstore p 
LEFT JOIN reviews r ON p.App = r.App
GROUP BY p.App, p.Category, p.Reviews, p.Rating 
ORDER BY p.Reviews DESC
LIMIT 10; 


# Free Vs Paid Apps Analysis 
SELECT Type,
	   COUNT(*) AS Total_Apss,
       ROUND(AVG(Rating),2) AS Avg_Rating,
       ROUND(AVG(Installs),2) AS Avg_Installs,
       ROUND(AVG(Price),2) AS Avg_Price
FROM playstore
WHERE Type IN( 'Free', 'Paid')
GROUP BY type;


# Top 10 Most Installed Paid Apps
SELECT App,
       Category,
       Price,
       Installs,
       Rating 
FROM playstore 
WHERE Type = 'Paid'
ORDER BY Installs DESC
LIMIT 10;


# Top Rated Categories 
SELECT Category, 
       ROUND(AVG(Rating),2) AS AVG_Rating, 
       COUNT(*) AS Total_Apps,
       SUM(Installs) AS Total_Installs 
FROM playstore 
GROUP BY Category 
HAVING COUNT(*) >= 50
ORDER BY Avg_Rating DESC
LIMIT 10;

#Bottom 5 Rated Categories 
SELECT Category,
       ROUND(AVG(Rating),2) AS Avg_Rating,
       COUNT(*) AS Total_Apps
FROM playstore 
GROUP BY Category 
HAVING COUNT(*)>=50
ORDER BY Avg_Rating ASC
LIMIT 5;


# Content Rating Distribution
SELECT Content_Rating,
       COUNT(*) AS Total_Apps,
       ROUND(AVG(Rating),2) AS Avg_Rating,
       SUM(Installs) AS Total_Installs,
       ROUND(AVG(Price),2) AS Avg_price
FROM playstore 
GROUP BY Content_Rating 
ORDER BY Total_Apps DESC;

# Most Installed App Per Content Rating 
SELECT p.Content_Rating,
       p.App,
       p.Installs,
       p.Rating 
FROM playstore p
INNER JOIN(
     SELECT Content_Rating,
     MAX(Installs) AS Max_Installs 
FROM playstore 
GROUP BY Content_Rating 
) AS max_table 
ON p.Content_Rating = max_table.Content_Rating
AND p.Installs = max_table.Max_Installs
ORDER BY p.Installs DESC;

# Top Genres by Average Rating 
SELECT Genres,
       COUNT(*) AS Total_Apps,
       ROUND(AVG(Rating),2) AS Avg_Rating, 
       SUM(Installs) AS Total_Installs 
FROM playstore 
GROUP BY Genres 
HAVING COUNT(*) >=20
ORDER BY Avg_Rating DESC
LIMIT 10; 

# Bottom 5 Genres by Rating 
SELECT Genres,
       COUNT(*) AS Total_Apps,
       ROUND(AVG(Rating),2) AS Avg_Rating,
       SUM(Installs) AS Total_Installs 
FROM playstore 
GROUP BY Genres
HAVING COUNT(*)>= 20
ORDER BY Avg_Rating ASC
LIMIT 5;

# Most Popular Genre Per Category 
SELECT Category,
       Genres,
       COUNT(*) AS Total_Apps,
       SUM(Installs) AS Total_Installs
FROM playstore 
GROUP BY Category, Genres 
ORDER BY Category, Total_Installs DESC
LIMIT 20;

# Sentiment Analysis by Category 
SELECT p.Category,
       COUNT(r.Sentiment) AS Total_Reviews,
       SUM(CASE WHEN r.Sentiment = 'Positive' THEN 1 ELSE 0 END) AS Positive,
       SUM(CASE WHEN r.Sentiment = 'Negative' THEN 1 ELSE 0 END) AS Negative ,
       SUM(CASE WHEN r.Sentiment = 'Neutral' THEN 1 ELSE 0 END) AS Neutral,
       ROUND(AVG(r.Sentiment_Polarity),4) AS Avg_Polarity,
       ROUND(AVG(r.Sentiment_Subjectivity),4) AS Avg_Subjectivity
FROM playstore p
INNER JOIN reviews r ON p.App = r.App
GROUP BY p.Category 
ORDER BY Positive DESC
LIMIT 10;
       
# Overall Sentiment Distribution
SELECT Sentiment,
       COUNT(*) AS Total,
       ROUND(AVG(Sentiment_Polarity),4) AS Avg_Polariy,
       ROUND(AVG(Sentiment_Subjectivity),4) AS Avg_Subjectivity
FROM reviews 
WHERE Sentiment IS NOT NULL
AND Sentiment != 'nan'
GROUP BY Sentiment 
ORDER BY Total DESC;

# Top 10 Most Positive Apps
SELECT p.App,
       p.Category,
       p.Rating,
       ROUND(AVG(r.Sentiment_Polarity), 4) AS Avg_Polarity,
       COUNT(r.Sentiment) AS Total_Reviews,
       SUM(CASE WHEN r.Sentiment = 'Positive' THEN 1 ELSE 0 END) AS Positive_Reivews
FROM playstore p
INNER JOIN reviews r ON p.App = r.App
GROUP BY p.App, p.Category , p.Rating 
HAVING COUNT(r.Sentiment) >=10
ORDER BY Avg_Polarity DESC
LIMIT 10;
       