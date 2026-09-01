{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_emp') }}
    where is_current = true

)

select
    md5(cast(matemp as text))  as employe_key,

    matemp,
    nomemp,
    prnemp,
    concat_ws(' ', prnemp, nomemp)  as nom_complet,
    sexemp,           -- brut M/F
    naiemp,
    coduntemp,
    dafemp,

    current_timestamp  as _load_timestamp

from src