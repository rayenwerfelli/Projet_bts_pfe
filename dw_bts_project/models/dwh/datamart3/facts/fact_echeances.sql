{{ config(
    materialized = 'table',
    indexes = [
        {'columns': ['date_key_ech'],  'type': 'btree'},
        {'columns': ['date_key_regl'], 'type': 'btree'},
        {'columns': ['codclt'],        'type': 'btree'},
        {'columns': ['codunt'],        'type': 'btree'},
        {'columns': ['codeng'],     'type': 'btree'}
    ]
) }}

with impeff as (
    select * from {{ ref('int_v_effimp') }}
),

cpt as (
    select * from {{ ref('hist_cpt') }}
    where is_current = true
),

dernier_projet as (
    select
        codcltprj,
        max(codprj) as codprjn
    from {{ ref('hist_prj') }}
    where suprj = 0
      and is_current = true
    group by codcltprj
),

projet_enrichi as (
    select
        dp.codcltprj,
        p.codzacprj,
        p.codgovprj,
        p.coddlgprj,
        p.codlocprj
    from dernier_projet dp
    inner join {{ ref('hist_prj') }} p
        on dp.codprjn   = p.codprj
       and p.is_current = true
),

enriched as (

    select

        -- ================================================
        -- SURROGATE KEY LIGNE
        -- ================================================
      md5(
    coalesce(cast(f.refauteff  as text), '') || '-' ||
    coalesce(cast(f.orddapeff  as text), '') || '-' ||
    coalesce(cast(f.numtrheff  as text), '') || '-' ||
    coalesce(cast(f.codengeff  as text), '') || '-' ||
    coalesce(cast(f.ordcpxeff  as text), '') || '-' ||
    coalesce(f.echeff::text,   '1900-01-01') || '-' ||
    coalesce(f.drgleff::text,  '1900-01-01') || '-' ||  -- ← ajouté
    coalesce(cast(f.typeff     as text), '') || '-' ||
    coalesce(cast(f.ppleff     as text), '') || '-' ||
    coalesce(cast(f.sueff      as text), '') || '-' ||
    coalesce(cast(f.codinseff  as text), '') || '-' ||
    coalesce(cast(f.mnteff     as text), '')
) as effet_key,

        -- ================================================
        -- FK → dim_date  (clé entière YYYYMMDD)
        -- ================================================
        to_char(f.echeff,  'YYYYMMDD')::int   as date_key_ech,
        to_char(f.drgleff, 'YYYYMMDD')::int   as date_key_regl,

        -- ================================================
        -- FK → dim_client   (PK métier = codclt)
        -- ================================================
        c.codcltcpt                            as codclt,

        -- ================================================
        -- FK → dim_unite    (PK métier = codunt)
        -- ================================================
        c.burcpt                               as codunt,

        -- ================================================
        -- FK → dim_nature   (PK métier = codnat)
        -- ================================================
        c.codnatcpt                            as codnat,

        -- ================================================
        -- FK → dim_engagement  (PK métier = codeng)
        -- ================================================
        f.codengeff                            as codeng,

        -- ================================================
        -- FK → dim_trh  (PK métier = numtrh + ordcpt)
        -- ================================================
        f.numtrheff                            as numtrh,
        f.ordcpxeff                            as ordcpt,

        -- ================================================
        -- FK → dim_zac         (PK métier = codzac)
        -- FK → dim_gouvernorat (PK métier = codgov)
        -- FK → dim_localite    (PK métier = codgov+coddlg+codloc)
        -- ================================================
        p.codzacprj                            as codzac,
        p.codgovprj                            as codgov,
        p.coddlgprj                            as coddlg,
        p.codlocprj                            as codloc,

        -- ================================================
        -- ATTRIBUTS DÉGÉNÉRÉS
        -- ================================================
        f.codinseff,
        f.typeff,
        f.ppleff,
        f.sueff,
        f.crpeff,
        f.ctxeff,
        f.echeff,
        f.drgleff,
        f.refauteff,
        f.orddapeff,

        -- ================================================
        -- MESURES BRUTES
        -- ================================================
        f.mnteff,
        f.blceff,
        coalesce(f.mttceff, 0) as mttceff,
        coalesce(f.minteff, 0) as minteff,
        coalesce(f.mtvaeff, 0) as mtvaeff,
        coalesce(f.mtmbeff, 0) as mtmbeff,

        -- ================================================
        -- MESURES CALCULÉES
        -- ================================================
        case
            when f.typeff = 1 and f.ppleff = 1 then f.mnteff
            when f.typeff in (6, 3)             then f.mnteff
            else 0
        end                                    as mnt_engagement,

        case when f.ppleff = 1 and f.typeff = 1      then f.mnteff else 0 end as mnt_a_echoir_princ,
        case when f.ppleff = 2 and f.typeff = 1      then f.mnteff else 0 end as mnt_a_echoir_inter,

        case when f.typeff not in (7, 1)             then f.mnteff else 0 end as mnt_echu,

        case when f.typeff = 6                       then f.mnteff else 0 end as mnt_impaye,
        case when f.ppleff = 1 and f.typeff = 6      then f.mnteff else 0 end as mnt_impaye_princ,
        case when f.ppleff = 2 and f.typeff = 6      then f.mnteff else 0 end as mnt_impaye_inter,
        case when f.typeff = 6 then f.mtvaeff         else 0 end              as mnt_tva_impaye,
        case when f.typeff = 6 then f.mtmbeff         else 0 end              as mnt_tmb_impaye,

        case when f.typeff = 6                        then 1 else 0 end       as is_ech_impayee,
        case when f.ppleff = 1 and f.typeff = 6       then 1 else 0 end       as is_ech_imp_princ,
        case when f.ppleff = 2 and f.typeff = 6       then 1 else 0 end       as is_ech_imp_inter,

        case when f.typeff in (8, 9)                  then f.mnteff else 0 end as mnt_regle,
        case when f.ppleff = 1 and f.typeff in (8, 9) then f.mnteff else 0 end as mnt_regle_princ,
        case when f.ppleff = 2 and f.typeff in (8, 9) then f.mnteff else 0 end as mnt_regle_inter,

        case when f.typeff in (2, 3)                  then f.mnteff else 0 end as mnt_en_attente_regl,
        case when f.ppleff = 1 and f.typeff in (2, 3) then f.mnteff else 0 end as mnt_en_attente_regl_princ,
        case when f.ppleff = 2 and f.typeff in (2, 3) then f.mnteff else 0 end as mnt_en_attente_regl_inter,

        case
            when f.typeff = 6 then (current_date - f.echeff)::int
            else null
        end                                    as nb_jours_impaye,

        current_timestamp                      as _load_timestamp

    from impeff f
    left join cpt            c on f.ordcpxeff  = c.ordcpt
    left join projet_enrichi p on c.codcltcpt  = p.codcltprj

)

select * from enriched