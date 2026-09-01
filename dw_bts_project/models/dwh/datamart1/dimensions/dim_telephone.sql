{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_tel') }}
    where is_current = true

)

select

    -- =========================
    -- SURROGATE KEY
    -- =========================
    md5(cast(numtel || '-' || codclttel as text)) as telephone_key,

    -- =========================
    -- BUSINESS KEYS
    -- =========================
    numtel,
    codclttel,

    -- =========================
    -- TYPOLOGIE / CLASSIFICATION
    -- =========================
    sutel,
    coptel,
    paytel,
    typetel,
    utltel,

    -- =========================
    -- STATUT / INDICATEURS
    -- =========================
    emptel,
    exrtel,
    rojtel,

    -- =========================
    -- CONTACT INFO (texte brut)
    -- =========================
    rmqtel,

    -- =========================
    -- DATES
    -- =========================
    dmjtel,
    hdatel,
    hfatel,

    -- =========================
    -- TECHNICAL
    -- =========================
    timtel,

    -- =========================
    -- AUDIT
    -- =========================
    current_timestamp as _load_timestamp

from src