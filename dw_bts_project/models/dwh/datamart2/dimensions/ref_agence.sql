{{ config(materialized='table', tags=['ref','req4']) }}

/*
  REF_AGENCE
  ─────────────────────────────────────────────────────────────────────
  Vue pont sur dim_unite (domaine externe — lecture seule).
  Objectif : exposer les colonnes utiles au domaine REQ4
             sans modifier dim_unite.

  Clé réutilisée : unite_key (md5 de codunt) → sk_agence
  Colonne ajoutée : agence_libelle (CODUNT || ' :' || LIBUNT)
                    non présente dans dim_unite.
  ─────────────────────────────────────────────────────────────────────
*/

SELECT
    -- Clé de substitution (réutilisée depuis dim_unite)
    unite_key                               AS sk_agence,

    -- Identifiant métier
    codunt                                  AS cod_agence,

    -- Libellés
    libunt                                  AS agence_nom,
    codunt || ' :' || libunt                AS agence_libelle,
    alibunt                                 AS agence_nom_alternatif,

    -- Rattachement géographique / bancaire
    codtntunt                               AS agence_code_territoire,
    codpttunt                               AS agence_code_postal,
    codnogunt                               AS agence_code_gouvernorat,
    codbaqunt                               AS agence_code_banque,

    -- Coordonnées
    adr1unt                                 AS agence_adresse,
    telunt                                  AS agence_telephone,
    emlunt                                  AS agence_email,
    faxunt                                  AS agence_fax,
    lttunt                                  AS agence_latitude,
    lgtunt                                  AS agence_longitude

FROM {{ ref('dim_unite') }}