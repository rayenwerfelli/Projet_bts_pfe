{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_dmg') }}
    where is_current = true
      and sudmg = 0

)

select
    md5(cast(numdmg as text))  as demande_key,

    numdmg,
    datdmg,
    etadmg,           -- brut 0/1/2...
    dsddmg,           -- brut 1/2/3/4
    idcadmg,          -- brut 1/2
    daddmg,
    cd1dmg,
    dtrfdmg,
    drpdmg,
    dncdmg,
    denrdmg,
    davidmg,
    dadcdmg,
    dautdmg,
    drcpdmg,
    numautdmg,
    tepdmg,
    codcltdmg,
    untidmg,
    coddmydmg,
    coddmxdmg,
    codhmfdmg,
    dcddmg,
    codunddmg,
    rpcdmg,

    current_timestamp  as _load_timestamp

from src