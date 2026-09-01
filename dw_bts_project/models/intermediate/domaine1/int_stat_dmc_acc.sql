{{ config(materialized='table') }}

select
    numdmgdmc as numdmg,
    count(*) as nbr_credprop_acc,
    sum(duradmc) as dureedde,
    min(codenadmc) as codenadmc_min,
    max(codenadmc) as codenadmc_max
from {{ ref('hist_dmc') }}
where is_current = true
  and sudmc = 0
group by numdmgdmc