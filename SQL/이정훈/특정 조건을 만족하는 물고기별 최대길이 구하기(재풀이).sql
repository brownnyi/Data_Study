with type as  (select id
                    , fish_type
                    , case when length is null then 10  else length end as length
               from FISH_INFO)
               
select count(id) as fish_count
     , max(length) as max_length
     , fish_type
from type
group by fish_type
having avg(length) >= 33
order by fish_type
