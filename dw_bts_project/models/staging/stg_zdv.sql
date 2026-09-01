with source as (
    select *
    from ods."ZDV"
),

cleaned as (
    select
        -- colonne technique : 0 partout
        {{ clean_int('"SUZDV"') }} as suzdv,

        {{ parse_mixed_date('"DMJZDV"') }} as dmjzdv,

        -- colonne très peu remplie, mais on garde les vraies valeurs
        {{ clean_bigint('"TIMZDV"') }} as timzdv,

        -- 999999 semble être une valeur par défaut technique
         {{ clean_bigint('"EMPZDV"') }}  as empzdv,

        -- très peu remplie, on garde si présente
        {{ clean_text('"COPZDV"') }} as copzdv,

        {{ clean_text('"CODZDV"') }} as codzdv,
        {{ clean_text('"CODZSSZDV"') }} as codzsszdv,
        {{ clean_text('"LIBZDV"') }} as libzdv,

        -- colonne totalement vide
        cast(null as text) as abrzdv,

        current_timestamp as _load_timestamp
    from source
)

select *
from cleaned