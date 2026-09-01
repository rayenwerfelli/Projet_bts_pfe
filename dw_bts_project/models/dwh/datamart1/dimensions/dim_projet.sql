{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_prj') }}
    where is_current = true
      and suprj = 0

)

select
    md5(cast(codprj as text))  as projet_key,

    codprj,
    codcltprj,
    codzacprj,
    codgovprj,
    coddlgprj,
    codlocprj,
    codtpjprj,
    codpttprj,
    codapmprj,
    datprj,
    denrprj,
    adrprj,
    dscprj,
    insprj,
    etbprj,
    nepprj,
    srfiprj,
    srfprj,
    rvnprj,
    chgprj,

    current_timestamp  as _load_timestamp

from src