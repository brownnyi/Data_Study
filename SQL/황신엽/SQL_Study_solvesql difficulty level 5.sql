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
FROM cte;

-- 지역별 자전거 대여 현황
SELECT s1.local
      , COUNT(r.rent_station_id) AS all_rent
      , COUNT(CASE WHEN s1.local = s2.local THEN r.return_station_id END) AS same_local
      , COUNT(CASE WHEN s1.local != s2.local THEN r.return_station_id END) AS diff_local
FROM rental_history AS r
  INNER JOIN station AS s1 ON s1.station_id = r.rent_station_id
  INNER JOIN station AS s2 ON s2.station_id = r.return_station_id
WHERE r.rent_at BETWEEN '2021-01-01' AND '2021-01-31 23:59:59'
  AND r.return_at BETWEEN '2021-01-01' AND '2021-01-31 23:59:59'
GROUP BY s1.local
ORDER BY all_rent DESC;

-- SQL 데이터 분석 캠프 실전반 전환율
WITH scroll AS(
  SELECT user_pseudo_id
        , ga_session_id
        , event_timestamp_kst
  FROM ga
  WHERE page_title = '백문이불여일타 SQL 캠프 실전반'
    AND event_name = 'scroll'
), click AS(
  SELECT user_pseudo_id
        , ga_session_id
        , event_timestamp_kst
  FROM ga
  WHERE event_name = 'SQL_advanced_form_click'
)
SELECT COUNT(DISTINCT g.user_pseudo_id, g.ga_session_id) AS pv
      , COUNT(DISTINCT s.user_pseudo_id, s.ga_session_id) AS scroll_after_pv
      , COUNT(DISTINCT c.user_pseudo_id, c.ga_session_id) AS click_after_scroll
      , ROUND(COUNT(DISTINCT s.user_pseudo_id, s.ga_session_id) / COUNT(DISTINCT g.user_pseudo_id, g.ga_session_id), 3) AS pv_scroll_rate
      , ROUND(COUNT(DISTINCT c.user_pseudo_id, c.ga_session_id) / COUNT(DISTINCT g.user_pseudo_id, g.ga_session_id), 3) AS pv_click_rate
      , ROUND(COUNT(DISTINCT c.user_pseudo_id, c.ga_session_id) / COUNT(DISTINCT s.user_pseudo_id, s.ga_session_id), 3) AS scroll_click_rate
FROM ga AS g
  LEFT JOIN scroll AS s ON g.user_pseudo_id = s.user_pseudo_id AND g.ga_session_id = s.ga_session_id AND g.event_timestamp_kst <= s.event_timestamp_kst
  LEFT JOIN click AS c ON s.user_pseudo_id = c.user_pseudo_id AND s.ga_session_id = c.ga_session_id AND s.event_timestamp_kst <= c.event_timestamp_kst
WHERE page_title = '백문이불여일타 SQL 캠프 실전반'
  AND event_name = 'page_view';

-- 유입 채널 별 실전반 전환율
WITH scroll AS(
  SELECT user_pseudo_id
        , ga_session_id
        , event_timestamp_kst
  FROM ga
  WHERE page_title = '백문이불여일타 SQL 캠프 실전반'
    AND event_name = 'scroll'
), click AS(
  SELECT user_pseudo_id
        , ga_session_id
        , event_timestamp_kst
  FROM ga
  WHERE event_name = 'SQL_advanced_form_click'
)
SELECT g.source
      , g.medium
      , COUNT(DISTINCT g.user_pseudo_id, g.ga_session_id) AS pv
      , COUNT(DISTINCT s.user_pseudo_id, s.ga_session_id) AS scroll_after_pv
      , COUNT(DISTINCT c.user_pseudo_id, c.ga_session_id) AS click_after_scroll
      , ROUND(COUNT(DISTINCT s.user_pseudo_id, s.ga_session_id) / COUNT(DISTINCT g.user_pseudo_id, g.ga_session_id), 3) AS pv_scroll_rate
      , ROUND(COUNT(DISTINCT c.user_pseudo_id, c.ga_session_id) / COUNT(DISTINCT g.user_pseudo_id, g.ga_session_id), 3) AS pv_click_rate
      , ROUND(COUNT(DISTINCT c.user_pseudo_id, c.ga_session_id) / COUNT(DISTINCT s.user_pseudo_id, s.ga_session_id), 3) AS scroll_click_rate
FROM ga AS g
  LEFT JOIN scroll AS s ON g.user_pseudo_id = s.user_pseudo_id AND g.ga_session_id = s.ga_session_id AND g.event_timestamp_kst <= s.event_timestamp_kst
  LEFT JOIN click AS c ON s.user_pseudo_id = c.user_pseudo_id AND s.ga_session_id = c.ga_session_id AND s.event_timestamp_kst <= c.event_timestamp_kst
WHERE page_title = '백문이불여일타 SQL 캠프 실전반'
  AND event_name = 'page_view'
GROUP BY source, medium
ORDER BY pv DESC;

-- 카테고리 별 매출 비율
SELECT DISTINCT category
      , sub_category
      , ROUND(SUM(sales) OVER(PARTITION BY sub_category), 2) AS sales_sub_category
      , ROUND(SUM(sales) OVER(PARTITION BY category), 2) AS sales_category
      , ROUND(SUM(sales) OVER(), 2) AS sales_total
      , ROUND(SUM(sales) OVER(PARTITION BY sub_category) / SUM(sales) OVER(PARTITION BY category) * 100, 2) AS pct_in_category
      , ROUND(SUM(sales) OVER(PARTITION BY sub_category) / SUM(sales) OVER() * 100, 2) AS pct_in_total
FROM records;

-- 세션 재정의하기
WITH step1 AS(
  SELECT user_pseudo_id
        , event_timestamp_kst
        , LAG(event_timestamp_kst) OVER(ORDER BY event_timestamp_kst) AS last_event_time
        , LEAD(event_timestamp_kst) OVER(ORDER BY event_timestamp_kst) AS next_event_time
        , ROW_NUMBER() OVER(ORDER BY event_timestamp_kst) AS id
  FROM ga
  WHERE user_pseudo_id = 'S3WDQCqLpK'  
), step2 AS(
  SELECT user_pseudo_id
        , event_timestamp_kst
        , TIMESTAMPDIFF(SECOND, last_event_time, event_timestamp_kst) AS last_event
        , TIMESTAMPDIFF(SECOND, event_timestamp_kst, next_event_time) AS next_event
        , id
  FROM step1
), step3 AS(
  SELECT step2.*
        , CASE
              WHEN last_event IS NULL THEN id
              WHEN last_event >= 3600 THEN id
              ELSE LAG(id) OVER(ORDER BY event_timestamp_kst)
        END AS session
  FROM step2
  WHERE last_event IS NULL
    OR last_event >= 3600
    OR next_event IS NULL
    OR next_event >= 3600
), step4 AS(
  SELECT user_pseudo_id
        , session
        , MIN(event_timestamp_kst) AS session_start
        , MAX(event_timestamp_kst) AS session_end
  FROM step3
  GROUP BY user_pseudo_id, session
)
SELECT user_pseudo_id
      , session_start
      , session_end
FROM step4
ORDER BY session_start;

-- 어떤 컨텐츠를 보고 유입되었을까?
SELECT DISTINCT REPLACE(REGEXP_SUBSTR(page_location, 'utm_content=[a-zA-Z0-9-_]*'), 'utm_content=', '') AS content
      , page_location
FROM ga
WHERE event_name = 'page_view'
  AND page_title IN ('백문이불여일타 SQL 캠프 심화반', '백문이불여일타 SQL 캠프 실전반')
  AND source = 'brunch'
  AND page_location REGEXP 'utm_content';

-- 스테디셀러 작가 찾기
WITH cte1 AS(
  SELECT author
        , year
  FROM books
  WHERE genre = 'Fiction'
  GROUP BY author, year
), cte2 AS(
  SELECT author
        , year
        , DENSE_RANK() OVER(PARTITION BY author ORDER BY year) AS d_rk
        , year - DENSE_RANK() OVER(PARTITION BY author ORDER BY year) AS diff
  FROM cte1
), cte3 AS(
  SELECT author
        , diff
        , MAX(year) AS year
        , COUNT(diff) AS depth
  FROM cte2
  GROUP BY author, diff
  HAVING depth >= 5
)
SELECT author
      , year
      , depth
FROM cte3;

-- 세션 유지 시간을 10분으로 재정의하기
WITH step1 AS(
  SELECT user_pseudo_id
        , ga_session_id
        , event_name
        , event_timestamp_kst
        , LAG(event_timestamp_kst) OVER(ORDER BY event_timestamp_kst) AS last_event_time
  FROM ga
  WHERE user_pseudo_id = 'a8Xu9GO6TB'
), step2 AS(
  SELECT step1.*
        , TIMESTAMPDIFF(SECOND, last_event_time, event_timestamp_kst) AS last_event
  FROM step1
), step3 AS(
  SELECT step2.*
        , ROW_NUMBER() OVER(ORDER BY event_timestamp_kst) AS id
        , CASE WHEN last_event >= 600 THEN 1 ELSE 0 END AS time_diff
  FROM step2 
)
SELECT user_pseudo_id
      , event_timestamp_kst
      , event_name
      , ga_session_id
      , SUM(time_diff) OVER(ORDER BY event_timestamp_kst) + 1 AS new_session_id
FROM step3
ORDER BY event_timestamp_kst;