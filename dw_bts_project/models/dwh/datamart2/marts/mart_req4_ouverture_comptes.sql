{{ config(materialized='table', tags=['mart','req4']) }}

/*
  MART_REQ4_OUVERTURE_COMPTES
  ─────────────────────────────────────────────────────────────────────
  Objectif : table plate consommée directement par le dashboard REQ4.
             Joint fact + dims pour exposer tous les libellés sans
             jointure côté Superset/BI.

  Source    : fact_ouverture_compte
            + ref_agence          (agence_libelle, agence_nom, ...)
            + dim_nature_compte   (nature_libelle, ...)
            + dim_compte          (nom_client, prenom_client, ...)
            + dim_client          (sexe, situation familiale, NIS, ZAC …)
            + dim_niveau_instruction (libnis)
            + dim_zac             (libzac, secteur …)
  Grain     : une ligne = un compte actif ouvert dans [date1, date2]
  ─────────────────────────────────────────────────────────────────────
*/

WITH fact AS (
    SELECT * FROM {{ ref('fact_ouverture_compte') }}
),

agence AS (
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
        agence_latitude,
        agence_longitude
    FROM {{ ref('ref_agence') }}
),

nature AS (
    SELECT
        sk_nature,
        cod_nature,
        nature_libelle,
        nature_type,
        nature_categorie,
        nature_type_solde,
        nature_type_devise,
        nature_reglementation,
        nature_ind_avance,
        nature_ind_pret,
        nature_bct,
        nature_taux,
        nature_tva,
        nature_impot,
        nature_marge
    FROM {{ ref('dim_nature_compte') }}
    WHERE is_current = true
),

compte AS (
    SELECT
        compte_key AS sk_compte,
        ord_cpt,
        cod_client,
        nom_client,
        prenom_client,
        date_naissance,
        ville_naissance,
        adresse_client,
        nom_autorise,
        prenom_autorise,
        iban,
        rib,
        type_compte,
        categorie_compte,
        langue_compte,
        taux_compte,
        ind_bloque,
        ind_bloque_credit,
        ind_gele
    FROM {{ ref('dim_compte') }}
    WHERE is_current = true
),

/*
  ── Dim client : genre, situation familiale, NIS, ZAC ─────────────────
  La jointure se fait sur cod_client (codclt dans dim_client).
  On ne prend que les colonnes utiles au dashboard.
*/
client AS (
    SELECT
        nomclt,
        prnclt,
        codclt,
        sexclt,
        lib_sexe,
        stfclt,
        lib_situation_familiale,
        codnisclt,      -- clé vers dim_niveau_instruction
        ageclt,         -- code agence client (≠ agence bancaire)
        naeclt,         -- code activité économique
        napclt,         -- code activité professionnelle
        rgmclt,         -- code régime
        rsdclt,         -- code résidence
        crpclt,         -- code catégorie socio-professionnelle
        codqlfclt,      -- qualification
        codstjclt,      -- statut juridique
        lttclt,         -- latitude
        lgtclt          -- longitude
    FROM {{ ref('dim_client') }}
),

/*
  ── Dim niveau d'instruction ──────────────────────────────────────────
  Jointure sur codnisclt (côté client) = codnis (côté dim).
*/
nis AS (
    SELECT
        codnis,
        libnis
    FROM {{ ref('dim_niveau_instruction') }}
)

/*
  ── Dim ZAC (zone d'activité / secteur) ───────────────────────────────
  La ZAC est portée par le client via son code ZAC.
  Si dim_client expose codzac, sinon adapter la jointure.
*/


SELECT
    -- ── Identifiant ligne ──────────────────────────────────────────────
    fact.sk_compte,
    fact.sk_agence,
    fact.sk_nature,

    -- ── Agence (dénormalisé depuis ref_agence) ────────────────────────
    fact.cod_agence,
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
    a.agence_latitude,
    a.agence_longitude,

    -- ── Nature compte (dénormalisé depuis dim_nature_compte) ──────────
    fact.cod_nature_cpt,
    n.nature_libelle,
    n.nature_type,
    n.nature_categorie,
    n.nature_type_solde,
    n.nature_type_devise,
    n.nature_reglementation,
    n.nature_ind_avance,
    n.nature_ind_pret,
    n.nature_bct,
    n.nature_taux,
    n.nature_tva,
    n.nature_impot,
    n.nature_marge,

    -- ── Compte / Client (dénormalisé depuis dim_compte) ───────────────
    fact.ord_cpt,
    fact.cod_client,
    cl.nomclt  AS nom_client,
    cl.prnclt  AS prenom_client,
    c.date_naissance,
    c.ville_naissance,
    c.adresse_client,
    c.nom_autorise,
    c.prenom_autorise,
    c.iban,
    c.rib,
    c.type_compte,
    c.categorie_compte,
    c.langue_compte,
    c.taux_compte,

    -- ── Genre & situation familiale (depuis dim_client) ───────────────
    cl.sexclt,
    cl.lib_sexe,
    cl.stfclt,
    cl.lib_situation_familiale,

    -- ── Niveau d'instruction (depuis dim_niveau_instruction) ──────────
    cl.codnisclt,
    nis.libnis                                     AS lib_niveau_instruction,

 

    -- ── Codes socio-professionnels supplémentaires (dim_client) ───────
    cl.crpclt                                      AS cod_categorie_sociopro,
    cl.codqlfclt                                   AS cod_qualification,
    cl.codstjclt                                   AS cod_statut_juridique,
    cl.naeclt                                      AS cod_activite_eco,
    cl.napclt                                      AS cod_activite_pro,
    cl.rgmclt                                      AS cod_regime,
    cl.rsdclt                                      AS cod_residence,

    -- ── Situation compte ──────────────────────────────────────────────
    fact.situation_cpt,
    fact.situation_libelle,
    fact.motif_cloture,
    fact.type_doc_cloture,
    fact.num_doc_cloture,
    fact.ind_bloque,
    fact.ind_bloque_credit,
    fact.ind_gele,

    -- ── Indicateurs ───────────────────────────────────────────────────
    fact.ind_isrs,
    fact.ind_ias,
    fact.ind_ian,
    fact.ind_bct,
    fact.ind_ival,
    fact.ind_iac,
    fact.ind_iie,
    fact.ind_trs,
    fact.ind_net,
    fact.ind_tsp,
    fact.ind_rsp,
    fact.ind_avs,

    -- ── Devise ────────────────────────────────────────────────────────
    fact.cod_devise,

    -- ── Dates ─────────────────────────────────────────────────────────
    fact.date_ouverture,
    fact.date_cloture,
    fact.date_dernier_mvt,
    fact.date_solde,
    fact.date_maj,

    -- ── Dimensions calendaires calculées ──────────────────────────────
    DATE_PART('year',  fact.date_ouverture)::INT   AS annee_ouverture,
    DATE_PART('month', fact.date_ouverture)::INT   AS mois_ouverture,
    TO_CHAR(fact.date_ouverture, 'YYYY-MM')        AS annee_mois_ouverture,

    -- ── Mesures soldes ────────────────────────────────────────────────
    fact.solde_courant,
    fact.solde_comptable,
    fact.solde_arrete,
    fact.solde_min,
    fact.solde_max,
    fact.solde_moyen,

    -- ── Mesures mouvements ────────────────────────────────────────────
    fact.mvt_credit_mois,
    fact.mvt_debit_mois,
    fact.mvt_moyen_mois,

    -- ── Mesures dérivées ──────────────────────────────────────────────
    fact.ecart_solde,
    fact.solde_net_mois,

    -- ── Dimension calculée : tranche de solde ─────────────────────────
    CASE
        WHEN fact.solde_courant < 0           THEN 'Débiteur'
        WHEN fact.solde_courant = 0           THEN 'Nul'
        WHEN fact.solde_courant < 10000       THEN '0 – 10 K'
        WHEN fact.solde_courant < 100000      THEN '10 K – 100 K'
        WHEN fact.solde_courant < 1000000     THEN '100 K – 1 M'
        ELSE                                       '> 1 M'
    END                                            AS tranche_solde,

    -- ── Flag actif ────────────────────────────────────────────────────
    CASE WHEN fact.situation_cpt = '0' THEN true ELSE false END
                                                   AS est_actif,

    -- ── SCD2 metadata ─────────────────────────────────────────────────
    fact.valid_from,
    fact.valid_to,
    fact.is_current,
    fact.snapshot_updated_at,

    CURRENT_TIMESTAMP                              AS dbt_loaded_at

FROM fact

-- dims existantes
LEFT JOIN agence  a   ON fact.sk_agence  = a.sk_agence
LEFT JOIN nature  n   ON fact.sk_nature  = n.sk_nature
LEFT JOIN compte  c   ON fact.sk_compte  = c.sk_compte

-- nouvelles dims
LEFT JOIN client  cl  ON fact.cod_client = cl.codclt
LEFT JOIN nis         ON cl.codnisclt    = nis.codnis
