{{ config(materialized='table') }}

with fact as (
    select * from {{ ref('fact_demande_financement') }}
),
niveau as (
    select * from {{ ref('dim_niveau_instruction') }}
),
client as (
    select * from {{ ref('dim_client') }}
),
zac as (
    select * from {{ ref('dim_zac') }}
),
unite as (
    select * from {{ ref('dim_unite') }}
),
recov_nat as (
    select
        codzac,
        txrecovnat
    from {{ ref('mart_recouvrement_zac') }}
),
recap_client as (
    select *
    from {{ ref('mart_recouvrement_client') }}
),
recov_reg as (
    select
        codzac,
        codgov,
        txrecouvreg
    from {{ ref('mart_recouvrement_gov') }}
)

select

    -- ✅ Clés
    fact.demande_key,
    fact.client_key,
    fact.unite_key,
    fact.type_demande_key,
    fact.origine_demande_key,
    fact.modele_financement_key,
    fact.niveau_instruction_key,
    niveau.codnis                                           as cod_niveau_instruction,
    niveau.libnis                                           as lib_niveau_instruction,
    unite.codunt                                            as cod_unite,
    unite.libunt                                            as lib_unite,
    unite.alibunt                                           as alibunt,
    fact.coddlg                                             as coddlgprj,
    fact.employe_key,
    fact.zac_key,
    fact.gouvernorat_key,
    fact.delegation_key,
    fact.localite_key,
    fact.eng1_key,
    fact.eng2_key,
    fact.autorisation_key,
    fact.ptt_key,
    fact.classif_activite_key,

    -- ✅ Identifiants naturels
    fact.numdmg,
    fact.codclt,
    fact.codunt,
    fact.codtypedde,
    fact.codorigindde,
    fact.codmodelesf,
    fact.matdecideur,
    fact.codprj,
    fact.codzac,
    fact.codgov,
    fact.coddlg,
    fact.codloc,
    fact.codenadmc1,
    fact.codenadmc2,

    -- ✅ Dates
    fact.datdmg,
    fact.date_decision,
    fact.dattransfert,
    fact.drpdmg,
    fact.dncdmg,
    fact.denrdmg,
    fact.davidmg,
    fact.dadcdmg,
    fact.dautdmg,
    fact.drcpdmg,

    -- ✅ Codes bruts
    fact.etadmg,
    fact.decision,
    fact.idcadmg,
    fact.numautdmg,
    fact.natdmp,
    fact.nepdmp,
    fact.nbrprj,
    fact.nbrcrdpropaccor,
    fact.dureedde,
    fact.libdlg,
    -- ✅ Identité client (ajout demandé)
client.nomclt,
client.prnclt,
client.aprnclt,
client.anomclt,
client.crpclt,
client.ndcclt,
client.dnaclt,           

fact.libdmy                        as libdmy,
fact.libdmx                     as libdmx,
fact.libhmf                           as libhmf,


    -- ✅ Libellés état demande
    case fact.etadmg
        when 0 then 'Enregistré'
        when 1 then 'En Etude'
        when 2 then 'Transfert pour décision'
        when 3 then 'Accord'
        when 4 then 'Rejet'
        when 5 then 'Réexaminer'
        when 6 then 'Décision Prise'
        when 7 then 'Client Notifié'
        when 8 then 'Traitement Terminé'
        when 9 then 'Annulé'
    end                                                     as lib_etat,

    case fact.decision
        when 1 then 'Acceptée'
        when 2 then 'Acceptée sous Réserve'
        when 3 then 'Ajournée'
        when 4 then 'Rejetée'
    end                                                     as lib_decision,

    case fact.idcadmg
        when 1 then 'Acceptation'
        when 2 then 'Rejet'
    end                                                     as decision_agence,

    case fact.natdmp
        when 1 then 'Création'
        when 2 then 'Extension'
        else 'Création'
    end                                                     as nature_projet,

    case fact.cloaut
        when 0 then 'Enregistrée'
        when 1 then 'Contrat Remis au Client'
        when 2 then 'En Cours'
        when 3 then 'Fin Formalités'
        when 4 then 'Débloqué'
        when 5 then 'Frais dossier sur ligne de crédit'
        when 6 then 'Désistement'
        when 7 then 'À Clôturer'
        when 8 then 'Annulée'
        when 9 then 'Clôturé'
    end                                                     as lib_etat_aut,

    -- ✅ Libellés client
    case client.sexclt
        when 'M' then 'Masculin'
        when 'F' then 'Féminin'
        else 'F'
    end                                                     as lib_sexe,

    case client.stfclt
        when 'C' then 'Célibataire'
        when 'M' then 'Marié'
        when 'D' then 'Divorcé'
        when 'V' then 'Veuf'
        else 'N/A'
    end                                                     as lib_stfclt,

    case client.tidnclt
        when 1  then 'Identifiant National'
        when 2  then 'CIN'
        when 3  then 'Passeport'
        when 4  then 'CS'
        when 5  then 'Visa'
        when 6  then 'Code Ministère'
        when 7  then 'Identifiant BCT'
        when 8  then 'Code Localité'
        when 9  then 'RC'
        when 13 then 'Identifiant Fiscal Unique'
    end                                                     as lib_tidnclt,

    -- ✅ Libellé secteur ZAC
    case zac.seczac
        when 'A' then 'Agriculture'
        when 'S' then 'Service'
        when 'I' then 'Industrie'
        when 'B' then 'Artisanat'
        when 'M' then 'Petits Métiers'
        else 'Service'
    end                                                     as lib_secteur,

    -- ✅ Classification activité
    fact.codactivclass,
    fact.activclass,
    fact.codactivgroup,
    fact.activgroup,
    fact.codactivdiv,
    fact.activdiv,
    fact.codactivsoussect,
    fact.activsoussect,
    fact.codactivsection,
    fact.activsection,

    -- ✅ Mesures financement proposé
    fact.tepdmg,
    fact.mntpropequip,
    fact.mntpropamnag,
    fact.mntpropmatertransp,
    fact.mntpropchept,
    fact.mntpropfdr,
    fact.mntpropass,
    fact.mntpropcct,
    fact.mntpropdon_tunjobs,
    
   
  

    -- ✅ Mesures financement accordé
    fact.cout_projet_acc,
    fact.equifrs_acc,
    fact.equiclt_acc,
    fact.amngfrs_acc,
    fact.amngclt_acc,
    fact.mattranspfrs_acc,
    fact.mattranspclt_acc,
    fact.cheptfrs_acc,
    fact.cheptclt_acc,
    fact.fdrclt_acc,
    fact.approvfrs_acc,
    fact.assurancefrs_acc,
    fact.assuranceclt_acc,
    fact.fraisetd_acc,
    fact.fraisfng_acc,
    fact.fad_acc,
    fact.matroulant_acc,
    fact.mntacc_ap,
    fact.mntacc_autfrais,
    fact.mntacc_subv,
    fact.mntacc_cmt,
    fact.mntacc_dot,
    fact.mntacc_credct,
    fact.mntacc_dotqff,
    fact.mntacc_dotes,
    fact.mntacc_mourabmt,
    fact.mntacc_mourabct,
    fact.mntacc_dotmpjfem,
    fact.mntacc_pretparlfc,
    fact.mntacc_pretparfem,
    fact.mntacc_pretparfem2,
    fact.mntacc_pretparcpg,
    fact.mntacc_donpnud,
    fact.mntacc_pretparpnud,
    fact.mntacc_cct_avsubv,
    fact.mntacc_don_proagro,
    fact.mntacc_don_tun_jobs,
    fact.mntacc_dot_agripr3,
    fact.mntacc_gen_civil_frs,
    fact.mntacc_gen_civil_clt,
    fact.mntacc_plantation_frs,
    fact.mntacc_plantation_clt,
    fact.mntacc_puit_forage_frs,
    fact.mntacc_puit_forage_clt,
    fact.mntacc_subvpremloy,
    fact.mntacc_autofpremloy,
    fact.mntacc_finijara,
    fact.mntacc_dot_etap,
    fact.mntacc_pret_participatif,
    fact.mntacc_cred_ess_lf2022,
    fact.mntacc_don_giz_agricole,
    fact.mntacc_don_giz_non_agricole,
    fact.mntacc_cred_art29_lf2023,
    fact.mntacc_cred_af_tunithon,
    fact.mntacc_don_bit_prog_jeun_ess,
    fact.mntacc_entp_com_art32lf2024,
    fact.mntacc_dot_ct_avance_subv_agr,
    fact.mntacc_pret_honneur_cap_emploi,
    fact.mntacc_don_fad_we_fi,
    recap_client.mntechu,
recap_client.mntechuimpay,
recap_client.mntechuenattregl,
recap_client.mntechupay,
recap_client.mntencourseff,
recap_client.tx_impaye_clt,
recap_client.mntechuimpayprinc,
recap_client.mntechuimpayint,
recap_client.mntechupayprinc,
recap_client.mntechupayint,

-- ✅ KPI Montant Total global (Proposé + Accordé)
(
    -- 🔵 Montant proposé
    coalesce(fact.mntpropequip, 0)
    + coalesce(fact.mntpropamnag, 0)
    + coalesce(fact.mntpropmatertransp, 0)
    + coalesce(fact.mntpropchept, 0)
    + coalesce(fact.mntpropfdr, 0)
    + coalesce(fact.mntpropass, 0)
    + coalesce(fact.mntpropcct, 0)
    + coalesce(fact.mntpropdon_tunjobs, 0)

    +

    -- 🟢 Montant accordé
    coalesce(fact.mntacc_cmt, 0)
    + coalesce(fact.mntacc_dot, 0)
    + coalesce(fact.mntacc_credct, 0)
    + coalesce(fact.mntacc_dotqff, 0)
    + coalesce(fact.mntacc_mourabmt, 0)
    + coalesce(fact.mntacc_mourabct, 0)
    + coalesce(fact.mntacc_subv, 0)
    + coalesce(fact.mntacc_ap, 0)
    + coalesce(fact.mntacc_dotmpjfem, 0)
    + coalesce(fact.mntacc_pretparlfc, 0)
    + coalesce(fact.mntacc_pretparfem, 0)
    + coalesce(fact.mntacc_pretparfem2, 0)
    + coalesce(fact.mntacc_donpnud, 0)
    + coalesce(fact.mntacc_pretparpnud, 0)
    + coalesce(fact.mntacc_pretparcpg, 0)
    + coalesce(fact.mntacc_finijara, 0)
    + coalesce(fact.mntacc_subvpremloy, 0)
    + coalesce(fact.mntacc_dotes, 0)
    + coalesce(fact.mntacc_dot_etap, 0)
    + coalesce(fact.mntacc_autofpremloy, 0)
    + coalesce(fact.mntacc_cct_avsubv, 0)
    + coalesce(fact.mntacc_don_proagro, 0)
    + coalesce(fact.mntacc_don_tun_jobs, 0)
    + coalesce(fact.mntacc_cred_ess_lf2022, 0)
    + coalesce(fact.mntacc_don_giz_non_agricole, 0)
    + coalesce(fact.mntacc_don_giz_agricole, 0)
    + coalesce(fact.mntacc_pret_participatif, 0)
    + coalesce(fact.mntacc_cred_art29_lf2023, 0)
    + coalesce(fact.mntacc_cred_af_tunithon, 0)
    + coalesce(fact.mntacc_don_bit_prog_jeun_ess, 0)
    + coalesce(fact.mntacc_entp_com_art32lf2024, 0)
    + coalesce(fact.mntacc_dot_ct_avance_subv_agr, 0)
    + coalesce(fact.mntacc_pret_honneur_cap_emploi, 0)
    + coalesce(fact.mntacc_don_fad_we_fi, 0)
    + coalesce(fact.mntacc_autfrais, 0)
    + coalesce(fact.mntacc_dot_agripr3, 0)
    + coalesce(fact.mntacc_gen_civil_frs, 0)
    + coalesce(fact.mntacc_gen_civil_clt, 0)
    + coalesce(fact.mntacc_plantation_frs, 0)
    + coalesce(fact.mntacc_plantation_clt, 0)
    + coalesce(fact.mntacc_puit_forage_frs, 0)
    + coalesce(fact.mntacc_puit_forage_clt, 0)
) as mnt_total,
(
    coalesce(fact.mntacc_cmt, 0)
    + coalesce(fact.mntacc_dot, 0)
    + coalesce(fact.mntacc_credct, 0)
    + coalesce(fact.mntacc_dotqff, 0)
    + coalesce(fact.mntacc_mourabmt, 0)
    + coalesce(fact.mntacc_mourabct, 0)
    + coalesce(fact.mntacc_subv, 0)
    + coalesce(fact.mntacc_ap, 0)
    + coalesce(fact.mntacc_dotmpjfem, 0)
    + coalesce(fact.mntacc_pretparlfc, 0)
    + coalesce(fact.mntacc_pretparfem, 0)
    + coalesce(fact.mntacc_pretparfem2, 0)
    + coalesce(fact.mntacc_donpnud, 0)
    + coalesce(fact.mntacc_pretparpnud, 0)
    + coalesce(fact.mntacc_pretparcpg, 0)
    + coalesce(fact.mntacc_finijara, 0)
    + coalesce(fact.mntacc_subvpremloy, 0)
    + coalesce(fact.mntacc_dotes, 0)
    + coalesce(fact.mntacc_dot_etap, 0)
    + coalesce(fact.mntacc_autofpremloy, 0)
    + coalesce(fact.mntacc_cct_avsubv, 0)
    + coalesce(fact.mntacc_don_proagro, 0)
    + coalesce(fact.mntacc_don_tun_jobs, 0)
    + coalesce(fact.mntacc_cred_ess_lf2022, 0)
    + coalesce(fact.mntacc_don_giz_non_agricole, 0)
    + coalesce(fact.mntacc_don_giz_agricole, 0)
    + coalesce(fact.mntacc_pret_participatif, 0)
    + coalesce(fact.mntacc_cred_art29_lf2023, 0)
    + coalesce(fact.mntacc_cred_af_tunithon, 0)
    + coalesce(fact.mntacc_don_bit_prog_jeun_ess, 0)
    + coalesce(fact.mntacc_entp_com_art32lf2024, 0)
    + coalesce(fact.mntacc_dot_ct_avance_subv_agr, 0)
    + coalesce(fact.mntacc_pret_honneur_cap_emploi, 0)
    + coalesce(fact.mntacc_don_fad_we_fi, 0)
    + coalesce(fact.mntacc_autfrais, 0)
    + coalesce(fact.mntacc_dot_agripr3, 0)
    + coalesce(fact.mntacc_gen_civil_frs, 0)
    + coalesce(fact.mntacc_gen_civil_clt, 0)
    + coalesce(fact.mntacc_plantation_frs, 0)
    + coalesce(fact.mntacc_plantation_clt, 0)
    + coalesce(fact.mntacc_puit_forage_frs, 0)
    + coalesce(fact.mntacc_puit_forage_clt, 0)
) AS cout_total,

    -- ✅ Frais
    fact.comdmg,
    fact.tvadmg,

   -- ✅ KPIs ratios proposé (format décimal 0 à 1)
    case
        when fact.tepdmg is null or fact.tepdmg = 0 then null
        else round(fact.mntpropfdr / fact.tepdmg, 4)
    end                                                     as txfdr,

    case
        when fact.tepdmg is null or fact.tepdmg = 0 then null
        else round(fact.mntpropamnag / fact.tepdmg, 4)
    end                                                     as txamg,

    case
        when fact.tepdmg is null or fact.tepdmg = 0 then null
        else round(fact.mntpropequip / fact.tepdmg, 4)
    end                                                     as txequip,

    case
        when fact.tepdmg is null or fact.tepdmg = 0 then null
        else round(fact.mntpropmatertransp / fact.tepdmg, 4)
    end                                                     as txmatertransp,

    -- ✅ KPI Age : date dépôt - date naissance
    case
        when fact.dnaclt is not null
         and fact.datdmg  is not null
            then round((fact.datdmg - fact.dnaclt) / 360.0, 1)
    end                                                     as age,

    -- ✅ KPI DSA : date transfert - date dépôt (en jours)
    case
        when fact.dattransfert is not null
         and fact.datdmg       is not null
            then (fact.dattransfert - fact.datdmg)
    end                                                     as dsa,

    -- ✅ KPI DSS : date actuelle - date transfert (en jours)
    case
        when fact.dattransfert is not null
            then (current_date - fact.dattransfert)
    end                                                     as dss,

    -- ✅ KPI TxFDRAMG : (FDR + Aménagement) / Total emplois (format décimal 0 à 1)
    case
        when fact.tepdmg is null or fact.tepdmg = 0 then null
        else round(
            (coalesce(fact.mntpropfdr, 0) + coalesce(fact.mntpropamnag, 0))
            / fact.tepdmg, 4
        )
    end                                                     as txfdramg,

    -- ✅ KPI TOTENG : Total emplois (mntencours_eff à intégrer quand disponible)
    coalesce(fact.tepdmg, 0)                                as toteng,

    -- ✅ KPI TxRecAct : Oui si taux national < taux régional
    case
        when recov_nat.txrecovnat is null
          or recov_reg.txrecouvreg is null then null
        when recov_nat.txrecovnat < recov_reg.txrecouvreg then 'Oui'
        else 'Non'
    end                                                     as txrecact,

    -- ✅ KPI Coût Total accordé
    (
        coalesce(fact.mntacc_cmt, 0)
        + coalesce(fact.mntacc_dot, 0)
        + coalesce(fact.mntacc_credct, 0)
        + coalesce(fact.mntacc_dotqff, 0)
        + coalesce(fact.mntacc_mourabmt, 0)
        + coalesce(fact.mntacc_mourabct, 0)
        + coalesce(fact.mntacc_subv, 0)
        + coalesce(fact.mntacc_ap, 0)
        + coalesce(fact.mntacc_dotmpjfem, 0)
        + coalesce(fact.mntacc_pretparlfc, 0)
        + coalesce(fact.mntacc_pretparfem, 0)
        + coalesce(fact.mntacc_pretparfem2, 0)
        + coalesce(fact.mntacc_donpnud, 0)
        + coalesce(fact.mntacc_pretparpnud, 0)
        + coalesce(fact.mntacc_pretparcpg, 0)
        + coalesce(fact.mntacc_finijara, 0)
        + coalesce(fact.mntacc_subvpremloy, 0)
        + coalesce(fact.mntacc_dotes, 0)
        + coalesce(fact.mntacc_dot_etap, 0)
        + coalesce(fact.mntacc_autofpremloy, 0)
        + coalesce(fact.mntacc_cct_avsubv, 0)
        + coalesce(fact.mntacc_don_proagro, 0)
        + coalesce(fact.mntacc_don_tun_jobs, 0)
        + coalesce(fact.mntacc_cred_ess_lf2022, 0)
        + coalesce(fact.mntacc_don_giz_non_agricole, 0)
        + coalesce(fact.mntacc_don_giz_agricole, 0)
        + coalesce(fact.mntacc_pret_participatif, 0)
        + coalesce(fact.mntacc_cred_art29_lf2023, 0)
        + coalesce(fact.mntacc_cred_af_tunithon, 0)
        + coalesce(fact.mntacc_don_bit_prog_jeun_ess, 0)
        + coalesce(fact.mntacc_entp_com_art32lf2024, 0)
        + coalesce(fact.mntacc_dot_ct_avance_subv_agr, 0)
        + coalesce(fact.mntacc_pret_honneur_cap_emploi, 0)
        + coalesce(fact.mntacc_don_fad_we_fi, 0)
        + coalesce(fact.mntacc_autfrais, 0)
        + coalesce(fact.mntacc_dot_agripr3, 0)
        + coalesce(fact.mntacc_gen_civil_frs, 0)
        + coalesce(fact.mntacc_gen_civil_clt, 0)
        + coalesce(fact.mntacc_plantation_frs, 0)
        + coalesce(fact.mntacc_plantation_clt, 0)
        + coalesce(fact.mntacc_puit_forage_frs, 0)
        + coalesce(fact.mntacc_puit_forage_clt, 0)
    )                                                       as cout_total_acc,

    -- ✅ KPI Montant Total Proposé
    (
        coalesce(fact.mntpropequip, 0)
        + coalesce(fact.mntpropamnag, 0)
        + coalesce(fact.mntpropmatertransp, 0)
        + coalesce(fact.mntpropchept, 0)
        + coalesce(fact.mntpropfdr, 0)
        + coalesce(fact.mntpropass, 0)
        + coalesce(fact.mntpropcct, 0)
        + coalesce(fact.mntpropdon_tunjobs, 0)
    )                                                       as mnt_total_prop,
    current_timestamp                                       as _load_timestamp

from fact
left join client
    on fact.codclt = client.codclt
left join zac
    on fact.codzac = zac.codzac
left join niveau
    on client.codnisclt = niveau.codnis
left join unite
    on fact.unite_key = unite.unite_key
left join recov_nat
    on fact.codzac = recov_nat.codzac
left join recov_reg
    on fact.codzac  = recov_reg.codzac
   and fact.codgov  = recov_reg.codgov
left join recap_client
    on fact.codclt = recap_client.codclt