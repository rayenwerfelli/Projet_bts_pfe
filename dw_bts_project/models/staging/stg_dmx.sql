{{ config(materialized='table') }}

with source as (
    select *
    from {{ source('ods', 'DMX') }}
),

cleaned as (
    select
        {{ clean_int('"SUDMX"') }} as sudmx,
        {{ parse_mixed_date('"DMJDMX"') }} as dmjdmx,
        {{ clean_int('"TIMDMX"') }} as timdmx,
        {{ clean_int('"EMPDMX"') }} as empdmx,
        {{ clean_legacy_text('"COPDMX"', 4) }} as copdmx,

        {{ clean_int('"CODDMX"') }} as coddmx,
        upper({{ clean_legacy_text('"LIBDMX"', 60) }}) as libdmx,

        upper({{ clean_legacy_text('"DMDDMX"', 1) }}) as dmddmx,
        upper({{ clean_legacy_text('"AVIDMX"', 1) }}) as avidmx,
        upper({{ clean_legacy_text('"SBVDMX"', 1) }}) as sbvdmx,

        current_timestamp as _load_timestamp
    from source
)

select *
from cleaned