with source as (
    select *
    from ods."ZSC"
),

cleaned as (
    select
        -- colonne technique : 0 partout
       {{ clean_int('"SUZSC"') }} as suzsc,

        {{ parse_mixed_date('"DMJZSC"') }} as dmjzsc,

        -- colonne très peu remplie
        {{ clean_bigint('"TIMZSC"') }} as timzsc,

        -- 999999 = valeur technique
         {{ clean_bigint('"EMPZSC"') }}  as empzsc,

        -- très peu remplie
        {{ clean_text('"COPZSC"') }} as copzsc,

        {{ clean_text('"CODZSC"') }} as codzsc,
        {{ clean_text('"LIBZSC"') }} as libzsc,

        -- colonne totalement vide
        cast(null as text) as abrzsc,

        current_timestamp as _load_timestamp
    from source
)

select *
from cleaned