{{ config(materialized='table', tags=['intermediate','req4']) }}

/*
  INT_CPT_ENRICHI
  ─────────────────────────────────────────────────────────────────────
  Source    : int_cpt_actifs
            + ref_agence    (pont sur dim_unite — domaine externe)
            + hist_nat      (is_current — domaine REQ4)
  Grain     : une ligne = un compte actif enrichi
  ─────────────────────────────────────────────────────────────────────
*/

WITH cpt AS (
    SELECT * FROM {{ ref('int_cpt_actifs') }}
),

agence AS (
    -- Lecture seule via le pont ref_agence (ne modifie pas dim_unite)
    SELECT
        sk_agence,
        cod_agence,
        agence_nom,
        agence_libelle,
        agence_nom_alternatif,
        agence_code_territoire,
        agence_code_postal,
        agence_code_gouvernorat,
        agence_code_banque,
        agence_adresse,
        agence_telephone,
        agence_email,
        agence_fax,
        agence_latitude,
        agence_longitude
    FROM {{ ref('ref_agence') }}
),

nat AS (
    SELECT
        codnat,
        libnat,
        typnat,
        catnat,
        crjnat,
        chqnat,
        tysnat,
        parnat,
        rglnat,
        tdvnat,
        iavcnat,
        iprtmnat,
        bctnat,
        cpfnat,
        taunat,
        ttvanat,
        impnat,
        mrgnat,
        irsnat
    FROM {{ ref('hist_nat') }}
    WHERE is_current = true

)

SELECT
    -- ── Agence (via ref_agence → dim_unite) ───────────────────────────
    cpt.burcpt                              AS cod_agence,
    a.sk_agence,
    a.agence_libelle,
    a.agence_nom,
    a.agence_nom_alternatif,
    a.agence_code_territoire,
    a.agence_code_postal,
    a.agence_code_gouvernorat,
    a.agence_code_banque,
    a.agence_adresse,
    a.agence_telephone,
    a.agence_email,
    a.agence_fax,
    a.agence_latitude,
    a.agence_longitude,

    -- ── Nature compte (via hist_nat) ──────────────────────────────────
    cpt.codnatcpt                           AS cod_nature_cpt,
    nat.libnat                              AS nature_libelle,
    nat.typnat                              AS nature_type,
    nat.catnat                              AS nature_categorie,
    nat.crjnat                              AS nature_crejour,
    nat.chqnat                              AS nature_cheque,
    nat.tysnat                              AS nature_type_solde,
    nat.parnat                              AS nature_parrainage,
    nat.rglnat                              AS nature_reglementation,
    nat.tdvnat                              AS nature_type_devise,
    nat.iavcnat                             AS nature_ind_avance,
    nat.iprtmnat                            AS nature_ind_pret,
    nat.bctnat                              AS nature_bct,
    nat.cpfnat                              AS nature_cpf,
    nat.taunat                              AS nature_taux,
    nat.ttvanat                             AS nature_tva,
    nat.impnat                              AS nature_impot,
    nat.mrgnat                              AS nature_marge,
    nat.irsnat                              AS nature_irs,

    -- ── Compte ────────────────────────────────────────────────────────
    cpt.ordcpt                              AS ord_cpt,
    cpt.codcltcpt                           AS cod_client,
    cpt.coddvscpt                           AS cod_devise,
    cpt.klecpt                              AS cle_compte,
    cpt.typcpt                              AS type_compte,
    cpt.catcpt                              AS categorie_compte,
    cpt.ppmcpt                              AS ppm_compte,

    -- ── Client ────────────────────────────────────────────────────────
    cpt.nomcpt                              AS nom_client,
    cpt.prncpt                              AS prenom_client,
    cpt.dnacpt                              AS date_naissance,
    cpt.vnacpt                              AS ville_naissance,
    cpt.adr1cpt                             AS adresse_client,
    cpt.anomcpt                             AS nom_autorise,
    cpt.aprncpt                             AS prenom_autorise,
    cpt.aadr1cpt                            AS adresse_autorise,

    -- ── Coordonnées bancaires ─────────────────────────────────────────
    cpt.ibancpt                             AS iban,
    cpt.ribcpt                              AS rib,
    cpt.ribbcpt                             AS rib_banque,
    cpt.ribacpt                             AS rib_agence,
    cpt.ribccpt                             AS rib_compte,
    cpt.ribkcpt                             AS rib_cle,

    -- ── Situation compte ──────────────────────────────────────────────
    cpt.clocpt                              AS situation_cpt,
    CASE WHEN cpt.clocpt = '0' THEN 'Actif' ELSE 'Clôturé' END
                                            AS situation_libelle,
    cpt.mclocpt                             AS motif_cloture,
    cpt.tdccpt                              AS type_doc_cloture,
    cpt.ndccpt                              AS num_doc_cloture,
    cpt.blkcpt                              AS ind_bloque,
    cpt.blccpt                              AS ind_bloque_credit,
    cpt.gelcpt                              AS ind_gele,

    -- ── Indicateurs ───────────────────────────────────────────────────
    cpt.isrcpt                              AS ind_isrs,
    cpt.iascpt                              AS ind_ias,
    cpt.iancpt                              AS ind_ian,
    cpt.avscpt                              AS ind_avs,
    cpt.bctcpt                              AS ind_bct,
    cpt.ivalcpt                             AS ind_ival,
    cpt.iaccpt                              AS ind_iac,
    cpt.iiecpt                              AS ind_iie,
    cpt.trscpt                              AS ind_trs,
    cpt.netcpt                              AS ind_net,
    cpt.tspcpt                              AS ind_tsp,
    cpt.rspcpt                              AS ind_rsp,

    -- ── Dates ────────────────────────────────────────────────────────
    cpt.ouvcpt                              AS date_ouverture,
    cpt.dclocpt                             AS date_cloture,
    cpt.ddmvcpt                             AS date_dernier_mvt,
    cpt.dsldcpt                             AS date_solde,
    cpt.dmjcpt                              AS date_maj,

    -- ── Soldes ───────────────────────────────────────────────────────
    cpt.sldcpt                              AS solde_cpt,
    cpt.slccpt                              AS solde_comptable,
    cpt.smncpt                              AS solde_min,
    cpt.smxcpt                              AS solde_max,
    cpt.smmcpt                              AS solde_moyen,
    cpt.mcmcpt                              AS mvt_credit_mois,
    cpt.mdmcpt                              AS mvt_debit_mois,
    cpt.mmmcpt                              AS mvt_moyen_mois,
    cpt.sarcpt                              AS solde_arrete,

    -- ── SCD2 metadata ────────────────────────────────────────────────
    cpt.valid_from,
    cpt.valid_to,
    cpt.is_current,
    cpt.snapshot_updated_at

FROM cpt
LEFT JOIN agence a   ON cpt.burcpt     = a.cod_agence
LEFT JOIN nat        ON cpt.codnatcpt  = nat.codnat
