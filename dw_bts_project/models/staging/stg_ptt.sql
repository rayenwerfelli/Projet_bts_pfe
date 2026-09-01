with source as (
    select *
    from ods."PTT"
),

cleaned as (
    select
         {{ clean_int('"SUPTT"') }} as suptt,

        {{ parse_mixed_date('"DMJPTT"') }} as dmjptt,

        -- garder les valeurs
        {{ clean_bigint('"TIMPTT"') }} as timptt,

        {{ clean_bigint('"EMPPTT"') }}  as empptt,

        {{ clean_text('"COPPTT"') }} as copptt,
        {{ clean_text('"CODPTT"') }} as codptt,
        {{ clean_text('"LIBPTT"') }} as libptt,

        -- partiellement null → garder
        {{ clean_text('"ALIBPTT"') }} as alibptt,

        {{ clean_int('"GOVPTT"') }} as govptt,
        {{ clean_int('"DLGPTT"') }} as dlgptt,
        {{ clean_int('"LOCPTT"') }} as locptt,

        current_timestamp as _load_timestamp
    from source
)

select *
from cleaned