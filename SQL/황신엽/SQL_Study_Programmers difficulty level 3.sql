-- 대장균의 크기에 따라 분류하기 2
WITH cte AS(
    SELECT id
            , size_of_colony
            , ROW_NUMBER() OVER(ORDER BY size_of_colony DESC) AS rk
            , COUNT(*) OVER() AS total_cnt
    FROM ecoli_data
)
SELECT id
        , CASE 
                WHEN rk / total_cnt <= 0.25 THEN 'CRITICAL'
                WHEN rk / total_cnt <= 0.5 THEN 'HIGH'
                WHEN rk / total_cnt <= 0.75 THEN 'MEDIUM'
                ELSE 'LOW'
            END AS colony_name
FROM cte
ORDER BY id;

-- 대장균의 크기에 따라 분류하기 1
SELECT id
        , CASE 
                WHEN size_of_colony <= 100 THEN 'LOW'
                WHEN size_of_colony <= 1000 THEN 'MEDIUM'
                ELSE 'HIGH'
            END AS size
FROM ecoli_data
ORDER BY id;

-- 대장균들의 자식의 수 구하기
SELECT e1.id
        , COUNT(e2.id) AS child_count
FROM ecoli_data AS e1
    LEFT JOIN ecoli_data AS e2 ON e1.id = e2.parent_id
GROUP BY e1.id
ORDER BY e1.id;

-- 특정 조건을 만족하는 물고기별 수와 최대 길이 구하기
SELECT COUNT(*) AS fish_count
        , MAX(length) AS max_length
        , fish_type
FROM fish_info
GROUP BY fish_type
HAVING AVG(IFNULL(length, 10)) >= 33
ORDER BY fish_type;

-- 물고기 종류 별 대어 찾기
SELECT i.id
        , n.fish_name
        , i.length
FROM fish_info AS i
    INNER JOIN fish_name_info AS n ON i.fish_type = n.fish_type
WHERE (i.fish_type, i.length) IN (SELECT fish_type, MAX(length) FROM fish_info GROUP BY fish_type)
ORDER BY i.id;

-- 부서별 평균 연봉 조회하기
SELECT d.dept_id
        , d.dept_name_en
        , ROUND(AVG(e.sal)) AS avg_sal
FROM hr_department AS d
  INNER JOIN hr_employees AS e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name_en
ORDER BY avg_sal DESC;

-- 업그레이드 할 수 없는 아이템 구하기
SELECT i.item_id
        , i.item_name
        , i.rarity
FROM item_info AS i
  LEFT JOIN item_tree AS t ON i.item_id = t.parent_item_id
WHERE t.item_id IS NULL
ORDER BY i.item_id DESC;

-- 조회수가 가장 많은 중고거래 게시판의 첨부파일 조회하기
SELECT CONCAT('/home/grep/src/', b.board_id, '/', f.file_id, f.file_name, f.file_ext) AS FILE_PATH
FROM used_goods_board AS b
  INNER JOIN used_goods_file AS f ON b.board_id = f.board_id
WHERE b.views = (SELECT MAX(views) FROM used_goods_board)
ORDER BY f.file_id DESC;

-- 조건에 맞는 사용자 정보 조회하기
SELECT DISTINCT u.user_id
        , u.nickname
        , CONCAT(u.city, ' ', u.street_address1, ' ', u.street_address2) AS 전체주소
        , CONCAT(LEFT(u.tlno, 3), '-', MID(u.tlno, 4, 4), '-', RIGHT(u.tlno, 4)) AS 전화번호
FROM used_goods_board AS b
  INNER JOIN used_goods_user AS u ON b.writer_id = u.user_id
WHERE u.user_id IN (SELECT writer_id FROM used_goods_board GROUP BY writer_id HAVING COUNT(board_id) >= 3)
ORDER BY u.user_id DESC;

-- 조건에 맞는 사용자와 총 거래 금액 조회하기
SELECT u.user_id
        , u.nickname
        , SUM(b.price) AS total_sales
FROM used_goods_board AS b
  INNER JOIN used_goods_user AS u ON b.writer_id = u.user_id
WHERE b.status = 'DONE'
GROUP BY u.user_id, u.nickname
HAVING total_sales >= 700000
ORDER BY total_sales;

-- 대여 기록이 존재하는 자동차 리스트 구하기
SELECT DISTINCT c.car_id
FROM car_rental_company_car AS c
  INNER JOIN car_rental_company_rental_history AS h ON c.car_id = h.car_id
WHERE c.car_type = '세단'
  AND h.start_date LIKE '2022-10%'
ORDER BY c.car_id DESC;

-- 자동차 대여 기록에서 대여중 / 대여 가능 여부 구분하기
SELECT car_id
        , MAX(CASE WHEN start_date <= '2022-10-16' AND end_date >= '2022-10-16' THEN '대여중'  ELSE '대여 가능' END) AS availability
FROM car_rental_company_rental_history
GROUP BY car_id
ORDER BY car_id DESC;

-- 대여 횟수가 많은 자동차들의 월별 대여 횟수 구하기
SELECT MONTH(start_date) AS month
        , car_id
        , COUNT(history_id) AS records
FROM car_rental_company_rental_history
WHERE car_id IN (SELECT car_id 
                 FROM car_rental_company_rental_history 
                 WHERE start_date BETWEEN '2022-08-01' AND '2022-10-31 23:59:59' 
                 GROUP BY car_id 
                 HAVING COUNT(history_id) >= 5)
  AND start_date BETWEEN '2022-08-01' AND '2022-10-31 23:59:59'
GROUP BY month, car_id
ORDER BY month, car_id DESC

-- 카테고리 별 도서 판매량 집계하기
SELECT b.category
        , SUM(s.sales) AS total_sales
FROM book AS b
  INNER JOIN book_sales AS s ON b.book_id = s.book_id
WHERE s.sales_date LIKE '2022-01%'
GROUP BY b.category
ORDER BY b.category;

-- 즐겨찾기가 가장 많은 식당 정보 출력하기
SELECT food_type
        , rest_id
        , rest_name
        , favorites
FROM rest_info
WHERE (food_type, favorites) IN (SELECT food_type
                                    , MAX(favorites) 
                               FROM rest_info 
                               GROUP BY food_type)
ORDER BY food_type DESC;

-- 조건별로 분류하여 주문상태 출력하기
SELECT order_id
        , product_id
        , DATE_FORMAT(out_date, '%Y-%m-%d') AS out_date
        , CASE 
                WHEN out_date <= '2022-05-01' THEN '출고완료'
                WHEN out_date > '2022-05-01' THEN '출고대기'
                WHEN out_date IS NULL THEN '출고미정'
        END AS 출고여부
FROM food_order
ORDER BY order_id;

-- 헤비 유저가 소유한 장소
SELECT *
FROM places
WHERE host_id IN (SELECT host_id FROM places GROUP BY host_id HAVING COUNT(*) >= 2)
ORDER BY id;

-- 오랜 기간 보호한 동물(2)
SELECT i.animal_id
        , i.name
FROM animal_ins AS i
  INNER JOIN animal_outs AS o ON i.animal_id = o.animal_id
ORDER BY TIMESTAMPDIFF(SECOND, i.datetime, o.datetime) DESC
LIMIT 2;

-- 오랜 기간 보호한 동물(1)
WITH cte AS(
    SELECT i.name
            , i.datetime
    FROM animal_ins AS i
      LEFT JOIN animal_outs AS o ON i.animal_id = o.animal_id
    WHERE o.animal_id IS NULL
    ORDER BY i.datetime 
    LIMIT 3
)
SELECT name
        , datetime
FROM cte
ORDER BY datetime;

-- 있었는데요 없었습니다
SELECT i.animal_id
        , i.name
FROM animal_ins AS i
  INNER JOIN animal_outs AS o ON i.animal_id = o.animal_id
WHERE i.datetime > o.datetime
ORDER BY i.datetime;

-- 없어진 기록 찾기
SELECT o.animal_id
        , o.name
FROM animal_outs AS o
  LEFT JOIN animal_ins AS i ON o.animal_id = i.animal_id
WHERE i.animal_id IS NULL
ORDER BY o.animal_id;