{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('ods', 'EMP') }}

),

cleaned as (

    select
        {{ clean_int('"SUEMP"') }} as suemp,
        {{ parse_mixed_date('"DMJEMP"') }} as dmjemp,
        {{ clean_bigint('"TIMEMP"') }} as timemp,
        {{ clean_int('"EMPEMP"') }} as empemp,
        {{ clean_legacy_text('"COPEMP"', 4) }} as copemp,

        {{ clean_int('"MATEMP"') }} as matemp,
        {{ clean_int('"CODUNTEMP"') }} as coduntemp,

        upper({{ clean_legacy_text('"NOMEMP"', 50) }}) as nomemp,
        initcap(lower({{ clean_legacy_text('"PRNEMP"', 30) }})) as prnemp,

        case
            when upper({{ clean_legacy_text('"SEXEMP"', 1) }}) in ('M', 'F')
                then upper({{ clean_legacy_text('"SEXEMP"', 1) }})
            else null
        end as sexemp,

        {{ parse_mixed_date('"NAIEMP"') }} as naiemp,

        {{ clean_int('"NVHEMP"') }} as nvhemp,
        {{ clean_int('"UCSSEMP"') }} as ucssemp,
        {{ clean_int('"TCSSEMP"') }} as tcssemp,
        {{ clean_int('"NCSSEMP"') }} as ncssemp,

        {{ clean_text('"GUIDEMP"') }} as guidemp,

        {{ parse_mixed_date('"DAFEMP"') }} as dafemp,
        {{ clean_bigint('"CODCLTEMP"') }} as codcltemp,

        current_timestamp as _load_timestamp

    from source

)

select *
from cleaned