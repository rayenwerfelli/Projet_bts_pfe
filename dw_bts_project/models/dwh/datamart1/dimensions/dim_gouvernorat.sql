{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_gov') }}
    where is_current = true

)

select
    md5(cast(codgov as text))  as gouvernorat_key,

    codgov,
    libgov,
    alibgov,
    codreggov,

    current_timestamp  as _load_timestamp

from src