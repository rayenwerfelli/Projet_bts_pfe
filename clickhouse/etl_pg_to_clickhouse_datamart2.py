import sys
import os
import logging
import argparse
from datetime import datetime, date
from decimal import Decimal

import psycopg2
import psycopg2.extras
import clickhouse_connect


PG_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "dbname": os.getenv("DB_NAME", "Projet_bts"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASS", ""),
    "port": int(os.getenv("DB_PORT", "5432")),
}

CH_CONFIG = {
    "host": os.getenv("CLICKHOUSE_HOST", "localhost"),
    "port": int(os.getenv("CLICKHOUSE_PORT", "8123")),
    "username": os.getenv("CLICKHOUSE_USER", "admin"),
    "password": os.getenv("CLICKHOUSE_PASSWORD", "admin123"),
    "database": "default",
}

PG_SCHEMA = "bts_datamart2"
CH_DATABASE = "bts_datamart2"

TABLES = [
    "fact_ouverture_compte",
    "mart_req4_ouverture_comptes",
]

BATCH_SIZE = 5000

# ── Plafonds ClickHouse Date32 (supporte 1900-01-01 à 2299-12-31) ──
# Les snapshots dbt utilisent 9999-12-31 comme sentinelle, et certaines
# dates de naissance sont antérieures à 1970 → on plafonne des deux côtés.
MAX_DATE     = date(2299, 12, 31)
MIN_DATE     = date(1900, 1, 1)
MAX_DATETIME = datetime(2299, 12, 31, 23, 59, 59)
MIN_DATETIME = datetime(1900, 1, 1, 0, 0, 0)


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-8s | %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)

log = logging.getLogger(__name__)


def get_pg_conn():
    return psycopg2.connect(**PG_CONFIG)


def get_ch_client():
    return clickhouse_connect.get_client(**CH_CONFIG)


def quote_ident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def cap_datetime(val):
    """
    Plafonne les dates/datetimes hors limites (Date32: 1900-2299).
    Les snapshots dbt utilisent 9999-12-31 comme sentinelle → plafonné à 2299-12-31.
    Les dates de naissance antérieures à 1900 → plafonnées à 1900-01-01.
    """
    if val is None:
        return None
    if isinstance(val, datetime):
        if val.year > 2299:
            return MAX_DATETIME
        if val.year < 1900:
            return MIN_DATETIME
        return val
    if isinstance(val, date):
        if val.year > 2299:
            return MAX_DATE
        if val.year < 1900:
            return MIN_DATE
        return val
    return val


def get_pg_columns(schema: str, table: str):
    sql = """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = %s
          AND table_name = %s
        ORDER BY ordinal_position
    """
    with get_pg_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, (schema, table))
            rows = cur.fetchall()

    if not rows:
        raise ValueError(f"Table PostgreSQL introuvable: {schema}.{table}")

    return [r[0] for r in rows]


def get_ch_columns(database: str, table: str):
    ch = get_ch_client()
    result = ch.query(
        """
        SELECT name, type
        FROM system.columns
        WHERE database = {db:String}
          AND table = {table:String}
        ORDER BY position
        """,
        parameters={"db": database, "table": table},
    )

    cols = {name: col_type for name, col_type in result.result_rows}

    if not cols:
        raise ValueError(f"Table ClickHouse introuvable: {database}.{table}")

    return cols


def normalize_ch_type(ch_type: str):
    if ch_type.startswith("Nullable(") and ch_type.endswith(")"):
        return True, ch_type[len("Nullable("):-1]
    return False, ch_type


def sanitize_value(val, ch_type: str):
    nullable, base_type = normalize_ch_type(ch_type)

    if val is None:
        if nullable:
            return None
        if "String" in base_type:
            return ""
        if "Int" in base_type:
            return 0
        if "Float" in base_type:
            return 0.0
        if "Decimal" in base_type:
            return Decimal("0")
        if base_type in ("Date", "Date32"):
            return date(1970, 1, 1)
        if "DateTime" in base_type:
            return MIN_DATETIME
        return None

    if "String" in base_type:
        return str(val)

    if base_type in ("Date", "Date32"):
        if isinstance(val, datetime):
            return cap_datetime(val.date())
        return cap_datetime(val)

    if "DateTime" in base_type:
        if isinstance(val, date) and not isinstance(val, datetime):
            val = datetime(val.year, val.month, val.day)
        return cap_datetime(val)

    if "Int" in base_type:
        try:
            return int(val)
        except Exception:
            return None if nullable else 0

    if "Float" in base_type:
        try:
            return float(val)
        except Exception:
            return None if nullable else 0.0

    if "Decimal" in base_type:
        try:
            return Decimal(str(val))
        except Exception:
            return None if nullable else Decimal("0")

    return val


def fetch_pg_rows(schema: str, table: str, ch_columns: dict):
    pg_columns = get_pg_columns(schema, table)
    common_columns = [col for col in pg_columns if col in ch_columns]

    if not common_columns:
        raise ValueError(f"Aucune colonne commune pour {schema}.{table}")

    select_cols = ", ".join(quote_ident(c) for c in common_columns)

    sql = f"""
        SELECT {select_cols}
        FROM {quote_ident(schema)}.{quote_ident(table)}
    """

    with get_pg_conn() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql)
            raw_rows = cur.fetchall()

    rows = [
        [sanitize_value(raw[col], ch_columns[col]) for col in common_columns]
        for raw in raw_rows
    ]

    return common_columns, rows


def load_table(table: str, truncate: bool = True):
    log.info("Chargement %s.%s -> %s.%s", PG_SCHEMA, table, CH_DATABASE, table)

    ch = get_ch_client()
    ch_columns = get_ch_columns(CH_DATABASE, table)
    columns, rows = fetch_pg_rows(PG_SCHEMA, table, ch_columns)

    if truncate:
        ch.command(f"TRUNCATE TABLE {CH_DATABASE}.{table}")

    if rows:
        total = len(rows)
        for i in range(0, total, BATCH_SIZE):
            batch = rows[i: i + BATCH_SIZE]
            ch.insert(f"{CH_DATABASE}.{table}", batch, column_names=columns)
            log.info("  batch %d/%d — %d lignes", i // BATCH_SIZE + 1,
                     -(-total // BATCH_SIZE), len(batch))
        log.info("OK: %d lignes insérées dans %s", total, table)
    else:
        log.warning("Aucune ligne pour %s", table)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--table", choices=TABLES)
    parser.add_argument("--no-truncate", action="store_true")
    args = parser.parse_args()

    tables = [args.table] if args.table else TABLES

    for table in tables:
        load_table(table, truncate=not args.no_truncate)


if __name__ == "__main__":
    main()