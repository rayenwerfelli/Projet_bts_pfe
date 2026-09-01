{{ config(materialized='table') }}

with fact as (

    select *
    from {{ ref('fact_recouvrement_client') }}

),

client as (

    select *
    from {{ ref('dim_client') }}

)

select

    -- ✅ Clés
    fact.client_key,
    fact.codclt,

    -- ✅ Infos client
    client.nomclt,
    client.prnclt,
    client.dnaclt,

    -- ✅ Libellé sexe
    case client.sexclt
        when 'M' then 'Masculin'
        when 'F' then 'Féminin'
    end                                         as lib_sexe,

    -- ✅ Mesures brutes
    fact.mntechupayprinc,
    fact.mntechupayint,
    fact.mntechupay,

    fact.mntechuimpayprinc,
    fact.mntechuimpayint,
    fact.mntechuimpay,

    fact.mntechuenattreglprinc,
    fact.mntechuenattreglint,
    fact.mntechuenattregl,

    fact.mntannulprinc,
    fact.mntannulint,
    fact.mntannul,

    fact.mntaechoirprinc,
    fact.mntaechoirint,
    fact.mntaechoir,

    -- ✅ Dates
    fact.datpremregl,
    fact.datderregl,
    fact.datpremech,
    fact.datderech,
    fact.premechimp,

    -- ✅ Compteurs
    fact.nbrechimpprinc,
    fact.nbrechimpint,

    -- ✅ KPIs calculés
    (
        coalesce(fact.mntechuenattregl, 0)
        + coalesce(fact.mntechuimpay,   0)
        + coalesce(fact.mntechupay,     0)
    )                                           as mntechu,

    (
        coalesce(fact.mntechuimpay,     0)
        + coalesce(fact.mntechuenattregl, 0)
        + coalesce(fact.mntaechoirprinc, 0)
    )                                           as mntencourseff,

    -- ✅ Taux impayé client
    case
        when (
            coalesce(fact.mntechuenattregl, 0)
            + coalesce(fact.mntechuimpay,   0)
            + coalesce(fact.mntechupay,     0)
        ) = 0 then 0
        else round(
            coalesce(fact.mntechuimpay, 0)
            /
            (
                coalesce(fact.mntechuenattregl, 0)
                + coalesce(fact.mntechuimpay,   0)
                + coalesce(fact.mntechupay,     0)
            ) * 100
        , 2)
    end                                         as tx_impaye_clt,

    current_timestamp                           as _load_timestamp

from fact

left join client
    on fact.codclt = client.codclt