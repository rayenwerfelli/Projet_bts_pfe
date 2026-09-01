{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_dmy') }}
    where is_current = true

)

select
    md5(cast(coddmy as text))  as type_demande_key,

    coddmy,
    libdmy,
    nbjcdmy,
    nbjadmy,
    mmidmy,
    mmxdmy,
    rmbdmy,
    codnatdmy,

    current_timestamp  as _load_timestamp

from src