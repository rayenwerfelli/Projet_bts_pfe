{{ config(materialized='table', tags=['intermediate','req4']) }}

/*
  INT_CPT_ACTIFS
  ─────────────────────────────────────────────────────────────────────
  Source    : hist_cpt
  Grain     : une ligne = un compte actif (version courante)
*/

SELECT
    -- ── Clés ──────────────────────────────────────────────────────────
    ordcpt,
    codcltcpt,
    burcpt,
    codnatcpt,
    coddvscpt,

    -- ── Identification client ─────────────────────────────────────────
    nomcpt,
    prncpt,
    dnacpt,
    vnacpt,
    adr1cpt,
    anomcpt,
    aprncpt,
    aadr1cpt,
    aadr2cpt,
    aadr3cpt,
    aadr4cpt,

    -- ── Coordonnées bancaires ─────────────────────────────────────────
    ibancpt,
    ribbcpt,
    ribacpt,
    ribccpt,
    ribkcpt,
    ribcpt,

    -- ── Nature / classification ───────────────────────────────────────
    typcpt,
    catcpt,
    ppmcpt,
    klecpt,

    -- ── Dates ────────────────────────────────────────────────────────
    ouvcpt,
    dclocpt,
    ddmvcpt,
    dsldcpt,
    dmjcpt,

    -- ── Situation compte ──────────────────────────────────────────────
    clocpt,
    mclocpt,
    tdccpt,
    ndccpt,
    blkcpt,
    blccpt,
    gelcpt,

    -- ── Soldes ───────────────────────────────────────────────────────
    sldcpt,
    slccpt,
    smncpt,
    smxcpt,
    smmcpt,
    mcmcpt,
    mdmcpt,
    mmmcpt,
    sarcpt,

    -- ── Indicateurs divers ────────────────────────────────────────────
    isrcpt,
    iascpt,
    iancpt,
    avscpt,
    bctcpt,
    ivalcpt,
    iaccpt,
    iiecpt,
    trscpt,
    netcpt,
    tspcpt,
    rspcpt,

    -- ── SCD2 metadata ────────────────────────────────────────────────
    valid_from,
    valid_to,
    is_current,

    snapshot_updated_at

FROM {{ ref('hist_cpt') }}

WHERE
    is_current = true

    AND sucpt = '0'

    -- Dates sécurisées (évite crash dbt si var absente)
    AND ouvcpt BETWEEN
        DATE '{{ var("date1", "1900-01-01") }}'
        AND DATE '{{ var("date2", "9999-12-31") }}'

    AND (
        clocpt = '0'
        OR dclocpt <= DATE '{{ var("date2", "9999-12-31") }}'
    )
