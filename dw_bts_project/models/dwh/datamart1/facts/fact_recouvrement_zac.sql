{{ config(materialized='table') }}

with recouv as (

    select *
    from {{ ref('int_suiv_recouv_zac') }}

),

zac as (

    select *
    from {{ ref('dim_zac') }}

)

select

    -- ✅ Surrogate key
    zac.zac_key,

    -- ✅ Clé naturelle
    recouv.codzacprj                as codzac,

    -- ✅ Mesures brutes uniquement
    recouv.mntechupay,
    recouv.mntechuimpay,
    recouv.mntechuenattregl,
    recouv.mntannul,
    recouv.mntaechoir,

    current_timestamp               as _load_timestamp

from recouv

left join zac
    on recouv.codzacprj = zac.codzac