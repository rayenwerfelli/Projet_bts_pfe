
with source as (
    select * from {{ source('ods', 'DMP') }}
),

cleaned as (
    select
        {{ clean_int('"SUDMP"') }} as sudmp,
        {{ parse_mixed_date('"DMJDMP"') }} as dmjdmp,
        {{ clean_int('"TIMDMP"') }} as timdmp,
        {{ clean_int('"EMPDMP"') }} as empdmp,
        {{ clean_legacy_text('"COPDMP"', 4) }} as copdmp,
        {{ clean_int('"NUMDMGDMP"') }} as numdmgdmp,
        {{ clean_int('"CODPRJDMP"') }} as codprjdmp,

        -- ✅ brut uniquement
        {{ clean_int('"NATDMP"') }} as natdmp,
        {{ clean_int('"NEPDMP"') }} as nepdmp,

        current_timestamp as _load_timestamp
    from source
)

select * from cleaned