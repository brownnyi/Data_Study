-- 문제 상황1: order_id 하나당 customer_id가 하나여야 하는데 그러지 못한 order_id들이 1319개 있음
-- 해결 방법1: 엑셀 파일에서 수식을 사용해서 중복이 있는 order_id에 대해서는 customer_id의 뒤의 5자리를 order_id에 결합하여 서로 구분할 수 있도록 함
-- 수정후 onlinesales2라는 테이블로 새로 업로드
SELECT order_id
      , COUNT(DISTINCT customer_id) AS cnts
FROM e_commerce_project.onlinesales
GROUP BY order_id
HAVING cnts > 1
ORDER BY order_id;

-- 해결 방법2: SQL쿼리로 중복이 있는 order_id에 대해서는 customer_id의 뒤의 5자리를 order_id에 결합하여 서로 구분할 수 있도록 함
CREATE OR REPLACE TABLE e_commerce_project.onlinesales3 AS(
  WITH double_order AS(
    SELECT order_id
          , COUNT(DISTINCT customer_id) AS cnts
    FROM e_commerce_project.onlinesales
    GROUP BY order_id
  )
  SELECT o.customer_id
        , CASE 
              WHEN do.cnts > 1 THEN CONCAT(o.order_id, RIGHT(o.customer_id, 5)) 
              ELSE o.order_id
        END AS new_order_id
        , o.date
        , o.product_id
        , o.category
        , o.quantity
        , o.avg_cost
        , o.shipping_fee
        , o.coupon_status
  FROM e_commerce_project.onlinesales AS o
    LEFT JOIN double_order AS do ON o.order_id = do.order_id
);

-- 문제 상황2: onlinesales2와 discount 테이블을 조인할 컬럼이 없어 오류 발생
-- (category로 조인하면 같은 onlinesales2 테이블 한 행당 discount 테이블의 month 12개가 조인되어 month로 조인 필)
-- 해결 방법: 
-- 1단계: discount 테이블의 month를 숫자 형태로 변환한 month_numeric 컬럼 생성
CREATE OR REPLACE TABLE e_commerce_project.discount AS( -- discount 테이블이 없으면 새로 만들고, 있으면 덮어쓰기
SELECT *,
  CASE 
    WHEN month = 'Jan' THEN '01'
    WHEN month = 'Feb' THEN '02'
    WHEN month = 'Mar' THEN '03'
    WHEN month = 'Apr' THEN '04'
    WHEN month = 'May' THEN '05'
    WHEN month = 'Jun' THEN '06'
    WHEN month = 'Jul' THEN '07'
    WHEN month = 'Aug' THEN '08'
    WHEN month = 'Sep' THEN '09'
    WHEN month = 'Oct' THEN '10'
    WHEN month = 'Nov' THEN '11'
    WHEN month = 'Dec' THEN '12'
  END AS month_numeric -- 새로운 컬럼 추가
FROM e_commerce_project.discount
);

-- 2단계: onlinesales2 테이블의 date 컬럼을 기준으로 month 컬럼 생성
CREATE OR REPLACE TABLE e_commerce_project.onlinesales2 AS(      
  SELECT *
        , FORMAT_DATE('%m', date) AS month
  FROM e_commerce_project.onlinesales2
);

-- 3단계: 조인 확인
SELECT *
FROM e_commerce_project.onlinesales2 AS o
  INNER JOIN e_commerce_project.discount AS d ON o.month = d.month_numeric
  AND o.category = d.category;
