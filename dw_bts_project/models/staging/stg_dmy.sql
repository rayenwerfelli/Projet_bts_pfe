{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('ods', 'DMY') }}

),

cleaned as (

    select
        {{ clean_int('"SUDMY"') }} as sudmy,
        {{ parse_mixed_date('"DMJDMY"') }} as dmjdmy,
        {{ clean_int('"TIMDMY"') }} as timdmy,
        {{ clean_int('"EMPDMY"') }} as empdmy,
        {{ clean_legacy_text('"COPDMY"', 4) }} as copdmy,

        {{ clean_int('"CODDMY"') }} as coddmy,
        {{ clean_legacy_text('"LIBDMY"', 60) }} as libdmy,

        {{ clean_int('"NBJCDMY"') }} as nbjcdmy,
        {{ clean_int('"NBJADMY"') }} as nbjadmy,
        {{ clean_number('"MMIDMY"', 15, 3) }} as mmidmy,
        {{ clean_number('"MMXDMY"', 15, 3) }} as mmxdmy,

        {{ clean_int('"IISDMY"') }} as iisdmy,
        {{ clean_int('"MXFDMY"') }} as mxfdmy,
        {{ clean_int('"MNFDMY"') }} as mnfdmy,

        upper({{ clean_legacy_text('"RMBDMY"', 1) }}) as rmbdmy,
        upper({{ clean_legacy_text('"IRTCDMY"', 1) }}) as irtcdmy,

        {{ clean_int('"CODNATDMY"') }} as codnatdmy,
        {{ clean_int('"ICSLDMY"') }} as icsldmy,
        {{ clean_int('"IFTSDMY"') }} as iftsdmy,

        current_timestamp as _load_timestamp

    from source

)

select *
from cleaned