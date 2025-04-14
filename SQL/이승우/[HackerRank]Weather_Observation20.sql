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
