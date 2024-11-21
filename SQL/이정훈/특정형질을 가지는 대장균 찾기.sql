select count(*) as count
from ecoli_data
where (genotype & 2) = 0
  and (genotype & 4 > 0  or genotype & 1 > 0)

# 이진수로 변환 후 매치 해보기
