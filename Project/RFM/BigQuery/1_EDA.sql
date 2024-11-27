-- EDA
-- customer
SELECT *
FROM e_commerce_project.customer
LIMIT 10;

-- 성별별 유저 수 및 비율 확인
-- 여성:924명(64%), 남성:534명(36%) 여성 유저수가 더 많음
SELECT COUNT(CASE WHEN sex = 'female' THEN customer_id END) AS cnt_female
      , COUNT(CASE WHEN sex = 'male' THEN customer_id END) AS cnt_male
      , ROUND(COUNT(CASE WHEN sex = 'female' THEN customer_id END) / COUNT(*), 2) AS pct_female
      , ROUND(COUNT(CASE WHEN sex = 'male' THEN customer_id END) / COUNT(*), 2) AS pct_male
FROM e_commerce_project.customer;

-- 가입기간별 유저수 분포 확인
-- 전반적으로 가입기간별로 총 유저에 큰 차이는 없음
-- 가입기간이 6, 12, 36개월 은 남성 유저가 여성 유저보다 많음
SELECT period
      , COUNT(customer_id) AS total_user
      , COUNT(CASE WHEN sex = 'female' THEN customer_id END) AS cnt_female
      , COUNT(CASE WHEN sex = 'male' THEN customer_id END) AS cnt_male
FROM e_commerce_project.customer
GROUP BY period;

-- 지역별 유저수 분포 확인
-- 캘리포니아>시카고>뉴욕>뉴저지>워싱턴DC 유저 수가 많음
SELECT local
      , COUNT(customer_id) AS total_user
      , COUNT(CASE WHEN sex = 'female' THEN customer_id END) AS cnt_female
      , COUNT(CASE WHEN sex = 'male' THEN customer_id END) AS cnt_male
FROM e_commerce_project.customer
GROUP BY local
ORDER BY total_user DESC;

-- 가입기간별 지역 분포 확인
SELECT period
      , COUNT(customer_id) AS total_user
      , COUNT(CASE WHEN local = 'California' THEN customer_id END) AS cnt_california
      , COUNT(CASE WHEN local = 'Chicago' THEN customer_id END) AS cnt_chicago
      , COUNT(CASE WHEN local = 'New York' THEN customer_id END) AS cnt_newyork
      , COUNT(CASE WHEN local = 'New Jersey' THEN customer_id END) AS cnt_newjersey
      , COUNT(CASE WHEN local = 'Washington DC' THEN customer_id END) AS cnt_washingtiondc
FROM e_commerce_project.customer
GROUP BY period
ORDER BY period;

-- discount
SELECT *
FROM e_commerce_project.discount;

-- 각 컬럼별 유니크 값 확인
SELECT COUNT(*) AS cnt_total
      , COUNT(DISTINCT month) AS cnt_month
      , COUNT(DISTINCT category) AS cnt_category
      , COUNT(DISTINCT coupon_code) AS cnt_coupon_code
      , COUNT(DISTINCT discount_rate) AS cnt_discount_rate
FROM e_commerce_project.discount;

-- 할인율에 무슨 값이 있는지 확인
-- 10, 20, 30만 있음
SELECT DISTINCT discount_rate
FROM e_commerce_project.discount;

-- 월별 할인율 확인
-- 1,4,7,10월은 10%
-- 2,5,8,11월은 20%
-- 3,6,9,12월은 30%로 할인율 고정됨
SELECT DISTINCT month
      , discount_rate
FROM e_commerce_project.discount; 

-- 카테고리별 쿠폰 코드 확인
-- Drinkware, Lifestyle의 쿠폰 코드가 'EXTRA**'로 동일한 것을 제외하면 모두 다름
SELECT DISTINCT category
      , coupon_code
FROM e_commerce_project.discount
ORDER BY category;

-- marketing
SELECT *
FROM e_commerce_project.marketing;

-- 각 컬럼별 유니크 값 확인
-- 오프라인 마케팅 비용은 정해진 비용이 있는 거 같음
-- 온라인 마케팅 비용은 매일 변함
SELECT COUNT(*) AS cnt_total
      , COUNT(DISTINCT date) AS cnt_date
      , COUNT(DISTINCT offline_cost) AS cnt_offline
      , COUNT(DISTINCT online_cost) AS cnt_online
FROM e_commerce_project.marketing;

-- 일별로 정렬해서 비용 비교해보기
-- 오프라인 마케팅 비용은 주단위로 주기를 가짐
SELECT *
FROM e_commerce_project.marketing
ORDER BY date;

-- 오프라인 마케팅 비용 값 확인
-- 500~5000까지 500씩 증가, 700 제외 
SELECT DISTINCT offline_cost
FROM e_commerce_project.marketing
ORDER BY offline_cost;

-- onlinesales2
SELECT *
FROM e_commerce_project.onlinesales2;

-- onlinesales와 onlinesales2 order_id 비교
-- 25061
SELECT COUNT(DISTINCT order_id)
FROM e_commerce_project.onlinesales;

-- 26631
SELECT COUNT(DISTINCT new_order_id)
FROM e_commerce_project.onlinesales2;

-- 컬럼별 유니크 값 확인
SELECT COUNT(*) AS cnt_total
      , COUNT(DISTINCT customer_id) AS cnt_customer_id
      , COUNT(DISTINCT new_order_id) AS cnt_new_order_id
      , COUNT(DISTINCT date) AS cnt_date
      , COUNT(DISTINCT product_id) AS cnt_product_id
      , COUNT(DISTINCT category) AS cnt_category
      , COUNT(DISTINCT quantity) AS cnt_quantity
      , COUNT(DISTINCT avg_cost) AS cnt_avg_cost
      , COUNT(DISTINCT shipping_fee) AS cnt_shipping_fee
      , COUNT(DISTINCT coupon_status) AS cnt_coupon_status
FROM e_commerce_project.onlinesales2;

-- discount, tax테이블의 category와 차이점 확인
-- tax, onlinesales2 테이블 Backpacks, Fun, Google, More Bags
-- discount 테이블 Notebooks
-- 추후 RFM 분석을 수행할 때는 onlinesales2 테이블을 기준으로 LEFT JOIN을 활용하여 'Notebooks' 카테고리는 사용X
SELECT DISTINCT category
FROM e_commerce_project.onlinesales2
ORDER BY category;

SELECT DISTINCT category
FROM e_commerce_project.discount
ORDER BY category;

SELECT DISTINCT category
FROM e_commerce_project.tax
ORDER BY category;

-- 쿠폰 상태 및 상태별 주문수 확인
-- Used: 17904 / Clicked: 26926 / Not Used: 8094
-- 쿠폰 사용이 적음
SELECT coupon_status
      , COUNT(customer_id)
FROM e_commerce_project.onlinesales2
GROUP BY coupon_status;

-- 할인율, 세율, 배송비를 고려하지 않은 총 매출액 확인 (quantity * avg_cost)
-- $ 4,670,794.62
SELECT ROUND(SUM(quantity * avg_cost), 2) AS total_sales
FROM e_commerce_project.onlinesales2;

-- 판매 기간 확인
-- 2019-01-01 ~ 2019-12-31
SELECT MIN(date)
      , MAX(date)
FROM e_commerce_project.onlinesales2;

-- 일자별 매출 추이 확인
SELECT date
      , ROUND(SUM(quantity * avg_cost), 2) AS daily_sales
FROM e_commerce_project.onlinesales2
GROUP BY date;

-- 고객별 평균 주문 주기 확인
WITH customer_orders AS(
  SELECT customer_id
        , date
        , ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY date) AS order_num
  FROM e_commerce_project.onlinesales2
  GROUP BY customer_id, date
)
SELECT c1.customer_id
      , c1.date AS order_date
      , c2.date AS next_order_date
      , DATE_DIFF(c2.date, c1.date, DAY) AS purchase_interval
FROM customer_orders AS c1
  LEFT JOIN customer_orders AS c2 ON c1.customer_id = c2.customer_id AND c2.order_num = c1.order_num + 1;

-- 전체 고객의 평균 주문 주기 확인
-- 대략 65일
WITH customer_orders AS(
  SELECT customer_id
        , date
        ,ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY date) AS order_num
  FROM e_commerce_project.onlinesales2
  GROUP BY customer_id, date
), purchase_intervals AS(
  SELECT c1.customer_id
        , DATE_DIFF(c2.date, c1.date, DAY) AS purchase_interval
  FROM customer_orders AS c1
    LEFT JOIN customer_orders AS c2 ON c1.customer_id = c2.customer_id AND c2.order_num = c1.order_num + 1
), purchase_interval_customers AS(
  SELECT customer_id
        , AVG(purchase_interval) AS avg_purchase_interval
  FROM purchase_intervals
  GROUP BY customer_id
  HAVING COUNT(*) >= 2
)
SELECT AVG(avg_purchase_interval) AS total_avg_purchase_interval
FROM purchase_interval_customers;

-- tax
SELECT *
FROM e_commerce_project.tax;
