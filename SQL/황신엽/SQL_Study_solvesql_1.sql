-- 제목이 모음으로 끝나지 않는 영화
-- LIKE 말고 REGEXP의 문법을 활용하여 제목이 대소문자 상관없이 모음으로 끝나지 않는 것만 필터링 하도록 함
SELECT title
FROM film
WHERE title NOT REGEXP '[aeiouAEIOU]$'
  AND rating IN ('R', 'NC-17');

-- 데이터 그룹으로 묶기
-- 표본 분산을 구하는 수식인 'VAR_SAMP'을 사용하는 것이 중요 포인트
SELECT quartet
      , ROUND(AVG(x), 2) AS x_mean
      , ROUND(VAR_SAMP(x), 2) AS x_var
      , ROUND(AVG(y), 2) AS y_mean
      , ROUND(VAR_SAMP(y), 2) AS y_var
FROM points
GROUP BY quartet;

-- 다음날도 서울숲의 미세먼지 농도는 나쁨
-- 방법1: LEAD 함수를 활용하여 다음 날 데이터 출력
WITH cte AS(
  SELECT DATE_FORMAT(measured_at, '%Y-%m-%d') AS today
        , LEAD(DATE_FORMAT(measured_at, '%Y-%m-%d'), 1) OVER () AS next_day
        , pm10
        , LEAD(pm10, 1) OVER (ORDER BY measured_at) AS next_pm10
  FROM measurements
)
SELECT *
FROM cte
WHERE pm10 < next_pm10;

-- 방법2: 셀프 조인을 활용하여 다음 날 데이터 출력
SELECT DATE_FORMAT(m1.measured_at, '%Y-%m-%d') AS today
      , DATE_FORMAT(m2.measured_at, '%Y-%m-%d') AS next_day
      , m1.pm10
      , m2.pm10 AS next_pm10
FROM measurements AS m1
  LEFT JOIN measurements AS m2 ON m1.measured_at = DATE_SUB(m2.measured_at, INTERVAL 1 DAY)
WHERE m1.pm10 < m2.pm10;

-- 버뮤다 삼각지대에 들어가버린 택배
SELECT DATE_FORMAT(order_delivered_carrier_date, '%Y-%m-%d') AS delivered_carrier_date
      , COUNT(CASE WHEN order_delivered_carrier_date IS NOT NULL AND order_delivered_customer_date IS NULL THEN order_id END) AS orders
FROM olist_orders_dataset
WHERE order_delivered_carrier_date LIKE '2017-01%'
GROUP BY delivered_carrier_date
HAVING orders != 0
ORDER BY delivered_carrier_date;

-- 3년간 들어온 소장품 집계하기
SELECT classification
      , SUM(IF(YEAR(acquisition_date) = 2014, 1, 0)) AS '2014'
      , SUM(IF(YEAR(acquisition_date) = 2015, 1, 0)) AS '2015'
      , SUM(IF(YEAR(acquisition_date) = 2016, 1, 0)) AS '2016'
FROM artworks
GROUP BY classification;