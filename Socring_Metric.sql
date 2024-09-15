
 WITH MovieStats AS (
    -- Calculate the mean IMDb score across all movies
    SELECT
        
        AVG(Imdb_score) AS c,
        0.5 AS W_Imdb,
        0.5 AS W_Top10,
        -- define average vote a static minimum vote threshold .
        AVG(Imdb_votes_1) AS m,
        AVG(Total_days_in_Top_10) AS AvgDays  -- Average days in Top 10 for normalization
    FROM
        `argon-key-429508-v5.Project.Betflix_0`
),
WeightedScores AS (
    -- Calculate the weighted score for each movie
    SELECT
        *,
        ROUND((Imdb_votes_1 * Imdb_score + m * c) / (Imdb_votes_1 + m),2) AS Weighted_Score,
        -- Normalize Total Days in Top 10 using the average (if Total_Days_Top_10 is NULL, treat as 0)
        ROUND(IFNULL(Total_days_in_Top_10,0) / AvgDays,2) AS Normalized_Top10_Score,
        -- Final Score combining IMDb Weighted Score and Normalized Days in Top 10
        ROUND((((Imdb_votes_1 * Imdb_score) + (m * c)) / ((Imdb_votes_1 + m)) +
        (IFNULL( Total_days_in_Top_10, 0) / AvgDays)),2) AS Final_Weighted_Score
    FROM
        `argon-key-429508-v5.Project.Betflix_0` ,
        MovieStats
),
-- Retrieve the results
ClassifiedScores AS (
    -- Use NTILE to divide the scores into 5 groups (quintiles, top 20% = 5, bottom 20% = 1)
    SELECT
        *,
        NTILE(20) OVER (ORDER BY Final_Weighted_Score) AS score_class
    FROM
        WeightedScores
)
-- Classify the results based on the NTILE ranking
SELECT
    Title,Type,Director,Year,`Cast`,Country,Netflix_Release_Date,Age_rating,Runtime,Genre,Description,Imdb_score,Imdb_votes_1,Total_days_in_Top_10
  
    Final_Weighted_Score,
    CASE
    WHEN score_class = 20 THEN 'Successful'
    WHEN score_class BETWEEN 11 AND 19 THEN 'Medium'
    WHEN score_class BETWEEN 1 AND 10 THEN 'Failure'
    ELSE 'Unclassified' -- Handles any unexpected score_class values
END AS classification

FROM
    ClassifiedScores
ORDER BY
    Final_Weighted_Score DESC;