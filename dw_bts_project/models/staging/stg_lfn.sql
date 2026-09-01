with source as (

    select *
    from ods."LFN"

),

cleaned as (

    select

        -- =========================
        -- IDENTIFIANTS
        -- =========================
        "CODLFN" as codlfn,

        -- =========================
        -- TEXTES
        -- =========================
        upper({{ clean_text('"LIBLFN"') }})              as liblfn,
        {{ clean_text('"TYPLFN"') }}                     as typlfn,
        coalesce({{ clean_text('"STTLFN"') }}, 'N')      as sttlfn,
        coalesce({{ clean_text('"NATLFN"') }}, 'N')      as natlfn,
        coalesce({{ clean_text('"COFLFN"') }}, 'N')      as coflfn,
        coalesce({{ clean_text('"MODLFN"') }}, 'N')      as modlfn,

        -- =========================
        -- DATES (SAFE)
        -- =========================
        {{ parse_mixed_date('"DMJLFN"') }} as dmjlfn,

        coalesce(
            {{ parse_mixed_date('"DDBLFN"') }},
            to_date('2099-12-31', 'YYYY-MM-DD')
        ) as ddblfn,

        coalesce(
            {{ parse_mixed_date('"DFNLFN"') }},
            to_date('2099-12-31', 'YYYY-MM-DD')
        ) as dfnlfn,

        coalesce(
            {{ parse_mixed_date('"DDBRLFN"') }},
            to_date('2099-12-31', 'YYYY-MM-DD')
        ) as ddrblfn,

        coalesce(
            {{ parse_mixed_date('"DFNRLFN"') }},
            to_date('2099-12-31', 'YYYY-MM-DD')
        ) as dfnrlfn,

        -- =========================
        -- MONTANTS / NUMERIQUES (ROBUSTE via safe_numeric)
        -- =========================
        coalesce({{ safe_numeric('"RMBLFN"') }},   0) as rmblfn,
        coalesce({{ safe_numeric('"MNTCLFN"') }},  0) as mntclfn,
        coalesce({{ safe_numeric('"MCOMLFN"') }},  0) as mcomlfn,
        coalesce({{ safe_numeric('"TAUILFN"') }},  0) as tauilfn,
        coalesce({{ safe_numeric('"CCELFN"') }},   0) as ccelfn,
        coalesce({{ safe_numeric('"CCDLFN"') }},   0) as ccdlfn,
        coalesce({{ safe_numeric('"DVSCLFN"') }},  0) as dvsclfn,
        coalesce({{ safe_numeric('"AIRLFN"') }},   0) as airlfn,
        coalesce({{ safe_numeric('"AINRLFN"') }},  0) as ainrlfn,
        coalesce({{ safe_numeric('"RSCLFN"') }},   0) as rsclfn,

        -- =========================
        -- FLAGS / INDICATEURS TEXTE
        -- =========================
        coalesce({{ clean_text('"FRZLFN"') }}, 'N') as frzlfn,
        coalesce({{ clean_text('"BAFLFN"') }}, 'N') as baflfn,
        coalesce({{ clean_text('"DOALFN"') }}, 'N') as doalfn,

        -- =========================
        -- CODES STRUCTURELS
        -- =========================
        "CODKGRLFN" as codkgrlfn,
        "ETBKGRLFN" as etbkgrlfn,
        "PLNKGRLFN" as plnkgrlfn,
        "REFCLFN"   as refclfn,
        "REFGLFN"   as refglfn,

        -- =========================
        -- AUDIT
        -- =========================
        current_timestamp as _load_timestamp

    from source

)

select *
from cleaned