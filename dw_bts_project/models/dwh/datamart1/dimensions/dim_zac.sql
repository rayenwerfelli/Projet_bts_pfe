{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_zac') }}
    where is_current = true

)

select
    md5(cast(codzac as text))  as zac_key,

    codzac,
    libzac,
    seczac,           -- brut A/S/I/B/M
    codzclzac,
    codzabzac,
    codapmzac,
    abrzac,

    current_timestamp  as _load_timestamp

from src