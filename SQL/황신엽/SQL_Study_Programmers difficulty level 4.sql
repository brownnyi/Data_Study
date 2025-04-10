-- 특정 세대의 대장균 찾기
SELECT e1.id
FROM ecoli_data AS e1
  INNER JOIN ecoli_data AS e2 ON e1.parent_id = e2.id
  INNER JOIN ecoli_data AS e3 ON e2.parent_id = e3.id
WHERE e3.parent_id IS NULL
ORDER BY e1.id;

-- 연간 평가점수에 해당하는 평가 등급 및 성과금 조회하기
SELECT 
    e.emp_no,
    e.emp_name,
    CASE 
        WHEN s.avg_score >= 96 THEN 'S'
        WHEN s.avg_score >= 90 THEN 'A'
        WHEN s.avg_score >= 80 THEN 'B'
        ELSE 'C'
    END AS grade,
    CASE 
        WHEN s.avg_score >= 96 THEN e.sal * 0.2
        WHEN s.avg_score >= 90 THEN e.sal * 0.15
        WHEN s.avg_score >= 80 THEN e.sal * 0.1
        ELSE 0
    END AS bonus
FROM hr_employees AS e
JOIN (
    SELECT emp_no, AVG(score) AS avg_score
    FROM hr_grade
    WHERE year = 2022
    GROUP BY emp_no
) AS s ON e.emp_no = s.emp_no
ORDER BY e.emp_no;

-- 언어별 개발자 분류하기
WITH t AS(
  SELECT d.id
          , SUM(IF(s.name = 'Python', 1, 0)) AS p
          , SUM(IF(s.name = 'C#', 1, 0)) AS c
          , SUM(IF(s.category = 'Front End', 1, 0)) AS f
  FROM skillcodes AS s
    INNER JOIN developers AS d ON s.code & d.skill_code = s.code
  GROUP BY d.id
)
SELECT CASE 
            WHEN t.p >= 1 AND t.f >= 1 THEN 'A'
            WHEN t.c >= 1 THEN 'B'
            WHEN t.f >= 1 THEN 'C'
        END AS grade
        , d.id
        , d.email
FROM t
  INNER JOIN developers AS d ON t.id = d.id
WHERE t.c != 0 OR t.f != 0
ORDER BY grade, id;

-- FrontEnd 개발자 찾기
SELECT DISTINCT d.id
        , d.email
        , d.first_name
        , d.last_name
FROM skillcodes AS s
  INNER JOIN developers AS d ON s.code & d.skill_code = s.code
WHERE s.category = 'Front End'
ORDER BY d.id;

-- 특정 기간동안 대여 가능한 자동차들의 대여비용 구하기
WITH history AS(
  SELECT c.car_id
          , c.car_type
          , c.daily_fee
  FROM car_rental_company_car AS c
    INNER JOIN car_rental_company_rental_history AS h ON c.car_id = h.car_id
  WHERE c.car_type IN ('세단', 'SUV')
    AND c.car_id NOT IN (SELECT car_id 
                         FROM car_rental_company_rental_history
                         WHERE start_date <= '2022-11-30'
                           AND end_date >= '2022-11-01')
)
SELECT DISTINCT h.car_id
        , h.car_type
        , ROUND((h.daily_fee - (h.daily_fee * p.discount_rate * 0.01)) * 30) AS fee
FROM history AS h
  INNER JOIN car_rental_company_discount_plan AS p ON h.car_type = p.car_type
WHERE p.duration_type = '30일 이상'
HAVING fee >= 500000
  AND fee < 2000000
ORDER BY fee DESC, h.car_type, h.car_id DESC;

-- 자동차 대여 기록 별 대여 금액 구하기
WITH cte AS(
    SELECT c.car_id
            , c.car_type
            , c.daily_fee
            , h.history_id
            , DATEDIFF(h.end_date, h.start_date) + 1 AS date_diff
            , REPLACE(p.duration_type, RIGHT(p.duration_type, 4), '') AS duration_type
            , p.discount_rate
    FROM car_rental_company_car AS c
      INNER JOIN car_rental_company_rental_history AS h ON c.car_id = h.car_id
      INNER JOIN car_rental_company_discount_plan AS p ON c.car_type = p.car_type
    WHERE c.car_type = '트럭'
), cte2 AS(
  SELECT *
          , CASE 
                  WHEN date_diff >= duration_type THEN (daily_fee - (daily_fee * discount_rate * 0.01)) * date_diff
                  ELSE daily_fee * date_diff
          END AS fee
  FROM cte
)
SELECT history_id
        , ROUND(MIN(fee)) AS fee
FROM cte2
GROUP BY history_id
ORDER BY fee DESC, history_id DESC;

-- 저자 별 카테고리 별 매출액 집계하기
SELECT b.author_id
        , a.author_name
        , b.category
        , SUM(b.price * s.sales) AS total_sales
FROM book AS b
  INNER JOIN author AS a ON b.author_id = a.author_id
  INNER JOIN book_sales AS s ON b.book_id = s.book_id
WHERE s.sales_date BETWEEN '2022-01-01' AND '2022-01-31'
GROUP BY b.author_id, a.author_name, b.category
ORDER BY b.author_id, b.category DESC;

-- 주문량이 많은 아이스크림들 조회하기
WITH total AS(
  SELECT *
  FROM first_half

  UNION ALL

  SELECT *
  FROM july
)
SELECT flavor
FROM total
GROUP BY flavor
ORDER BY SUM(total_order) DESC
LIMIT 3;

-- 취소되지 않은 진료 예약 조회하기
SELECT a.apnt_no
        , p.pt_name
        , p.pt_no
        , a.mcdp_cd
        , d.dr_name
        , a.apnt_ymd
FROM appointment AS a
  INNER JOIN patient AS p ON a.pt_no = p.pt_no
  INNER JOIN doctor AS d ON a.mddr_id = d.dr_id
WHERE a.apnt_ymd LIKE '2022-04-13%'
  AND a.apnt_cncl_yn = 'N'
  AND a.mcdp_cd = 'CS'
ORDER BY a.apnt_ymd;

-- 오프라인/온라인 판매 데이터 통합하기
WITH cte AS(
  SELECT offline_sale_id AS id
          , NULL AS user_id
          , product_id
          , sales_amount
          , sales_date
  FROM offline_sale

  UNION ALL

  SELECT online_sale_id AS id
          , user_id
          , product_id
          , sales_amount
          , sales_date
  FROM online_sale
)
SELECT DATE_FORMAT(sales_date, '%Y-%m-%d') AS sales_date
        , product_id
        , user_id
        , sales_amount
FROM cte
WHERE sales_date BETWEEN '2022-03-01' AND '2022-03-31'
ORDER BY sales_date, product_id, user_id;

-- 년, 월, 성별 별 상품 구매 회원 수 구하기
SELECT YEAR(o.sales_date) AS year
        , MONTH(o.sales_date) AS month
        , u.gender
        , COUNT(DISTINCT o.user_id) AS users
FROM user_info AS u
  INNER JOIN online_sale AS o ON u.user_id = o.user_id
WHERE u.gender IS NOT NULL 
GROUP BY year, month, u.gender
ORDER BY year, month, u.gender;

-- 그룹별 조건에 맞는 식당 목록 출력하기
SELECT m.member_name
        , r.review_text
        , DATE_FORMAT(r.review_date, '%Y-%m-%d') AS review_date
FROM rest_review AS r
  INNER JOIN member_profile AS m ON r.member_id = m.member_id
WHERE m.member_id = (SELECT member_id 
                     FROM rest_review 
                     GROUP BY member_id  
                     ORDER BY COUNT(DISTINCT review_id) DESC
                     LIMIT 1)
ORDER BY review_date, r.review_text;

-- 서울에 위치한 식당 목록 출력하기
SELECT i.rest_id
        , i.rest_name
        , i.food_type
        , i.favorites
        , i.address
        , ROUND(AVG(r.review_score), 2) AS score
FROM rest_info AS i
  INNER JOIN rest_review AS r ON i.rest_id = r.rest_id
WHERE i.address LIKE '서울%'
GROUP BY i.rest_id, i.rest_name, i.food_type, i.favorites, i.address
ORDER BY score DESC, i.favorites DESC;

-- 5월 식품들의 총매출 조회하기
SELECT p.product_id
        , p.product_name
        , SUM(p.price * o.amount) AS total_sales
FROM food_product AS p
  INNER JOIN food_order AS o ON p.product_id = o.product_id
WHERE o.produce_date BETWEEN '2022-05-01' AND '2022-05-31'
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC, p.product_id;

-- 식품분류별 가장 비싼 식품의 정보 조회하기
SELECT category
        , price AS max_price
        , product_name
FROM food_product
WHERE (category, price) IN (SELECT category, MAX(price) 
                            FROM food_product 
                            WHERE category IN ('과자', '국', '김치', '식용유')
                            GROUP BY category)
ORDER BY max_price DESC;

-- 우유와 요거트가 담긴 장바구니
SELECT cart_id
FROM cart_products
WHERE name IN ('Milk', 'Yogurt')
GROUP BY cart_id
HAVING COUNT(DISTINCT name) = 2
ORDER BY cart_id;

-- 입양 시각 구하기(2)
WITH RECURSIVE cte AS(
SELECT 0 AS hour

UNION ALL

SELECT hour + 1 AS hour
FROM cte
WHERE hour < 23
)
SELECT c.hour
        , COUNT(animal_id) AS 'count'
FROM cte AS c
  LEFT JOIN animal_outs AS a ON c.hour = HOUR(a.datetime)
GROUP BY c.hour
ORDER BY c.hour;

-- 보호소에서 중성화한 동물
SELECT i.animal_id
        , i.animal_type
        , i.name
FROM animal_ins AS i
  INNER JOIN animal_outs AS o ON i.animal_id = o.animal_id
WHERE sex_upon_intake LIKE 'Intact%'
  AND (sex_upon_outcome LIKE 'Spayed%' OR sex_upon_outcome LIKE 'Neutered%')
ORDER BY i.animal_id;