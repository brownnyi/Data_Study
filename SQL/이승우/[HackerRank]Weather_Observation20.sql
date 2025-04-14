WITH Ordered AS (
    SELECT LAT_N, ROW_NUMBER() OVER (ORDER BY LAT_N) AS rn
    FROM STATION
),
Counted AS (
    SELECT COUNT(*) AS total_rows FROM STATION
),
Median AS (
    SELECT 
        o.LAT_N
    FROM Ordered o
    JOIN Counted c ON 1=1
    WHERE 
        (c.total_rows % 2 = 1 AND o.rn = (c.total_rows + 1) / 2)
        OR (c.total_rows % 2 = 0 AND (o.rn = c.total_rows / 2 OR o.rn = c.total_rows / 2 + 1))
)
SELECT 
    ROUND(AVG(LAT_N), 4) AS median_lat_n
FROM Median;

-----------------------------------------
WITH cte AS(
    SELECT lat_n
            , ROW_NUMBER() OVER(ORDER BY lat_n) AS row_n
            , COUNT(*) OVER() AS total_cnt
    FROM station
)
SELECT ROUND(AVG(lat_n), 4)
FROM cte
WHERE row_n IN (CEIL((total_cnt + 1) / 2), FLOOR((total_cnt + 1) / 2))
