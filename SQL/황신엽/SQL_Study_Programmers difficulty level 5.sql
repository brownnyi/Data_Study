-- 멸종위기의 대장균 찾기
WITH RECURSIVE g AS(
  SELECT id
            , parent_id
            , 1 AS gen
  FROM ecoli_data
  WHERE parent_id IS NULL
    
  UNION ALL
    
  SELECT e.id
            , e.parent_id
            , g.gen + 1 AS gen
  FROM ecoli_data AS e
    INNER JOIN g ON e.parent_id = g.id
)
SELECT COUNT(id) AS 'count'
        , gen AS generation
FROM g
WHERE id NOT IN (SELECT parent_id FROM ecoli_data WHERE parent_id IS NOT NULL)
GROUP BY gen
ORDER BY gen;

-- 상품을 구매한 회원 비율 구하기
WITH total AS(
  SELECT COUNT(DISTINCT user_id) AS total_users
  FROM user_info 
  WHERE joined BETWEEN '2021-01-01' AND '2021-12-31'
)
SELECT YEAR(o.sales_date) AS year
        , MONTH(o.sales_date) AS month
        , COUNT(DISTINCT o.user_id) AS purchased_users
        , ROUND(COUNT(DISTINCT o.user_id) / t.total_users, 1) AS purchased_ratio
FROM user_info AS u
  INNER JOIN online_sale AS o ON u.user_id = o.user_id
  CROSS JOIN total AS t
WHERE u.joined BETWEEN '2021-01-01' AND '2021-12-31' 
GROUP BY year, month
ORDER BY year, month;