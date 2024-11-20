select t2.id
     , t2.genotype
     , t1.genotype as parent_genotype
from ECOLI_DATA as t1
join ECOLI_DATA as t2 on t1.id = t2.parent_id
where(t1.genotype & t2.genotype) = t1.genotype
order by t2.id
