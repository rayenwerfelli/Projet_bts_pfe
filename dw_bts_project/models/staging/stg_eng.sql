{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('ods', 'ENG') }}

),

cleaned as (

    select
        {{ clean_int('"SUENG"') }} as sueng,
        {{ parse_mixed_date('"DMJENG"') }} as dmjeng,
        {{ clean_bigint('"TIMENG"') }} as timeng,
        {{ clean_int('"EMPENG"') }} as empeng,
        {{ clean_legacy_text('"COPENG"', 4) }} as copeng,

        {{ clean_int('"CODENG"') }} as codeng,
        {{ clean_int('"CODTEGENG"') }} as codtegeng,
        {{ clean_int('"CODBEGENG"') }} as codbegeng,
        {{ clean_int('"CODENAENG"') }} as codenaeng,
        {{ clean_bigint('"CODPRDENG"') }} as codprdeng,

        {{ clean_legacy_text('"LIBENG"', 70) }} as libeng,

        {{ clean_int('"IDXENG"') }} as idxeng,
        {{ clean_number('"TAUENG"', 8, 6) }} as taueng,
        {{ clean_number('"TMXENG"', 8, 6) }} as tmxeng,
        {{ clean_number('"TMNENG"', 8, 6) }} as tmneng,
        {{ clean_number('"CPCENG"', 8, 6) }} as cpceng,
        {{ clean_number('"TCGENG"', 8, 6) }} as tcgeng,

        {{ clean_int('"MOBENG"') }} as mobeng,
        {{ clean_int('"TUTENG"') }} as tuteng,
        {{ clean_number('"FNGENG"', 8, 6) }} as fngeng,
        {{ clean_legacy_text('"TTAENG"', 10) }} as ttaeng,
        {{ clean_number('"TFXENG"', 8, 6) }} as tfxeng,
        {{ clean_number('"TBQENG"', 8, 6) }} as tbqeng,
        {{ clean_number('"TINENG"', 8, 6) }} as tineng,

        {{ clean_int('"MPEENG"') }} as mpeeng,
        {{ clean_number('"MMIENG"', 15, 3) }} as mmieng,
        {{ clean_number('"MMXENG"', 15, 3) }} as mmxeng,
        {{ clean_int('"PDSENG"') }} as pdseng,
        {{ clean_int('"DRIENG"') }} as drieng,
        {{ clean_int('"DRXENG"') }} as drxeng,
        {{ clean_int('"CODLFNENG"') }} as codlfneng,
        {{ clean_int('"PCPENG"') }} as pcpeng,
        {{ clean_int('"EPSENG"') }} as epseng,
        {{ clean_int('"FRCENG"') }} as frceng,
        {{ clean_int('"CODBEGPENG"') }} as codbegpeng,
        {{ clean_int('"CODBEGIENG"') }} as codbegieng,
        {{ clean_int('"ESCNENG"') }} as escneng,
        {{ clean_int('"ESCVENG"') }} as escveng,
        {{ clean_int('"NBJIENG"') }} as nbjieng,
        {{ clean_int('"NBJXENG"') }} as nbjxeng,

        {{ clean_legacy_text('"TEXENG"', 10) }} as texeng,
        {{ clean_int('"NTEXENG"') }} as ntexeng,
        {{ clean_bigint('"SEDENG"') }} as sedeng,
        {{ clean_int('"NTAUIRENG"') }} as ntauireng,
        {{ clean_int('"ACENG"') }} as aceng,
        {{ clean_int('"IISENG"') }} as iiseng,
        {{ clean_number('"MTAUIRENG"', 8, 6) }} as mtauireng,
        {{ clean_int('"CTAUIRENG"') }} as ctauireng,
        {{ clean_legacy_text('"TAUIRENG"', 10) }} as tauireng,
        {{ clean_int('"CEEPSENG"') }} as ceepseng,
        {{ clean_bigint('"SEDGENG"') }} as sedgeng,
        {{ clean_int('"CODCTCENG"') }} as codctceng,
        {{ clean_int('"ICSLENG"') }} as icsleng,

        upper({{ clean_legacy_text('"IRMBENG"', 1) }}) as irmbeng,
        upper({{ clean_legacy_text('"IRPTENG"', 1) }}) as irpteng,
        upper({{ clean_legacy_text('"IRCHENG"', 1) }}) as ircheng,

        current_timestamp as _load_timestamp

    from source

)

select *
from cleaned