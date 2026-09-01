with source as (
    select *
    from ods."ZGR"
),

cleaned as (
    select
        {{ clean_int('"SUZGR"') }}  as suzgr,

        {{ parse_mixed_date('"DMJZGR"') }} as dmjzgr,

        -- colonne très peu remplie
        {{ clean_bigint('"TIMZGR"') }} as timzgr,

         {{ clean_bigint('"EMPZGR"') }} as empzgr,

        -- très peu remplie
        {{ clean_text('"COPZGR"') }} as copzgr,

        {{ clean_text('"CODZGR"') }} as codzgr,
        {{ clean_text('"CODZDVZGR"') }} as codzdvzgr,
        {{ clean_text('"LIBZGR"') }} as libzgr,

        -- colonne totalement vide
        cast(null as text) as abrzgr,

        current_timestamp as _load_timestamp
    from source
)

select *
from cleaned