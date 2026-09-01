{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_trh') }}
    where is_current = true

)

select

    -- =========================
    -- SURROGATE KEY
    -- =========================
    md5(cast(numtrh || '-' || codclttrh || '-' || ordcpttrh as text)) as trh_key,

    -- =========================
    -- BUSINESS KEYS
    -- =========================
    numtrh,
    num2trh,
    codclttrh,
    ordcpttrh,
    klecpttrh,

    -- =========================
    -- STRUCTURE / META
    -- =========================
    sutrh,
    emptrh,
    coptrh,
    codengtrh,
    refauttrh,

    -- =========================
    -- TYPOLOGIE
    -- =========================
    codgovtrh,
    codtrbtrh,
    typtrbtrh,

    -- =========================
    -- FINANCIAL ATTRIBUTES (DESCRIPTIF UNIQUEMENT)
    -- =========================
    mnttrh,
    minttrh,
    mhtvtrh,
    mtvatrh,
    mttctrh,
    mtmbtrh,
    masstrh,
    mloytrh,

    tautrh,
    tegtrh,
    tautvatrh,

    comtrh,
    com1trh,
    com2trh,
    com3trh,

    fra1trh,
    fra2trh,
    fra3trh,

    tvatrh,
    tvaf1trh,
    tvaf2trh,
    tvaf3trh,

    -- =========================
    -- STATUS FLAGS
    -- =========================
    etatrh,
    dbktrh,
    frztrh,
    dechtrh,
    rejset,

    -- =========================
    -- DATES
    -- =========================
    dmjtrh,
    dtbtrh,
    dtttrh,
    ddsttrh,
    dattrbtrh,

    -- =========================
    -- COMMENTAIRE
    -- =========================
    cmntrh,

    -- =========================
    -- AUDIT
    -- =========================
    current_timestamp as _load_timestamp

from src