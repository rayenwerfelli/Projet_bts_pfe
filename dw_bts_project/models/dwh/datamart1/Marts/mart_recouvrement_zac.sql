{{ config(materialized='table') }}

with fact as (

    select *
    from {{ ref('fact_recouvrement_zac') }}

),

zac as (

    select *
    from {{ ref('dim_zac') }}

)

select

    -- ✅ Clés
    fact.zac_key,
    fact.codzac,

    -- ✅ Infos ZAC
    zac.libzac,
    zac.seczac,

    -- ✅ Libellé secteur
    case zac.seczac
        when 'A' then 'Agriculture'
        when 'S' then 'Service'
        when 'I' then 'Industrie'
        when 'B' then 'Artisanat'
        when 'M' then 'Petits Métiers'
    end                                         as lib_secteur,

    -- ✅ Mesures brutes
    fact.mntechupay,
    fact.mntechuimpay,
    fact.mntechuenattregl,
    fact.mntannul,
    fact.mntaechoir,

    -- ✅ KPIs calculés
    (
        coalesce(fact.mntechuenattregl, 0)
        + coalesce(fact.mntechuimpay,   0)
        + coalesce(fact.mntechupay,     0)
    )                                           as mntechuparactiv,

    coalesce(fact.mntechuimpay, 0)              as mntechuimpparactiv,

    -- ✅ Taux recouvrement national
    case
        when (
            coalesce(fact.mntechuenattregl, 0)
            + coalesce(fact.mntechuimpay,   0)
            + coalesce(fact.mntechupay,     0)
        ) = 0 then 0
        else round(
            (
                coalesce(fact.mntechupay,     0)
                + coalesce(fact.mntechuenattregl, 0)
            )
            /
            (
                coalesce(fact.mntechuenattregl, 0)
                + coalesce(fact.mntechuimpay,   0)
                + coalesce(fact.mntechupay,     0)
            ) * 100
        , 2)
    end                                         as txrecovnat,

    current_timestamp                           as _load_timestamp

from fact

left join zac
    on fact.codzac = zac.codzac