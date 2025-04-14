SELECT CONCAT(NAME, '(', LEFT(Occupation, 1), ')') AS NAME
FROM OCCUPATIONS
UNION ALL
SELECT CONCAT('There are a total of ', COUNT(Name), ' ', LOWER(Occupation), 's.')
FROM OCCUPATIONS
GROUP BY Occupation
ORDER BY NAME;
# ORDER 조건에 COUNT랑 Occupation으로 정렬하는 방법 찾아야할듯
# WITH문으로 정렬된 이름(직업코드) 테이블과 직업(수) 테이블을 만드는 것이 좋을듯
