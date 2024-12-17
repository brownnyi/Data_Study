SELECT A.name
FROM games A
JOIN platforms B
ON A.platform_id = B.platform_id
WHERE A.year >= 2012
GROUP BY A.name
HAVING COUNT(DISTINCT CASE 
                        WHEN B.name IN ('PS3', 'PS4', 'PSP', 'PSV') THEN 'Sony'
                        WHEN B.name IN ('Wii', 'WiiU', 'DS', '3DS') THEN 'Nintendo'
                        WHEN B.name IN ('X360', 'XONE') THEN 'Microsoft'
                      END
            ) >= 2;
