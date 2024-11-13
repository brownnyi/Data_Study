-- RFM
-- 전체 테이블을 조인하기(marketing 테이블 제외)
SELECT *
FROM e_commerce_project.onlinesales2 AS o
  LEFT JOIN e_commerce_project.customer AS c ON o.customer_id = c.customer_id
  LEFT JOIN e_commerce_project.discount AS d ON o.month = d.month_numeric AND o.category = d.category
  LEFT JOIN e_commerce_project.tax AS t ON o.category = t.category;

-- Recency 구하기(2020-01-01 - 고객별 마지막 주문일)
WITH date_criteria AS(
  SELECT MAX(date)+1 AS total_last_order_date
  FROM e_commerce_project.onlinesales2
)
SELECT customer_id
      , MAX(date) AS last_order_date
      , DATE_DIFF(MAX(total_last_order_date), MAX(date), DAY) AS Recency
FROM e_commerce_project.onlinesales2
  CROSS JOIN date_criteria
GROUP BY customer_id;

-- Frequency 구하기
SELECT customer_id
      , COUNT(DISTINCT new_order_id) AS Frequency
FROM e_commerce_project.onlinesales2
GROUP BY customer_id;

-- Monetary 구하기(계산식: 수량*평균비용*(1-할인율/100)+수량*평균비용*(1-할인율/100)*세율+배송비)
-- 할인율은 쿠폰 상태가 Used일때만 적용, 배송비는 new_order_id당 한번만 더하기
-- 1단계: 배송비를 제외하고 전부 계산
SELECT o.customer_id
      , o.new_order_id
      , SUM(CASE
            WHEN d.discount_rate IS NULL THEN o.quantity*o.avg_cost+o.quantity*o.avg_cost*t.gst
            WHEN o.coupon_status = 'Used' THEN o.quantity*o.avg_cost*(1-d.discount_rate/100)+o.quantity*o.avg_cost*(1-d.discount_rate/100)*t.gst
            WHEN o.coupon_status <> 'Used' THEN o.quantity*o.avg_cost+o.quantity*o.avg_cost*t.gst
      END) subtotal_sales
FROM e_commerce_project.onlinesales2 AS o
  LEFT JOIN e_commerce_project.customer AS c ON o.customer_id = c.customer_id
  LEFT JOIN e_commerce_project.discount AS d ON o.month = d.month_numeric AND o.category = d.category
  LEFT JOIN e_commerce_project.tax AS t ON o.category = t.category
GROUP BY o.customer_id, o.new_order_id;

-- 2단계: 서브쿼리로 배송비 계산
WITH subtotal_sales AS (
  SELECT o.customer_id
        , o.new_order_id
        , SUM(CASE
              WHEN d.discount_rate IS NULL THEN o.quantity*o.avg_cost+o.quantity*o.avg_cost*t.gst
              WHEN o.coupon_status = 'Used' THEN o.quantity*o.avg_cost*(1-d.discount_rate/100)+o.quantity*o.avg_cost*(1-d.discount_rate/100)*t.gst
              WHEN o.coupon_status <> 'Used' THEN o.quantity*o.avg_cost+o.quantity*o.avg_cost*t.gst
        END) subtotal_sales
  FROM e_commerce_project.onlinesales2 AS o
    LEFT JOIN e_commerce_project.customer AS c ON o.customer_id = c.customer_id
    LEFT JOIN e_commerce_project.discount AS d ON o.month = d.month_numeric AND o.category = d.category
    LEFT JOIN e_commerce_project.tax AS t ON o.category = t.category
  GROUP BY o.customer_id, o.new_order_id
), shipping_fee AS (
  SELECT DISTINCT new_order_id
        , shipping_fee
  FROM e_commerce_project.onlinesales2
)
SELECT ss.customer_id
      , ss.new_order_id
      , ss.subtotal_sales + sf.shipping_fee AS total_sales
FROM shipping_fee AS sf
  INNER JOIN subtotal_sales AS ss ON sf.new_order_id = ss.new_order_id;

-- 3단계: 고객ID별로 Monetary 계산하기
WITH subtotal_sales AS (
  SELECT o.customer_id
        , o.new_order_id
        , SUM(CASE
              WHEN d.discount_rate IS NULL THEN o.quantity*o.avg_cost+o.quantity*o.avg_cost*t.gst
              WHEN o.coupon_status = 'Used' THEN o.quantity*o.avg_cost*(1-d.discount_rate/100)+o.quantity*o.avg_cost*(1-d.discount_rate/100)*t.gst
              WHEN o.coupon_status <> 'Used' THEN o.quantity*o.avg_cost+o.quantity*o.avg_cost*t.gst
        END) subtotal_sales
  FROM e_commerce_project.onlinesales2 AS o
    LEFT JOIN e_commerce_project.customer AS c ON o.customer_id = c.customer_id
    LEFT JOIN e_commerce_project.discount AS d ON o.month = d.month_numeric AND o.category = d.category
    LEFT JOIN e_commerce_project.tax AS t ON o.category = t.category
  GROUP BY o.customer_id, o.new_order_id
), shipping_fee AS (
  SELECT DISTINCT new_order_id
        , shipping_fee
  FROM e_commerce_project.onlinesales2
), total_sales AS(
  SELECT ss.customer_id
        , ss.new_order_id
        , ss.subtotal_sales + sf.shipping_fee AS total_sales
  FROM shipping_fee AS sf
    INNER JOIN subtotal_sales AS ss ON sf.new_order_id = ss.new_order_id
)
SELECT ts.customer_id
       , ROUND(SUM(ts.total_sales), 2) AS Monetary
FROM total_sales AS ts
GROUP BY customer_id;

-- RFM 
WITH subtotal_sales AS (
  SELECT o.customer_id
        , o.new_order_id
        , SUM(CASE
              WHEN d.discount_rate IS NULL THEN o.quantity*o.avg_cost+o.quantity*o.avg_cost*t.gst
              WHEN o.coupon_status = 'Used' THEN o.quantity*o.avg_cost*(1-d.discount_rate/100)+o.quantity*o.avg_cost*(1-d.discount_rate/100)*t.gst
              WHEN o.coupon_status <> 'Used' THEN o.quantity*o.avg_cost+o.quantity*o.avg_cost*t.gst
        END) subtotal_sales
  FROM e_commerce_project.onlinesales2 AS o
    LEFT JOIN e_commerce_project.customer AS c ON o.customer_id = c.customer_id
    LEFT JOIN e_commerce_project.discount AS d ON o.month = d.month_numeric AND o.category = d.category
    LEFT JOIN e_commerce_project.tax AS t ON o.category = t.category
  GROUP BY o.customer_id, o.new_order_id
), shipping_fee AS (
  SELECT DISTINCT new_order_id
        , shipping_fee
  FROM e_commerce_project.onlinesales2
), total_sales AS(
  SELECT ss.customer_id
        , ss.new_order_id
        , ss.subtotal_sales + sf.shipping_fee AS total_sales
  FROM shipping_fee AS sf
    INNER JOIN subtotal_sales AS ss ON sf.new_order_id = ss.new_order_id
), monetary AS(
  SELECT ts.customer_id
        , ROUND(SUM(ts.total_sales), 2) AS Monetary
  FROM total_sales AS ts
GROUP BY customer_id
), rf AS(
  SELECT o.customer_id
      , DATE_DIFF('2020-01-01', MAX(o.date), DAY) AS Recency
      , COUNT(DISTINCT o.new_order_id) AS Frequency
FROM e_commerce_project.onlinesales2 AS o
GROUP BY o.customer_id
)
SELECT rf.customer_id
      , rf.Recency
      , rf.Frequency
      , m.Monetary
FROM monetary AS m
  LEFT JOIN rf AS rf ON m.customer_id = rf.customer_id
ORDER BY customer_id

-- 별도의 rfm 테이블을 생성하여 사용
CREATE OR REPLACE TABLE e_commerce_project.rfm AS(
  WITH subtotal_sales AS (
  SELECT o.customer_id
        , o.new_order_id
        , SUM(CASE
              WHEN d.discount_rate IS NULL THEN o.quantity*o.avg_cost+o.quantity*o.avg_cost*t.gst
              WHEN o.coupon_status = 'Used' THEN o.quantity*o.avg_cost*(1-d.discount_rate/100)+o.quantity*o.avg_cost*(1-d.discount_rate/100)*t.gst
              WHEN o.coupon_status <> 'Used' THEN o.quantity*o.avg_cost+o.quantity*o.avg_cost*t.gst
        END) subtotal_sales
  FROM e_commerce_project.onlinesales2 AS o
    LEFT JOIN e_commerce_project.customer AS c ON o.customer_id = c.customer_id
    LEFT JOIN e_commerce_project.discount AS d ON o.month = d.month_numeric AND o.category = d.category
    LEFT JOIN e_commerce_project.tax AS t ON o.category = t.category
  GROUP BY o.customer_id, o.new_order_id
), shipping_fee AS (
  SELECT DISTINCT new_order_id
        , shipping_fee
  FROM e_commerce_project.onlinesales2
), total_sales AS(
  SELECT ss.customer_id
        , ss.new_order_id
        , ss.subtotal_sales + sf.shipping_fee AS total_sales
  FROM shipping_fee AS sf
    INNER JOIN subtotal_sales AS ss ON sf.new_order_id = ss.new_order_id
), monetary AS(
  SELECT ts.customer_id
        , ROUND(SUM(ts.total_sales), 2) AS Monetary
  FROM total_sales AS ts
GROUP BY customer_id
), rf AS(
  SELECT o.customer_id
        , DATE_DIFF('2020-01-01', MAX(o.date), DAY) AS Recency
        , COUNT(DISTINCT o.new_order_id) AS Frequency
  FROM e_commerce_project.onlinesales2 AS o
  GROUP BY o.customer_id
  )
  SELECT rf.customer_id
        , rf.Recency
        , rf.Frequency
        , m.Monetary
  FROM monetary AS m
    INNER JOIN rf AS rf ON m.customer_id = rf.customer_id
  ORDER BY customer_id
);

-- 사분위수와 이상치 공식(Q3 + 1.5 * IQR)을 활용한 고객 등급별 인원수 및 매출액
WITH rfm_criteria AS(
  SELECT PERCENTILE_CONT(Frequency, 0.25) OVER() AS frequency_q1    -- 5
    , PERCENTILE_CONT(Frequency, 0.5) OVER() AS frequency_q2        -- 11
    , PERCENTILE_CONT(Frequency, 0.75) OVER() AS frequency_q3       -- 23
    , PERCENTILE_CONT(Frequency, 0.75) OVER() + 1.5 * (PERCENTILE_CONT(Frequency, 0.75) OVER() - PERCENTILE_CONT(Frequency, 0.25) OVER()) AS frequency_upper_bound                                               -- 50
    , PERCENTILE_CONT(Monetary, 0.25) OVER() AS monetary_q1         -- 713.7175
    , PERCENTILE_CONT(Monetary, 0.5) OVER() AS monetary_q2          -- 1889.5550
    , PERCENTILE_CONT(Monetary, 0.75) OVER() AS monetary_q3         -- 4249.4350
    , PERCENTILE_CONT(Monetary, 0.75) OVER() + 1.5 * (PERCENTILE_CONT(Monetary, 0.75) OVER() - PERCENTILE_CONT(Monetary, 0.25) OVER()) AS monetary_upper_bound                                                -- 9611.21875
  FROM e_commerce_project.rfm
  LIMIT 1
), rfm_score AS(
  SELECT rfm.*
        , CASE 
              WHEN rfm.Recency <= 92 THEN '활성 고객'
              ELSE '이탈 고객' END AS customer_status
        , CASE
              WHEN rfm.Frequency >= rfm_criteria.frequency_upper_bound THEN 5 
              WHEN rfm.Frequency >= rfm_criteria.frequency_q3 THEN 4
              WHEN rfm.Frequency >= rfm_criteria.frequency_q2 THEN 3
              WHEN rfm.Frequency >= rfm_criteria.frequency_q1 THEN 2
              ELSE 1 END AS F_score
        , CASE 
              WHEN rfm.Monetary >= rfm_criteria.monetary_upper_bound THEN 'Black'
              WHEN rfm.Monetary >= rfm_criteria.monetary_q3 THEN 'Emerald'
              WHEN rfm.Monetary >= rfm_criteria.monetary_q2 THEN 'Purple'
              WHEN rfm.Monetary >= rfm_criteria.monetary_q1 THEN 'Red'
              ELSE 'Green' END AS customer_grade
  FROM e_commerce_project.rfm
    CROSS JOIN rfm_criteria
)
SELECT customer_status
      , F_score
      , customer_grade
      , COUNT(customer_id) AS customer_cnts
      , ROUND(SUM(Monetary), 2) AS sales
FROM rfm_score
GROUP BY customer_status, F_score, customer_grade
ORDER BY CASE
            WHEN customer_grade = 'Black' THEN 1
            WHEN customer_grade = 'Emerald' THEN 2
            WHEN customer_grade = 'Purple' THEN 3
            WHEN customer_grade = 'Red' THEN 4
            WHEN customer_grade = 'Green' THEN 5
         END, customer_status DESC, F_score DESC;

-- 사분위수와 이상치 공식(Q3 + 1.5 * IQR)을 활용한 고객 구분 테이블 생성
CREATE OR REPLACE TABLE e_commerce_project.rfm_segment AS (
  WITH rfm_criteria AS(
    SELECT PERCENTILE_CONT(Frequency, 0.25) OVER() AS frequency_q1    -- 5
      , PERCENTILE_CONT(Frequency, 0.5) OVER() AS frequency_q2        -- 11
      , PERCENTILE_CONT(Frequency, 0.75) OVER() AS frequency_q3       -- 23
      , PERCENTILE_CONT(Frequency, 0.75) OVER() + 1.5 * (PERCENTILE_CONT(Frequency, 0.75) OVER() - PERCENTILE_CONT(Frequency, 0.25) OVER()) AS frequency_upper_bound                                                 -- 50
      , PERCENTILE_CONT(Monetary, 0.25) OVER() AS monetary_q1         -- 713.7175
      , PERCENTILE_CONT(Monetary, 0.5) OVER() AS monetary_q2          -- 1889.5550
      , PERCENTILE_CONT(Monetary, 0.75) OVER() AS monetary_q3         -- 4249.4350
      , PERCENTILE_CONT(Monetary, 0.75) OVER() + 1.5 * (PERCENTILE_CONT(Monetary, 0.75) OVER() - PERCENTILE_CONT(Monetary, 0.25) OVER()) AS monetary_upper_bound                                                  -- 9611.21875
    FROM e_commerce_project.rfm
    LIMIT 1
  ), rfm_score AS(
    SELECT rfm.*
          , CASE 
                WHEN rfm.Recency <= 92 THEN '활성 고객'
                ELSE '이탈 고객' END AS customer_status
          , CASE
                WHEN rfm.Frequency >= rfm_criteria.frequency_upper_bound THEN 5 
                WHEN rfm.Frequency >= rfm_criteria.frequency_q3 THEN 4
                WHEN rfm.Frequency >= rfm_criteria.frequency_q2 THEN 3
                WHEN rfm.Frequency >= rfm_criteria.frequency_q1 THEN 2
                ELSE 1 END AS F_score
          , CASE 
                WHEN rfm.Monetary >= rfm_criteria.monetary_upper_bound THEN 'Black'
                WHEN rfm.Monetary >= rfm_criteria.monetary_q3 THEN 'Emerald'
                WHEN rfm.Monetary >= rfm_criteria.monetary_q2 THEN 'Purple'
                WHEN rfm.Monetary >= rfm_criteria.monetary_q1 THEN 'Red'
                ELSE 'Green' END AS customer_grade
    FROM e_commerce_project.rfm
      CROSS JOIN rfm_criteria
  )
  SELECT *
  FROM rfm_score
  ORDER BY customer_id
);