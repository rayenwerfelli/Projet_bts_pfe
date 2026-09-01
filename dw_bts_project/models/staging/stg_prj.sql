{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('ods', 'PRJ') }}

),

cleaned as (

    select
        {{ clean_int('"SUPRJ"') }} as suprj,
        {{ parse_mixed_date('"DMJPRJ"') }} as dmjprj,
        {{ clean_bigint('"TIMPRJ"') }} as timprj,
        {{ clean_int('"EMPPRJ"') }} as empprj,
        {{ clean_legacy_text('"COPPRJ"', 4) }} as copprj,

        {{ clean_bigint('"CODPRJ"') }} as codprj,
        {{ clean_int('"CODTPJPRJ"') }} as codtpjprj,
        {{ clean_legacy_text('"CODZACPRJ"', 7) }} as codzacprj,
        {{ clean_int('"CODPTTPRJ"') }} as codpttprj,
        {{ clean_bigint('"CODCLTPRJ"') }} as codcltprj,
        {{ clean_int('"CODGOVPRJ"') }} as codgovprj,
        {{ clean_int('"CODDLGPRJ"') }} as coddlgprj,
        {{ clean_int('"CODLOCPRJ"') }} as codlocprj,

        {{ clean_legacy_text('"ADRPRJ"', 120) }} as adrprj,
        {{ clean_legacy_text('"DSCPRJ"', 120) }} as dscprj,

        {{ parse_mixed_date('"DATPRJ"') }} as datprj,
        {{ parse_mixed_date('"DENRPRJ"') }} as denrprj,

        {{ clean_bigint('"CODCLT2PRJ"') }} as codclt2prj,
        {{ clean_int('"CODCTPPRJ"') }} as codctpprj,
        {{ clean_int('"CODAPMPRJ"') }} as codapmprj,

        upper({{ clean_legacy_text('"INSPRJ"', 1) }}) as insprj,
        upper({{ clean_legacy_text('"ETBPRJ"', 1) }}) as etbprj,

        {{ clean_number('"SRFIPRJ"', 10, 2) }} as srfiprj,
        {{ clean_number('"SRFPRJ"', 10, 2) }} as srfprj,
        {{ clean_int('"NEPPRJ"') }} as nepprj,
        {{ clean_number('"RVNPRJ"', 15, 3) }} as rvnprj,
        {{ clean_number('"CHGPRJ"', 15, 3) }} as chgprj,
        {{ clean_int('"CODPMTPRJ"') }} as codpmtprj,

        current_timestamp as _load_timestamp

    from source

)

select *
from cleaned