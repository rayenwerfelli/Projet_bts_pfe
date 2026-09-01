{{ config(materialized='table', tags=['fact','req4']) }}

/*
  FACT_OUVERTURE_COMPTE
  ─────────────────────────────────────────────────────────────────────
  Source    : int_cpt_enrichi
  Grain     : une ligne = un compte actif ouvert dans [date1, date2]

  FK agence : sk_agence provient de ref_agence (pont sur dim_unite).
              La clé est le md5(codunt) produit par dim_unite — cohérence
              garantie sans modifier le domaine externe.

  FK nature : sk_nature depuis dim_nature_compte (domaine REQ4).
  FK compte : sk_compte depuis dim_compte (domaine REQ4).
  FK date   : date_ouverture → dim_date.
  ─────────────────────────────────────────────────────────────────────
*/

WITH enrichi AS (
    SELECT * FROM {{ ref('int_cpt_enrichi') }}
),

-- sk_agence est déjà porté par int_cpt_enrichi (via ref_agence)
-- on l'utilise directement sans nouvelle jointure

dim_nature AS (
    SELECT sk_nature, cod_nature
    FROM {{ ref('dim_nature_compte') }}
    WHERE is_current = true
),

dim_compte AS (
    SELECT compte_key AS sk_compte, ord_cpt
    FROM {{ ref('dim_compte') }}
    WHERE is_current = true
)

SELECT
    -- ── Clés de substitution (FK → dims) ──────────────────────────────
    dc.sk_compte,
    e.sk_agence,                        -- ← md5(codunt) de dim_unite via ref_agence
    dn.sk_nature,
    e.date_ouverture                    AS fk_date_ouverture,
    e.date_dernier_mvt                  AS fk_date_dernier_mvt,
    e.date_cloture                      AS fk_date_cloture,

    -- ── Clés métier (débogage / rapprochement) ────────────────────────
    e.ord_cpt,
    e.cod_client,
    e.cod_agence,
    e.cod_nature_cpt,
    e.cod_devise,

    -- ── Attributs dégénérés ───────────────────────────────────────────
    e.situation_cpt,
    e.situation_libelle,
    e.motif_cloture,
    e.type_doc_cloture,
    e.num_doc_cloture,
    e.ind_bloque,
    e.ind_bloque_credit,
    e.ind_gele,

    -- ── Indicateurs ───────────────────────────────────────────────────
    e.ind_isrs,
    e.ind_ias,
    e.ind_ian,
    e.ind_bct,
    e.ind_ival,
    e.ind_iac,
    e.ind_iie,
    e.ind_trs,
    e.ind_net,
    e.ind_tsp,
    e.ind_rsp,
    e.ind_avs,

    -- ── Mesures soldes ────────────────────────────────────────────────
    e.solde_cpt                         AS solde_courant,
    e.solde_comptable,
    e.solde_arrete,
    e.solde_min,
    e.solde_max,
    e.solde_moyen,

    -- ── Mesures mouvements ────────────────────────────────────────────
    e.mvt_credit_mois,
    e.mvt_debit_mois,
    e.mvt_moyen_mois,

    -- ── Mesures dérivées ─────────────────────────────────────────────
    e.solde_cpt - e.solde_comptable     AS ecart_solde,
    e.mvt_credit_mois - e.mvt_debit_mois AS solde_net_mois,

    -- ── Dates ────────────────────────────────────────────────────────
    e.date_ouverture,
    e.date_cloture,
    e.date_dernier_mvt,
    e.date_solde,
    e.date_maj,

    -- ── SCD2 metadata ────────────────────────────────────────────────
    e.valid_from,
    e.valid_to,
    e.is_current,
    e.snapshot_updated_at,

    CURRENT_TIMESTAMP                   AS dbt_loaded_at

FROM enrichi e
LEFT JOIN dim_nature dn ON e.cod_nature_cpt = dn.cod_nature
LEFT JOIN dim_compte dc ON e.ord_cpt        = dc.ord_cpt
