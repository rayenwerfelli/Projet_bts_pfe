with source as (
    select *
    from ods."NAT"
),

cleaned as (
    select
        "SUNAT" as sunat,
        {{ parse_mixed_date('"DMJNAT"') }} as dmjnat,
        "TIMNAT" as timnat,
        "EMPNAT" as empnat,

        {{ clean_text('"COPNAT"') }} as copnat,
        "CODNAT" as codnat,
        upper({{ clean_text('"LIBNAT"') }}) as libnat,

        "TYPNAT" as typnat,
        "CATNAT" as catnat,
        "CRJNAT" as crjnat,
        "CHQNAT" as chqnat,
        "TYSNAT" as tysnat,
        "TPXCNAT" as tpxcnat,
        "RLVNAT" as rlvnat,

        -- NULL remplacé par 0 : frais / commission non applicable
        coalesce("CPFNAT", 0) as cpfnat,

        "TDVNAT" as tdvnat,
        "PARNAT" as parnat,
        "RGLNAT" as rglnat,
        "CODTDPNAT" as codtdpnat,
        "CODETBNAT" as codetbnat,
        "RZDNAT" as rzdnat,
        "TUNNAT" as tunnat,

        -- NULL remplacé par 'N' : non lié à une agence spécifique
        coalesce({{ clean_text('"AGENAT"') }}, 'N') as agenat,

        -- NULL remplacé par 0 : non concerné BCT
        coalesce("BCTNAT", 0) as bctnat,

        "PPMNAT" as ppmnat,

        -- Dates : on garde NULL si aucune règle métier
        coalesce(
    {{ parse_mixed_date('"DARTNAT"') }},
    to_date('2099-12-31','YYYY-MM-DD')
) as dartnat,



        -- Codes / indicateurs non applicables
        coalesce({{ clean_text('"TPNLNAT"') }}, 'N') as tpnlnat,

        -- Date/règle métier : garder NULL si absent
        {{ parse_mixed_date('"DRXNAT"') }} as drxnat,

        -- Montants / taux non applicables
        coalesce("TAUNAT", 0) as taunat,
        coalesce("MNTNAT", 0) as mntnat,

        -- Traitements / actions spécifiques non applicables
        coalesce({{ clean_text('"TRTSNAT"') }}, 'N') as trtsnat,
        coalesce({{ clean_text('"ACNAT"') }}, 'N') as acnat,

        coalesce("TAVXNAT", 0) as tavxnat,
        coalesce("AVJNAT", 0) as avjnat,
        coalesce("TDRNAT", 0) as tdrnat,

       coalesce(
    {{ parse_mixed_date('"DRMNAT"') }},
    to_date('2099-12-31','YYYY-MM-DD')
) as drmnat,

        -- Indicateur avance/crédit
        coalesce({{ clean_text('"IAVCNAT"') }}, 'N') as iavcnat,

        -- TVA / impôt / marge / IRS
        coalesce("TTVANAT", 0) as ttvanat,
        coalesce("IMPNAT", 0) as impnat,
        coalesce("MRGNAT", 0) as mrgnat,
        coalesce("IRSNAT", 0) as irsnat,

        "BCTRGLNAT" as bctrglnat,

        -- Indicateur prêt
        coalesce({{ clean_text('"IPRTMNAT"') }}, 'N') as iprtmnat,

        current_timestamp as _load_timestamp

    from source
)

select *
from cleaned