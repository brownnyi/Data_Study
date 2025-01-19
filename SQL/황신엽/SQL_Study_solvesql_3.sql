-- 폐쇄할 따릉이 정류소 찾기 1
WITH cte AS(
  SELECT s1.station_id
        , s1.name
        , COUNT(s2.station_id) AS cnt
  FROM station AS s1
    LEFT JOIN station AS s2 ON s1.station_id != s2.station_id
  WHERE (6371 * acos(cos(radians(s1.lat)) * cos(radians(s2.lat)) 
                * cos(radians( s2.lng) - radians(s1.lng))
                + sin(radians(s1.lat)) * sin(radians(s2.lat)))) < 0.3
    AND s1.updated_at < s2.updated_at
  GROUP BY s1.station_id, s1.name
  HAVING cnt >= 5
)
SELECT station_id
      , name
FROM cte