-- 복수 국적 메달 수상한 선수 찾기
SELECT a.name
FROM records AS r
  INNER JOIN athletes AS a ON r.athlete_id = a.id
  INNER JOIN games AS g ON r.game_id = g.id
WHERE g.year >= 2000
  AND r.medal IS NOT NULL
GROUP BY a.id
HAVING COUNT(DISTINCT r.team_id) >= 2
ORDER BY a.name;

-- 할부는 몇 개월로 해드릴까요
SELECT payment_installments
      , COUNT(DISTINCT order_id) AS order_count
      , MIN(payment_value) AS min_value
      , MAX(payment_value) AS max_value
      , AVG(payment_value) AS avg_value
FROM olist_order_payments_dataset
WHERE payment_type = 'credit_card'
GROUP BY payment_installments;

-- RFM 분석 3단계. 떠나간 VIP
WITH RFM AS (
  SELECT 
    CASE 
      WHEN DATEDIFF('2021-01-01', last_order_date) <= 31 THEN 'recent'
      ELSE 'past' 
    END AS recency,

    CASE
      WHEN cnt_orders >= 3 THEN 'high'
      ELSE 'low'
    END AS frequency,

    CASE
      WHEN sum_sales >= 500 THEN 'high'
      ELSE 'low'
    END AS monetary,

    customer_id
  FROM customer_stats
)
SELECT 
  recency, 
  frequency, 
  monetary, 
  COUNT(customer_id) AS customers
FROM RFM
GROUP BY recency, frequency, monetary
HAVING (recency = 'recent' AND frequency = 'high' AND monetary = 'high')
  OR (recency = 'past' AND frequency = 'high' AND monetary = 'high')
ORDER BY recency DESC;

-- 지역별 주문의 특징
SELECT region AS Region
      , COUNT(DISTINCT CASE WHEN category = 'Furniture' THEN order_id END) AS Furniture
      , COUNT(DISTINCT CASE WHEN category = 'Office Supplies' THEN order_id END) AS 'Office Supplies'
      , COUNT(DISTINCT CASE WHEN category = 'Technology' THEN order_id END) AS Technology
FROM records
GROUP BY Region
ORDER BY Region;

-- 배송 예정일 예측 성공과 실패
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m-%d') AS purchase_date
      , COUNT(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN order_id END) AS success
      , COUNT(DISTINCT CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN order_id END) AS fail
FROM olist_orders_dataset
WHERE order_purchase_timestamp LIKE '2017-01%'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY purchase_date
ORDER BY purchase_date

-- 쇼핑몰의 일일 매출액과 ARPPU
SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-%d') AS dt
      , COUNT(DISTINCT o.customer_id) AS pu
      , ROUND(SUM(p.payment_value), 2) AS revenue_daily
      , ROUND(SUM(p.payment_value) / COUNT(DISTINCT o.customer_id), 2) AS arppu
FROM olist_orders_dataset AS o
  INNER JOIN olist_order_payments_dataset AS p ON o.order_id = p.order_id
WHERE order_purchase_timestamp >= '2018-01-01'
GROUP BY dt
ORDER BY dt;

-- 멘토링 짝꿍 리스트
WITH mentee AS(
  SELECT employee_id AS mentee_id
        , name AS mentee_name
        , department
  FROM employees
  WHERE join_date >= '2021-10-01'
)
, mentor AS(
  SELECT employee_id AS mentor_id
        , name AS mentor_name
        , department
  FROM employees
  WHERE join_date <= '2019-12-31'
)
SELECT e.mentee_id
      , e.mentee_name
      , r.mentor_id
      , r.mentor_name
FROM mentee AS e
  LEFT JOIN mentor AS r ON e.department != r.department
ORDER BY mentee_id, mentor_id;

-- 작품이 없는 작가 찾기
SELECT a.artist_id
      , a.name
FROM artists AS a
  LEFT JOIN artworks_artists AS aa ON a.artist_id = aa.artist_id
WHERE a.death_year IS NOT NULL
  AND aa.artist_id IS NULL;
  
-- 일주일 후 안내 메일 발송 건수 계산하기
SELECT 
  DATE_ADD(license_issue_date, INTERVAL 7 DAY) AS email_send_date, 
  COUNT(DISTINCT license_number) AS email_cnts
FROM seattle_pet_licenses
WHERE license_issue_date >= '2016-10-01'
GROUP BY DATE_ADD(license_issue_date, INTERVAL 7 DAY)
ORDER BY email_send_date ASC;

-- Amy는 이 영화를 어디서 볼까?
SELECT 
  title, 
  year, 
  genres, 
  directors, 
  CASE 
    WHEN netflix = 1 THEN 'netflix'
    WHEN prime_video = 1 THEN 'prime_video'
    WHEN disney_plus = 1 THEN 'disney_plus'
    ELSE 'hulu'
  END AS platform
FROM movies
WHERE year = '2021'
ORDER BY title ASC;

-- 바겐 세일!
SELECT order_date, SUM(CASE WHEN discount >= 0.8 THEN quantity END) AS big_discount_items ,SUM(quantity) AS all_items
FROM records
GROUP BY order_date
HAVING big_discount_items >= 1
  AND all_items >= 10
ORDER BY big_discount_items DESC;

-- 오스트리안 고객들의 환불 금액
SELECT ABS(SUM(price * quantity)) AS refund_austria
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
JOIN order_items t
ON o.order_id = t.order_id
WHERE o.order_id LIKE 'C%' AND country = 'Austria';

-- 국가 별 판매 금액
SELECT c.country, SUM(price * quantity) AS sales
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
JOIN order_items t
ON o.order_id = t.order_id
WHERE DATE_FORMAT(o.order_date, '%Y-%m') = '2019-01' AND o.order_id NOT LIKE 'C%'
GROUP BY c.country
ORDER BY sales DESC;

-- 온라인 쇼핑몰의 월 별 매출액 집계
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month
      , SUM(CASE WHEN oi.order_id NOT LIKE 'C%' THEN oi.price * oi.quantity END) AS ordered_amount
      , SUM(CASE WHEN oi.order_id LIKE 'C%' THEN oi.price * oi.quantity END) AS canceled_amount
      , SUM(oi.price * oi.quantity) AS total_amount
FROM orders AS o
  INNER JOIN order_items AS oi ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month;

-- 게임 평점 예측하기 1
WITH CTE AS(
  SELECT genre_id
        , ROUND(avg(critic_score), 3) AS avg_critic_score
        , CEILING(avg(critic_count)) AS avg_critic_count
        , ROUND(avg(user_score), 3) AS avg_user_score
        , CEILING(avg(user_count)) AS avg_user_count
  FROM games
  GROUP BY genre_id
)
SELECT g.game_id
      , g.name
      , CASE WHEN g.critic_score IS NULL THEN c.avg_critic_score ELSE g.critic_score END AS critic_score
      , CASE WHEN g.critic_count IS NULL THEN c.avg_critic_count ELSE g.critic_count END AS critic_count
      , CASE WHEN g.user_score IS NULL THEN c.avg_user_score ELSE g.user_score END AS user_score
      , CASE WHEN g.user_count IS NULL THEN c.avg_user_count ELSE g.user_count END AS user_count
FROM games AS g
  INNER JOIN CTE AS c ON g.genre_id = c.genre_id
WHERE g.year >= 2015
  AND (critic_score IS NULL
  OR user_score IS NULL);

-- 서울숲 요일별 대기오염도 계산하기
SELECT CASE 
            WHEN DATE_FORMAT(measured_at, '%w') = 1 THEN '월요일'
            WHEN DATE_FORMAT(measured_at, '%w') = 2 THEN '화요일'
            WHEN DATE_FORMAT(measured_at, '%w') = 3 THEN '수요일'
            WHEN DATE_FORMAT(measured_at, '%w') = 4 THEN '목요일'
            WHEN DATE_FORMAT(measured_at, '%w') = 5 THEN '금요일'
            WHEN DATE_FORMAT(measured_at, '%w') = 6 THEN '토요일'
            WHEN DATE_FORMAT(measured_at, '%w') = 0 THEN '일요일'
      END AS weekday
      , ROUND(AVG(no2), 4) AS no2
      , ROUND(AVG(o3), 4) AS o3
      , ROUND(AVG(co), 4) AS co
      , ROUND(AVG(so2), 4) AS so2
      , ROUND(AVG(pm10), 4) AS pm10
      , ROUND(AVG(pm2_5), 4) AS pm2_5
FROM measurements
GROUP BY weekday
ORDER BY CASE 
            WHEN weekday = '월요일' THEN 1
            WHEN weekday = '화요일' THEN 2
            WHEN weekday = '수요일' THEN 3
            WHEN weekday = '목요일' THEN 4
            WHEN weekday = '금요일' THEN 5
            WHEN weekday = '토요일' THEN 6
            WHEN weekday = '일요일' THEN 7
      END;

-- 폐쇄할 따릉이 정류소 찾기 2
WITH rental_18 AS(
  SELECT rent_station_id AS rid
        , COUNT(bike_id) AS rental_cnt
  FROM rental_history
  WHERE rent_at BETWEEN '2018-10-01' AND '2018-10-31 23:59:59'
  GROUP BY rent_station_id

  UNION ALL

  SELECT return_station_id AS rid
        , COUNT(bike_id) AS rental_cnt
  FROM rental_history
  WHERE rent_at BETWEEN '2018-10-01' AND '2018-10-31 23:59:59'
  GROUP BY return_station_id
), r18 AS(
  SELECT rid
        , SUM(rental_cnt) AS rental_18
  FROM rental_18
  GROUP BY rid
), rental_19 AS(
  SELECT rent_station_id AS rid
        , COUNT(bike_id) AS rental_cnt
  FROM rental_history
  WHERE rent_at BETWEEN '2019-10-01' AND '2019-10-31 23:59:59'
  GROUP BY rent_station_id

  UNION ALL

  SELECT return_station_id AS rid
        , COUNT(bike_id) AS rental_cnt
  FROM rental_history
  WHERE rent_at BETWEEN '2019-10-01' AND '2019-10-31 23:59:59'
  GROUP BY return_station_id
), r19 AS(
  SELECT rid
        , SUM(rental_cnt) AS rental_19
  FROM rental_19
  GROUP BY rid
)
SELECT s.station_id
      , s.name
      , s.local
      , ROUND(r19.rental_19 / r18.rental_18 * 100, 2) AS usage_pct 
FROM r18
  INNER JOIN r19 ON r19.rid = r18.rid
  INNER JOIN station AS s ON r18.rid = s.station_id
WHERE ROUND(r19.rental_19 / r18.rental_18 * 100, 2) <= 50;

-- 멀티 플랫폼 게임 찾기
SELECT g.name
FROM games AS g
  INNER JOIN platforms AS p ON g.platform_id = p.platform_id
WHERE g.year >= 2012
GROUP BY g.name
HAVING COUNT(DISTINCT CASE 
                  WHEN p.name IN ('PS3', 'PS4', 'PSP', 'PSV') THEN 'Sony'
                  WHEN p.name IN ('Wii', 'WiiU', 'DS', '3DS') THEN 'Nintendo'
                  WHEN p.name IN ('X360', 'XONE') THEN 'Microsoft'
            END) >= 2;

-- 전국 카페 주소 데이터 정제하기
SELECT SUBSTRING_INDEX(address, ' ', 1) AS sido
      , SUBSTRING_INDEX(SUBSTRING_INDEX(address, ' ', 2), ' ', -1) AS sigungu
      , COUNT(cafe_id) AS cnt
FROM cafes
GROUP BY sido, sigungu
ORDER BY cnt DESC;

-- 미세먼지 수치의 계절간 차이
WITH CTE1 AS(
  SELECT CASE
              WHEN measured_at BETWEEN '2022-03-01' AND '2022-05-31' THEN 'spring'
              WHEN measured_at BETWEEN '2022-06-01' AND '2022-08-31' THEN 'summer'
              WHEN measured_at BETWEEN '2022-09-01' AND '2022-11-30' THEN 'autumn'
              ELSE 'winter'
        END AS season
        , pm10
  FROM measurements
), CTE2 AS(
  SELECT season
        , pm10
        , ROW_NUMBER() OVER(PARTITION BY season ORDER BY pm10) AS r_num
        , COUNT(*) OVER(PARTITION BY season) AS total_cnt
  FROM CTE1
), CTE3 AS(
  SELECT season
        , AVG(pm10) AS pm10_median
  FROM CTE2
  WHERE r_num IN (FLOOR((total_cnt + 1) / 2), CEIL((total_cnt + 1) / 2))
  GROUP BY season
)
SELECT c1.season
      , c3.pm10_median
      , ROUND(AVG(c1.pm10), 2) AS pm10_average
FROM CTE1 AS c1
  LEFT JOIN CTE3 AS c3 ON c1.season = c3.season
GROUP BY c1.season, c3.pm10_median
ORDER BY CASE 
            WHEN c1.season = 'spring' THEN 1
            WHEN c1.season = 'summer' THEN 2
            WHEN c1.season = 'autumn' THEN 3
            WHEN c1.season = 'winter' THEN 4
      END;

-- 친구 수 집계하기
WITH CTE AS(
  SELECT user_a_id AS user_id
        , COUNT(*) AS cnt
  FROM edges
  GROUP BY user_a_id

  UNION ALL 

  SELECT user_b_id AS user_id
        , COUNT(*) AS cnt
  FROM edges
  GROUP BY user_b_id
)
SELECT u.user_id
      , IFNULL(SUM(c.cnt), 0) AS num_friends
FROM users AS u
  LEFT JOIN CTE AS c ON u.user_id = c.user_id
GROUP BY u.user_id
ORDER BY num_friends DESC, u.user_id;