
-- clickhouse_microprojets_datamart1.sql
-- Tables physiques ClickHouse pour le datamart Microprojets
-- Engine recommandé : MergeTree
-- Base cible : bts_datamart1

CREATE DATABASE IF NOT EXISTS bts_datamart1;

-- ============================================================
-- FACTS — tables physiques MergeTree (copiées depuis PG)
-- ============================================================

-- ------------------------------------------------------------
-- FACT_DEMANDE_FINANCEMENT
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.fact_demande_financement;
CREATE TABLE bts_datamart1.fact_demande_financement
(
    demande_key                         String,
    client_key                          Nullable(String),
    unite_key                           Nullable(String),
    type_demande_key                    Nullable(String),
    origine_demande_key                 Nullable(String),
    modele_financement_key              Nullable(String),
    niveau_instruction_key              Nullable(String),
    employe_key                         Nullable(String),
    zac_key                             Nullable(String),
    gouvernorat_key                     Nullable(String),
    delegation_key                      Nullable(String),
    localite_key                        Nullable(String),
    eng1_key                            Nullable(String),
    eng2_key                            Nullable(String),
    autorisation_key                    Nullable(String),
    ptt_key                             Nullable(String),
    classif_activite_key                Nullable(String),

    numdmg                              Int64,
    codclt                              Nullable(Int64),
    codunt                              Nullable(Int32),
    codtypedde                          Nullable(Int32),
    codorigindde                        Nullable(Int32),
    codmodelesf                         Nullable(Int32),
    matdecideur                         Nullable(Int32),
    codprj                              Nullable(Int64),
    codzac                              Nullable(String),
    codgov                              Nullable(Int32),
    coddlg                              Nullable(Int32),
    codloc                              Nullable(Int32),
    codenadmc1                          Nullable(Int32),
    codenadmc2                          Nullable(Int32),

    datdmg                              Nullable(Date),
    date_decision                       Nullable(Date),
    dattransfert                        Nullable(Date),
    drpdmg                              Nullable(Date),
    dncdmg                              Nullable(Date),
    denrdmg                             Nullable(Date),
    davidmg                             Nullable(Date),
    dadcdmg                             Nullable(Date),
    dautdmg                             Nullable(Date),
    drcpdmg                             Nullable(Date),

    etadmg                              Nullable(Int32),
    decision                            Nullable(Int32),
    idcadmg                             Nullable(Int32),
    numautdmg                           Nullable(Int32),
    rpcdmg                              Nullable(Int32),
    natdmp                              Nullable(Int32),
    nepdmp                              Nullable(Int32),
    nbrprj                              Nullable(Int32),
    nbrcrdpropaccor                     Int32,
    dureedde                            Int32,

    comdmg                              Nullable(Decimal(15,3)),
    tvadmg                              Nullable(Decimal(15,3)),
    tepdmg                              Nullable(Decimal(15,3)),
    dnaclt                              Nullable(Date),

    cloaut                              Nullable(Int32),
    mntaut                              Nullable(Decimal(15,3)),
    dataut                              Nullable(Date),
    refaut                              Nullable(Int32),

    codactivclass                       Nullable(String),
    activclass                          Nullable(String),
    codactivgroup                       Nullable(String),
    activgroup                          Nullable(String),
    codactivdiv                         Nullable(String),
    activdiv                            Nullable(String),
    codactivsoussect                    Nullable(String),
    activsoussect                       Nullable(String),
    codactivsection                     Nullable(String),
    activsection                        Nullable(String),

    -- Montants proposés
    mntpropequip                        Decimal(15,3),
    mntpropamnag                        Decimal(15,3),
    mntpropmatertransp                  Decimal(15,3),
    mntpropchept                        Decimal(15,3),
    mntpropfdr                          Decimal(15,3),
    mntpropass                          Decimal(15,3),
    mntpropcct                          Decimal(15,3),
    mntpropdon_tunjobs                  Decimal(15,3),

    -- Montants accordés
    cout_projet_acc                     Decimal(15,3),
    equifrs_acc                         Decimal(15,3),
    equiclt_acc                         Decimal(15,3),
    amngfrs_acc                         Decimal(15,3),
    amngclt_acc                         Decimal(15,3),
    mattranspfrs_acc                    Decimal(15,3),
    mattranspclt_acc                    Decimal(15,3),
    cheptfrs_acc                        Decimal(15,3),
    cheptclt_acc                        Decimal(15,3),
    fdrclt_acc                          Decimal(15,3),
    approvfrs_acc                       Decimal(15,3),
    assurancefrs_acc                    Decimal(15,3),
    assuranceclt_acc                    Decimal(15,3),
    fraisetd_acc                        Decimal(15,3),
    fraisfng_acc                        Decimal(15,3),
    fad_acc                             Decimal(15,3),
    matroulant_acc                      Decimal(15,3),
    mntacc_ap                           Decimal(15,3),
    mntacc_autfrais                     Decimal(15,3),
    mntacc_subv                         Decimal(15,3),
    mntacc_cmt                          Decimal(15,3),
    mntacc_dot                          Decimal(15,3),
    mntacc_credct                       Decimal(15,3),
    mntacc_dotqff                       Decimal(15,3),
    mntacc_dotes                        Decimal(15,3),
    mntacc_mourabmt                     Decimal(15,3),
    mntacc_mourabct                     Decimal(15,3),
    mntacc_dotmpjfem                    Decimal(15,3),
    mntacc_pretparlfc                   Decimal(15,3),
    mntacc_pretparfem                   Decimal(15,3),
    mntacc_pretparfem2                  Decimal(15,3),
    mntacc_pretparcpg                   Decimal(15,3),
    mntacc_donpnud                      Decimal(15,3),
    mntacc_pretparpnud                  Decimal(15,3),
    mntacc_cct_avsubv                   Decimal(15,3),
    mntacc_don_proagro                  Decimal(15,3),
    mntacc_don_tun_jobs                 Decimal(15,3),
    mntacc_dot_agripr3                  Decimal(15,3),
    mntacc_gen_civil_frs                Decimal(15,3),
    mntacc_gen_civil_clt                Decimal(15,3),
    mntacc_plantation_frs               Decimal(15,3),
    mntacc_plantation_clt               Decimal(15,3),
    mntacc_puit_forage_frs              Decimal(15,3),
    mntacc_puit_forage_clt              Decimal(15,3),
    mntacc_subvpremloy                  Decimal(15,3),
    mntacc_autofpremloy                 Decimal(15,3),
    mntacc_finijara                     Decimal(15,3),
    mntacc_dot_etap                     Decimal(15,3),
    mntacc_pret_participatif            Decimal(15,3),
    mntacc_cred_ess_lf2022              Decimal(15,3),
    mntacc_don_giz_agricole             Decimal(15,3),
    mntacc_don_giz_non_agricole         Decimal(15,3),
    mntacc_cred_art29_lf2023            Decimal(15,3),
    mntacc_cred_af_tunithon             Decimal(15,3),
    mntacc_don_bit_prog_jeun_ess        Decimal(15,3),
    mntacc_entp_com_art32lf2024         Decimal(15,3),
    mntacc_dot_ct_avance_subv_agr       Decimal(15,3),
    mntacc_pret_honneur_cap_emploi      Decimal(15,3),
    mntacc_don_fad_we_fi                Decimal(15,3),

    _load_timestamp                     DateTime
)
ENGINE = MergeTree()
ORDER BY (numdmg)
SETTINGS index_granularity = 8192;

-- ------------------------------------------------------------
-- FACT_RECOUVREMENT_CLIENT
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.fact_recouvrement_client;
CREATE TABLE bts_datamart1.fact_recouvrement_client
(
    client_key                  Nullable(String),
    codclt                      Int64,

    mntechupayprinc             Decimal(15,3),
    mntechupayint               Decimal(15,3),
    mntechupay                  Decimal(15,3),

    mntechuimpayprinc           Decimal(15,3),
    mntechuimpayint             Decimal(15,3),
    mntechuimpay                Decimal(15,3),

    mntechuenattreglprinc       Decimal(15,3),
    mntechuenattreglint         Decimal(15,3),
    mntechuenattregl            Decimal(15,3),

    mntannulprinc               Decimal(15,3),
    mntannulint                 Decimal(15,3),
    mntannul                    Decimal(15,3),

    mntaechoirprinc             Decimal(15,3),
    mntaechoirint               Decimal(15,3),
    mntaechoir                  Decimal(15,3),

    datpremregl                 Nullable(Date),
    datderregl                  Nullable(Date),
    datpremech                  Nullable(Date),
    datderech                   Nullable(Date),
    premechimp                  Nullable(Date),

    nbrechimpprinc              Int32,
    nbrechimpint                Int32,

    _load_timestamp             DateTime
)
ENGINE = MergeTree()
ORDER BY (codclt)
SETTINGS index_granularity = 8192;

-- ------------------------------------------------------------
-- FACT_RECOUVREMENT_ZAC
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.fact_recouvrement_zac;
CREATE TABLE bts_datamart1.fact_recouvrement_zac
(
    zac_key                     Nullable(String),
    codzac                      String,

    mntechupay                  Decimal(15,3),
    mntechuimpay                Decimal(15,3),
    mntechuenattregl            Decimal(15,3),
    mntannul                    Decimal(15,3),
    mntaechoir                  Decimal(15,3),

    _load_timestamp             DateTime
)
ENGINE = MergeTree()
ORDER BY (codzac)
SETTINGS index_granularity = 8192;

-- ------------------------------------------------------------
-- FACT_RECOUVREMENT_GOV
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.fact_recouvrement_gov;
CREATE TABLE bts_datamart1.fact_recouvrement_gov
(
    zac_key                     Nullable(String),
    gouvernorat_key             Nullable(String),
    codzac                      String,
    codgov                      Int32,

    mntechupay                  Decimal(15,3),
    mntechuimpay                Decimal(15,3),
    mntechuenattregl            Decimal(15,3),
    mntannul                    Decimal(15,3),
    mntaechoir                  Decimal(15,3),

    _load_timestamp             DateTime
)
ENGINE = MergeTree()
ORDER BY (codzac, codgov)
SETTINGS index_granularity = 8192;

-- ============================================================
-- MARTS — tables physiques MergeTree (copiées depuis PG)
-- ============================================================

-- ------------------------------------------------------------
-- MART_DEMANDE_FINANCEMENT
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.mart_demande_financement;
CREATE TABLE bts_datamart1.mart_demande_financement
(
    demande_key                         String,
    client_key                          Nullable(String),
    unite_key                           Nullable(String),
    type_demande_key                    Nullable(String),
    origine_demande_key                 Nullable(String),
    modele_financement_key              Nullable(String),
    niveau_instruction_key              Nullable(String),
    employe_key                         Nullable(String),
    zac_key                             Nullable(String),
    gouvernorat_key                     Nullable(String),
    delegation_key                      Nullable(String),
    localite_key                        Nullable(String),
    eng1_key                            Nullable(String),
    eng2_key                            Nullable(String),
    autorisation_key                    Nullable(String),
    ptt_key                             Nullable(String),
    classif_activite_key                Nullable(String),

    numdmg                              Int64,
    codclt                              Nullable(Int64),
    codunt                              Nullable(Int32),
    codtypedde                          Nullable(Int32),
    codorigindde                        Nullable(Int32),
    codmodelesf                         Nullable(Int32),
    matdecideur                         Nullable(Int32),
    codprj                              Nullable(Int64),
    codzac                              Nullable(String),
    codgov                              Nullable(Int32),
    coddlg                              Nullable(Int32),
    codloc                              Nullable(Int32),
    codenadmc1                          Nullable(Int32),
    codenadmc2                          Nullable(Int32),

    datdmg                              Nullable(Date),
    date_decision                       Nullable(Date),
    dattransfert                        Nullable(Date),
    drpdmg                              Nullable(Date),
    dncdmg                              Nullable(Date),
    denrdmg                             Nullable(Date),
    davidmg                             Nullable(Date),
    dadcdmg                             Nullable(Date),
    dautdmg                             Nullable(Date),
    drcpdmg                             Nullable(Date),

    etadmg                              Nullable(Int32),
    decision                            Nullable(Int32),
    idcadmg                             Nullable(Int32),
    numautdmg                           Nullable(Int32),
    natdmp                              Nullable(Int32),
    nepdmp                              Nullable(Int32),
    nbrprj                              Nullable(Int32),
    nbrcrdpropaccor                     Int32,
    dureedde                            Int32,

    lib_etat                            Nullable(String),
    lib_decision                        Nullable(String),
    decision_agence                     Nullable(String),
    nature_projet                       Nullable(String),
    lib_etat_aut                        Nullable(String),
    lib_sexe                            Nullable(String),
    lib_stfclt                          Nullable(String),
    lib_tidnclt                         Nullable(String),
    lib_secteur                         Nullable(String),

    codactivclass                       Nullable(String),
    activclass                          Nullable(String),
    codactivgroup                       Nullable(String),
    activgroup                          Nullable(String),
    codactivdiv                         Nullable(String),
    activdiv                            Nullable(String),
    codactivsoussect                    Nullable(String),
    activsoussect                       Nullable(String),
    codactivsection                     Nullable(String),
    activsection                        Nullable(String),

    tepdmg                              Nullable(Decimal(15,3)),
    comdmg                              Nullable(Decimal(15,3)),
    tvadmg                              Nullable(Decimal(15,3)),

    mntpropequip                        Decimal(15,3),
    mntpropamnag                        Decimal(15,3),
    mntpropmatertransp                  Decimal(15,3),
    mntpropchept                        Decimal(15,3),
    mntpropfdr                          Decimal(15,3),
    mntpropass                          Decimal(15,3),
    mntpropcct                          Decimal(15,3),
    mntpropdon_tunjobs                  Decimal(15,3),

    cout_projet_acc                     Decimal(15,3),
    equifrs_acc                         Decimal(15,3),
    equiclt_acc                         Decimal(15,3),
    amngfrs_acc                         Decimal(15,3),
    amngclt_acc                         Decimal(15,3),
    mattranspfrs_acc                    Decimal(15,3),
    mattranspclt_acc                    Decimal(15,3),
    cheptfrs_acc                        Decimal(15,3),
    cheptclt_acc                        Decimal(15,3),
    fdrclt_acc                          Decimal(15,3),
    approvfrs_acc                       Decimal(15,3),
    assurancefrs_acc                    Decimal(15,3),
    assuranceclt_acc                    Decimal(15,3),
    fraisetd_acc                        Decimal(15,3),
    fraisfng_acc                        Decimal(15,3),
    fad_acc                             Decimal(15,3),
    matroulant_acc                      Decimal(15,3),
    mntacc_ap                           Decimal(15,3),
    mntacc_autfrais                     Decimal(15,3),
    mntacc_subv                         Decimal(15,3),
    mntacc_cmt                          Decimal(15,3),
    mntacc_dot                          Decimal(15,3),
    mntacc_credct                       Decimal(15,3),
    mntacc_dotqff                       Decimal(15,3),
    mntacc_dotes                        Decimal(15,3),
    mntacc_mourabmt                     Decimal(15,3),
    mntacc_mourabct                     Decimal(15,3),
    mntacc_dotmpjfem                    Decimal(15,3),
    mntacc_pretparlfc                   Decimal(15,3),
    mntacc_pretparfem                   Decimal(15,3),
    mntacc_pretparfem2                  Decimal(15,3),
    mntacc_pretparcpg                   Decimal(15,3),
    mntacc_donpnud                      Decimal(15,3),
    mntacc_pretparpnud                  Decimal(15,3),
    mntacc_cct_avsubv                   Decimal(15,3),
    mntacc_don_proagro                  Decimal(15,3),
    mntacc_don_tun_jobs                 Decimal(15,3),
    mntacc_dot_agripr3                  Decimal(15,3),
    mntacc_gen_civil_frs                Decimal(15,3),
    mntacc_gen_civil_clt                Decimal(15,3),
    mntacc_plantation_frs               Decimal(15,3),
    mntacc_plantation_clt               Decimal(15,3),
    mntacc_puit_forage_frs              Decimal(15,3),
    mntacc_puit_forage_clt              Decimal(15,3),
    mntacc_subvpremloy                  Decimal(15,3),
    mntacc_autofpremloy                 Decimal(15,3),
    mntacc_finijara                     Decimal(15,3),
    mntacc_dot_etap                     Decimal(15,3),
    mntacc_pret_participatif            Decimal(15,3),
    mntacc_cred_ess_lf2022              Decimal(15,3),
    mntacc_don_giz_agricole             Decimal(15,3),
    mntacc_don_giz_non_agricole         Decimal(15,3),
    mntacc_cred_art29_lf2023            Decimal(15,3),
    mntacc_cred_af_tunithon             Decimal(15,3),
    mntacc_don_bit_prog_jeun_ess        Decimal(15,3),
    mntacc_entp_com_art32lf2024         Decimal(15,3),
    mntacc_dot_ct_avance_subv_agr       Decimal(15,3),
    mntacc_pret_honneur_cap_emploi      Decimal(15,3),
    mntacc_don_fad_we_fi                Decimal(15,3),

    txfdr                               Nullable(Decimal(8,2)),
    txamg                               Nullable(Decimal(8,2)),
    txequip                             Nullable(Decimal(8,2)),
    txmatertransp                       Nullable(Decimal(8,2)),
    age                                 Nullable(Decimal(5,1)),
    cout_total                          Decimal(15,3),
    cout_total_acc                      Decimal(15,3),
    mnt_total_prop                      Decimal(15,3),
    fngcalc                             Decimal(15,3),
    totfrais                            Decimal(15,3),

    _load_timestamp                     DateTime
)
ENGINE = MergeTree()
ORDER BY (numdmg)
SETTINGS index_granularity = 8192;

-- ------------------------------------------------------------
-- MART_RECOUVREMENT_CLIENT
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.mart_recouvrement_client;
CREATE TABLE bts_datamart1.mart_recouvrement_client
(
    client_key                  Nullable(String),
    codclt                      Int64,
    nomclt                      Nullable(String),
    prnclt                      Nullable(String),
    dnaclt                      Nullable(Date),
    lib_sexe                    Nullable(String),

    mntechupayprinc             Decimal(15,3),
    mntechupayint               Decimal(15,3),
    mntechupay                  Decimal(15,3),
    mntechuimpayprinc           Decimal(15,3),
    mntechuimpayint             Decimal(15,3),
    mntechuimpay                Decimal(15,3),
    mntechuenattreglprinc       Decimal(15,3),
    mntechuenattreglint         Decimal(15,3),
    mntechuenattregl            Decimal(15,3),
    mntannulprinc               Decimal(15,3),
    mntannulint                 Decimal(15,3),
    mntannul                    Decimal(15,3),
    mntaechoirprinc             Decimal(15,3),
    mntaechoirint               Decimal(15,3),
    mntaechoir                  Decimal(15,3),

    datpremregl                 Nullable(Date),
    datderregl                  Nullable(Date),
    datpremech                  Nullable(Date),
    datderech                   Nullable(Date),
    premechimp                  Nullable(Date),

    nbrechimpprinc              Int32,
    nbrechimpint                Int32,

    mntechu                     Decimal(15,3),
    mntencourseff               Decimal(15,3),
    tx_impaye_clt               Decimal(8,2),

    _load_timestamp             DateTime
)
ENGINE = MergeTree()
ORDER BY (codclt)
SETTINGS index_granularity = 8192;

-- ------------------------------------------------------------
-- MART_RECOUVREMENT_ZAC
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.mart_recouvrement_zac;
CREATE TABLE bts_datamart1.mart_recouvrement_zac
(
    zac_key                     Nullable(String),
    codzac                      String,
    libzac                      Nullable(String),
    seczac                      Nullable(String),
    lib_secteur                 Nullable(String),

    mntechupay                  Decimal(15,3),
    mntechuimpay                Decimal(15,3),
    mntechuenattregl            Decimal(15,3),
    mntannul                    Decimal(15,3),
    mntaechoir                  Decimal(15,3),

    mntechuparactiv             Decimal(15,3),
    mntechuimpparactiv          Decimal(15,3),
    txrecovnat                  Decimal(8,2),

    _load_timestamp             DateTime
)
ENGINE = MergeTree()
ORDER BY (codzac)
SETTINGS index_granularity = 8192;

-- ------------------------------------------------------------
-- MART_RECOUVREMENT_GOV
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.mart_recouvrement_gov;
CREATE TABLE bts_datamart1.mart_recouvrement_gov
(
    zac_key                     Nullable(String),
    gouvernorat_key             Nullable(String),
    codzac                      String,
    codgov                      Int32,
    libzac                      Nullable(String),
    seczac                      Nullable(String),
    lib_secteur                 Nullable(String),
    libgov                      Nullable(String),

    mntechupay                  Decimal(15,3),
    mntechuimpay                Decimal(15,3),
    mntechuenattregl            Decimal(15,3),
    mntannul                    Decimal(15,3),
    mntaechoir                  Decimal(15,3),

    mntechuparactivgov          Decimal(15,3),
    mntechuimpparactivgov       Decimal(15,3),
    txrecouvreg                 Decimal(8,2),

    _load_timestamp             DateTime
)
ENGINE = MergeTree()
ORDER BY (codzac, codgov)
SETTINGS index_granularity = 8192;

-- ============================================================
-- VERIFICATION FINALE
-- ============================================================
SELECT
    name        AS table_name,
    engine      AS engine_type,
    total_rows
FROM system.tables
WHERE database = 'bts_datamart1'
ORDER BY engine, name;
