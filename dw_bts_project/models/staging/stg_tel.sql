with source as (

    select *
    from ods."TEL"

),

cleaned as (

    select

        -- =========================
        -- IDENTIFIANTS
        -- =========================
        "NUMTEL" as numtel,
        "CODCLTTEL" as codclttel,

        -- =========================
        -- TEXTES / CODES
        -- =========================
        coalesce({{ clean_text('"SUTEL"') }}, 'N') as sutel,
        {{ clean_text('"COPTEL"') }} as coptel,
        {{ clean_text('"PAYTEL"') }} as paytel,
        {{ clean_text('"TYPTEL"') }} as typetel,
        {{ clean_text('"UTLTEL"') }} as utltel,

        -- =========================
        -- TECHNIQUES
        -- =========================
        coalesce({{ clean_text('"EMPTEL"') }}, 'UNKNOWN') as emptel,
        coalesce({{ clean_text('"EXRTEL"') }}, 'N') as exrtel,
        coalesce({{ clean_text('"ROJTEL"') }}, 'N') as rojtel,

        -- =========================
        -- DATES / TEMPS
        -- =========================
        coalesce(
            {{ parse_mixed_date('"DMJTEL"') }},
            to_date('2099-12-31','YYYY-MM-DD')
        ) as dmjtel,

        coalesce(
            {{ parse_mixed_date('"HDATEL"') }},
            to_date('2099-12-31','YYYY-MM-DD')
        ) as hdatel,

        coalesce(
            {{ parse_mixed_date('"HFATEL"') }},
            to_date('2099-12-31','YYYY-MM-DD')
        ) as hfatel,

        -- =========================
        -- TEMPS / TIMESTAMP
        -- =========================
        {{ clean_text('"TIMTEL"') }} as timtel,

        -- =========================
        -- REMARQUE / COMMENTAIRE
        -- =========================
        upper({{ clean_text('"RMQTEL"') }}) as rmqtel,

        -- =========================
        -- AUDIT
        -- =========================
        current_timestamp as _load_timestamp

    from source

)

select *
from cleaned