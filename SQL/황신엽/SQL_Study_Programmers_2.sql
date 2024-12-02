-- 특정 기간동안 대여 가능한 자동차들의 대여비용 구하기
WITH cte AS (
  SELECT c.car_id
        , c.car_type
        , c.daily_fee
  FROM car_rental_company_car AS c
    INNER JOIN car_rental_company_rental_history AS h ON c.car_id = h.car_id
WHERE c.car_type IN ('세단', 'SUV')
  AND c.car_id NOT IN (SELECT car_id
                       FROM car_rental_company_rental_history
                       WHERE start_date <= '2022-11-30' 
                         AND end_date >='2022-11-01')
),cte2 AS (
  SELECT DISTINCT c.car_id
        , c.car_type
        , ROUND((c.daily_fee * (1 - (p.discount_rate / 100))) * 30) AS fee
  FROM cte AS c
    INNER JOIN car_rental_company_discount_plan AS p ON c.car_type = p.car_type
  WHERE p.duration_type = '30일 이상'
)
SELECT *
FROM cte2
WHERE fee >= 500000 
  AND fee < 2000000
ORDER BY fee DESC, car_type ASC, car_id DESC;

-- 주문량이 많은 아이스크림들 조회하기
WITH total AS(
  SELECT flavor
        , SUM(total_order) AS total
  FROM first_half
  GROUP BY flavor

  UNION ALL

  SELECT flavor
        , SUM(total_order) AS total
  FROM july
  GROUP BY flavor
)
SELECT flavor
FROM total
GROUP BY flavor
ORDER BY SUM(total) DESC
LIMIT 3;

-- 상품을 구매한 회원 비율 구하기
SELECT YEAR(o.sales_date) AS year
      , MONTH(o.sales_date) AS month
      , COUNT(DISTINCT o.user_id) AS purchased_users
      , ROUND(COUNT(DISTINCT o.user_id) / (SELECT COUNT(user_id) FROM user_info WHERE LEFT(joined, 4) = '2021'), 1) AS puchased_ratio
FROM user_info AS u
  INNER JOIN online_sale AS o ON u.user_id = o.user_id
WHERE LEFT(u.joined, 4) = '2021'
GROUP BY year, month
ORDER BY year, month;