{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_nis') }}
    where is_current = true

)

select
    md5(cast(codnis as text))  as niveau_instruction_key,

    codnis,
    libnis,           -- brut complet

    current_timestamp  as _load_timestamp

from src