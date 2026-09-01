{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_eng') }}
    where is_current = true

)

select

    md5(trim(cast(codeng as text))) as engagement_key,

    codeng,
    libeng,
    codlfneng,

    coalesce(irmbeng::int,0) as irmbeng,

    taueng,
    tmxeng,
    tmneng,

    current_timestamp as _load_timestamp

from src