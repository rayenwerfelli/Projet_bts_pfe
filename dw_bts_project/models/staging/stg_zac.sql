

with source as (
    select * from {{ source('ods', 'ZAC') }}
),

cleaned as (
    select
        {{ clean_int('"SUZAC"') }} as suzac,
        {{ parse_mixed_date('"DMJZAC"') }} as dmjzac,
        {{ clean_bigint('"TIMZAC"') }} as timzac,
        {{ clean_int('"EMPZAC"') }} as empzac,
        {{ clean_legacy_text('"COPZAC"', 4) }} as copzac,
        {{ clean_legacy_text('"CODZAC"', 7) }} as codzac,
        {{ clean_legacy_text('"CODZCLZAC"', 6) }} as codzclzac,
        {{ clean_legacy_text('"LIBZAC"', 160) }} as libzac,
        {{ clean_legacy_text('"CODZABZAC"', 7) }} as codzabzac,
        {{ clean_int('"CODAPMZAC"') }} as codapmzac,
        {{ clean_int('"CODZFGZAC"') }} as codzfgzac,

        -- ✅ brut uniquement, décodage → mart
        upper({{ clean_legacy_text('"SECZAC"', 1) }}) as seczac,

        {{ clean_text('"ABRZAC"') }} as abrzac,
        {{ clean_int('"IMFSZAC"') }} as imfszac,
        current_timestamp as _load_timestamp
    from source
)

select * from cleaned