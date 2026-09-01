{{ config(materialized='table') }}

with zcl as (
    select * from {{ ref('hist_zcl') }} where is_current = true
),
zgr as (
    select * from {{ ref('hist_zgr') }} where is_current = true
),
zdv as (
    select * from {{ ref('hist_zdv') }} where is_current = true
),
zss as (
    select * from {{ ref('hist_zss') }} where is_current = true
),
zsc as (
    select * from {{ ref('hist_zsc') }} where is_current = true
)

select
    md5(
        coalesce(zcl.codzcl, 'X') || '-' ||
        coalesce(zgr.codzgr, 'X') || '-' ||
        coalesce(zdv.codzdv, 'X') || '-' ||
        coalesce(zss.codzss, 'X') || '-' ||
        coalesce(zsc.codzsc, 'X')
    ) as classif_activite_key,

    -- Classe
    zcl.codzcl as codactivclass,
    zcl.libzcl as activclass,

    -- Groupe
    zgr.codzgr as codactivgroup,
    zgr.libzgr as activgroup,

    -- Division
    zdv.codzdv as codactivdiv,
    zdv.libzdv as activdiv,

    -- Sous-section
    zss.codzss as codactivsoussect,
    zss.libzss as activsoussect,

    -- Section
    zsc.codzsc as codactivsection,
    zsc.libzsc as activsection,

    current_timestamp as _load_timestamp

from zcl
left join zgr on zcl.codzgrzcl = zgr.codzgr
left join zdv on zgr.codzdvzgr = zdv.codzdv
left join zss on zdv.codzsszdv = zss.codzss
left join zsc on zss.codzsczss = zsc.codzsc