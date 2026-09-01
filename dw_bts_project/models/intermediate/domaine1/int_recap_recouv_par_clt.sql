{{ config(materialized='table') }}

with effimp as (

    select *
    from {{ ref('int_v_effimp') }}

),

cpt as (

    select *
    from {{ ref('hist_cpt') }}
    where is_current = true

)

select
    cpt.codcltcpt as codclt,

    -- ✅ Principal
    sum(case when v.ppleff = 1 and v.typeff in (8,9) then v.mnteff else 0 end) as mntechupayprinc,
    sum(case when v.ppleff = 2 and v.typeff in (8,9) then v.mnteff else 0 end) as mntechupayint,
    sum(case when v.typeff in (8,9)                  then v.mnteff else 0 end) as mntechupay,

    -- ✅ Impayés
    sum(case when v.ppleff = 1 and v.typeff = 6 then v.mnteff else 0 end) as mntechuimpayprinc,
    sum(case when v.ppleff = 2 and v.typeff = 6 then v.mnteff else 0 end) as mntechuimpayint,
    sum(case when v.typeff = 6                  then v.mnteff else 0 end) as mntechuimpay,

    -- ✅ En attente règlement
    sum(case when v.ppleff = 1 and v.typeff in (2,3) then v.mnteff else 0 end) as mntechuenattreglprinc,
    sum(case when v.ppleff = 2 and v.typeff in (2,3) then v.mnteff else 0 end) as mntechuenattreglint,
    sum(case when v.typeff in (2,3)                  then v.mnteff else 0 end) as mntechuenattregl,

    -- ✅ Annulés
    sum(case when v.ppleff = 1 and v.typeff = 7 then v.mnteff else 0 end) as mntannulprinc,
    sum(case when v.ppleff = 2 and v.typeff = 7 then v.mnteff else 0 end) as mntannulint,
    sum(case when v.typeff = 7                  then v.mnteff else 0 end) as mntannul,

    -- ✅ A échoir
    sum(case when v.ppleff = 1 and v.typeff = 1 then v.mnteff else 0 end) as mntaechoirprinc,
    sum(case when v.ppleff = 2 and v.typeff = 1 then v.mnteff else 0 end) as mntaechoirint,
    sum(case when v.typeff = 1                  then v.mnteff else 0 end) as mntaechoir,

    -- ✅ Dates
    min(v.drgleff)                              as datpremregl,
    max(v.drgleff)                              as datderregl,
    min(v.echeff)                               as datpremech,
    max(v.echeff)                               as datderech,
    min(case when v.typeff = 6 then v.echeff end) as premechimp,

    -- ✅ Compteurs
    sum(case when v.ppleff = 1 and v.typeff = 6 then 1 else 0 end) as nbrechimpprinc,
    sum(case when v.ppleff = 2 and v.typeff = 6 then 1 else 0 end) as nbrechimpint

from effimp v
left join cpt
    on cpt.ordcpt = v.ordcpxeff
where v.codinseff = 'EFF'
group by cpt.codcltcpt