with source as (

    select *
    from ods."ADR"

),

cleaned as (

    select

        -- =========================
        -- IDENTIFIANTS
        -- =========================
        "SUADR"      as suadr,
        "CODCLTADR"  as codcltadr,
        "NUMADR"     as numadr,

        -- =========================
        -- META / STRUCTURE
        -- =========================
        {{ clean_text('"EMPADR"') }} as empadr,
        {{ clean_text('"COPADR"') }} as copadr,

        -- =========================
        -- DATES
        -- =========================
        coalesce(
            {{ parse_mixed_date('"DMJADR"') }},
            to_date('2099-12-31','YYYY-MM-DD')
        ) as dmjadr,

        "TIMADR" as timadr,

        -- =========================
        -- CODES GEOGRAPHIQUES
        -- =========================
        {{ clean_text('"CODPAYADR"') }} as codpayadr,
        {{ clean_text('"CODPTTADR"') }} as codpttadr,
        {{ clean_text('"TYPADR"') }}    as typadr,

        -- =========================
        -- ADRESSE (NETTOYAGE TEXTE FORT)
        -- =========================
        upper(
            regexp_replace(
                {{ clean_text('"LG1ADR"') }},
                '[^A-Za-z0-9À-ÿ ]',
                '',
                'g'
            )
        ) as lg1adr,

        coalesce(
            upper(
                regexp_replace(
                    {{ clean_text('"PTEADR"') }},
                    '[^A-Za-z0-9À-ÿ ]',
                    '',
                    'g'
                )
            ),
            'NON RENSEIGNE'
        ) as pteadr,

        coalesce(
            upper(
                regexp_replace(
                    {{ clean_text('"ALIBADR"') }},
                    '[^A-Za-z0-9À-ÿ ]',
                    '',
                    'g'
                )
            ),
            'NON RENSEIGNE'
        ) as alibadr,

        -- =========================
        -- AUDIT
        -- =========================
        current_timestamp as _load_timestamp

    from source

)

select *
from cleaned