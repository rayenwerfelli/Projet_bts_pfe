{{ config(
    materialized = 'table',
    tags         = ['fact', 'comptes_geles']
) }}

with

-- ============================================================
-- 1. COMPTES filtrés (natures gelées, solde ≤ 10)
-- ============================================================
cpt as (
    select *
    from {{ ref('dim_compte') }}
    where cod_nature_cpt in (101, 103, 115, 145)
      and is_current = true
      and sldcpt <= 10
),

-- ============================================================
-- 2. EFFETS + IMPAYES EN COURS  (via int_v_effimp)
--    typeff != 9  → effets purs
--    typeff  = 9  → impayés
-- ============================================================
recap_eff as (
    select
        ordcpxeff                                        as ord_cpt,
        sum(case when typeff != 9 then mnteff else 0 end) as mnt_eff_encours,
        sum(case when typeff  = 9 then mnteff else 0 end) as mnt_imp
    from {{ ref('int_v_effimp') }}
    where sueff  = '0'
      and ppleff = 1
    group by ordcpxeff
),

-- ============================================================
-- 3. DAP EN COURS  (dim_dap + dim_autorisation + dim_demande)
-- ============================================================
recap_dap as (
    select
        dap.ord_compte                   as ord_cpt,
        sum(dap.mnt_dap)                 as mnt_dap
    from {{ ref('dim_dap') }}            as dap
    left join {{ ref('dim_autorisation') }} as aut
           on aut.refaut      = dap.ref_autorisation
    left join {{ ref('dim_demande') }}   as dmg
           on dmg.numautdmg   = cast(aut.refaut as bigint)
    where aut.cloaut != 6
      and dmg.etadmg != 9
    group by dap.ord_compte
),

-- ============================================================
-- 4. TRH DÉBLOQUÉS  (dim_trh + dim_demande)
-- ============================================================
recap_trh as (
    select
        trh.ordcpttrh                    as ord_cpt,
        sum(trh.mnttrh)                  as mnt_trh_debloq
    from {{ ref('dim_trh') }}            as trh
    left join {{ ref('dim_demande') }}   as dmg
           on dmg.numautdmg   = cast(trh.refauttrh as bigint)
    where trh.sutrh                    = '0'
      and cast(trh.etatrh as integer)  = 1
      and dmg.etadmg                  != 9
    group by trh.ordcpttrh
),

-- ============================================================
-- 5. DATE DE SNAPSHOT (aujourd'hui)
-- ============================================================
snap_date as (
    select date_key
    from {{ ref('dim_date') }}
    where date_jour = current_date
),

-- ============================================================
-- 6. ASSEMBLAGE
-- ============================================================
joined as (
    select
        -- Surrogate key
        md5(
            cast(cpt.ord_cpt  as text) || '|' ||
            cast(sd.date_key  as text)
        )                                                    as fait_key,

        -- ── Clés étrangères vers dimensions ──────────────────────
        cpt.compte_key,
        dim_unt.unite_key,
        dim_nat.nature_key,
        dim_clt.client_key,
        dim_zac.zac_key,
        sd.date_key                                          as date_snap_key,

        -- ── Clés métier (drill-through) ───────────────────────────
        cpt.ord_cpt,
        cpt.cod_client,
        cpt.cod_agence,
        cpt.cod_nature_cpt,

        -- ── Agence ───────────────────────────────────────────────
        dim_unt.libunt                                       as lib_unt,

        -- ── Client : sexe & niveau d'instruction ─────────────────
        
        dim_clt.lib_sexe,
        
        case dim_clt.nslclt
            when '1' then 'Sans instruction'
            when '2' then 'Primaire'
            when '3' then 'Secondaire'
            when '4' then 'Supérieur'
            else          'Supérieur'
        end                                                  as lib_niveau_instruction,

        -- ── Secteur (via dim_zac) ─────────────────────────────────
        dim_zac.codzac,
        dim_zac.libzac                                       as lib_secteur,
               
        case dim_zac.seczac
            when 'A' then 'Agriculture'
            when 'S' then 'Services'
            when 'I' then 'Industrie'
            when 'B' then 'Bâtiment'
            when 'M' then 'Commerce'
            else          'Services'
        end                                                  as lib_secteur_detail,

        -- ── Indicateurs gel / blocage ─────────────────────────────
        cpt.ind_gele,
        cpt.ind_bloque,
        cpt.ind_bloque_credit,
        cpt.situation_cpt,
        cpt.situation_libelle,

        -- ── Solde débiteur ────────────────────────────────────────
        case
            when cpt.sldcpt < 0 then abs(cpt.sldcpt)
            else 0
        end                                                  as mnt_solde_debiteur,
        cpt.sldcpt                                           as sld_cpt_brut,

        -- ── Métriques financières ─────────────────────────────────
        coalesce(eff.mnt_eff_encours, 0)                     as mnt_eff_encours,
        coalesce(eff.mnt_imp,         0)                     as mnt_imp,
        coalesce(dap.mnt_dap,         0)                     as mnt_dap,
        coalesce(trh.mnt_trh_debloq,  0)                     as mnt_trh_debloq,

        -- Exposition totale
        coalesce(eff.mnt_eff_encours, 0)
        + coalesce(eff.mnt_imp,       0)
        + coalesce(dap.mnt_dap,       0)
        + coalesce(trh.mnt_trh_debloq, 0)                    as mnt_exposition_totale,

        -- ── Flag ──────────────────────────────────────────────────
        true                                                 as is_compte_gele,

        -- ── Audit ─────────────────────────────────────────────────
        current_timestamp                                    as dbt_loaded_at

    from cpt

    -- Agence
    left join {{ ref('dim_unite') }}    as dim_unt
           on dim_unt.codunt    = cpt.cod_agence

    -- Nature
    left join {{ ref('dim_nature') }}   as dim_nat
           on dim_nat.codnat    = cpt.cod_nature_cpt

    -- Client (sexe, niveau instruction)
    left join {{ ref('dim_client') }}   as dim_clt
           on dim_clt.codclt    = cpt.cod_client

    -- Secteur (via zone d'activité du client)
    left join {{ ref('dim_zac') }}      as dim_zac
           on dim_zac.codzac    = cast(cast(dim_clt.naeclt as integer) as text)

    -- Métriques
    left join recap_eff  as eff on eff.ord_cpt = cpt.ord_cpt
    left join recap_dap  as dap on dap.ord_cpt = cpt.ord_cpt
    left join recap_trh  as trh on trh.ord_cpt = cpt.ord_cpt

    cross join snap_date as sd
)

select * from joined