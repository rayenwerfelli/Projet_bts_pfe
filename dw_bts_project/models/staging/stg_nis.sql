

with source as (
    select * from {{ source('ods', 'NIS') }}
),

cleaned as (
    select
        {{ clean_int('"SUNIS"') }} as sunis,
        {{ parse_mixed_date('"DMJNIS"') }} as dmjnis,
        {{ clean_bigint('"TIMNIS"') }} as timnis,
        {{ clean_int('"EMPNIS"') }} as empnis,
        {{ clean_legacy_text('"COPNIS"', 4) }} as copnis,
        {{ clean_int('"CODNIS"') }} as codnis,

        -- ✅ brut complet, pas de troncature
        {{ clean_legacy_text('"LIBNIS"', 60) }} as libnis,

        current_timestamp as _load_timestamp
    from source
)

select * from cleaned