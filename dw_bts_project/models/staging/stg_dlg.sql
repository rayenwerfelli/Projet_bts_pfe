

with source as (
    select *
    from {{ source('ods', 'DLG') }}
),

cleaned as (
    select
        {{ clean_int('"SUDLG"') }} as sudlg,
        {{ parse_mixed_date('"DMJDLG"') }} as dmjdlg,
        {{ clean_int('"TIMDLG"') }} as timdlg,
        {{ clean_int('"EMPDLG"') }} as empdlg,
        {{ clean_legacy_text('"COPDLG"', 4) }} as copdlg,

        {{ clean_int('"CODGOVDLG"') }} as codgovdlg,
        {{ clean_int('"CODDLG"') }} as coddlg,

        upper({{ clean_legacy_text('"LIBDLG"', 40) }}) as libdlg,
        upper({{ clean_legacy_text('"ALIBDLG"', 40) }}) as alibdlg,

        current_timestamp as _load_timestamp
    from source
)

select *
from cleaned