with source as (
    select *
    from ods."ZSS"
),

cleaned as (
    select
       {{ clean_int('"SUZSS"') }}  as suzss,

        {{ parse_mixed_date('"DMJZSS"') }} as dmjzss,

        -- colonne très peu remplie
        {{ clean_bigint('"TIMZSS"') }} as timzss,

        -- 999999 = valeur technique
        {{ clean_bigint('"EMPZSS"') }}  as empzss,

        -- très peu remplie
        {{ clean_text('"COPZSS"') }} as copzss,

        {{ clean_text('"CODZSS"') }} as codzss,
        {{ clean_text('"CODZSCZSS"') }} as codzsczss,
        {{ clean_text('"LIBZSS"') }} as libzss,

        -- colonne totalement vide
        cast(null as text) as abrzss,

        current_timestamp as _load_timestamp
    from source
)

select *
from cleaned