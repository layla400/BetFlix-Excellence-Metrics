# **BetFlix-Excellence-Metrics**

This project focuses on analyzing content success metrics for Betflix, a video streaming platform. Using real Netflix data, we explore the trends, patterns, and factors that contribute to the success of TV shows and movies on the platform.

## **Project Overview**

The objective is to provide a data-driven assessment of Betflix content. We aim to identify key attributes that drive content popularity, such as genre, release year, user ratings, and viewership metrics. Insights from this analysis will guide strategic decisions in content creation and maximize ROI for the platform.

## **Project Motivation**

1. Identify key features contributing to the success of Betflix content.
2. Provide actionable insights to optimize content strategy and increase viewership.
3. Develop a predictive model to forecast the success of future content.

---

## **Data Description**

- [**Netflix_titles**](https://www.kaggle.com/datasets/paramvir705/netflix-dataset)
- [**IMDB Dataset**](https://docs.google.com/spreadsheets/d/1MnhUFfkANskF_f-JHaWFxpIJPppSrqrY8R05s-A84fQ/edit?gid=1971309909#gid=1971309909)
- [**Netflix User Base**](https://www.kaggle.com/datasets/arnavsmayan/netflix-userbase-dataset/data)
- [**Global_all_weeks**](https://docs.google.com/spreadsheets/d/198DZVpLAxUZDBlGA5cMYl3-bIJQAdm9h/edit?usp=sharing&ouid=106503551153519138225&rtpof=true&sd=true)
- [**Netflix_stock**](https://www.kaggle.com/datasets/mayankanand2701/netflix-stock-price-dataset)
- [**Netflix_Global_Revenue**](https://www.kaggle.com/datasets/adnananam/netflix-revenue-and-usage-statistics/data)

- [**Tables' ERD**](https://lucid.app/lucidchart/5c148e6c-b7a1-41d5-8d01-31189a4c7e86/edit?page=0_0&invitationId=inv_488da03f-fd0f-4428-8153-a8e92569e2d3#)
![ERD](https://github.com/user-attachments/assets/f05dedba-bba2-49e3-a4d7-8a8a1d08483d)

---

## **Data Exploration**

### **Methods**
- **Data Cleaning**: GoogleSheets / BigQuery (SQL) / GoogleColab (Python)
- **Exploratory Data Analysis (EDA)**: BigQuery (SQL) / GoogleColab (Python)
- **Dashboarding**: Looker Studio

---
## **Data Loading, Modelling and Cleaning using BigQuery**
```sql

-- .........................................................................................
-- Clean Netflix_titles Table
-- .........................................................................................
WITH Cleaned_Netflix_Titles AS (
    SELECT
        Title,
        SAFE.PARSE_DATE('%Y-%m-%d', Release_Date) AS Release_Date,  -- Standardize Release Date format
        SAFE.PARSE_DATE('%Y-%m-%d', Added_Date) AS Added_Date,      -- Clean Added Date format
        CASE
            WHEN Runtime LIKE '%min%' THEN CAST(REGEXP_EXTRACT(Runtime, r'\d+') AS INT64)
            ELSE NULL
        END AS Runtime_Minutes,  -- Extract runtime in minutes
        Genre,
        CASE
            WHEN Age_Rating = 'Not Rated' OR Age_Rating IS NULL THEN 'Unrated'
            ELSE Age_Rating
        END AS Age_Rating_Cleaned,  -- Standardize Age Rating
        Country,
        Description,
        Director
    FROM
        `argon-key-429508-v5.Project.Netflix_titles`
    WHERE
        Title IS NOT NULL  -- Ensure Title is not NULL for consistency
),

-- .........................................................................................
-- Clean Global_All_Weeks Table
-- .........................................................................................
Cleaned_Global_All_Weeks AS (
    SELECT
        Title,
        SAFE.PARSE_DATE('%Y-%m-%d', Week) AS Week_Date,  -- Standardize Week Date format
        Country,
        COALESCE(Total_Views, 0) AS Total_Views_Cleaned,  -- Handle missing Total Views
        COALESCE(Rank, 999) AS Rank_Cleaned,  -- Handle missing Rank data
        Category,
        comulative_weeks_in_top_10
    FROM
        `argon-key-429508-v5.Project.Global_all_weeks`
    WHERE
        Title IS NOT NULL  -- Only work with valid Title entries
),

-- .........................................................................................
-- Clean IMDB_DATASET Table
-- .........................................................................................
Cleaned_IMDB_Dataset AS (
    SELECT
        Title,
        SAFE.PARSE_DATE('%Y-%m-%d', Release_Date) AS IMDB_Release_Date,  -- Clean IMDB Release Date
        SAFE.PARSE_DATE('%Y-%m-%d', First_Air_Date) AS IMDB_First_Air_Date,  -- Clean First Air Date
        CAST(Imdb_Score AS FLOAT64) AS Imdb_Score_Cleaned,  -- Ensure IMDb score is float
        CAST(REPLACE(Imdb_Votes, ",", "") AS INT64) AS Imdb_Votes_Cleaned,  -- Remove commas in votes
        COALESCE(CAST(Imdb_Score AS FLOAT64), 0) AS Imdb_Score_Processed,  -- Handle missing IMDb scores
        COALESCE(CAST(REPLACE(Imdb_Votes, ',', '') AS INT64), 0) AS Imdb_Votes_Processed  -- Handle missing votes
    FROM
        `argon-key-429508-v5.Project.IMDB_DATASET0`
    WHERE
        Title IS NOT NULL
)

-- .........................................................................................
-- Join All Cleaned Tables on Title
-- .........................................................................................
SELECT
    COALESCE(nt.Title, g.Title, i.Title) AS Title,  -- Prioritize Title from any source
    nt.Release_Date AS Netflix_Release_Date,
    nt.Added_Date AS Netflix_Added_Date,
    nt.Runtime_Minutes,
    nt.Genre,
    nt.Age_Rating_Cleaned AS Age_Rating,
    nt.Country AS Netflix_Country,
    nt.Description,
    nt.Director,
    g.Week_Date,
    g.Country AS Global_Country,
    g.Total_Views_Cleaned,
    g.Rank_Cleaned,
    g.Category,
    i.IMDB_Release_Date,
    i.IMDB_First_Air_Date,
    i.Imdb_Score_Cleaned,
    i.Imdb_Votes_Cleaned
FROM
    Cleaned_Netflix_Titles nt
LEFT JOIN
    Cleaned_Global_All_Weeks g ON nt.Title = g.Title
LEFT JOIN
    Cleaned_IMDB_Dataset i ON nt.Title = i.Title;

-- .........................................................................................
-- Save Final Results into a New Table 'Final_new_betflix_updated'
-- .........................................................................................
CREATE OR REPLACE TABLE `argon-key-429508-v5.Project.Final_new_betflix_updated` AS
SELECT
    *
FROM (
    SELECT
        COALESCE(nt.Title, g.Title, i.Title) AS Title,
        nt.Release_Date AS Netflix_Release_Date,
        nt.Added_Date AS Netflix_Added_Date,
        nt.Runtime_Minutes,
        nt.Genre,
        nt.Age_Rating_Cleaned AS Age_Rating,
        nt.Country AS Netflix_Country,
        nt.Description,
        nt.Director,
        g.Week_Date,
        g.Country AS Global_Country,
        g.Total_Views_Cleaned,
        g.comulative_weeks_in_top_10,
        g.Category,
        i.IMDB_Release_Date,
        i.IMDB_First_Air_Date,
        i.Imdb_Score_Cleaned,
        i.Imdb_Votes_Cleaned
    FROM Cleaned_Netflix_Titles nt
    LEFT JOIN Cleaned_Global_All_Weeks g ON nt.Title = g.Title
    LEFT JOIN Cleaned_IMDB_Dataset i ON nt.Title = i.Title
);

-- .........................................................................................
-- Additional Cleaning on Final Data (Netflix_Release_Date and Imdb_votes)
-- .........................................................................................
SELECT
    COALESCE(
        SAFE.PARSE_DATE('%Y-%m-%d', TRIM(Netflix_Release_Date)),
        SAFE.PARSE_DATE('%d/%m/%Y', TRIM(Netflix_Release_Date)),
        SAFE.PARSE_DATE('%m/%d/%Y', TRIM(Netflix_Release_Date))
    ) AS Cleaned_Release_Date,  -- Clean multiple date formats
    EXTRACT(YEAR FROM Cleaned_Release_Date) AS Release_Year,  -- Extract Year
    CASE
        WHEN Imdb_votes = "N/A" THEN NULL  -- Handle 'N/A' in IMDb votes
        ELSE CAST(REPLACE(Imdb_votes, ",", "") AS INT64)  -- Remove commas in votes
    END AS Cleaned_Imdb_Votes,
    *
FROM `argon-key-429508-v5.Project.Final_new_betflix_updated`;

-- .........................................................................................
-- Generate Movie Statistics and Weighted Scores
-- .........................................................................................
WITH MovieStats AS (
    SELECT
        AVG(Imdb_Score_Cleaned) AS c,  -- Average IMDb score
        0.5 AS W_Imdb,
        0.5 AS W_Top10,  -- Weighting for IMDb score and Top 10 performance
        AVG(Imdb_Votes_Processed) AS m,  -- Average votes for minimum threshold
        AVG(comulative_weeks_in_top_10) AS AvgDays  -- Average days in Top 10
    FROM
        `argon-key-429508-v5.Project.Final_new_betflix_updated`
),
WeightedScores AS (
    SELECT
        *,
        ROUND((Imdb_Votes_Processed * Imdb_Score_Processed + m * c) / (Imdb_Votes_Processed + m), 2) AS Weighted_Score,  -- Bayesian Average
        ROUND(IFNULL(comulative_weeks_in_top_10, 0) / AvgDays, 2) AS Normalized_Top10_Score,
        ROUND(((Imdb_Votes_Processed * Imdb_Score_Processed) + (m * c)) / ((Imdb_Votes_Processed + m)) + (IFNULL(comulative_weeks_in_top_10, 0) / AvgDays), 2) AS Final_Weighted_Score
    FROM
        `argon-key-429508-v5.Project.Final_new_betflix_updated`,
        MovieStats
),
ClassifiedScores AS (
    SELECT
        *,
        NTILE(20) OVER (ORDER BY Final_Weighted_Score DESC) AS Score_Class
    FROM
        WeightedScores
)
SELECT
    Title,
    Genre,
    Director,
    Release_Year,
    Final_Weighted_Score,
    CASE
        WHEN Score_Class = 20 THEN 'Successful' -- Choosing top 5% as Successful
        WHEN Score_Class BETWEEN 11 AND 19 THEN 'Medium'
        ELSE 'Failure' -- Choosing bottom 50% as Failure
    END AS Classification
FROM
    ClassifiedScores
ORDER BY Final_Weighted_Score DESC;

-- .........................................................................................
-- Aggregating Yearly Performance
-- .........................................................................................
SELECT
    Release_Year,
    COUNT(*) AS nb_contents,
    ROUND(AVG(Final_Weighted_Score), 2) AS avg_Final_Weighted_Score
FROM
    `argon-key-429508-v5.Project.Final_new_betflix_updated`
WHERE
    Release_Year IS NOT NULL
    AND Classification = 'Successful'
GROUP BY
    Release_Year
ORDER BY
    Release_Year;

-- .........................................................................................
-- Netflix_Global_Revenue - Revenue Aggregation
-- .........................................................................................
SELECT 
    EXTRACT(YEAR FROM Date) AS Year, 
    ROUND(SUM(Global_Revenue), 2) AS Global_Revenue,  
    ROUND(SUM(UCAN_Streaming_Revenue), 2) AS UCAN,    
    ROUND(SUM(EMEA_Streaming_Revenue), 2) AS EMEA,    
    ROUND(SUM(LATM_Streaming_Revenue), 2) AS LATM,    
    ROUND(SUM(APAC_Streaming_Revenue), 2) AS APAC,    
    ROUND(SUM(Netflix_Streaming_Memberships), 2) AS Global_Memberships, 
    ROUND(SUM(UCAN_Members), 2) AS UCAN_Members,      
    ROUND(SUM(EMEA_Members), 2) AS EMEA_Members,      
    ROUND(SUM(LATM_Members), 2) AS LATM_Members,      
    ROUND(SUM(APAC_Members), 2) AS APAC_Members       
FROM `argon-key-429508-v5.Project.Cleaned_global_revenue`
GROUP BY Year  -- Group by year to aggregate revenue on a yearly basis
ORDER BY Year; -- Order by year for clear chronological presentation

-- Saved aggregated query result to table 'revenue2011-2024_by_year'


-- .........................................................................................
-- Netflix Stock Data - Stock Growth Calculation
-- .........................................................................................
SELECT 
    year,
    ROUND(SUM(Volume), 2) AS annual_stock_volume,  
    ROUND(SUM(open), 2) AS open_price,  
    ROUND(SUM(close), 2) AS close_price,  
    ROUND(SUM(((close - open) / open) * 100), 2) AS annual_stock_increase  -- Calculate annual stock increase in %
FROM `argon-key-429508-v5.Project.Netflix_stock`
GROUP BY year;  -- Group by year for yearly stock growth aggregation

-- Saved aggregated query result to table 'Cleaned_Stock_by_year'


-- .........................................................................................
-- Revenue_Stock_ContentPerformances - Final Report combining revenue, stock, and content data
-- .........................................................................................
WITH RevenueGrowth AS (
    SELECT
        year,
        Global_Memberships,
        LAG(Global_Memberships) OVER (ORDER BY year) AS previous_year_membership,  -- Get previous year's memberships for growth calculation
        ROUND(Global_Memberships - LAG(Global_Memberships) OVER (ORDER BY year), 2) AS membership_growth,  -- Calculate membership growth
        Global_Revenue,
        LAG(Global_Revenue) OVER (ORDER BY year) AS previous_year_revenue,  -- Get previous year's revenue for growth calculation
        ROUND((Global_Revenue - LAG(Global_Revenue) OVER (ORDER BY year)) * 100, 2) AS revenue_growth  -- Calculate revenue growth in %
    FROM `argon-key-429508-v5.Project.revenue2011-2024_by_year`
),
StockYearlyData AS (
    SELECT 
        year,
        MIN(open_price) AS open_price,  -- Get the minimum opening price in a year
        MAX(close_price) AS close_price  -- Get the maximum closing price in a year
    FROM `argon-key-429508-v5.Project.Cleaned_Stock_by_year`
    GROUP BY year
),
StockGrowth AS (
    SELECT
        year,
        close_price,
        open_price,
        ROUND(((close_price - open_price) / open_price) * 100, 2) AS stock_growth_percentage  -- Calculate stock growth percentage
    FROM StockYearlyData
),
ContentProduction AS (
    SELECT 
        *
    FROM `argon-key-429508-v5.Project.year_total_contents`  -- Yearly content production data
),

SELECT 
    r.year,
    nb_contents,  -- Number of successful contents produced in a year
    Global_Memberships,  -- Global memberships for that year
    membership_growth,  -- Year-on-year membership growth
    Global_Revenue,  -- Global revenue for that year
    close_price,  -- Closing stock price for the year
    COALESCE(r.revenue_growth, 0) AS revenue_growth,  -- Revenue growth (0 if missing)
    COALESCE(s.stock_growth_percentage, 0) AS stock_growth_percentage  -- Stock growth percentage (0 if missing)
FROM ContentProduction c
RIGHT JOIN RevenueGrowth r ON c.year = r.year  -- Join content production with revenue growth data
LEFT JOIN StockGrowth s ON c.year = s.year  -- Join stock growth data
ORDER BY c.year;  -- Order by year for chronological presentation

-- Saved aggregated query result to table 'Revene_Stock_ContentPerformances'

```

---
## **Looker Studio Dashboards and Insights**

You can access the Looker Studio dashboard from this [link](https://lookerstudio.google.com/u/0/reporting/82a09ffe-b1fc-4b3f-b2db-fb27591a300f/page/p_dh00duy3kd/edit).

### **Overview Dashboard**

This dashboard provides an overview of the project, including the context, hypothesis, and a general summary of the data sources used.

### **Financial Performance Dashboard**

This dashboard focuses on financial metrics such as stock prices, global revenue, and subscription performance from 2015 to 2024.

- **Global Membership Growth**  
  The analysis reveals steady and incremental growth in both global revenue and subscription numbers over the past 12 years. A strong positive correlation is observed between global memberships and revenue growth, which aligns with the business model of Betflix.

- **Impact of Successful Content on Memberships**  
  The chart shows the correlation between the release of successful content and the annual growth in subscriptions. In 2020, there was the highest subscription growth, coinciding with the release of successful content.

- **Global Revenue by Release Date**  
  This analysis shows that most successful content is released on Fridays, when users are more likely to engage with streaming platforms over the weekend.

### **Content Analysis Dashboard**

This dashboard explores content performance based on metrics like viewership scores, genres, and director impact.

- **Top 10 Directors & Content on Average Final Score**  
  Directors and content with the highest average final score are displayed, with Cocomelon being the top performer, spending over 200 weeks in the top 10 between 2021-2024.

- **Distribution of Genres by Age Rating**  
  Comedy and drama dominate across all age groups, reflecting general audience preferences.

- **Average Viewership Score by Type**  
  TV shows consistently outperform other content types in terms of viewership scores.

### **User Analysis Dashboard**

This dashboard explores user demographics and behavior patterns.

- **Users by Continent**  
  The majority of users come from North America, which corresponds with the platform's heavy focus on English-language content.

- **User Age Distribution**  
  The age distribution chart shows that a majority of Betflix's users are younger, with a relatively balanced gender distribution. Device usage for streaming is also evenly distributed.

---

## **Challenges and Limitations**

1. Data availability was limited to certain regions, which might skew some of the global analyses.
2. There were some missing values and inconsistencies in the data that required extensive cleaning.

---

## **Future Work**

1. Expand analysis to include more granular data on user engagement (e.g., time spent watching content, repeat views).
2. Incorporate machine learning models to predict future content success based on historical data.
3. Explore user preferences by deeper demographic insights (e.g., income, education).

---

