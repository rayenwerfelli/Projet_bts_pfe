with source as (
    select *
    from ods."ZCL"
),

cleaned as (
    select
        -- colonne technique : 0 partout
       
            {{ clean_int('"SUZCL"') }} as suzcl,

        {{ parse_mixed_date('"DMJZCL"') }} as dmjzcl,

        -- colonne très peu remplie, mais on garde les vraies valeurs
        {{ clean_bigint('"TIMZCL"') }} as timzcl,

        
         {{ clean_bigint('"EMPZCL"') }}  empzcl,

        -- très peu remplie, on garde si présente
        {{ clean_text('"COPZCL"') }} as copzcl,

        {{ clean_text('"CODZCL"') }} as codzcl,
        {{ clean_text('"CODZGRZCL"') }} as codzgrzcl,
        {{ clean_text('"LIBZCL"') }} as libzcl,

        -- colonne totalement vide
        cast(null as text) as abrzcl,

        current_timestamp as _load_timestamp
    from source
)

select *
from cleaned