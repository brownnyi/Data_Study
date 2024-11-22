SELECT CAR_ID, MAX(CASE 
                WHEN '2022-10-16' BETWEEN START_DATE AND END_DATE THEN '대여중'
                ELSE '대여 가능' 
                END) AS AVAILABILITY
FROM CAR_RENTAL_COMPANY_RENTAL_HISTORY
GROUP BY CAR_ID
ORDER BY CAR_ID DESC;
#사전 값 상 '대여중'이 '대여 가능'보다 앞서기 때문에 MAX를 통해 대여 된 적이 있는 지 체크함 => COUNT를 통해 차마다 1번 이상 대여된 적이 있는지 체크해줄 수 도 있음
