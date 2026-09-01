{{ config(materialized='table') }}

with src as (

    select *
    from {{ ref('hist_lfn') }}
    where is_current = true

)

select

    -- =========================
    -- SURROGATE KEY
    -- =========================
    md5(cast(codlfn as text)) as lfn_key,

    -- =========================
    -- BUSINESS KEY
    -- =========================
    codlfn,

    -- =========================
    -- DESCRIPTION
    -- =========================
    liblfn,

    -- =========================
    -- TYPOLOGIE
    -- =========================
    typlfn,
    sttlfn,
    natlfn,
    coflfn,
    modlfn,

    -- =========================
    -- STRUCTURE / RÉFÉRENTIEL
    -- =========================
    codkgrlfn,
    etbkgrlfn,
    plnkgrlfn,
    refclfn,
    refglfn,

    -- =========================
    -- INDICATEURS FINANCIERS
    -- =========================
    rmblfn,
    mntclfn,
    mcomlfn,
    tauilfn,

    ccelfn,
    ccdlfn,
    dvsclfn,
    airlfn,
    ainrlfn,
    rsclfn,

    -- =========================
    -- FLAGS MÉTIER
    -- =========================
    frzlfn,
    baflfn,
    doalfn,

    -- =========================
    -- DATES
    -- =========================
    dmjlfn,
    ddblfn,
    dfnlfn,
    ddrblfn,
    dfnrlfn,

    -- =========================
    -- AUDIT
    -- =========================
    current_timestamp as _load_timestamp

from src