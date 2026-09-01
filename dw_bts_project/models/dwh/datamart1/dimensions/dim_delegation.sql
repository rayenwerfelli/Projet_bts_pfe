{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_dlg') }}
    where is_current = true

)

select
    md5(cast(codgovdlg as text) || '-' || cast(coddlg as text))  as delegation_key,

    codgovdlg,
    coddlg,
    libdlg,
    alibdlg,

    current_timestamp  as _load_timestamp

from src