{{ config(materialized='table') }}

with source_hsf as (

    select *
    from {{ source('ods', 'HSF') }}

),

typed as (

    select
        cast("SUHSF" as integer) as suhsf,
        {{ parse_mixed_date('"DMJHSF"') }} as dmjhsf,
        cast("TIMHSF" as bigint) as timhsf,
        cast("EMPHSF" as integer) as emphsf,
        {{ clean_legacy_text('"COPHSF"', 4) }} as cophsf,

        cast("NUMDMGHSF" as bigint) as numdmghsf,
        cast("CODHRFHSF" as integer) as codhrfhsf,
        cast("TYPHSF" as integer) as typhsf,
        cast("NUMHSF" as integer) as numhsf,

        cast("MNCHSF" as numeric(15,3)) as mnchsf,
        cast("MNPHSF" as numeric(15,3)) as mnphsf,
        cast("MNAHSF" as numeric(15,3)) as mnahsf,

        {{ clean_legacy_text('"LIBHSF"', 60) }} as libhsf,

        cast("MNCTHSF" as numeric(15,3)) as mncthsf,
        cast("MNPTHSF" as numeric(15,3)) as mnpthsf,
        cast("MNATHSF" as numeric(15,3)) as mnathsf,
        cast("MNCVHSF" as numeric(15,3)) as mncvhsf,
        cast("MNPVHSF" as numeric(15,3)) as mnpvhsf,
        cast("MNAVHSF" as numeric(15,3)) as mnavhsf,

        current_timestamp as dwh_load_ts

    from source_hsf

)

select *
from typed