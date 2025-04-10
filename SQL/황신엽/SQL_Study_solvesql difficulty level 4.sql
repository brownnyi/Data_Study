-- 가구 판매의 비중이 높았던 날 찾기
SELECT order_date
      , COUNT(DISTINCT CASE WHEN category = 'Furniture' THEN order_id END) AS furniture
      , ROUND(COUNT(DISTINCT CASE WHEN category = 'Furniture' THEN order_id END)
      / COUNT(DISTINCT order_id) * 100, 2) AS furniture_pct
FROM records
GROUP BY order_date
HAVING COUNT(DISTINCT order_id) >= 10
  AND furniture_pct >= 40
ORDER BY furniture_pct DESC, order_date;

-- 월별 주문 리텐션 (클래식 리텐션)
WITH cte1 AS(
  SELECT customer_id
        , DATE_FORMAT(MIN(order_date), '%Y-%m-01') AS first_order_month
  FROM records
  GROUP BY customer_id
), cte2 AS(
  SELECT c1.customer_id
        , c1.first_order_month
        , DATE_FORMAT(order_date, '%Y-%m-01') AS order_month
  FROM cte1 AS c1
    INNER JOIN records AS r ON c1.customer_id = r.customer_id
)
SELECT first_order_month
      , COUNT(DISTINCT customer_id) AS month0
      , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 1 MONTH) THEN customer_id END) AS month1
      , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 2 MONTH) THEN customer_id END) AS month2
      , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 3 MONTH) THEN customer_id END) AS month3
      , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 4 MONTH) THEN customer_id END) AS month4
      , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 5 MONTH) THEN customer_id END) AS month5
      , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 6 MONTH) THEN customer_id END) AS month6
      , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 7 MONTH) THEN customer_id END) AS month7
      , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 8 MONTH) THEN customer_id END) AS month8
      , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 9 MONTH) THEN customer_id END) AS month9
      , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 10 MONTH) THEN customer_id END) AS month10
      , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 11 MONTH) THEN customer_id END) AS month11
FROM cte2
GROUP BY first_order_month;

-- 온라인 쇼핑몰의 Stickiness
SELECT d.order_date AS dt
      , COUNT(DISTINCT d.customer_id) AS dau
      , COUNT(DISTINCT w.customer_id) AS wau
      , ROUND(COUNT(DISTINCT d.customer_id) / COUNT(DISTINCT w.customer_id), 2) AS stickiness
FROM records AS d
  LEFT JOIN records AS w ON w.order_date BETWEEN DATE_SUB(d.order_date, INTERVAL 6 DAY) AND d.order_date
WHERE d.order_date BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY d.order_date
ORDER BY d.order_date;

-- 월별 주문 리텐션 (롤링 리텐션)
WITH cte1 AS(
  SELECT customer_id
        , DATE_FORMAT(MIN(order_date), '%Y-%m-01') AS first_order_month
        , DATE_FORMAT(MAX(order_date), '%Y-%m-01') AS last_order_month
  FROM records
  GROUP BY customer_id
), cte2 AS(
  SELECT c1.customer_id
        , c1.first_order_month
        , c1.last_order_month
        , DATE_FORMAT(r.order_date, '%Y-%m-01') AS order_month
  FROM cte1 AS c1
    INNER JOIN records AS r ON c1.customer_id = r.customer_id
)
SELECT first_order_month
      , COUNT(DISTINCT customer_id) AS month0
      , COUNT(DISTINCT CASE WHEN last_order_month >= DATE_ADD(first_order_month, INTERVAL 1 MONTH) THEN customer_id END) AS month1
      , COUNT(DISTINCT CASE WHEN last_order_month >= DATE_ADD(first_order_month, INTERVAL 2 MONTH) THEN customer_id END) AS month2
      , COUNT(DISTINCT CASE WHEN last_order_month >= DATE_ADD(first_order_month, INTERVAL 3 MONTH) THEN customer_id END) AS month3
      , COUNT(DISTINCT CASE WHEN last_order_month >= DATE_ADD(first_order_month, INTERVAL 4 MONTH) THEN customer_id END) AS month4
      , COUNT(DISTINCT CASE WHEN last_order_month >= DATE_ADD(first_order_month, INTERVAL 5 MONTH) THEN customer_id END) AS month5
      , COUNT(DISTINCT CASE WHEN last_order_month >= DATE_ADD(first_order_month, INTERVAL 6 MONTH) THEN customer_id END) AS month6
      , COUNT(DISTINCT CASE WHEN last_order_month >= DATE_ADD(first_order_month, INTERVAL 7 MONTH) THEN customer_id END) AS month7
      , COUNT(DISTINCT CASE WHEN last_order_month >= DATE_ADD(first_order_month, INTERVAL 8 MONTH) THEN customer_id END) AS month8
      , COUNT(DISTINCT CASE WHEN last_order_month >= DATE_ADD(first_order_month, INTERVAL 9 MONTH) THEN customer_id END) AS month9
      , COUNT(DISTINCT CASE WHEN last_order_month >= DATE_ADD(first_order_month, INTERVAL 10 MONTH) THEN customer_id END) AS month10
      , COUNT(DISTINCT CASE WHEN last_order_month >= DATE_ADD(first_order_month, INTERVAL 11 MONTH) THEN customer_id END) AS month11
FROM cte2
GROUP BY first_order_month
ORDER BY first_order_month;

-- 입문반 페이지를 본 세션 찾기
SELECT COUNT(DISTINCT user_pseudo_id, ga_session_id) AS total
      , COUNT(DISTINCT user_pseudo_id, ga_session_id) - COUNT(DISTINCT CASE WHEN page_title = '백문이불여일타 SQL 캠프 입문반' AND event_name = 'page_view' THEN CONCAT(user_pseudo_id, ga_session_id) END) AS pv_no
      , COUNT(DISTINCT CASE WHEN page_title = '백문이불여일타 SQL 캠프 입문반' AND event_name = 'page_view' THEN CONCAT(user_pseudo_id, ga_session_id) END) AS pv_yes
FROM ga;

-- 페이지에서 스크롤을 내렸을까?
WITH pv AS(
  SELECT user_pseudo_id
        , ga_session_id
  FROM ga
  WHERE page_title = '백문이불여일타 SQL 캠프 입문반'
    AND event_name = 'page_view'
), scroll AS(
  SELECT user_pseudo_id
        , ga_session_id
  FROM ga
  WHERE page_title = '백문이불여일타 SQL 캠프 입문반'
    AND event_name = 'scroll'
)
SELECT COUNT(DISTINCT g.user_pseudo_id, g.ga_session_id) AS total
      , COUNT(DISTINCT g.user_pseudo_id, g.ga_session_id) - COUNT(DISTINCT p.user_pseudo_id, p.ga_session_id) AS pv_no
      , COUNT(DISTINCT p.user_pseudo_id, p.ga_session_id) - COUNT(DISTINCT s.user_pseudo_id, s.ga_session_id) AS pv_yes_scroll_no
      , COUNT(DISTINCT s.user_pseudo_id, s.ga_session_id) AS pv_yes_scroll_yes
FROM ga AS g
  LEFT JOIN pv AS p ON g.user_pseudo_id = p.user_pseudo_id AND g.ga_session_id = p.ga_session_id
  LEFT JOIN scroll AS s ON p.user_pseudo_id = s.user_pseudo_id AND p.ga_session_id = s.ga_session_id;

-- 레스토랑 요일 별 구매금액 Top 3 영수증
WITH cte AS(
  SELECT day
        , time
        , sex
        , total_bill
        , DENSE_RANK() OVER(PARTITION BY day ORDER BY total_bill DESC) AS d_rank
  FROM tips
)
SELECT day
      , time
      , sex
      , total_bill
FROM cte
WHERE d_rank IN (1, 2, 3);

-- 게임 개발사의 주력 플랫폼 찾기
WITH rk AS(
  SELECT c.name AS developer
        , p.name AS platform
        , SUM(g.sales_eu + g.sales_jp + g.sales_na + g.sales_other) AS sales
        , DENSE_RANK() OVER(PARTITION BY c.name ORDER BY SUM(g.sales_eu + g.sales_jp + g.sales_na + g.sales_other) DESC) AS d_rank
  FROM games AS g
    INNER JOIN companies AS c ON g.developer_id = c.company_id
    INNER JOIN platforms AS p ON g.platform_id = p.platform_id
  GROUP BY g.developer_id, g.platform_id
)
SELECT developer
      , platform
      , sales
FROM rk
WHERE d_rank = 1;

-- 전력 소비량 이동 평균 구하기
SELECT p2.measured_at AS end_at
      , ROUND(AVG(p1.zone_quads) OVER(ORDER BY p2.measured_at ROWS BETWEEN 5 PRECEDING AND CURRENT ROW), 2) AS zone_quads
      , ROUND(AVG(p1.zone_smir) OVER(ORDER BY p2.measured_at ROWS BETWEEN 5 PRECEDING AND CURRENT ROW), 2) AS zone_smir
      , ROUND(AVG(p1.zone_boussafou) OVER(ORDER BY p2.measured_at ROWS BETWEEN 5 PRECEDING AND CURRENT ROW), 2) AS zone_boussafou
FROM power_consumptions AS p1
  LEFT JOIN power_consumptions AS p2 ON p1.measured_at = DATE_SUB(p2.measured_at, INTERVAL 10 MINUTE)
WHERE p2.measured_at BETWEEN '2017-01-01 00:00:00' AND '2017-02-01 00:00:00';

-- 펭귄 날개와 몸무게의 상관 계수
WITH penguins_avg AS (
    SELECT species,
           flipper_length_mm,
           body_mass_g,
           AVG(flipper_length_mm) OVER (PARTITION BY species) AS avg_flipper,
           AVG(body_mass_g) OVER (PARTITION BY species) AS avg_body
    FROM penguins
)
SELECT species,
       ROUND(SUM((flipper_length_mm - avg_flipper) * (body_mass_g - avg_body)) /
       SQRT(SUM(POWER(flipper_length_mm - avg_flipper, 2)) * SUM(POWER(body_mass_g - avg_body, 2))), 3) AS corr
FROM penguins_avg
GROUP BY species;

-- 유량(Flow)와 저량(Stock)
WITH cte AS(
  SELECT year(acquisition_date) AS 'Acquisition year'
        , COUNT(artwork_id) AS 'New acquisitions this year (Flow)'
  FROM artworks
  WHERE acquisition_date IS NOT NULL
  GROUP BY 1
)
SELECT `Acquisition year`
      , `New acquisitions this year (Flow)`
      , SUM(`New acquisitions this year (Flow)`) OVER(ORDER BY `Acquisition year`) AS 'Total collection size (Stock)'
FROM cte;

-- 세 명이 서로 친구인 관계 찾기
SELECT DISTINCT e1.user_a_id AS user_a_id
      , e1.user_b_id AS user_b_id
      , e2.user_b_id AS user_c_id
FROM edges AS e1
  INNER JOIN edges AS e2 ON e1.user_b_id = e2.user_a_id
  INNER JOIN edges AS e3 ON e2.user_b_id = e3.user_b_id AND e1.user_a_id = e3.user_a_id
WHERE e1.user_a_id < e1.user_b_id
  AND e1.user_b_id < e2.user_b_id
  AND (e1.user_a_id = 3820 OR e1.user_b_id = 3820 OR e2.user_b_id = 3820);