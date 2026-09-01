{{ config(materialized='table', tags=['dimension','req4']) }}

SELECT
    
    
    md5(cast(ordcpt    as text))            AS compte_key,

    -- Clés métier
    ordcpt                                  AS ord_cpt,
    codcltcpt                               AS cod_client,
    burcpt                                  AS cod_agence,
    codnatcpt                               AS cod_nature_cpt,
    coddvscpt                               AS cod_devise,
    klecpt                                  AS cle_compte,
    sldcpt                                  AS sldcpt,

    -- Classification compte
    typcpt                                  AS type_compte,
    catcpt                                  AS categorie_compte,
    ppmcpt                                  AS ppm_compte,
    copcpt                                  AS cop_compte,
    ncvcpt                                  AS ncv_compte,

    -- Informations client
    nomcpt                                  AS nom_client,
    prncpt                                  AS prenom_client,
    dnacpt                                  AS date_naissance,
    vnacpt                                  AS ville_naissance,
    adr1cpt                                 AS adresse_client,

    -- Titulaire autorisé
    anomcpt                                 AS nom_autorise,
    aprncpt                                 AS prenom_autorise,
    aadr1cpt                                AS adresse_autorise_1,
    aadr2cpt                                AS adresse_autorise_2,
    aadr3cpt                                AS adresse_autorise_3,
    aadr4cpt                                AS adresse_autorise_4,

    -- Coordonnées bancaires
    ibancpt                                 AS iban,
    ribcpt                                  AS rib,
    ribbcpt                                 AS rib_banque,
    ribacpt                                 AS rib_agence,
    ribccpt                                 AS rib_compte,
    ribkcpt                                 AS rib_cle,

    -- Situation compte
    clocpt                                  AS situation_cpt,
    CASE WHEN clocpt = '0' THEN 'Actif'
         ELSE 'Clôturé' END                 AS situation_libelle,
    mclocpt                                 AS motif_cloture,
    tdccpt                                  AS type_doc_cloture,
    ndccpt                                  AS num_doc_cloture,

    -- Blocage / gel
    blkcpt                                  AS ind_bloque,
    blccpt                                  AS ind_bloque_credit,
    gelcpt                                  AS ind_gele,

    -- Indicateurs
    isrcpt                                  AS ind_isrs,
    iascpt                                  AS ind_ias,
    iancpt                                  AS ind_ian,
    avscpt                                  AS ind_avs,
    bctcpt                                  AS ind_bct,
    ivalcpt                                 AS ind_ival,
    iaccpt                                  AS ind_iac,
    iiecpt                                  AS ind_iie,
    trscpt                                  AS ind_trs,
    netcpt                                  AS ind_net,
    tspcpt                                  AS ind_tsp,
    rspcpt                                  AS ind_rsp,
    rcqcpt                                  AS ind_rcq,

    -- Paramètres crédit / épargne
    taucpt                                  AS taux_compte,
    prlcpt                                  AS periodicite_rl,
    cmncpt                                  AS commission,
    tadcpt                                  AS tad_compte,
    osgcpt                                  AS osg_compte,
    jntcpt                                  AS jnt_compte,
    cpscpt                                  AS cps_compte,
    cnpcpt                                  AS cnp_compte,
    effcpt                                  AS eff_compte,
    prvcpt                                  AS prv_compte,

    -- Codes divers
    rzdcpt                                  AS rzd_compte,
    rzvcpt                                  AS rzv_compte,
    lngcpt                                  AS langue_compte,
    opdcpt                                  AS opd_compte,
    opccpt                                  AS opc_compte,
    oppcpt                                  AS opp_compte,
    lnrcpt                                  AS lnr_compte,
    tidcpt                                  AS tid_compte,
    ndtcpt                                  AS ndt_compte,
    cazcpt                                  AS caz_compte,
    cazmcpt                                 AS cazm_compte,

    -- Dates
    ouvcpt                                  AS date_ouverture,
    dclocpt                                 AS date_cloture,
    ddmvcpt                                 AS date_dernier_mvt,
    dsldcpt                                 AS date_solde,
    dpdcpt                                  AS date_pd,
    dpccpt                                  AS date_pc,
    dcecpt                                  AS date_ce,
    dcrccpt                                 AS date_crc_debut,
    ecrccpt                                 AS date_crc_fin,
    dincpt                                  AS date_in,
    davcpt                                  AS date_av,
    dartcpt                                 AS date_art,
    dmjcpt                                  AS date_maj,

    -- SCD2
    valid_from,
    valid_to,
    is_current,
    snapshot_updated_at,

    CURRENT_TIMESTAMP                       AS dbt_loaded_at

FROM {{ ref('hist_cpt') }}