{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_nat') }}
    where is_current = true

)

select

    -- =========================
    -- SURROGATE KEY
    -- =========================
    md5(cast(codnat as text)) as nature_key,

    -- =========================
    -- BUSINESS KEY
    -- =========================
    codnat,

    -- =========================
    -- DESCRIPTION
    -- =========================
    libnat,

    -- =========================
    -- TYPOLOGIE
    -- =========================
    typnat,
    catnat,

    -- =========================
    -- INDICATEURS METIER
    -- =========================
    crjnat,
    chqnat,
    tysnat,
    tpxcnat,
    rlvnat,

    -- =========================
    -- PARAMETRES FINANCIERS
    -- =========================
    cpfnat,
    taunat,
    mntnat,
    tavxnat,
    avjnat,
    tdrnat,

    -- =========================
    -- FISCALITE / TAXES
    -- =========================
    ttvanat,
    impnat,
    mrgnat,
    irsnat,

    -- =========================
    -- FLAGS / INDICATEURS
    -- =========================
    agenat,
    tpnlnat,
    trtsnat,
    acnat,
    iavcnat,
    iprtmnat,

    -- =========================
    -- DATES
    -- =========================
    dmjnat,
    dartnat,
    drxnat,
    drmnat,

    -- =========================
    -- AUDIT
    -- =========================
    current_timestamp as _load_timestamp

from src