{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('ods', 'HMF') }}

),

cleaned as (

    select
        -- =========================
        -- METADATA
        -- =========================
        {{ clean_int('"SUHMF"') }} as suhmf,
        {{ parse_mixed_date('"DMJHMF"') }} as dmjhmf,
        {{ clean_bigint('"TIMHMF"') }} as timhmf,
        {{ clean_bigint('"EMPHMF"') }} as emphmf,
        {{ clean_legacy_text('"COPHMF"', 4) }} as cophmf,

        -- =========================
        -- IDENTIFIANT
        -- =========================
        {{ clean_bigint('"CODHMF"') }} as codhmf,

        -- =========================
        -- LIBELLES
        -- =========================
        {{ clean_legacy_text('"LIBHMF"', 100) }} as libhmf,

        -- =========================
        -- TYPE
        -- =========================
        {{ clean_legacy_text('"TYPHMF"', 10) }} as typhmf,

        -- =========================
        -- TAUX
        -- =========================
        {{ clean_number('"TAUHMF"', 10, 4) }} as tauhmf,
        {{ clean_number('"TVAHMF"', 10, 4) }} as tvahmf,

        -- =========================
        -- FLAGS
        -- =========================
        {{ clean_int('"EGNHMF"') }} as egnhmf,
        {{ clean_int('"EDKHMF"') }} as edkhmf,
        {{ clean_int('"ICSLHMF"') }} as icslhmf,
        {{ clean_int('"ISBVHMF"') }} as isbvhmf,
        {{ clean_int('"IASRHMF"') }} as iasrhmf,

        -- =========================
        -- MONTANTS
        -- =========================
        {{ clean_number('"MPLFHMF"', 15, 3) }} as mplfhmf,
        {{ clean_number('"MPLCHMF"', 15, 3) }} as mplchmf,
        {{ clean_number('"MCOMHMF"', 15, 3) }} as mcomhmf,

        -- =========================
        -- SUBVENTION
        -- =========================
        {{ clean_legacy_text('"CODHRFHMF"', 20) }} as codhrfhmf,
        {{ clean_legacy_text('"ITDSHMF"', 20) }} as itdshmf,

        current_timestamp as _load_timestamp

    from source

)

select *
from cleaned