import os
import logging
import warnings
from pathlib import Path
import pandas as pd
import psycopg2
from sqlalchemy import create_engine
import openpyxl
import xlrd

try:
    from dotenv import load_dotenv
    # Load a .env file placed at the project root (one level above this script's folder)
    load_dotenv(Path(__file__).resolve().parent.parent / ".env")
except ImportError:
    pass  # python-dotenv is optional; env vars can still be set another way

# ==============================
# Chemins (relatifs au projet, plus de chemin Windows en dur)
# ==============================
BASE_DIR = Path(__file__).resolve().parent.parent
LOG_DIR = Path(os.getenv("LOG_DIR", BASE_DIR / "logs"))
DATA_PATH = Path(os.getenv("RAW_DATA_DIR", BASE_DIR / "data" / "raw"))
LOG_DIR.mkdir(parents=True, exist_ok=True)

# ==============================
# Logging
# ==============================
logging.basicConfig(
    filename=str(LOG_DIR / "load_ods.log"),
    level=logging.DEBUG,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
logger = logging.getLogger(__name__)

# Supprime les warnings OLE2 de la console et les redirige vers le log
logging.captureWarnings(True)
warnings.filterwarnings("ignore", message=".*OLE2 inconsistency.*")

# ==============================
# Connexion PostgreSQL (configurable via variables d'environnement / .env)
# ==============================
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "Projet_bts")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASS = os.getenv("DB_PASS", "")
DB_PORT = os.getenv("DB_PORT", "5432")

tables = [
    "DMG", "DMY", "DMX", "CLT", "UNT", "HMF", "NIS", "EMP",
    "HSF", "DMC", "ENG", "CPT", "PRJ", "ZAC", "GOV", "DLG", "LOC", "DMP", "EFF", "IMP",
    "AUT", "PTT", "ZCL", "ZGR", "ZDV", "ZSS", "ZSC", "IMQ", "NAT", "DAU", "DAP", "TRH", "EPS", "EXT", "LFN",
    "ADR", "TEL"
]

engine = create_engine(
    f"postgresql+psycopg2://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

conn = psycopg2.connect(
    host=DB_HOST,
    database=DB_NAME,
    user=DB_USER,
    password=DB_PASS,
    port=DB_PORT
)
cursor = conn.cursor()

# ==============================
# Utilitaires DB
# ==============================
def create_schema_if_not_exists():
    cursor.execute("CREATE SCHEMA IF NOT EXISTS ods")
    conn.commit()

def table_exists(table):
    query = """
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'ods'
          AND table_name = %s
    )
    """
    cursor.execute(query, (table,))
    return cursor.fetchone()[0]

def truncate_table(table):
    cursor.execute(f'TRUNCATE TABLE ods."{table}"')
    conn.commit()

# ==============================
# Conversion dates Excel
# ==============================
DATE_COLUMNS_BY_TABLE = {
    "CLT": [
        "DMJCLT", "DNACLT", "DERCLT", "DDCCLT", "EDCCLT",
        "DSTJCLT", "DJRTCLT", "DINCCLT", "DEXPCLT", "DDCECLT"
    ]
}

def excel_serial_to_datetime(value):
    if pd.isna(value):
        return None
    if isinstance(value, (pd.Timestamp,)):
        return value.to_pydatetime()
    s = str(value).strip()
    if s == "" or s.lower() in {"nan", "none", "nat"}:
        return None
    if s.isdigit():
        n = int(s)
        if 1 <= n <= 60000:
            dt = pd.to_datetime(n, unit="D", origin="1899-12-30", errors="coerce")
            return None if pd.isna(dt) else dt.to_pydatetime()
    dt = pd.to_datetime(s, errors="coerce", dayfirst=True)
    return None if pd.isna(dt) else dt.to_pydatetime()

def normalize_dataframe(df, table):
    for col in df.columns:
        if df[col].dtype == object:
            df[col] = df[col].apply(lambda x: x.strip() if isinstance(x, str) else x)
            df[col] = df[col].replace({"": None})
    for col in DATE_COLUMNS_BY_TABLE.get(table, []):
        if col in df.columns:
            df[col] = df[col].apply(excel_serial_to_datetime)
    return df

# ==============================
# Chargement d'une table
# ==============================
def load_table(table):
    file_path = os.path.join(DATA_PATH, f"{table}.xls")

    if not os.path.exists(file_path):
        logger.warning("Fichier non trouvé : %s", file_path)
        return

    logger.info("Lecture fichier : %s", table)

    try:
        df = pd.read_excel(file_path, engine="xlrd")
        df = normalize_dataframe(df, table)

        if table == "CLT":
            debug_cols = [c for c in DATE_COLUMNS_BY_TABLE["CLT"] if c in df.columns]
            logger.debug("Aperçu colonnes date CLT :\n%s", df[debug_cols].head(3).to_string())

        if not table_exists(table):
            logger.info("Table %s absente — CREATE", table)
            df.head(0).to_sql(table, engine, schema="ods", if_exists="replace", index=False)

        logger.info("Table %s — TRUNCATE + APPEND (%d lignes)", table, len(df))
        truncate_table(table)
        df.to_sql(table, engine, schema="ods", if_exists="append",
                  index=False, method="multi", chunksize=500)

        logger.info("Chargement terminé : %s", table)

    except Exception as e:
        logger.error("Erreur sur la table %s : %s", table, str(e), exc_info=True)
        raise

# ==============================
# Programme principal
# ==============================
def main():
    logger.info("=== Début chargement ODS ===")
    try:
        create_schema_if_not_exists()
        for table in tables:
            load_table(table)
        logger.info("=== Chargement ODS terminé avec succès ===")
    except Exception as e:
        logger.error("=== Chargement ODS échoué : %s ===", str(e), exc_info=True)
        raise

if __name__ == "__main__":
    main()