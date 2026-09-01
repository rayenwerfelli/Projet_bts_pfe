{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_dmx') }}
    where is_current = true

)

select
    md5(cast(coddmx as text))  as origine_demande_key,

    coddmx,
    libdmx,
    dmddmx,
    avidmx,
    sbvdmx,

    current_timestamp  as _load_timestamp

from src