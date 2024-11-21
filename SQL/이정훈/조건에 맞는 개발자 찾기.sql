select id
     , email
     , first_name
     , last_name
from developers
where skill_code & (select sum(code) as code
                    from skillcodes
                    where name in ('Python', 'C#'))
order by id

# 비트(이진수)로 변환했을때 포함
# 파이썬, C# 1280의 이진수 가 포함되어있는 코드
