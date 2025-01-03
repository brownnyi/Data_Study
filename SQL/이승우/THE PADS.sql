SELECT CONCAT(NAME, '(', LEFT(Occupation, 1), ')') AS NAME
FROM OCCUPATIONS
UNION ALL
SELECT CONCAT('There are a total of ', COUNT(Name), ' ', LOWER(Occupation), 's.')
FROM OCCUPATIONS
GROUP BY Occupation
ORDER BY NAME;
