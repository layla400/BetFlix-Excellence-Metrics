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


