-- 조건에 맞는 개발자 찾기
-- 1. & 비트연산자로 조인하여 개발자별로 어떤 스킬들을 가지고 있는지 출력
-- 2. WHERE절로 'Python', 'C#'을 필터링
-- 3. DISTINCT로 개발자당 한 행만 출력되도록 조절
SELECT DISTINCT d.id
      , d.email
      , d.first_name
      , d.last_name
FROM developers AS d
  INNER JOIN skillcodes AS s ON d.skill_code & s.code
WHERE s.name IN ('Python', 'C#')
ORDER BY d.id;

-- 특정 형질을 가지는 대장균 찾기
-- 1. n번 형질과 형질에 해당하는 수는 다름(1번 형질: 1(0001), 2번 형질: 2(0010), 3번 형질: 4(0100), 4번 형질: 8(1000))
-- 2. 2번 형질(2)는 제외하고 1번 형질(1)과 3번 형질(4)중 하나라도 해당하면 수를 세도록 필터링
SELECT COUNT(*) AS 'COUNT'
FROM ecoli_data
WHERE NOT (genotype & 2) 
  AND ((genotype & 1) OR (genotype & 4));

-- 부모의 형질을 모두 가지는 대장균 찾기
-- 1. e1의 parent_id 와 e2의 id를 LEFT JOIN 하여 e1은 자신의 데이터, e2는 부모의 데이터가 출력되도록함
-- 2. 부모 형질을 가지고 있는지 확인하기 위해 자신의 genotype과 부모의 genotype에 & 비트연산자를 수행하고 그 결과를 부모의 genotype와 일치하는지 확인
SELECT e1.id
      , e1.genotype
      , e2.genotype AS parent_genotype
FROM ecoli_data AS e1
  LEFT JOIN ecoli_data AS e2 ON e1.parent_id = e2.id
WHERE e2.genotype = (e1.genotype & e2.genotype)
ORDER BY e1.id;

-- 멸종위기의 대장균 찾기
-- 1. RECURSIVE를 활용해 데이터들의 세대를 표시
-- 2. UNION ALL 윗부분은 초기값 세팅, 아랫 부분은 반복할 내용 표시(ecoli_data의 parent_id와 조인이 한번 될때마다 세대가 1씩 추가되도록 설정)
-- 3. id중에서 parent_id가 있으면 출력되지 않도록 WHERE절로 필터링
WITH RECURSIVE gene AS(
  SELECT id
        , parent_id
        , 1 as generation
  FROM ecoli_data
  WHERE parent_id IS NULL
    
  UNION ALL
    
  SELECT e.id
        , e.parent_id
        , g.generation + 1 
  FROM gene AS g
    INNER JOIN ecoli_data AS e ON g.id = e.parent_id
)
SELECT COUNT(id) AS 'count'
      , generation
FROM gene
WHERE id NOT IN (SELECT parent_id
                 FROM gene
                 WHERE parent_id IS NOT NULL)
GROUP BY generation
ORDER BY generation;

-- 자동차 대여 기록에서 대여중 / 대여 가능 여부 구분하기
-- 1. car_id별로 '2022-10-16'이 대여 기간에 있는지 여부를 MAX() = 1을 통해 확인
-- 전체 대여 기간 중 2022-10-16에 대여 여부를 확인하는 것이 목표(가장 최신을 기준으로 하는 것이 아님)
SELECT car_id
      , CASE 
            WHEN MAX('2022-10-16' BETWEEN start_date AND end_date) = 1 THEN '대여중'
            ELSE '대여 가능'
      END AS availabity
FROM car_rental_company_rental_history
GROUP BY car_id
ORDER BY car_id DESC;

-- 언어별 개발자 분류하기
-- 1. 서브쿼리를 통해 id별로 Python, C#, Front End 스킬 획득 여부 확인
-- 2. CASE WHEN 문을 통해 grade 구분을 함
-- 3. C#, Front End 스킬 모두 가지고 있지 않은 개발자는 안 나오도록 필터링
WITH cte AS(
  SELECT d.id
        , SUM(IF(s.name = 'Python', 1, 0)) AS Python
        , SUM(IF(s.name = 'C#', 1, 0)) AS C
        , SUM(IF(s.category = 'Front End', 1, 0)) AS FE
  FROM developers AS d
    INNER JOIN skillcodes AS s ON d.skill_code & s.code
  GROUP BY d.id
)
SELECT CASE
            WHEN c.Python > 0 AND c.FE > 0 THEN 'A'
            WHEN c.C > 0 THEN 'B'
            WHEN c.FE > 0 THEN 'C'
      END AS grade
      , c.id
      , d.email
FROM cte AS c
  INNER JOIN developers AS d ON c.id = d.id
WHERE c.C <> 0 OR c.FE <> 0
ORDER BY grade, c.id;

-- 입양 시각 구하기(2)
-- 1. 재귀쿼리를 통해 0시~23시를 모두 표현하는 컬럼 생성
-- 2. 시간대별로 입양된 animal_id의 수를 세기
WITH RECURSIVE time AS(
  SELECT 0 AS hour
    
  UNION ALL

  SELECT hour + 1
  FROM time
  WHERE hour < 23
)
SELECT t.hour
      , COUNT(a.animal_id) AS 'count'
FROM time AS t
  LEFT JOIN ANIMAL_OUTS AS a ON t.hour = HOUR(a.datetime)
GROUP BY t.hour
ORDER BY t.hour;
