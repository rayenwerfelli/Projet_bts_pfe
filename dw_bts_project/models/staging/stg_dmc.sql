{{ config(materialized='table') }}

with source as (
    select *
    from {{ source('ods', 'DMC') }}
),

cleaned as (
    select
        {{ clean_int('"SUDMC"') }} as sudmc,
        {{ parse_mixed_date('"DMJDMC"') }} as dmjdmc,
        {{ clean_int('"TIMDMC"') }} as timdmc,
        {{ clean_int('"EMPDMC"') }} as empdmc,
        {{ clean_legacy_text('"COPDMC"', 4) }} as copdmc,

        {{ clean_int('"NUMDMGDMC"') }} as numdmgdmc,
        {{ clean_int('"ORDDMC"') }} as orddmc,
        {{ clean_int('"CODENADMC"') }} as codenadmc,

        {{ clean_legacy_text('"DSCDMC"', 250) }} as dscdmc,

        {{ clean_number('"MNTDMC"', 15, 3) }} as mntdmc,
        {{ clean_number('"ANTDMC"', 15, 3) }} as antdmc,
        {{ clean_int('"DURDMC"') }} as durdmc,
        {{ clean_int('"FRCDMC"') }} as frcdmc,
        {{ clean_int('"PERDMC"') }} as perdmc,

        {{ clean_number('"MNTADMC"', 15, 3) }} as mntadmc,
        {{ clean_number('"ANTADMC"', 15, 3) }} as antadmc,
        {{ clean_int('"DURADMC"') }} as duradmc,
        {{ clean_int('"FRCADMC"') }} as frcadmc,
        {{ clean_int('"PERADMC"') }} as peradmc,

        {{ clean_legacy_text('"CODDVSDMC"', 3) }} as coddvsdmc,
        {{ clean_legacy_text('"TASSDMC"', 1) }} as tassdmc,

        {{ clean_number('"MASSDMC"', 15, 3) }} as massdmc,
        {{ clean_number('"MLOYDMC"', 15, 3) }} as mloyddmc,
        {{ clean_number('"MFNGDMC"', 15, 3) }} as mfngdmc,
        {{ clean_int('"CODASRDMC"') }} as codasrdmc,

        current_timestamp as _load_timestamp
    from source
)

select *
from cleaned