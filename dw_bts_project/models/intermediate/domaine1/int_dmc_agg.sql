{{ config(materialized='table') }}

with dmc as (

    select *
    from {{ ref('hist_dmc') }}
    where is_current = true
      and sudmc = 0

)

select
    numdmgdmc as numdmg,

    -- Mesures
    count(*)       as nbrcrdpropaccor,
    min(codenadmc) as codenadmc1,
    max(codenadmc) as codenadmc2,
    sum(duradmc)   as dureedde

from dmc
group by numdmgdmc