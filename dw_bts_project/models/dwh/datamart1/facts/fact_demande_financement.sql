{{ config(materialized='table') }}

with dmg as (
    select *
    from {{ ref('hist_dmg') }}
    where is_current = true
      and sudmg = 0
),

hsf as (
    select * from {{ ref('int_hsf_agg') }}
),

dmc as (
    select * from {{ ref('int_dmc_agg') }}
),

projet as (
    select * from {{ ref('int_info_demande_der_projet') }}
),

client as (
    select * from {{ ref('dim_client') }}
),

unite as (
    select * from {{ ref('dim_unite') }}
),

type_demande as (
    select * from {{ ref('dim_type_demande') }}
),

origine_demande as (
    select * from {{ ref('dim_origine_demande') }}
),

modele_sf as (
    select * from {{ ref('dim_modele_sf') }}
),

niveau as (
    select * from {{ ref('dim_niveau_instruction') }}
),

employe as (
    select * from {{ ref('dim_employee') }}
),

zac as (
    select * from {{ ref('dim_zac') }}
),

gov as (
    select * from {{ ref('dim_gouvernorat') }}
),

dlg as (
    select * from {{ ref('dim_delegation') }}
),

loc as (
    select * from {{ ref('dim_localite') }}
),

eng as (
    select * from {{ ref('dim_engagement') }}
),

autorisation as (
    select * from {{ ref('dim_autorisation') }}
),

ptt as (
    select * from {{ ref('dim_ptt') }}
),

classif as (
    select * from {{ ref('dim_classification_activite') }}
)

select

    -- ✅ Surrogate keys
    md5(cast(dmg.numdmg as text))               as demande_key,
    client.client_key,
    unite.unite_key,
    type_demande.type_demande_key,
    origine_demande.origine_demande_key,
    modele_sf.modele_financement_key,
    niveau.niveau_instruction_key,
    
    employe.employe_key,
    zac.zac_key,
    gov.gouvernorat_key,
    dlg.delegation_key,
    loc.localite_key,
    eng1.engagement_key                                as eng1_key,
    eng2.engagement_key                                as eng2_key,
    autorisation.autorisation_key,
    ptt.ptt_key,
    classif.classif_activite_key,

    -- ✅ Clés naturelles
    dmg.numdmg,
    dmg.codcltdmg                               as codclt,
    dmg.untidmg                                 as codunt,
    dmg.coddmydmg                               as codtypedde,
    dmg.coddmxdmg                               as codorigindde,
    dmg.codhmfdmg                               as codmodelesf,
    dmg.dcddmg                                  as matdecideur,
    projet.codprj,
    projet.codzacprj                            as codzac,
    projet.codgovprj                            as codgov,
    projet.coddlgprj                            as coddlg,
    projet.codlocprj                            as codloc,
    dmc.codenadmc1,
    dmc.codenadmc2,
    -- ✅ Libellés demandes
type_demande.libdmy                        as libdmy,
origine_demande.libdmx                     as libdmx,
modele_sf.libhmf                           as libhmf,



    -- ✅ Dates
    dmg.datdmg::date                            as datdmg,
    dmg.daddmg::date                            as date_decision,
    dmg.dtrfdmg::date                           as dattransfert,
    dmg.drpdmg::date                            as drpdmg,
    dmg.dncdmg::date                            as dncdmg,
    dmg.denrdmg::date                           as denrdmg,
    dmg.davidmg::date                           as davidmg,
    dmg.dadcdmg::date                           as dadcdmg,
    dmg.dautdmg::date                           as dautdmg,
    dmg.drcpdmg::date                           as drcpdmg,

    -- ✅ Codes état / décision bruts
    dmg.etadmg,
    dmg.dsddmg                                  as decision,
    dmg.idcadmg,
    dmg.numautdmg,
    dmg.rpcdmg,

    -- ✅ Projet
    projet.natdmp,
    projet.nepdmp,
    projet.nbrprj,

    -- ✅ Frais bruts
    dmg.comdmg,
    dmg.tvadmg,

    -- ✅ Durée crédit
    coalesce(dmc.nbrcrdpropaccor, 0)            as nbrcrdpropaccor,
    coalesce(dmc.dureedde, 0)                   as dureedde,

    -- ✅ Montant total projet
    dmg.tepdmg,

    -- ✅ Client (pour calcul age dans mart)
    client.dnaclt,
    niveau.codnis                      as cod_niveau_instruction,
    niveau.libnis                      as lib_niveau_instruction,
    unite.libunt as lib_unite,
    unite.libunt as alibunt,
    dlg.libdlg,
    
    -- ✅ Autorisation brute
    autorisation.cloaut,
    autorisation.mntaut,
    autorisation.dataut,
    autorisation.refaut,

    -- ✅ Classification activité
    classif.codactivclass,
    classif.activclass,
    classif.codactivgroup,
    classif.activgroup,
    classif.codactivdiv,
    classif.activdiv,
    classif.codactivsoussect,
    classif.activsoussect,
    classif.codactivsection,
    classif.activsection,

    -- ✅ Montants PROPOSÉS bruts
    coalesce(hsf.mntpropequip, 0)               as mntpropequip,
    coalesce(hsf.mntpropamnag, 0)               as mntpropamnag,
    coalesce(hsf.mntpropmatertransp, 0)         as mntpropmatertransp,
    coalesce(hsf.mntpropchept, 0)               as mntpropchept,
    coalesce(hsf.mntpropfdr, 0)                 as mntpropfdr,
    coalesce(hsf.mntpropass, 0)                 as mntpropass,
    coalesce(hsf.mntpropcct, 0)                 as mntpropcct,
    coalesce(hsf.mntpropdon_tunjobs, 0)         as mntpropdon_tunjobs,

    -- ✅ Montants ACCORDÉS bruts
    coalesce(hsf.cout_projet_acc, 0)            as cout_projet_acc,
    coalesce(hsf.equifrs_acc, 0)                as equifrs_acc,
    coalesce(hsf.equiclt_acc, 0)                as equiclt_acc,
    coalesce(hsf.amngfrs_acc, 0)                as amngfrs_acc,
    coalesce(hsf.amngclt_acc, 0)                as amngclt_acc,
    coalesce(hsf.mattranspfrs_acc, 0)           as mattranspfrs_acc,
    coalesce(hsf.mattranspclt_acc, 0)           as mattranspclt_acc,
    coalesce(hsf.cheptfrs_acc, 0)               as cheptfrs_acc,
    coalesce(hsf.cheptclt_acc, 0)               as cheptclt_acc,
    coalesce(hsf.fdrclt_acc, 0)                 as fdrclt_acc,
    coalesce(hsf.approvfrs_acc, 0)              as approvfrs_acc,
    coalesce(hsf.assurancefrs_acc, 0)           as assurancefrs_acc,
    coalesce(hsf.assuranceclt_acc, 0)           as assuranceclt_acc,
    coalesce(hsf.fraisetd_acc, 0)               as fraisetd_acc,
    coalesce(hsf.fraisfng_acc, 0)               as fraisfng_acc,
    coalesce(hsf.fad_acc, 0)                    as fad_acc,
    coalesce(hsf.matroulant_acc, 0)             as matroulant_acc,
    coalesce(hsf.mntacc_ap, 0)                  as mntacc_ap,
    coalesce(hsf.mntacc_autfrais, 0)            as mntacc_autfrais,
    coalesce(hsf.mntacc_subv, 0)                as mntacc_subv,
    coalesce(hsf.mntacc_cmt, 0)                 as mntacc_cmt,
    coalesce(hsf.mntacc_dot, 0)                 as mntacc_dot,
    coalesce(hsf.mntacc_credct, 0)              as mntacc_credct,
    coalesce(hsf.mntacc_dotqff, 0)              as mntacc_dotqff,
    coalesce(hsf.mntacc_dotes, 0)               as mntacc_dotes,
    coalesce(hsf.mntacc_mourabmt, 0)            as mntacc_mourabmt,
    coalesce(hsf.mntacc_mourabct, 0)            as mntacc_mourabct,
    coalesce(hsf.mntacc_dotmpjfem, 0)           as mntacc_dotmpjfem,
    coalesce(hsf.mntacc_pretparlfc, 0)          as mntacc_pretparlfc,
    coalesce(hsf.mntacc_pretparfem, 0)          as mntacc_pretparfem,
    coalesce(hsf.mntacc_pretparfem2, 0)         as mntacc_pretparfem2,
    coalesce(hsf.mntacc_pretparcpg, 0)          as mntacc_pretparcpg,
    coalesce(hsf.mntacc_donpnud, 0)             as mntacc_donpnud,
    coalesce(hsf.mntacc_pretparpnud, 0)         as mntacc_pretparpnud,
    coalesce(hsf.mntacc_cct_avsubv, 0)          as mntacc_cct_avsubv,
    coalesce(hsf.mntacc_don_proagro, 0)         as mntacc_don_proagro,
    coalesce(hsf.mntacc_don_tun_jobs, 0)        as mntacc_don_tun_jobs,
    coalesce(hsf.mntacc_dot_agripr3, 0)         as mntacc_dot_agripr3,
    coalesce(hsf.mntacc_gen_civil_frs, 0)       as mntacc_gen_civil_frs,
    coalesce(hsf.mntacc_gen_civil_clt, 0)       as mntacc_gen_civil_clt,
    coalesce(hsf.mntacc_plantation_frs, 0)      as mntacc_plantation_frs,
    coalesce(hsf.mntacc_plantation_clt, 0)      as mntacc_plantation_clt,
    coalesce(hsf.mntacc_puit_forage_frs, 0)     as mntacc_puit_forage_frs,
    coalesce(hsf.mntacc_puit_forage_clt, 0)     as mntacc_puit_forage_clt,
    coalesce(hsf.mntacc_subvpremloy, 0)         as mntacc_subvpremloy,
    coalesce(hsf.mntacc_autofpremloy, 0)        as mntacc_autofpremloy,
    coalesce(hsf.mntacc_finijara, 0)            as mntacc_finijara,
    coalesce(hsf.mntacc_dot_etap, 0)            as mntacc_dot_etap,
    coalesce(hsf.mntacc_pret_participatif, 0)   as mntacc_pret_participatif,
    coalesce(hsf.mntacc_cred_ess_lf2022, 0)     as mntacc_cred_ess_lf2022,
    coalesce(hsf.mntacc_don_giz_agricole, 0)    as mntacc_don_giz_agricole,
    coalesce(hsf.mntacc_don_giz_non_agricole, 0) as mntacc_don_giz_non_agricole,
    coalesce(hsf.mntacc_cred_art29_lf2023, 0)   as mntacc_cred_art29_lf2023,
    coalesce(hsf.mntacc_cred_af_tunithon, 0)    as mntacc_cred_af_tunithon,
    coalesce(hsf.mntacc_don_bit_prog_jeun_ess, 0) as mntacc_don_bit_prog_jeun_ess,
    coalesce(hsf.mntacc_entp_com_art32lf2024, 0) as mntacc_entp_com_art32lf2024,
    coalesce(hsf.mntacc_dot_ct_avance_subv_agr, 0) as mntacc_dot_ct_avance_subv_agr,
    coalesce(hsf.mntacc_pret_honneur_cap_emploi, 0) as mntacc_pret_honneur_cap_emploi,
    coalesce(hsf.mntacc_don_fad_we_fi, 0)       as mntacc_don_fad_we_fi,

    current_timestamp                           as _load_timestamp

from dmg
left join client
    on dmg.codcltdmg = client.codclt
left join unite
    on dmg.untidmg = unite.codunt
left join type_demande
    on dmg.coddmydmg = type_demande.coddmy
left join origine_demande
    on dmg.coddmxdmg = origine_demande.coddmx
left join modele_sf
    on dmg.codhmfdmg = modele_sf.codhmf
left join niveau
    on client.codnisclt = niveau.codnis
left join employe
    on dmg.dcddmg = employe.matemp
left join projet
    on dmg.numdmg = projet.numdmgdmp
left join zac
    on projet.codzacprj = zac.codzac
left join gov
    on projet.codgovprj = gov.codgov
left join dlg
    on projet.codgovprj = dlg.codgovdlg
   and projet.coddlgprj = dlg.coddlg
left join loc
    on projet.codgovprj  = loc.codgovloc
   and projet.coddlgprj  = loc.coddlgloc
   and projet.codlocprj  = loc.codloc
left join hsf
    on dmg.numdmg = hsf.numdmg
left join dmc
    on dmg.numdmg = dmc.numdmg
left join eng eng1
    on dmc.codenadmc1 = eng1.codeng
left join eng eng2
    on dmc.codenadmc2 = eng2.codeng
left join autorisation
    on dmg.numautdmg = autorisation.refaut
left join ptt 
    on projet.codptt = ptt.codptt::bigint
left join classif
    on zac.codzclzac = classif.codactivclass
