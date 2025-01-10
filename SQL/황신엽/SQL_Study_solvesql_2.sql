-- 멘토링 짝궁 리스트
-- 멘티: 2021-12-31 기준 3개월 이내 입사한 인원
-- 멘토: 2021-12-31 기준 재직한지 2년 이상된 인원
-- 쿼리 결과에 매칭 가능한 멘토가 없어도 결과에 포함
-- 멘티 ID를 기준으로 오름차순 정렬, 멘티 1명당 멘토가 여러명이면 멘토 ID를 기준으로 오름차순 정렬
-- 멘토 멘티는 서로 다른 부서여야 함
WITH mentee AS(
  SELECT *
  FROM employees
  WHERE join_date BETWEEN DATE_SUB('2021-12-31', INTERVAL 3 MONTH) AND '2021-12-31'
), mentor AS(
  SELECT *
  FROM employees
  WHERE join_date <= DATE_SUB('2021-12-31', INTERVAL 2 YEAR)
)
SELECT e.employee_id AS mentee_id
      , e.name AS mentee_name
      , r.employee_id AS mentor_id
      , r.name AS mentor_name
FROM mentee AS e
  CROSS JOIN mentor AS r
WHERE e.department != r.department
ORDER BY e.employee_id, r.employee_id;

-- 바겐 세일!
-- 일별 판매된 상품의 전체 개수와 80% 이상 할인 판매된 상품의 전체 개수
-- 전체 상품 판매 개수가 10개 이상, 80% 이상 할인 판매된 상품 개수가 1개 이상만 필터링
-- 80% 이상 할인 판매된 상품의 개수 내림차순 정렬
-- 한 행이 개수가 1개를 의미하는 것이 아님 즉 quantity를 기준으로 합해야 함
SELECT order_date
      , SUM(CASE WHEN discount >= 0.8 THEN quantity END) AS big_discount_items
      , SUM(quantity) AS all_items
FROM records
GROUP BY order_date
HAVING big_discount_items >= 1
  AND all_items >= 10
ORDER BY big_discount_items DESC;

-- 폐쇄할 따릉이 정류소 찾기 2
WITH rental_2018 AS(
  SELECT rent_station_id AS station_id
  FROM rental_history
  WHERE rent_at LIKE '2018-10%'

  UNION ALL 

  SELECT return_station_id
  FROM rental_history
  WHERE return_at LIKE '2018-10%'
), r_8 AS(
  SELECT station_id
        , COUNT(*) AS cnt
  FROM rental_2018
  GROUP BY station_id
), rental_2019 AS(
  SELECT rent_station_id AS station_id
  FROM rental_history
  WHERE rent_at LIKE '2019-10%'

  UNION ALL 

  SELECT return_station_id
  FROM rental_history
  WHERE return_at LIKE '2019-10%'  
), r_9 AS(
  SELECT station_id
        , COUNT(*) AS cnt
  FROM rental_2019
  GROUP BY station_id
)
SELECT r_8.station_id
      , s.name
      , s.local
      , ROUND(r_9.cnt / r_8.cnt * 100, 2) AS usage_pct
FROM r_8
  INNER JOIN r_9 ON r_8.station_id = r_9.station_id
  INNER JOIN station AS s ON r_8.station_id = s.station_id
WHERE r_9.cnt <= r_8.cnt * 0.5;

-- 전국 카페 주소 데이터 정제하기
SELECT SUBSTRING_INDEX(address, ' ', 1) AS sido
      , SUBSTRING_INDEX(SUBSTRING_INDEX(address, ' ', 2), ' ', -1) AS sigungu
      , COUNT(cafe_id) AS cnt
FROM cafes
GROUP BY sido, sigungu
ORDER BY cnt DESC;

-- 미세먼지 수치의 계절간 차이
WITH ss AS(
  SELECT CASE
              WHEN measured_at BETWEEN '2022-03-01' AND '2022-05-31' THEN 'spring'
              WHEN measured_at BETWEEN '2022-06-01' AND '2022-08-31' THEN 'summer'
              WHEN measured_at BETWEEN '2022-09-01' AND '2022-11-30' THEN 'autumn'
              ELSE 'winter'
        END AS season
        , pm10
  FROM measurements
), mv AS(
  SELECT season
        , pm10
        , ROW_NUMBER() OVER(PARTITION BY season ORDER BY pm10) AS rn
        , COUNT(*) OVER(PARTITION BY season) AS total
  FROM ss
)
SELECT mv.season
      , mv.pm10 AS pm10_median
      , ROUND(AVG(ss.pm10), 2) AS pm10_average
FROM mv
  INNER JOIN ss ON mv.season = ss.season
WHERE mv.rn IN (CEIL((mv.total + 1) / 2), FLOOR((mv.total + 1) / 2))
GROUP BY mv.season, pm10_median;

-- 친구 수 집계하기
WITH cte AS(
  SELECT u.user_id
        , e.user_b_id AS f_id
  FROM users AS u
    LEFT JOIN edges AS e ON u.user_id = e.user_a_id

  UNION ALL 

  SELECT u.user_id
        , e.user_a_id
  FROM users AS u
    LEFT JOIN edges AS e ON u.user_id = e.user_b_id
)
SELECT user_id
      , COUNT(f_id) AS num_friends
FROM cte
GROUP BY user_id
ORDER BY num_friends DESC, user_id;