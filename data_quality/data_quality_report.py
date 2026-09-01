"""
=============================================================
  DATA QUALITY REPORT — SCRIPT UNIFIÉ
  Projet BTS PFE
  Tables : ADR, AUT, PTT, ZCL, ZGR, ZDV, ZSS, ZSC,
           CLT, CPT, DLG, DMC, DMG, DMP, DMX, DMY,
           EFF, EMP, ENG, GOV, HSF, IMP, LFN, LOC,
           NAT, PRJ, TEL, TRH, UNT, ZAC
=============================================================
"""

import pandas as pd
import logging
import warnings
import time
from pathlib import Path
from datetime import datetime

warnings.filterwarnings("ignore")

# =============================================================
#  CONFIGURATION GLOBALE
# =============================================================

import os as _os

BASE_DIR   = Path(__file__).resolve().parent.parent
RAW_DIR    = Path(_os.getenv("RAW_DATA_DIR", BASE_DIR / "data" / "raw"))
OUTPUT_DIR = BASE_DIR / "data_quality"
LOG_DIR    = Path(_os.getenv("LOG_DIR", BASE_DIR / "logs"))

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
LOG_DIR.mkdir(parents=True, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    handlers=[
        logging.FileHandler(LOG_DIR / "data_quality_unified.log", encoding="utf-8"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# =============================================================
#  CONFIGURATION PAR TABLE
# =============================================================
#
#  Chaque entrée décrit les règles métier propres à la table.
#  Les clés disponibles :
#
#   file            – nom du fichier .xls
#   critical_cols   – colonnes qui ne doivent pas être NULL
#   pk_cols         – liste de colonnes formant la clé primaire
#                     (unicité / doublons)
#   date_cols       – colonnes à convertir + vérifier
#   numeric_cols    – colonnes qui doivent être >= 0
#   validity        – dict  {colonne: [valeurs_autorisées]}
#   consistency     – liste de règles (callable ou dict décrit ci-dessous)
#   accuracy        – liste de tests (callable ou dict)
#   distribution    – colonnes pour lesquelles générer value_counts
#   text_cols       – colonnes à nettoyer (strip espaces)
#   freshness_cols  – colonnes dont les dates ne doivent pas être futures
#   extra_checks    – callable(df) -> dict{sheet_name: DataFrame}
#                     pour tout check spécifique non générique
#
# =============================================================

TABLE_CONFIG = {

    # ----------------------------------------------------------
    "ADR": {
        "file"          : "ADR.xls",
        "critical_cols" : ["NUMADR","CODCLTADR","CODPAYADR","TYPADR","LG1ADR"],
        "pk_cols"       : ["NUMADR"],
        "date_cols"     : ["DMJADR"],
        "text_cols"     : ["LG1ADR","PTEADR","ALIBADR"],
        "validity"      : {"TYPADR": ["P","S"]},
        "consistency"   : [
            {"label": "Adresse sans client",
             "rule" : lambda df: (df["CODCLTADR"].isnull()).sum()
                                  if "CODCLTADR" in df.columns else 0}
        ],
        "distribution"  : ["TYPADR","CODPAYADR","CODPTTADR"],
        "freshness_cols": [],
        "numeric_cols"  : [],
    },

    # ----------------------------------------------------------
    "CLT": {
        "file"          : "CLT.xls",
        "critical_cols" : ["CODCLT","NOMCLT","PRNCLT","DNACLT","SEXCLT"],
        "pk_cols"       : ["CODCLT"],
        "date_cols"     : ["DNACLT"],
        "validity"      : {"SEXCLT": ["M","F"]},
        "distribution"  : ["SEXCLT"],
        "freshness_cols": [],
        "numeric_cols"  : [],
        "extra_checks"  : lambda df: _age_check(df, "DNACLT"),
    },

    # ----------------------------------------------------------
    "CPT": {
        "file"          : "CPT.xls",
        "critical_cols" : ["ORDCPT","CODCLTCPT","NOMCPT","OUVCPT"],
        "pk_cols"       : ["ORDCPT"],
        "date_cols"     : ["OUVCPT","DNACPT","DCLOCPT"],
        "numeric_cols"  : ["SLCCPT","SLDCPT","SMNCPT","SMXCPT"],
        "validity"      : {},
        "consistency"   : [
            {"label": "Naissance > ouverture",
             "rule" : lambda df: (df["DNACPT"] > df["OUVCPT"]).sum()
                                  if all(c in df.columns for c in ["DNACPT","OUVCPT"]) else 0},
            {"label": "Solde min > solde max",
             "rule" : lambda df: (df["SMNCPT"] > df["SMXCPT"]).sum()
                                  if all(c in df.columns for c in ["SMNCPT","SMXCPT"]) else 0},
        ],
        "accuracy"      : [
            {"label": "IBAN longueur != 4",
             "rule" : lambda df: (df["IBANCPT"].astype(str).str.len() != 4).sum()
                                  if "IBANCPT" in df.columns else 0},
            {"label": "RIB longueur != 13",
             "rule" : lambda df: (df["RIBCCPT"].astype(str).str.len() != 13).sum()
                                  if "RIBCCPT" in df.columns else 0},
        ],
        "distribution"  : [],
        "freshness_cols": [],
    },

    # ----------------------------------------------------------
    "DLG": {
        "file"          : "DLG.xls",
        "critical_cols" : ["CODGOVDLG","CODDLG","LIBDLG"],
        "pk_cols"       : ["CODGOVDLG","CODDLG"],
        "date_cols"     : ["DMJDLG"],
        "numeric_cols"  : [],
        "validity"      : {},
        "consistency"   : [
            {"label": "Même CODDLG avec plusieurs LIBDLG",
             "rule" : lambda df: (df.groupby("CODDLG")["LIBDLG"].nunique() > 1).sum()
                                  if all(c in df.columns for c in ["CODDLG","LIBDLG"]) else 0},
            {"label": "Même LIBDLG avec plusieurs CODDLG",
             "rule" : lambda df: (df.groupby("LIBDLG")["CODDLG"].nunique() > 1).sum()
                                  if all(c in df.columns for c in ["CODDLG","LIBDLG"]) else 0},
        ],
        "accuracy"      : [
            {"label": "LIBDLG > 40 caractères",
             "rule" : lambda df: (df["LIBDLG"].astype(str).str.len() > 40).sum()
                                  if "LIBDLG" in df.columns else 0},
            {"label": "ALIBDLG > 40 caractères",
             "rule" : lambda df: (df["ALIBDLG"].astype(str).str.len() > 40).sum()
                                  if "ALIBDLG" in df.columns else 0},
        ],
        "distribution"  : ["CODGOVDLG","CODDLG"],
        "freshness_cols": ["DMJDLG"],
    },

    # ----------------------------------------------------------
    "DMC": {
        "file"          : "DMC.xls",
        "critical_cols" : ["NUMDMGDMC","ORDDMC","CODENADMC","MNTDMC","PERDMC","CODDVSDMC"],
        "pk_cols"       : ["NUMDMGDMC","ORDDMC"],
        "date_cols"     : ["DMJDMC"],
        "numeric_cols"  : ["MNTDMC","ANTDMC","DURDMC","FRCDMC","MNTADMC","ANTADMC",
                           "DURADMC","FRCADMC","MASSDMC","MLOYDMC","MFNGDMC"],
        "validity"      : {"PERDMC" : [0,1,2,3,6,12],
                           "PERADMC": [0,1,2,3,6,12]},
        "consistency"   : [
            {"label": "Montant accordé > montant proposé",
             "rule" : lambda df: (df["MNTADMC"] > df["MNTDMC"]).sum()
                                  if all(c in df.columns for c in ["MNTADMC","MNTDMC"]) else 0},
            {"label": "Durée accordée > durée proposée",
             "rule" : lambda df: (df["DURADMC"] > df["DURDMC"]).sum()
                                  if all(c in df.columns for c in ["DURADMC","DURDMC"]) else 0},
            {"label": "Franchise accordée > franchise proposée",
             "rule" : lambda df: (df["FRCADMC"] > df["FRCDMC"]).sum()
                                  if all(c in df.columns for c in ["FRCADMC","FRCDMC"]) else 0},
            {"label": "Annuité accordée > annuité proposée",
             "rule" : lambda df: (df["ANTADMC"] > df["ANTDMC"]).sum()
                                  if all(c in df.columns for c in ["ANTADMC","ANTDMC"]) else 0},
            {"label": "Montant accordé renseigné sans périodicité accordée",
             "rule" : lambda df: (df["MNTADMC"].notna() & df["PERADMC"].isnull()).sum()
                                  if all(c in df.columns for c in ["MNTADMC","PERADMC"]) else 0},
        ],
        "distribution"  : ["PERDMC","PERADMC","TASSDMC"],
        "freshness_cols": ["DMJDMC"],
    },

    # ----------------------------------------------------------
    "DMG": {
        "file"          : "DMG.xls",
        "critical_cols" : ["NUMDMG","CODCLTDMG","DATDMG","ETADMG","UNTIDMG","CODDMXDMG","CODDMYDMG"],
        "pk_cols"       : ["NUMDMG"],
        "date_cols"     : ["DMJDMG","DATDMG","DADDMG","DRPDMG","DNCDMG","DENRDMG",
                           "DAVIDMG","DADCDMG","DAUTDMG","DTRFDMG","DRCPDMG",
                           "DFTMKDMG","DVLDDMG","DCMFDMG"],
        "numeric_cols"  : ["MNTDMG","TMNTDMG","TECDMG","TEPDMG","TEADMG","TRCDMG",
                           "TRPDMG","TRADMG","CRDPDMG","CRDADMG","COMDMG","TVADMG",
                           "MATFDMG","MASSDMG","MHTVDMG","MTVADMG","MTTCDMG"],
        "validity"      : {
            "ETADMG" : [0,1,2,3,4,5,6,7,8,9],
            "DSDDMG" : [1,2,3,4],
            "RPCDMG" : [1,2,3,4,9],
            "NTFDMG" : [1,2],
            "IISDMG" : [0,1],
            "CHRDMG" : [1,2,8,9],
            "ITMKDMG": [1],
            "IATFDMG": [0,1],
            "TYPDMG" : [1,2,3,4],
            "IRMBDMG": ["0","1",0,1],
            "IDCADMG": [1,2],
            "ISBVDMG": ["0","1",0,1],
            "ITDSDMG": ["0","1",0,1],
        },
        "consistency"   : [
            {"label": "ETADMG >=3 sans DADDMG",
             "rule" : lambda df: ((df["ETADMG"] >= 3) & df["DADDMG"].isnull()).sum()
                                  if all(c in df.columns for c in ["ETADMG","DADDMG"]) else 0},
            {"label": "RPCDMG sans DRPDMG",
             "rule" : lambda df: (df["RPCDMG"].notna() & df["DRPDMG"].isnull()).sum()
                                  if all(c in df.columns for c in ["RPCDMG","DRPDMG"]) else 0},
            {"label": "DAUTDMG sans NUMAUTDMG",
             "rule" : lambda df: (df["DAUTDMG"].notna() & df["NUMAUTDMG"].isnull()).sum()
                                  if all(c in df.columns for c in ["DAUTDMG","NUMAUTDMG"]) else 0},
            {"label": "CRDADMG > CRDPDMG",
             "rule" : lambda df: (df["CRDADMG"] > df["CRDPDMG"]).sum()
                                  if all(c in df.columns for c in ["CRDADMG","CRDPDMG"]) else 0},
        ],
        "distribution"  : ["ETADMG","DSDDMG","RPCDMG","IISDMG","TYPDMG","IDCADMG"],
        "freshness_cols": ["DMJDMG","DATDMG","DENRDMG","DTRFDMG"],
    },

    # ----------------------------------------------------------
    "DMP": {
        "file"          : "DMP.xls",
        "critical_cols" : ["NUMDMGDMP","CODPRJDMP","NATDMP"],
        "pk_cols"       : ["NUMDMGDMP"],
        "date_cols"     : ["DMJDMP"],
        "numeric_cols"  : ["NEPDMP"],
        "validity"      : {"NATDMP": [1,2]},
        "consistency"   : [
            {"label": "NEPDMP négatif",
             "rule" : lambda df: (df["NEPDMP"] < 0).sum() if "NEPDMP" in df.columns else 0},
        ],
        "distribution"  : ["NATDMP"],
        "freshness_cols": ["DMJDMP"],
    },

    # ----------------------------------------------------------
    "DMX": {
        "file"          : "DMX.xls",
        "critical_cols" : ["CODDMX","LIBDMX"],
        "pk_cols"       : ["CODDMX"],
        "date_cols"     : ["DMJDMX"],
        "numeric_cols"  : [],
        "validity"      : {"DMDDMX": ["O","N"],
                           "AVIDMX": ["O","N"],
                           "SBVDMX": ["O","N"]},
        "consistency"   : [
            {"label": "Demande=N mais Avis=O",
             "rule" : lambda df: df[(df["DMDDMX"] == "N") & (df["AVIDMX"] == "O")].shape[0]
                                  if all(c in df.columns for c in ["DMDDMX","AVIDMX"]) else 0},
        ],
        "distribution"  : ["DMDDMX","AVIDMX","SBVDMX"],
        "freshness_cols": ["DMJDMX"],
    },

    # ----------------------------------------------------------
    "DMY": {
        "file"          : "DMY.xls",
        "critical_cols" : ["CODDMY","LIBDMY","MMIDMY","MMXDMY"],
        "pk_cols"       : ["CODDMY"],
        "date_cols"     : ["DMJDMY"],
        "numeric_cols"  : ["MMIDMY","MMXDMY","NBJCDMY","NBJADMY"],
        "validity"      : {"IISDMY" : [0,1],
                           "RMBDMY" : ["0","1",0,1],
                           "IRTCDMY": ["0","1",0,1],
                           "ICSLDMY": [0,1],
                           "IFTSDMY": [0,1]},
        "consistency"   : [
            {"label": "Montant min > montant max",
             "rule" : lambda df: (df["MMIDMY"] > df["MMXDMY"]).sum()
                                  if all(c in df.columns for c in ["MMIDMY","MMXDMY"]) else 0},
            {"label": "Franchise min > max",
             "rule" : lambda df: (df["MNFDMY"] > df["MXFDMY"]).sum()
                                  if all(c in df.columns for c in ["MNFDMY","MXFDMY"]) else 0},
        ],
        "distribution"  : ["IISDMY","RMBDMY","ICSLDMY","IFTSDMY"],
        "freshness_cols": ["DMJDMY"],
    },

    # ----------------------------------------------------------
    "EFF": {
        "file"          : "EFF.xls",
        "critical_cols" : ["CODINSEFF","REFEFF","DVSEFF","MNTEFF","CODENGEFF",
                           "ORDCPXEFF","ECHEFF","TYPEFF","PPLEFF"],
        "pk_cols"       : ["CODINSEFF","REFEFF","PPLEFF","LGNEFF"],
        "date_cols"     : ["DMJEFF","ECHEFF","DDBEFF","DFNEFF","DTCEFF","DRGLEFF"],
        "numeric_cols"  : ["MNTEFF","BLKEFF","BLCEFF"],
        "validity"      : {"CODINSEFF": ["LN","LNN","FNC","EFF"],
                           "PRTEFF"   : [0,1,2,3],
                           "ACPEFF"   : ["0","1","2",0,1,2],
                           "TYPEFF"   : [1,2,3,4,5,6,7,8,9],
                           "PPLEFF"   : [1,2]},
        "consistency"   : [
            {"label": "DDBEFF > ECHEFF",
             "rule" : lambda df: (df["DDBEFF"] > df["ECHEFF"]).sum()
                                  if all(c in df.columns for c in ["DDBEFF","ECHEFF"]) else 0},
        ],
        "distribution"  : [],
        "freshness_cols": ["DMJEFF","ECHEFF"],
    },

    # ----------------------------------------------------------
    "EMP": {
        "file"          : "EMP.xls",
        "critical_cols" : ["MATEMP","CODUNTEMP","NOMEMP","PRNEMP","SEXEMP"],
        "pk_cols"       : ["MATEMP"],
        "date_cols"     : ["DMJEMP","NAIEMP","DAFEMP"],
        "numeric_cols"  : [],
        "validity"      : {"SEXEMP": ["M","F"]},
        "consistency"   : [
            {"label": "DAFEMP < NAIEMP",
             "rule" : lambda df: ((df["DAFEMP"] < df["NAIEMP"]) & df["DAFEMP"].notna()).sum()
                                  if all(c in df.columns for c in ["NAIEMP","DAFEMP"]) else 0},
        ],
        "accuracy"      : [
            {"label": "NOMEMP > 50 caractères",
             "rule" : lambda df: (df["NOMEMP"].astype(str).str.len() > 50).sum()
                                  if "NOMEMP" in df.columns else 0},
            {"label": "PRNEMP > 30 caractères",
             "rule" : lambda df: (df["PRNEMP"].astype(str).str.len() > 30).sum()
                                  if "PRNEMP" in df.columns else 0},
        ],
        "distribution"  : ["SEXEMP","NVHEMP","CODUNTEMP"],
        "freshness_cols": ["DMJEMP","DAFEMP"],
        "extra_checks"  : lambda df: _age_check(df, "NAIEMP"),
    },

    # ----------------------------------------------------------
    "ENG": {
        "file"          : "ENG.xls",
        "critical_cols" : ["CODENG","LIBENG","CODTEGENG","MMIENG","MMXENG"],
        "pk_cols"       : ["CODENG"],
        "date_cols"     : ["DMJENG"],
        "numeric_cols"  : ["TAUENG","TMXENG","TMNENG","CPCENG","TCGENG","FNGENG",
                           "TFXENG","TBQENG","TINENG","MMIENG","MMXENG"],
        "validity"      : {"IDXENG" : [0,1],
                           "IISENG" : [0,1],
                           "ICSLENG": [0,1],
                           "IRMBENG": ["0","1",0,1],
                           "IRPTENG": ["0","1",0,1],
                           "IRCHENG": ["0","1",0,1]},
        "consistency"   : [
            {"label": "Montant min > montant max",
             "rule" : lambda df: (df["MMIENG"] > df["MMXENG"]).sum()
                                  if all(c in df.columns for c in ["MMIENG","MMXENG"]) else 0},
            {"label": "Durée min > durée max",
             "rule" : lambda df: (df["DRIENG"] > df["DRXENG"]).sum()
                                  if all(c in df.columns for c in ["DRIENG","DRXENG"]) else 0},
            {"label": "Taux standard hors bornes min/max",
             "rule" : lambda df: ((df["TAUENG"] < df["TMNENG"]) | (df["TAUENG"] > df["TMXENG"])).sum()
                                  if all(c in df.columns for c in ["TAUENG","TMNENG","TMXENG"]) else 0},
        ],
        "distribution"  : ["IDXENG","IISENG","IRMBENG","IRPTENG","IRCHENG"],
        "freshness_cols": ["DMJENG"],
    },

    # ----------------------------------------------------------
    "GOV": {
        "file"          : "GOV.xls",
        "critical_cols" : ["CODGOV","LIBGOV"],
        "pk_cols"       : ["CODGOV"],
        "date_cols"     : ["DMJGOV"],
        "numeric_cols"  : [],
        "validity"      : {},
        "consistency"   : [
            {"label": "Même CODGOV avec plusieurs LIBGOV",
             "rule" : lambda df: (df.groupby("CODGOV")["LIBGOV"].nunique(dropna=True) > 1).sum()
                                  if all(c in df.columns for c in ["CODGOV","LIBGOV"]) else 0},
            {"label": "Même LIBGOV avec plusieurs CODGOV",
             "rule" : lambda df: (df.groupby("LIBGOV")["CODGOV"].nunique(dropna=True) > 1).sum()
                                  if all(c in df.columns for c in ["CODGOV","LIBGOV"]) else 0},
        ],
        "accuracy"      : [
            {"label": "CODGOV > 99",
             "rule" : lambda df: (df["CODGOV"] > 99).sum() if "CODGOV" in df.columns else 0},
            {"label": "CODREGGOV > 99",
             "rule" : lambda df: (df["CODREGGOV"] > 99).sum() if "CODREGGOV" in df.columns else 0},
        ],
        "distribution"  : ["CODGOV","LIBGOV","CODREGGOV"],
        "freshness_cols": ["DMJGOV"],
    },

    # ----------------------------------------------------------
    "HSF": {
        "file"          : "HSF.xls",
        "critical_cols" : ["NUMDMGHSF","NUMHSF","TYPHSF","MNCHSF"],
        "pk_cols"       : ["NUMDMGHSF","NUMHSF"],
        "date_cols"     : ["DMJHSF"],
        "numeric_cols"  : ["MNCHSF","MNPHSF","MNAHSF","MNCTHSF","MNPTHSF",
                           "MNATHSF","MNCVHSF","MNPVHSF","MNAVHSF"],
        "validity"      : {"TYPHSF": [1,2]},
        "consistency"   : [
            {"label": "Montants incohérents (Demandé ≥ Proposé ≥ Accordé)",
             "rule" : lambda df: df[
                         (df["MNCHSF"] < df["MNPHSF"]) | (df["MNPHSF"] < df["MNAHSF"])
                       ].shape[0]
                       if all(c in df.columns for c in ["MNCHSF","MNPHSF","MNAHSF"]) else 0},
            {"label": "TTC < HT (Demandé)",
             "rule" : lambda df: (df["MNCTHSF"] < df["MNCHSF"]).sum()
                                  if all(c in df.columns for c in ["MNCTHSF","MNCHSF"]) else 0},
            {"label": "TVA > HT (Demandé)",
             "rule" : lambda df: (df["MNCVHSF"] > df["MNCHSF"]).sum()
                                  if all(c in df.columns for c in ["MNCVHSF","MNCHSF"]) else 0},
        ],
        "distribution"  : ["TYPHSF"],
        "freshness_cols": ["DMJHSF"],
    },

    # ----------------------------------------------------------
    "IMP": {
        "file"          : "IMP.xls",
        "critical_cols" : ["CODINSIMP","REFIMP","DVSIMP","MNTIMP","CODENGIMP",
                           "ORDCPXIMP","ECHIMP","TYPIMP","ETAIMP"],
        "pk_cols"       : ["CODINSIMP","REFIMP","ETAIMP"],
        "date_cols"     : ["DMJIMP","ECHIMP","DDBIMP","DFNIMP","DTCIMP",
                           "DTSIMP","DRGLIMP","DCTXIMP"],
        "numeric_cols"  : ["MNTIMP","BLKIMP","BLCIMP","VTTAIMP","TAUIMP","CPCIMP","TCGIMP"],
        "validity"      : {"CODINSIMP": ["LN","LNN","FNC","EFF"],
                           "PRTIMP"   : [0,1],
                           "ACPIMP"   : ["0","1",0,1],
                           "ENDIMP"   : [0,1],
                           "ODPIMP"   : [0,1],
                           "ETAIMP"   : [1,2],
                           "TYPIMP"   : [1,2,3,7,8,9],
                           "CTXIMP"   : [0,1,9],
                           "CRPIMP"   : [0,1,2,3,4,5],
                           "ICSLIMP"  : [0,1],
                           "IRPTIMP"  : [0,1,2],
                           "IRCHIMP"  : ["0","1",0,1],
                           "IRGPIMP"  : [0,1],
                           "TRPTIMP"  : ["1","2","3",1,2,3],
                           "CVVIMP"   : ["40","41",40,41]},
        "consistency"   : [
            {"label": "Date émission > échéance",
             "rule" : lambda df: (df["DDBIMP"] > df["ECHIMP"]).sum()
                                  if all(c in df.columns for c in ["DDBIMP","ECHIMP"]) else 0},
            {"label": "Date impayé < échéance",
             "rule" : lambda df: ((df["DTCIMP"] < df["ECHIMP"]) & df["DTCIMP"].notna()).sum()
                                  if all(c in df.columns for c in ["DTCIMP","ECHIMP"]) else 0},
            {"label": "Date apurement < date impayé",
             "rule" : lambda df: ((df["DTSIMP"] < df["DTCIMP"]) & df["DTSIMP"].notna()).sum()
                                  if all(c in df.columns for c in ["DTSIMP","DTCIMP"]) else 0},
        ],
        "distribution"  : ["CODINSIMP","TYPIMP","ETAIMP","CTXIMP","CRPIMP","IRPTIMP"],
        "freshness_cols": ["DMJIMP","ECHIMP","DDBIMP","DFNIMP","DTCIMP","DTSIMP","DRGLIMP"],
    },

    # ----------------------------------------------------------
    "LFN": {
        "file"          : "LFN.xls",
        "critical_cols" : ["CODLFN","LIBLFN","CODCLFN","MNTCLFN","DDBLFN","DFNLFN"],
        "pk_cols"       : ["CODLFN"],
        "date_cols"     : ["DMJLFN","DDBLFN","DFNLFN","DDBRLFN","DFNRLFN"],
        "numeric_cols"  : ["MNTCLFN","MCOMLFN","TAUILFN"],
        "text_cols"     : ["LIBLFN"],
        "validity"      : {"STTLFN": ["A","C","S"]},
        "consistency"   : [
            {"label": "Date fin < date début",
             "rule" : lambda df: ((df["DFNLFN"] < df["DDBLFN"]) & df["DFNLFN"].notna()).sum()
                                  if all(c in df.columns for c in ["DFNLFN","DDBLFN"]) else 0},
            {"label": "Renouvellement incohérent",
             "rule" : lambda df: ((df["DFNRLFN"] < df["DDBRLFN"]) & df["DFNRLFN"].notna()).sum()
                                  if all(c in df.columns for c in ["DFNRLFN","DDBRLFN"]) else 0},
        ],
        "distribution"  : ["TYPLFN","STTLFN","NATLFN","DVSCLFN"],
        "freshness_cols": [],
    },

    # ----------------------------------------------------------
    "LOC": {
        "file"          : "LOC.xls",
        "critical_cols" : ["CODGOVLOC","CODDLGLOC","CODLOC","LIBLOC"],
        "pk_cols"       : ["CODGOVLOC","CODDLGLOC","CODLOC"],
        "date_cols"     : ["DMJLOC"],
        "numeric_cols"  : [],
        "validity"      : {},
        "consistency"   : [
            {"label": "Même clé avec plusieurs LIBLOC",
             "rule" : lambda df: (df.groupby(["CODGOVLOC","CODDLGLOC","CODLOC"])["LIBLOC"].nunique() > 1).sum()
                                  if all(c in df.columns for c in ["CODGOVLOC","CODDLGLOC","CODLOC","LIBLOC"]) else 0},
        ],
        "accuracy"      : [
            {"label": "LIBLOC > 40 caractères",
             "rule" : lambda df: (df["LIBLOC"].astype(str).str.len() > 40).sum()
                                  if "LIBLOC" in df.columns else 0},
            {"label": "CODPTTLOC longueur > 4",
             "rule" : lambda df: ((df["CODPTTLOC"].notna()) & (df["CODPTTLOC"].astype(str).str.len() > 4)).sum()
                                  if "CODPTTLOC" in df.columns else 0},
        ],
        "distribution"  : ["CODGOVLOC","CODDLGLOC","ZBRLOC"],
        "freshness_cols": ["DMJLOC"],
    },

    # ----------------------------------------------------------
    "NAT": {
        "file"          : "NAT.xls",
        "critical_cols" : ["CODNAT","LIBNAT"],
        "pk_cols"       : ["CODNAT"],
        "date_cols"     : [],
        "numeric_cols"  : [],
        "text_cols"     : ["LIBNAT"],
        "validity"      : {},
        "distribution"  : ["CODNAT"],
        "freshness_cols": [],
    },

    # ----------------------------------------------------------
    "PRJ": {
        "file"          : "PRJ.xls",
        "critical_cols" : ["CODPRJ","CODCLTPRJ","CODZACPRJ","CODGOVPRJ",
                           "CODDLGPRJ","CODLOCPRJ","ADRPRJ","DATPRJ"],
        "pk_cols"       : ["CODPRJ"],
        "date_cols"     : ["DMJPRJ","DATPRJ","DENRPRJ"],
        "numeric_cols"  : ["SRFIPRJ","SRFPRJ","NEPPRJ","RVNPRJ","CHGPRJ","CODPMTPRJ"],
        "validity"      : {"INSPRJ": ["O","N"],
                           "ETBPRJ": ["O","N"]},
        "consistency"   : [
            {"label": "Date installation > date enregistrement",
             "rule" : lambda df: ((df["DATPRJ"] > df["DENRPRJ"]) & df["DENRPRJ"].notna()).sum()
                                  if all(c in df.columns for c in ["DATPRJ","DENRPRJ"]) else 0},
            {"label": "Superficie irriguée > superficie totale",
             "rule" : lambda df: ((df["SRFIPRJ"] > df["SRFPRJ"]) & df["SRFPRJ"].notna()).sum()
                                  if all(c in df.columns for c in ["SRFIPRJ","SRFPRJ"]) else 0},
            {"label": "Projet non installé avec date installation",
             "rule" : lambda df: ((df["INSPRJ"] == "N") & df["DATPRJ"].notna()).sum()
                                  if all(c in df.columns for c in ["INSPRJ","DATPRJ"]) else 0},
            {"label": "Revenus < charges",
             "rule" : lambda df: ((df["RVNPRJ"] < df["CHGPRJ"]) & df["RVNPRJ"].notna() & df["CHGPRJ"].notna()).sum()
                                  if all(c in df.columns for c in ["RVNPRJ","CHGPRJ"]) else 0},
        ],
        "distribution"  : ["INSPRJ","ETBPRJ","CODGOVPRJ","CODZACPRJ","CODPMTPRJ"],
        "freshness_cols": ["DMJPRJ","DATPRJ","DENRPRJ"],
    },

    # ----------------------------------------------------------
    "TEL": {
        "file"          : "TEL.xls",
        "critical_cols" : ["NUMTEL","CODCLTTEL","DMJTEL","TYPTEL","UTLTEL"],
        "pk_cols"       : ["NUMTEL"],
        "date_cols"     : ["DMJTEL","HDATEL","HFATEL"],
        "numeric_cols"  : [],
        "text_cols"     : ["RMQTEL"],
        "validity"      : {"PAYTEL": ["O","N"]},
        "consistency"   : [
            {"label": "Heure fin < heure début",
             "rule" : lambda df: ((df["HFATEL"] < df["HDATEL"]) & df["HFATEL"].notna()).sum()
                                  if all(c in df.columns for c in ["HDATEL","HFATEL"]) else 0},
        ],
        "distribution"  : ["TYPTEL","UTLTEL","PAYTEL"],
        "freshness_cols": [],
    },

    # ----------------------------------------------------------
    "TRH": {
        "file"          : "TRH.xls",
        "critical_cols" : ["NUMTRH","ORDCPTTRH","CODCLTTRH","MNTTRH","ETATRH","DMJTRH"],
        "pk_cols"       : ["NUMTRH"],
        "date_cols"     : ["DMJTRH","DTTTRH","DTEGTRH","DDSTTRH"],
        "numeric_cols"  : [],
        "validity"      : {},
        "consistency"   : [
            {"label": "TTC incohérent (HT + TVA ≠ TTC)",
             "rule" : lambda df: ((df["MHTVTRH"] + df["MTVATRH"] != df["MTTCTRH"]) & df["MTTCTRH"].notna()).sum()
                                  if all(c in df.columns for c in ["MHTVTRH","MTVATRH","MTTCTRH"]) else 0},
        ],
        "distribution"  : [],
        "freshness_cols": [],
    },

    # ----------------------------------------------------------
    "UNT": {
        "file"          : "UNT.xls",
        "critical_cols" : ["CODUNT","LIBUNT","CODTNTUNT","CODPTTUNT","CODBAQUNT","GOVUNT"],
        "pk_cols"       : ["CODUNT"],
        "date_cols"     : ["DMJUNT","DAFRUNT","DCLOUNT","DCLXUNT","D1OUVUNT","D2OUVUNT","DCLOXUNT"],
        "numeric_cols"  : ["MPRV1UNT","MPRV2UNT","MPRV3UNT","MIDVUNT","LTTUNT","LGTUNT"],
        "validity"      : {"IPVUNT" : [0,1,2,3],
                           "IACUNT" : [0,1,2,3],
                           "IEXUNT" : [0,1,2,3],
                           "IDCUNT" : [0,1,2,3],
                           "IXIUNT" : [0,1,2,3],
                           "INDUNT" : [0,1,2,3,4,5,9],
                           "ICPUNT" : [0,1]},
        "consistency"   : [
            {"label": "Date fermeture < ouverture",
             "rule" : lambda df: (df["DCLOUNT"] < df["D1OUVUNT"]).sum()
                                  if all(c in df.columns for c in ["DCLOUNT","D1OUVUNT"]) else 0},
            {"label": "Limite min > max",
             "rule" : lambda df: (df["LTTUNT"] > df["LGTUNT"]).sum()
                                  if all(c in df.columns for c in ["LTTUNT","LGTUNT"]) else 0},
        ],
        "accuracy"      : [
            {"label": "Email invalide (sans @)",
             "rule" : lambda df: df["EMLUNT"].dropna().apply(lambda x: "@" not in str(x)).sum()
                                  if "EMLUNT" in df.columns else 0},
            {"label": "Téléphone longueur != 8",
             "rule" : lambda df: df["TELUNT"].dropna().astype(str).apply(lambda x: len(x) != 8).sum()
                                  if "TELUNT" in df.columns else 0},
        ],
        "distribution"  : ["IPVUNT","IACUNT","IEXUNT","INDUNT","ICPUNT"],
        "freshness_cols": ["DMJUNT","DAFRUNT"],
    },

    # ----------------------------------------------------------
    "ZAC": {
        "file"          : "ZAC.xls",
        "critical_cols" : ["CODZAC","LIBZAC","SECZAC"],
        "pk_cols"       : ["CODZAC"],
        "date_cols"     : ["DMJZAC"],
        "numeric_cols"  : [],
        "validity"      : {"SECZAC" : ["A","B","S","I","M"],
                           "IMFSZAC": [0,1]},
        "consistency"   : [
            {"label": "CODZAC multi LIBZAC",
             "rule" : lambda df: (df.groupby("CODZAC")["LIBZAC"].nunique() > 1).sum()
                                  if all(c in df.columns for c in ["CODZAC","LIBZAC"]) else 0},
        ],
        "accuracy"      : [
            {"label": "CODZAC longueur != 7",
             "rule" : lambda df: (df["CODZAC"].astype(str).str.len() != 7).sum()
                                  if "CODZAC" in df.columns else 0},
        ],
        "distribution"  : ["SECZAC","CODZCLZAC"],
        "freshness_cols": ["DMJZAC"],
    },

    # ----------------------------------------------------------
    # Tables légères (AUT, PTT, ZCL, ZGR, ZDV, ZSS, ZSC)
    # gérées via le fichier data_quality_multi
    # ----------------------------------------------------------
    "AUT": {
        "file"          : "AUT.xls",
        "critical_cols" : ["REFAUT"],
        "pk_cols"       : ["REFAUT"],
        "date_cols"     : [],
        "numeric_cols"  : [],
        "validity"      : {},
        "distribution"  : [],
        "freshness_cols": [],
    },
    "PTT": {
        "file"          : "PTT.xls",
        "critical_cols" : ["CODPTT","LIBPTT"],
        "pk_cols"       : ["CODPTT"],
        "date_cols"     : [],
        "numeric_cols"  : [],
        "validity"      : {},
        "distribution"  : [],
        "freshness_cols": [],
    },
    "ZCL": {
        "file"          : "ZCL.xls",
        "critical_cols" : ["CODZCL","LIBZCL","CODZGR"],
        "pk_cols"       : ["CODZCL"],
        "date_cols"     : [],
        "numeric_cols"  : [],
        "validity"      : {},
        "distribution"  : ["CODZGR"],
        "freshness_cols": [],
    },
    "ZGR": {
        "file"          : "ZGR.xls",
        "critical_cols" : ["CODZGR","LIBZGR","CODZDV"],
        "pk_cols"       : ["CODZGR"],
        "date_cols"     : [],
        "numeric_cols"  : [],
        "validity"      : {},
        "distribution"  : ["CODZDV"],
        "freshness_cols": [],
    },
    "ZDV": {
        "file"          : "ZDV.xls",
        "critical_cols" : ["CODZDV","LIBZDV","CODZSS"],
        "pk_cols"       : ["CODZDV"],
        "date_cols"     : [],
        "numeric_cols"  : [],
        "validity"      : {},
        "distribution"  : ["CODZSS"],
        "freshness_cols": [],
    },
    "ZSS": {
        "file"          : "ZSS.xls",
        "critical_cols" : ["CODZSS","LIBZSS","CODZSC"],
        "pk_cols"       : ["CODZSS"],
        "date_cols"     : [],
        "numeric_cols"  : [],
        "validity"      : {},
        "distribution"  : ["CODZSC"],
        "freshness_cols": [],
    },
    "ZSC": {
        "file"          : "ZSC.xls",
        "critical_cols" : ["CODZSC","LIBZSC"],
        "pk_cols"       : ["CODZSC"],
        "date_cols"     : [],
        "numeric_cols"  : [],
        "validity"      : {},
        "distribution"  : [],
        "freshness_cols": [],
    },
    "DAP": {
        "file"          : "DAP.xls",
        "critical_cols" : ["REFAUTDAP","ORDDAP","CODENADAP","MNTDAP","PDPDAP",
                           "DBKDAP","DURDAP","MDFDAP"],
        "pk_cols"       : ["REFAUTDAP","ORDDAP"],
        "date_cols"     : ["DMJDAP","DBKDAP"],
        "numeric_cols"  : ["MNTDAP","TAUDAP","RMBDAP","FRZDAP","DURDAP",
                           "MNTTR1DAP","MNTR2DAP","MNTR3DAP","MNTR4DAP","MNTR5DAP",
                           "TOTDAP","PBQDAP"],
        "validity"      : {
            "PDPDAP" : [1, 2, 3, 6, 12],
            "CDFDAP" : [1, 2, 3, 4],
            "MDFDAP" : [0, 1, 9],
            "POLDAP" : ["0", "1", 0, 1],
            "IISDAP" : [0, 1],
            "ICSLDAP": [0, 1],
        },
        "consistency"   : [
            {"label": "Somme tranches > montant total",
             "rule" : lambda df: (
                 (df[["MNTTR1DAP","MNTR2DAP","MNTR3DAP","MNTR4DAP","MNTR5DAP"]]
                   .fillna(0).sum(axis=1) > df["TOTDAP"])
                 & df["TOTDAP"].notna()
             ).sum()
             if all(c in df.columns for c in
                    ["MNTTR1DAP","MNTR2DAP","MNTR3DAP","MNTR4DAP","MNTR5DAP","TOTDAP"])
             else 0},
            {"label": "Pourcentage banque hors [0–100]",
             "rule" : lambda df: ((df["PBQDAP"] < 0) | (df["PBQDAP"] > 100)).sum()
                                  if "PBQDAP" in df.columns else 0},
            {"label": "Date déblocage sans montant",
             "rule" : lambda df: (df["DBKDAP"].notna() & df["MNTDAP"].isnull()).sum()
                                  if all(c in df.columns for c in ["DBKDAP","MNTDAP"]) else 0},
            {"label": "Consolidation=Oui sans N° consolidation",
             "rule" : lambda df: ((df["ICSLDAP"] == 1) & df["NUMCSLDAP"].isnull()).sum()
                                  if all(c in df.columns for c in ["ICSLDAP","NUMCSLDAP"]) else 0},
            {"label": "Pool=Oui sans chef de file",
             "rule" : lambda df: ((df["POLDAP"].isin(["1",1])) & df["BQFDAP"].isnull()).sum()
                                  if all(c in df.columns for c in ["POLDAP","BQFDAP"]) else 0},
        ],
        "accuracy"      : [
            {"label": "Taux préférentiel hors [0–1] (> 100%)",
             "rule" : lambda df: ((df["TAUDAP"] < 0) | (df["TAUDAP"] > 1)).sum()
                                  if "TAUDAP" in df.columns else 0},
            {"label": "Durée = 0",
             "rule" : lambda df: (df["DURDAP"] == 0).sum()
                                  if "DURDAP" in df.columns else 0},
        ],
        "distribution"  : ["PDPDAP","CDFDAP","MDFDAP","IISDAP","ICSLDAP"],
        "freshness_cols": ["DMJDAP","DBKDAP"],
        "text_cols"     : [],
    },
}


# =============================================================
#  FONCTIONS UTILITAIRES
# =============================================================

def _age_check(df: pd.DataFrame, date_col: str) -> dict:
    """Calcule les stats d'âge à partir d'une colonne date de naissance."""
    if date_col not in df.columns:
        return {}
    col = pd.to_datetime(df[date_col], errors="coerce")
    age = (datetime.today() - col).dt.days // 365
    result = pd.DataFrame({
        "Metric": ["Age minimum", "Age maximum", "Individus < 18 ans"],
        "Value" : [age.min(), age.max(), (age < 18).sum()]
    })
    return {"Age_Check": result}


def _check_placeholders(df: pd.DataFrame) -> pd.DataFrame:
    """Détecte les valeurs placeholder dans toutes les colonnes."""
    placeholders = {"", " ", "0", "000000", "999999", "NULL", "null", "None"}
    rows = []
    for col in df.columns:
        count = sum(
            1 for v in df[col]
            if not pd.isna(v) and str(v).strip() in placeholders
        )
        rows.append([col, count, round(count / len(df) * 100, 2) if len(df) else 0])
    return pd.DataFrame(rows, columns=["Colonne", "Nb Placeholders", "% Placeholders"])


def _null_global(df: pd.DataFrame) -> pd.DataFrame:
    result = df.isnull().sum().reset_index()
    result.columns = ["Colonne", "Nb NULL"]
    result["% NULL"] = (result["Nb NULL"] / len(df) * 100).round(2) if len(df) else 0
    return result


def _empty_columns(df: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for col in df.columns:
        nb = df[col].isnull().sum()
        if nb == len(df):
            rows.append([col, "Colonne totalement vide"])
        elif len(df) > 0 and nb / len(df) >= 0.5:
            rows.append([col, "Colonne partiellement vide (>50%)"])
    return pd.DataFrame(rows, columns=["Colonne", "Observation"])


# =============================================================
#  MOTEUR DE RAPPORT
# =============================================================

def run_report(table_key: str, cfg: dict) -> None:
    """Génère le rapport Data Quality pour une table donnée."""

    file_path   = RAW_DIR    / cfg["file"]
    output_file = OUTPUT_DIR / f"data_quality_{table_key.lower()}_report.xlsx"
    t0 = time.time()

    logger.info("=" * 60)
    logger.info("START  %-6s  →  %s", table_key, cfg["file"])

    # ---- lecture ----
    if not file_path.exists():
        logger.error("Fichier introuvable : %s", file_path)
        return

    try:
        df = pd.read_excel(file_path, engine="xlrd")
        logger.info("Chargé : %d lignes | %d colonnes", df.shape[0], df.shape[1])
    except Exception as exc:
        logger.error("Lecture échouée : %s", exc, exc_info=True)
        return

    sheets = {}   # dict  sheet_name -> DataFrame  (ordre d'insertion conservé)

    # ---- 1. SUMMARY ----
    pk     = cfg.get("pk_cols", [])
    pk_col = pk[0] if len(pk) == 1 else (pk[0] if pk else None)
    dup_pk = df.duplicated(subset=pk, keep=False).sum() if (pk and all(c in df.columns for c in pk)) else None

    summary = pd.DataFrame({
        "Metric": ["Nombre lignes", "Nombre colonnes",
                   f"Doublons clé ({'+'.join(pk)})"],
        "Value" : [df.shape[0], df.shape[1], dup_pk]
    })
    sheets["Summary"] = summary

    # ---- 2. NULL critiques ----
    null_crit_rows = []
    for col in cfg.get("critical_cols", []):
        if col in df.columns:
            n = df[col].isnull().sum()
            if n: logger.warning("NULL critique  %-20s : %d", col, n)
            null_crit_rows.append([col, n])
        else:
            logger.warning("Colonne absente : %s", col)
            null_crit_rows.append([col, "colonne inexistante"])
    sheets["Null_Critical"] = pd.DataFrame(null_crit_rows, columns=["Colonne","Nb NULL"])

    # ---- 3. NULL global ----
    sheets["Null_All"] = _null_global(df)

    # ---- 4. UNICITÉ ----
    dup_rows = df.duplicated().sum()
    uniq_data = [
        [f"Doublons clé ({'+'.join(pk)})", dup_pk],
        ["Doublons lignes complètes",       dup_rows],
    ]
    if pk and all(c in df.columns for c in pk):
        dup_detail = df[df.duplicated(subset=pk, keep=False)]
        if not dup_detail.empty:
            sheets["Duplicates"] = dup_detail
    sheets["Uniqueness"] = pd.DataFrame(uniq_data, columns=["Metric","Value"])

    # ---- 5. DATES ----
    date_rows = []
    for col in cfg.get("date_cols", []):
        if col in df.columns:
            before = df[col].isnull().sum()
            df[col] = pd.to_datetime(df[col], errors="coerce")
            inv = df[col].isnull().sum() - before
            if inv: logger.warning("Dates invalides %-15s : %d", col, inv)
            date_rows.append([col, inv])
        else:
            date_rows.append([col, "colonne inexistante"])
    if date_rows:
        sheets["Date_Check"] = pd.DataFrame(date_rows, columns=["Colonne","Nb dates invalides"])

    # ---- 6. NETTOYAGE TEXTE ----
    text_issues = []
    for col in cfg.get("text_cols", []):
        if col in df.columns:
            clean = df[col].astype(str).str.strip()
            bad   = df[df[col].astype(str) != clean]
            if not bad.empty:
                logger.warning("Espaces dans %-15s : %d lignes", col, len(bad))
                text_issues.append(bad[[col]].assign(**{col + "_CLEAN": clean[bad.index]}))
    if text_issues:
        sheets["Text_Cleaning"] = pd.concat(text_issues)

    # ---- 7. VALIDITÉ ----
    valid_rows = []
    for col, allowed in cfg.get("validity", {}).items():
        if col in df.columns:
            inv = (~df[col].isin(allowed) & df[col].notna()).sum()
            if inv: logger.warning("Validité %-20s : %d invalides", col, inv)
            valid_rows.append([col, inv])
        else:
            valid_rows.append([col, "colonne inexistante"])
    if valid_rows:
        sheets["Validity"] = pd.DataFrame(valid_rows, columns=["Colonne","Nb valeurs invalides"])

    # ---- 8. COHÉRENCE ----
    cons_rows = []
    for rule in cfg.get("consistency", []):
        try:
            val = rule["rule"](df)
            cons_rows.append([rule["label"], val])
            if val: logger.warning("Cohérence %-35s : %d", rule["label"], val)
        except Exception as exc:
            logger.debug("Cohérence skip '%s' : %s", rule["label"], exc)
    if cons_rows:
        sheets["Consistency"] = pd.DataFrame(cons_rows, columns=["Règle","Nb anomalies"])

    # ---- 9. ACCURACY (valeurs négatives + checks custom) ----
    acc_rows = []
    for col in cfg.get("numeric_cols", []):
        if col in df.columns:
            neg = (df[col] < 0).sum()
            if neg: logger.warning("Négatifs %-20s : %d", col, neg)
            acc_rows.append([col, neg])
        else:
            acc_rows.append([col, "colonne inexistante"])

    for check in cfg.get("accuracy", []):
        try:
            val = check["rule"](df)
            acc_rows.append([check["label"], val])
            if val: logger.warning("Accuracy %-30s : %d", check["label"], val)
        except Exception as exc:
            logger.debug("Accuracy skip '%s' : %s", check["label"], exc)

    if acc_rows:
        sheets["Accuracy"] = pd.DataFrame(acc_rows, columns=["Test","Nb anomalies"])

    # ---- 10. FRAÎCHEUR ----
    today = pd.Timestamp.today()
    fresh_rows = []
    for col in cfg.get("freshness_cols", []):
        if col in df.columns:
            fut = (df[col] > today).sum()
            fresh_rows.append([col, fut])
    if fresh_rows:
        sheets["Freshness"] = pd.DataFrame(fresh_rows, columns=["Colonne","Nb dates futures"])

    # ---- 11. PLACEHOLDERS ----
    ph_df = _check_placeholders(df)
    if ph_df["Nb Placeholders"].sum() > 0:
        sheets["Placeholders"] = ph_df

    # ---- 12. COLONNES VIDES ----
    empty_df = _empty_columns(df)
    if not empty_df.empty:
        sheets["Empty_Columns"] = empty_df

    # ---- 13. DISTRIBUTIONS ----
    for col in cfg.get("distribution", []):
        if col in df.columns:
            dist = df[col].value_counts(dropna=False).reset_index()
            dist.columns = [col, "Count"]
            sheets[f"Dist_{col[:18]}"] = dist

    # ---- 14. STATISTIQUES ----
    try:
        sheets["Statistics"] = df.describe(include="all")
    except Exception as exc:
        logger.warning("Statistiques échouées : %s", exc)

    # ---- 15. CHECKS EXTRA (spécifiques à la table) ----
    extra_fn = cfg.get("extra_checks")
    if extra_fn:
        try:
            extras = extra_fn(df)
            if extras:
                sheets.update(extras)
        except Exception as exc:
            logger.warning("Extra checks échoués : %s", exc)

    # ---- EXPORT EXCEL ----
    try:
        with pd.ExcelWriter(output_file, engine="openpyxl") as writer:
            for sheet_name, frame in sheets.items():
                # openpyxl limite les noms d'onglets à 31 caractères
                safe_name = sheet_name[:31]
                frame.to_excel(writer, sheet_name=safe_name,
                               index=(sheet_name == "Statistics"))
        elapsed = round(time.time() - t0, 2)
        logger.info("OK %-6s  →  %s  (%.2fs)", table_key, output_file.name, elapsed)
        print(f"  ✔  {table_key:<6}  →  {output_file.name}  ({elapsed}s)")
    except Exception as exc:
        logger.error("Export échoué pour %s : %s", table_key, exc, exc_info=True)
        raise


# =============================================================
#  POINT D'ENTRÉE
# =============================================================

if __name__ == "__main__":

    global_start = time.time()

    print("\n" + "=" * 60)
    print("  DATA QUALITY REPORT — SCRIPT UNIFIÉ")
    print(f"  {len(TABLE_CONFIG)} tables  |  {datetime.now():%Y-%m-%d %H:%M:%S}")
    print("=" * 60 + "\n")

    logger.info("=== DÉBUT GÉNÉRATION RAPPORTS DATA QUALITY ===")
    logger.info("Tables : %s", ", ".join(TABLE_CONFIG.keys()))

    errors = []
    for key, config in TABLE_CONFIG.items():
        try:
            run_report(key, config)
        except Exception as e:
            logger.error("ERREUR table %s : %s", key, e)
            errors.append(key)

    elapsed_total = round(time.time() - global_start, 2)

    print("\n" + "=" * 60)
    if errors:
        print(f"  ⚠  Terminé avec erreurs sur : {', '.join(errors)}")
    else:
        print("  ✔  Tous les rapports générés avec succès")
    print(f"  Durée totale : {elapsed_total}s")
    print(f"  Rapports dans : {OUTPUT_DIR}")
    print("=" * 60 + "\n")

    logger.info("=== FIN | %d tables | %d erreurs | %.2fs ===",
                len(TABLE_CONFIG), len(errors), elapsed_total)