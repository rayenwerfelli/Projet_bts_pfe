{{ config(materialized='table') }}

with src as (
    select *
    from {{ ref('hist_aut') }}
    where is_current = true
      and suaut = 0
)

select
    md5(cast(refaut as text))  as autorisation_key,
    refaut,
    mntaut,
    dataut,
    cloaut,               -- brut 0..9
    current_timestamp      as _load_timestamp
from src