{{ config(materialized='table', tags=['dimension','req4']) }}

/*
  DIM_NATURE_COMPTE
  ─────────────────────────────────────────────────────────────────────
  Source  : hist_nat (snapshot SCD2 sur stg_nat)
  Grain   : une ligne par version de nature (SCD2 complet)
  is_current = true → version active aujourd'hui
  ─────────────────────────────────────────────────────────────────────
*/

SELECT
    {{ dbt_utils.generate_surrogate_key(['codnat', 'valid_from']) }}  AS sk_nature,

    -- Clé métier
    codnat                                          AS cod_nature,

    -- Libellé
    libnat                                          AS nature_libelle,

    -- Classification
    typnat                                          AS nature_type,
    catnat                                          AS nature_categorie,
    tysnat                                          AS nature_type_solde,
    tdvnat                                          AS nature_type_devise,
    rglnat                                          AS nature_reglementation,
    parnat                                          AS nature_parrainage,
    codtdpnat                                       AS nature_code_tdp,
    codetbnat                                       AS nature_code_etb,

    -- Fonctionnalités
    crjnat                                          AS nature_crejour,
    chqnat                                          AS nature_cheque,
    rlvnat                                          AS nature_releve,

    -- Indicateurs
    iavcnat                                         AS nature_ind_avance,
    iprtmnat                                        AS nature_ind_pret,
    bctnat                                          AS nature_bct,
    acnat                                           AS nature_ind_ac,
    trtsnat                                         AS nature_ind_trt,
    tpnlnat                                         AS nature_type_nliq,

    -- Paramètres financiers
    cpfnat                                          AS nature_cpf,
    taunat                                          AS nature_taux,
    mntnat                                          AS nature_montant,
    ttvanat                                         AS nature_tva,
    impnat                                          AS nature_impot,
    mrgnat                                          AS nature_marge,
    irsnat                                          AS nature_irs,
    tavxnat                                         AS nature_taux_avx,
    avjnat                                          AS nature_avance_jour,
    tdrnat                                          AS nature_taux_dr,

    -- Réglementation BCT
    bctrglnat                                       AS nature_bct_reg,

    -- Dates
    dartnat                                         AS nature_date_art,
    drmnat                                          AS nature_date_rm,
    drxnat                                          AS nature_date_rx,

    -- SCD2
    valid_from,
    valid_to,
    is_current,

    snapshot_updated_at,

    CURRENT_TIMESTAMP                               AS dbt_loaded_at

FROM {{ ref('hist_nat') }}
