{{ config(materialized='table') }}

with effimp as (

    select *
    from {{ ref('int_v_effimp') }}

),

cpt as (

    select *
    from {{ ref('hist_cpt') }}
    where is_current = true

),

prj as (

    select *
    from {{ ref('hist_prj') }}
    where is_current = true
      and suprj = 0

),

cltprj as (

    select
        p.codcltprj,
        p.codzacprj,
        p.codgovprj
    from (
        select
            codcltprj,
            max(codprj) as codprjn
        from prj
        group by codcltprj
    ) lp
    left join prj p
        on p.codcltprj = lp.codcltprj
       and p.codprj    = lp.codprjn

),

eff_clt as (

    select
        cpt.codcltcpt,
        sum(case when v.typeff in (8,9) then v.mnteff else 0 end) as mntechupay,
        sum(case when v.typeff = 6      then v.mnteff else 0 end) as mntechuimpay,
        sum(case when v.typeff in (2,3) then v.mnteff else 0 end) as mntechuenattregl,
        sum(case when v.typeff = 7      then v.mnteff else 0 end) as mntannul,
        sum(case when v.typeff = 1      then v.mnteff else 0 end) as mntaechoir

    from effimp v
    left join cpt
        on cpt.ordcpt = v.ordcpxeff
    where v.codinseff = 'EFF'
    group by cpt.codcltcpt

)

-- ✅ agrégation finale par ZAC + GOV
select
    cltprj.codzacprj,
    cltprj.codgovprj,

    sum(eff_clt.mntechupay)       as mntechupay,
    sum(eff_clt.mntechuimpay)     as mntechuimpay,
    sum(eff_clt.mntechuenattregl) as mntechuenattregl,
    sum(eff_clt.mntannul)         as mntannul,
    sum(eff_clt.mntaechoir)       as mntaechoir

from eff_clt
left join cltprj
    on eff_clt.codcltcpt = cltprj.codcltprj
group by cltprj.codzacprj, cltprj.codgovprj