{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_adr') }}
    where is_current = true

)

select

    -- =========================
    -- SURROGATE KEY
    -- =========================
    md5(cast(codcltadr || '-' || numadr as text)) as adresse_key,

    -- =========================
    -- BUSINESS KEYS
    -- =========================
    codcltadr,
    numadr,

    -- =========================
    -- LOCALISATION
    -- =========================
    codpayadr,
    codpttadr,
    typadr,

    -- =========================
    -- ADRESSE BRUTE (sans transformation lourde en dim)
    -- =========================
    lg1adr,
    pteadr,
    alibadr,

    -- =========================
    -- META
    -- =========================
    suadr,
    dmjadr,
    timadr,

    -- =========================
    -- AUDIT
    -- =========================
    current_timestamp as _load_timestamp

from src