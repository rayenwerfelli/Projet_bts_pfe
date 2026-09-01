{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_loc') }}
    where is_current = true

)

select
    md5(
        cast(codgovloc as text) || '-' ||
        cast(coddlgloc as text) || '-' ||
        cast(codloc    as text)
    )  as localite_key,

    codgovloc,
    coddlgloc,
    codloc,
    codpttloc,
    libloc,
    alibloc,
    zbrloc,

    current_timestamp  as _load_timestamp

from src