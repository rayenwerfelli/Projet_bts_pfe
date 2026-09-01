{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('ods', 'UNT') }}

),

cleaned as (

    select
        {{ clean_int('"SUUNT"') }} as suunt,
        {{ parse_mixed_date('"DMJUNT"') }} as dmjunt,
        {{ clean_bigint('"TIMUNT"') }} as timunt,
        {{ clean_int('"EMPUNT"') }} as empunt,
        {{ clean_legacy_text('"COPUNT"', 4) }} as copunt,

        {{ clean_int('"CODUNT"') }} as codunt,
        {{ clean_int('"CODTNTUNT"') }} as codtntunt,
        {{ clean_int('"CODPTTUNT"') }} as codpttunt,
        {{ clean_int('"CODNOGUNT"') }} as codnogunt,
        {{ clean_int('"CODUNTUNT"') }} as coduntunt,
        {{ clean_int('"CODBAQUNT"') }} as codbaqunt,

        {{ clean_legacy_text('"LIBUNT"', 40) }} as libunt,
        {{ clean_int('"BCTUNT"') }} as bctunt,
        {{ clean_legacy_text('"ADR1UNT"', 120) }} as adr1unt,
        {{ clean_bigint('"TELUNT"') }} as telunt,
        {{ clean_text('"EMLUNT"') }} as emlunt,
        {{ clean_bigint('"FAXUNT"') }} as faxunt,

        {{ clean_legacy_text('"CTBUNT"', 6) }} as ctbunt,
        {{ clean_legacy_text('"INFUNT"', 4) }} as infunt,
        {{ clean_legacy_text('"MCNUNT"', 4) }} as mcnunt,
        {{ clean_int('"UCRUNT"') }} as ucrunt,

        {{ clean_number('"MPRV1UNT"', 15, 3) }} as mprv1unt,
        {{ clean_number('"MPRV2UNT"', 15, 3) }} as mprv2unt,
        {{ clean_number('"MPRV3UNT"', 15, 3) }} as mprv3unt,
        {{ clean_number('"MIDVUNT"', 15, 3) }} as midvunt,
        {{ clean_int('"PRCUNT"') }} as prcunt,

        {{ clean_legacy_text('"CODCLSUNT"', 2) }} as codclsunt,
        {{ clean_int('"MATEMPUNT"') }} as matempunt,
        {{ parse_mixed_date('"DAFRUNT"') }} as dafrunt,

        {{ clean_int('"IPVUNT"') }} as ipvunt,
        {{ clean_int('"IACUNT"') }} as iacunt,
        {{ clean_int('"IEXUNT"') }} as iexunt,
        {{ clean_int('"IDCUNT"') }} as idcunt,
        {{ clean_int('"IXIUNT"') }} as ixiunt,
        {{ clean_int('"INDUNT"') }} as indunt,
        {{ clean_int('"ICPUNT"') }} as icpunt,

        {{ parse_mixed_date('"DCLOUNT"') }} as dclount,
        {{ parse_mixed_date('"DCLXUNT"') }} as dclxunt,
        {{ parse_mixed_date('"D1OUVUNT"') }} as d1ouvunt,
        {{ clean_bigint('"H1OUVUNT"') }} as h1ouvunt,
        {{ parse_mixed_date('"D2OUVUNT"') }} as d2ouvunt,
        {{ clean_bigint('"H2OUVUNT"') }} as h2ouvunt,
        {{ parse_mixed_date('"DCLOXUNT"') }} as dcloxunt,
        {{ clean_int('"DLAUNT"') }} as dlaunt,

        {{ clean_legacy_text('"ALIBUNT"', 40) }} as alibunt,

        {{ clean_int('"IP1UNT"') }} as ip1unt,
        {{ clean_int('"IP2UNT"') }} as ip2unt,
        {{ clean_int('"IP3UNT"') }} as ip3unt,
        {{ clean_int('"IP4UNT"') }} as ip4unt,

        {{ clean_text('"MSSUNT"') }} as mssunt,
        {{ clean_text('"TYPCNTUNT"') }} as typcntunt,
        {{ clean_text('"TYPUNT"') }} as typunt,
        {{ clean_text('"GOVUNT"') }} as govunt,
        {{ clean_text('"LIBGOVUNT"') }} as libgovunt,

        {{ clean_number('"LTTUNT"', 15, 3) }} as lttunt,
        {{ clean_number('"LGTUNT"', 15, 3) }} as lgtunt,

        {{ clean_legacy_text('"RCQAUNT"', 16) }} as rcqaunt,
        {{ clean_legacy_text('"RCQCUNT"', 16) }} as rcqcunt,

        current_timestamp as _load_timestamp

    from source

)

select *
from cleaned