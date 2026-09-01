{{ config(materialized='table') }}

with fact as (
    select * from {{ ref('fact_echeances') }}
),

-- ================================================
-- DÉDOUBLONNAGE TÉLÉPHONE : 1 seul numéro par client
-- ================================================
tel_dedup as (
    select distinct on (codclttel)
        codclttel,
        numtel,
        typetel,
        paytel
    from {{ ref('dim_telephone') }}
    where sutel = '0'
    order by codclttel, numtel asc
),

-- ================================================
-- DÉDOUBLONNAGE TRH : 1 seule ligne par (refauttrh, ordcpttrh)
-- ================================================
trh_dedup as (
    select distinct on (refauttrh, ordcpttrh::text)
        refauttrh,
        ordcpttrh::text         as ordcpttrh,
        numtrh,
        mnttrh,
        dbktrh,
        etatrh,
        dtbtrh,
        dtttrh
    from {{ ref('dim_trh') }}
    order by refauttrh, ordcpttrh::text, dmjtrh desc nulls last
),

-- ================================================
-- DÉDOUBLONNAGE PROJET : 1 seul projet par client (le plus récent)
-- ================================================
prj_dedup as (
    select distinct on (codcltprj)
        codcltprj,
        codprj,
        adrprj,
        datprj,
        denrprj,
        nepprj,
        rvnprj,
        chgprj
    from {{ ref('dim_projet') }}
    order by codcltprj, codprj desc
),

-- ================================================
-- DÉDOUBLONNAGE ADRESSE : 1 seule adresse par client (la principale)
-- ================================================
adr_dedup as (
    select distinct on (codcltadr)
        codcltadr,
        lg1adr,
        codpttadr,
        typadr
    from {{ ref('dim_adresse') }}
    where suadr = '0'
    order by codcltadr, numadr asc
),

-- ================================================
-- DÉDOUBLONNAGE COMPTE : 1 seul compte courant
-- ================================================
cpt_dedup as (
    select distinct on (ord_cpt)
        ord_cpt,
        type_compte,
        categorie_compte,
        situation_libelle,
        ind_bloque,
        ind_gele,
        date_ouverture,
        date_cloture
    from {{ ref('dim_compte') }}
    where is_current = true
    order by ord_cpt, date_ouverture desc nulls last
)

select
    -- ================================================
    -- TEMPS — ÉCHÉANCE
    -- ================================================
    ech.annee_mois              as annee_mois_ech,
    ech.lib_mois                as lib_mois_ech,
    ech.trimestre               as trimestre_ech,
    ech.semestre                as semestre_ech,
    ech.annee                   as annee_ech,
    ech.mois                    as mois_ech,
    ech.date_jour               as date_echeance,

    -- TEMPS — RÈGLEMENT
    rgl.annee_mois              as annee_mois_regl,
    rgl.annee                   as annee_regl,
    rgl.mois                    as mois_regl,
    rgl.date_jour               as date_reglement,

    -- ================================================
    -- ORGANISATION
    -- ================================================
    u.codunt,
    u.libunt                    as agence,

    -- ================================================
    -- CLIENT
    -- ================================================
    c.codclt,
    c.nomclt,
    c.prnclt,
    c.lib_sexe,
    c.lib_situation_familiale,
    n.libnis                    as niveau_instruction,

    -- ================================================
    -- COMPTE
    -- ================================================
    cpt.ord_cpt,
    cpt.type_compte,
    cpt.categorie_compte,
    cpt.situation_libelle       as situation_compte,
    cpt.ind_bloque,
    cpt.ind_gele,
    cpt.date_ouverture,
    cpt.date_cloture,

    -- ================================================
    -- ENGAGEMENT / PRODUIT
    -- ================================================
    e.codeng,
    e.libeng                    as type_engagement,
    lf.codlfn                   as cod_ligne_financement,
    lf.liblfn                   as ligne_financement,

    -- ================================================
    -- NATURE COMPTE
    -- ================================================
    nat.codnat                  as cod_nature_compte,
    nat.libnat                  as nature_compte,
    nat.typnat                  as type_nature,
    nat.catnat                  as categorie_nature,
    nat.ttvanat                 as ind_tva,
    nat.impnat                  as ind_impot,

    -- ================================================
    -- GÉOGRAPHIE / PROJET
    -- ================================================
    z.codzac                    as cod_zone_activite,
    z.libzac                    as zone_activite,
    z.seczac                    as code_secteur,
    case z.seczac
        when 'A' then 'Agriculture'
        when 'S' then 'Service'
        when 'I' then 'Industrie'
        when 'B' then 'Artisanat'
        when 'M' then 'Petits Métiers'
        else          'Service'
    end                         as lib_secteur,
    g.codgov                    as cod_gouvernorat,
    g.libgov                    as gouvernorat,
    l.codloc                    as cod_localite,
    l.libloc                    as localite,

    -- ================================================
    -- PROJET
    -- ================================================
    prj.codprj,
    prj.adrprj                  as adresse_projet,
    prj.datprj                  as date_projet,
    prj.denrprj                 as denomination_projet,
    prj.nepprj                  as nb_emplois_projet,
    prj.rvnprj                  as revenu_projet,
    prj.chgprj                  as charge_projet,

    -- ================================================
    -- TIREUR (TRH)
    -- ================================================
    trh.numtrh,
    trh.mnttrh                  as montant_tireur,
    trh.dbktrh                  as ind_debloque,
    trh.etatrh                  as etat_tireur,
    trh.dtbtrh                  as date_tirage,
    trh.dtttrh                  as date_echeance_trh,

    -- ================================================
    -- TÉLÉPHONE
    -- ================================================
    tel.numtel                  as telephone,
    tel.typetel                 as type_telephone,
    tel.paytel                  as pays_telephone,

    -- ================================================
    -- ADRESSE
    -- ================================================
    adr.lg1adr                  as adresse_ligne1,
    adr.codpttadr               as code_postal,
    adr.typadr                  as type_adresse,

    -- ================================================
    -- EFFET — CLASSIFICATION
    -- ================================================
    fact.typeff,
    case fact.typeff
        when 1 then 'À Échoir'
        when 2 then 'En Attente Règlement'
        when 3 then 'En Cours Règlement'
        when 6 then 'Impayé'
        when 7 then 'Annulé'
        when 8 then 'Réglé Partiel'
        when 9 then 'Réglé Total'
        else        'Autre'
    end                         as lib_type_effet,

    fact.ppleff,
    case fact.ppleff
        when 1 then 'Principal'
        when 2 then 'Intérêts'
        else        'Autre'
    end                         as lib_nature_effet,

    fact.nb_jours_impaye,
    case
        when fact.nb_jours_impaye is null  then null
        when fact.nb_jours_impaye <=  30   then '0-30j'
        when fact.nb_jours_impaye <=  60   then '31-60j'
        when fact.nb_jours_impaye <=  90   then '61-90j'
        when fact.nb_jours_impaye <= 180   then '91-180j'
        when fact.nb_jours_impaye <= 365   then '181-365j'
        else                                    '+365j'
    end                         as tranche_anciennete_impaye,

    -- ================================================
    -- MESURES — ENGAGEMENT
    -- ================================================
    fact.mnt_engagement,

    -- ================================================
    -- MESURES — À ÉCHOIR
    -- ================================================
    fact.mnt_a_echoir_princ,
    fact.mnt_a_echoir_inter,
    (fact.mnt_a_echoir_princ
     + fact.mnt_a_echoir_inter)  as mnt_a_echoir_total,

    -- ================================================
    -- MESURES — ÉCHU
    -- ================================================
    fact.mnt_echu,

    -- ================================================
    -- MESURES — IMPAYÉS
    -- ================================================
    fact.mnt_impaye,
    fact.mnt_impaye_princ,
    fact.mnt_impaye_inter,
    fact.mnt_tva_impaye,
    fact.mnt_tmb_impaye,
    fact.is_ech_impayee,
    fact.is_ech_imp_princ,
    fact.is_ech_imp_inter,

    -- ================================================
    -- MESURES — RÈGLEMENT
    -- ================================================
    fact.mnt_regle,
    fact.mnt_regle_princ,
    fact.mnt_regle_inter,

    -- ================================================
    -- MESURES — EN ATTENTE
    -- ================================================
    fact.mnt_en_attente_regl,
    fact.mnt_en_attente_regl_princ,
    fact.mnt_en_attente_regl_inter,

    -- ================================================
    -- KPIs DÉRIVÉS
    -- ================================================
    round(
        fact.mnt_regle::numeric
        / nullif(fact.mnt_echu, 0) * 100, 2
    )                            as taux_recouvrement,

    round(
        fact.mnt_impaye::numeric
        / nullif(fact.mnt_engagement, 0) * 100, 2
    )                            as poids_impaye,

    -- ================================================
    -- AUDIT
    -- ================================================
    fact._load_timestamp

from fact

-- TEMPS
left join {{ ref('dim_date') }}                ech on fact.date_key_ech  = ech.date_key
left join {{ ref('dim_date') }}                rgl on fact.date_key_regl = rgl.date_key

-- CLIENT
left join {{ ref('dim_client') }}                c on fact.codclt        = c.codclt

-- UNITÉ
left join {{ ref('dim_unite') }}                 u on fact.codunt        = u.codunt

-- NATURE COMPTE
left join {{ ref('dim_nature') }}              nat on fact.codnat        = nat.codnat

-- NIVEAU INSTRUCTION
left join {{ ref('dim_niveau_instruction') }}    n on c.codnisclt        = n.codnis

-- ENGAGEMENT
left join {{ ref('dim_engagement') }}            e on fact.codeng        = e.codeng

-- LIGNE FINANCEMENT
left join {{ ref('dim_lfn') }}                  lf on e.codlfneng        = lf.codlfn

-- GÉOGRAPHIE PROJET
left join {{ ref('dim_zac') }}                   z on fact.codzac        = z.codzac
left join {{ ref('dim_gouvernorat') }}           g on fact.codgov        = g.codgov
left join {{ ref('dim_localite') }}              l on fact.codgov        = l.codgovloc
                                              and fact.coddlg            = l.coddlgloc
                                              and fact.codloc            = l.codloc

-- COMPTE (dédoublonné)
left join cpt_dedup                          cpt on fact.ordcpt          = cpt.ord_cpt

-- PROJET (dédoublonné)
left join prj_dedup                          prj on fact.codclt          = prj.codcltprj

-- TIREUR (dédoublonné)
left join trh_dedup                          trh on fact.refauteff::text = trh.refauttrh
                                              and fact.ordcpt::text      = trh.ordcpttrh

-- TÉLÉPHONE (dédoublonné)
left join tel_dedup                          tel on fact.codclt          = tel.codclttel

-- ADRESSE (dédoublonnée)
left join adr_dedup                          adr on fact.codclt          = adr.codcltadr