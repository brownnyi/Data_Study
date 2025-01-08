-- 업그레이드 할 수 없는 아이템 구하기
SELECT i.item_id
      , i.item_name
      , i.rarity
FROM item_info AS i
  LEFT JOIN item_tree AS t ON i.item_id = t.parent_item_id
WHERE t.item_id IS NULL
ORDER BY i.item_id DESC;

-- 조회수가 가장 많은 중고거래 게시판의 첨부파일 조회하기
SELECT CONCAT('/home/grep/src/', f.board_id, '/', f.file_id, f.file_name, f.file_ext) AS FILE_PATH
FROM used_goods_board AS b
  INNER JOIN used_goods_file AS f ON b.board_id = f.board_id
WHERE b.views = (SELECT MAX(views) FROM used_goods_board)
ORDER BY f.file_id DESC;

-- 자동차 대여 기록별 대여 금액 구하기
WITH cte AS(
  SELECT h.history_id
        , c.car_type
        , c.daily_fee
        , TIMESTAMPDIFF(DAY, h.start_date, h.end_date) + 1 AS diff
  FROM car_rental_company_car AS c
    INNER JOIN car_rental_company_rental_history AS h ON c.car_id = h.car_id
  WHERE c.car_type = '트럭'
), cte2 AS(
  SELECT CAST(duration_type AS UNSIGNED) AS duration
        , discount_rate
        , car_type
  FROM car_rental_company_discount_plan
  WHERE car_type = '트럭'
), cte3 AS(
  SELECT history_id
        , diff
        , duration
        , CASE 
              WHEN c1.diff >= c2.duration THEN ROUND(daily_fee * (1 - discount_rate / 100) * diff)
              ELSE daily_fee * diff
        END AS FEE
  FROM cte AS c1
    INNER JOIN cte2 AS c2 ON c1.car_type = c2.car_type
)
SELECT history_id
      , MIN(FEE) AS FEE
FROM cte3
GROUP BY history_id
ORDER BY FEE DESC, history_id DESC;