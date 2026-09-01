{{ config(materialized='table') }}

with source_gov as (

    select *
    from {{ source('ods', 'GOV') }}

),

typed as (

    select
        cast("SUGOV" as integer) as sugov,
        {{ parse_mixed_date('"DMJGOV"') }} as dmjgov,
        cast("TIMGOV" as bigint) as timgov,
        cast("EMPGOV" as integer) as empgov,
        {{ clean_legacy_text('"COPGOV"', 4) }} as copgov,

        cast("CODGOV" as integer) as codgov,
        {{ clean_legacy_text('"LIBGOV"', 40) }} as libgov,
        {{ clean_legacy_text('"ALIBGOV"', 40) }} as alibgov,
        cast("CODREGGOV" as integer) as codreggov,

        current_timestamp as dwh_load_ts

    from source_gov

)

select *
from typed