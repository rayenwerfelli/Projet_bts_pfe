{{ config(materialized='table') }}

with src as (
    select *
    from {{ ref('hist_unt') }}
    where is_current = true
)

select
    md5(cast(codunt as text))  as unite_key,
    codunt,
    libunt,
    alibunt,
    codtntunt,
    codpttunt,
    codnogunt,
    codbaqunt,
    adr1unt,
    telunt,
    emlunt,
    faxunt,
    lttunt,
    lgtunt,
    current_timestamp  as _load_timestamp
from src