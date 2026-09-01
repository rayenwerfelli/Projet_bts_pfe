{{ config(materialized='table') }}

with src as (
    select *
    from {{ ref('hist_ptt') }}
    where is_current = true
)

select
    md5(cast(codptt as text))  as ptt_key,
    codptt,
    libptt,
    current_timestamp           as _load_timestamp
from src