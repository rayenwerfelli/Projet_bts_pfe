with source as (

    select *
    from ods."TRH"

),

cleaned as (

    select

        -- =========================
        -- IDENTIFIANTS
        -- =========================
        "NUMTRH" as numtrh,
        "NUM2TRH" as num2trh,
        "CODCLTTRH" as codclttrh,
        "ORDCPTTRH" as ordcpttrh,
        "KLECPTTRH" as klecpttrh,

        -- =========================
        -- META / STRUCTURE
        -- =========================
        {{ clean_text('"SUTRH"') }} as sutrh,
        {{ clean_text('"EMPTRH"') }} as emptrh,
        {{ clean_text('"COPTRH"') }} as coptrh,
        {{ clean_text('"CODENGTRH"') }} as codengtrh,
        {{ clean_text('"REFAUTTRH"') }} as refauttrh,

        -- =========================
        -- DATES
        -- =========================
        coalesce({{ parse_mixed_date('"DMJTRH"') }},
                 to_date('2099-12-31','YYYY-MM-DD')) as dmjtrh,

        coalesce({{ parse_mixed_date('"DTBTRH"') }},
                 to_date('2099-12-31','YYYY-MM-DD')) as dtbtrh,

        coalesce({{ parse_mixed_date('"DTTTRH"') }},
                 to_date('2099-12-31','YYYY-MM-DD')) as dtttrh,

        coalesce({{ parse_mixed_date('"DDSTTRH"') }},
                 to_date('2099-12-31','YYYY-MM-DD')) as ddsttrh,

        coalesce({{ parse_mixed_date('"DATTRBTRH"') }},
                 to_date('2099-12-31','YYYY-MM-DD')) as dattrbtrh,

        -- =========================
        -- MONTANTS (SAFE NUMERIC)
        -- =========================
        {{ safe_numeric('"MNTTRH"') }}  as mnttrh,
        {{ safe_numeric('"MINTTRH"') }} as minttrh,
        {{ safe_numeric('"MHTVTRH"') }}  as mhtvtrh,
        {{ safe_numeric('"MTVATRH"') }}  as mtvatrh,
        {{ safe_numeric('"MTTCTRH"') }}  as mttctrh,
        {{ safe_numeric('"MTMBTRH"') }}  as mtmbtrh,
        {{ safe_numeric('"MASSTRH"') }}  as masstrh,
        {{ safe_numeric('"MLOYTRH"') }}  as mloytrh,

        -- =========================
        -- TAUX / INDICATEURS FINANCIERS
        -- =========================
        {{ safe_numeric('"TAUTRH"') }}    as tautrh,
        {{ safe_numeric('"TEGTRH"') }}     as tegtrh,
        {{ safe_numeric('"TAUTVATRH"') }}  as tautvatrh,

        -- =========================
        -- FRAIS / COMMISSIONS
        -- =========================
        {{ safe_numeric('"COMTRH"') }}  as comtrh,
        {{ safe_numeric('"COM1TRH"') }} as com1trh,
        {{ safe_numeric('"COM2TRH"') }} as com2trh,
        {{ safe_numeric('"COM3TRH"') }} as com3trh,

        {{ safe_numeric('"FRA1TRH"') }} as fra1trh,
        {{ safe_numeric('"FRA2TRH"') }} as fra2trh,
        {{ safe_numeric('"FRA3TRH"') }} as fra3trh,

        -- TVA
        {{ safe_numeric('"TVATRH"') }}  as tvatrh,
        {{ safe_numeric('"TVAF1TRH"') }} as tvaf1trh,
        {{ safe_numeric('"TVAF2TRH"') }} as tvaf2trh,
        {{ safe_numeric('"TVAF3TRH"') }} as tvaf3trh,

        -- =========================
        -- INDICATEURS METIER
        -- =========================
        coalesce({{ clean_text('"ETATRH"') }}, 'N') as etatrh,
        coalesce({{ clean_text('"DBKTRH"') }}, 'N') as dbktrh,
        coalesce({{ clean_text('"FRZTRH"') }}, 'N') as frztrh,
        coalesce({{ clean_text('"DECHTRH"') }}, 'N') as dechtrh,
        coalesce({{ clean_text('"REJSED"') }}, 'N') as rejset,

        -- =========================
        -- TYPOLOGIE
        -- =========================
        {{ clean_text('"CODGOVTRH"') }} as codgovtrh,
        {{ clean_text('"CODTRBTRH"') }} as codtrbtrh,
        {{ clean_text('"TYPTRBTRH"') }} as typtrbtrh,

        -- =========================
        -- COMMENTAIRE
        -- =========================
        upper({{ clean_text('"CMNTRH"') }}) as cmntrh,

        -- =========================
        -- AUDIT
        -- =========================
        current_timestamp as _load_timestamp

    from source

)

select *
from cleaned