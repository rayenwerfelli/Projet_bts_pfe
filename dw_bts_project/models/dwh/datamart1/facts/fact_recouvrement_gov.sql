{{ config(materialized='table') }}

with recouv as (

    select *
    from {{ ref('int_suiv_recouv_zac_gov') }}

),

zac as (

    select *
    from {{ ref('dim_zac') }}

),

gov as (

    select *
    from {{ ref('dim_gouvernorat') }}

)

select

    -- ✅ Surrogate keys
    zac.zac_key,
    gov.gouvernorat_key,

    -- ✅ Clés naturelles
    recouv.codzacprj                as codzac,
    recouv.codgovprj                as codgov,

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

left join gov
    on recouv.codgovprj = gov.codgov