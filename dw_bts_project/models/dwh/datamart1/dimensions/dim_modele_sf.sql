{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_hmf') }}
    where is_current = true

)

select
    md5(cast(codhmf as text))  as modele_financement_key,

    codhmf,
    libhmf,
    typhmf,
    tauhmf,
    tvahmf,
    mplfhmf,
    mplchmf,
    mcomhmf,

    current_timestamp  as _load_timestamp

from src