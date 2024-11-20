WITH RECURSIVE hours AS (
    SELECT 0 AS hour
    UNION ALL
    SELECT hour + 1
    FROM hours
    WHERE hour < 23 -- 0부터 23시까지 생성
)
SELECT 
    h.hour, 
    COALESCE(COUNT(a.ANIMAL_ID), 0) AS count
FROM hours h
LEFT JOIN ANIMAL_OUTS a
ON HOUR(a.DATETIME) = h.hour -- DATETIME에서 시간 추출
GROUP BY h.hour
ORDER BY h.hour;
