import argparse
from datetime import date, datetime
from decimal import Decimal
import logging
import os
import sys

import clickhouse_connect
import psycopg2
import psycopg2.extras

PG_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "dbname": os.getenv("DB_NAME", "Projet_bts"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASS", "admin123"),
    "port": int(os.getenv("DB_PORT", "5432")),
}

CH_CONFIG = {
    "host": os.getenv("CLICKHOUSE_HOST", "localhost"),
    "port": int(os.getenv("CLICKHOUSE_PORT", "8123")),
    "username": os.getenv("CLICKHOUSE_USER", "admin"),
    "password": os.getenv("CLICKHOUSE_PASSWORD", "admin123"),
    "database": "default",
}

# Search all active datamart schemas in priority order
PG_SCHEMAS = [
    "public_datamart1",
    "public_datamart2",
    "public_datamart3",
    "public_intermediate",
    "public_staging",
    "public",
]
CH_DATABASE = "bts_datamart1"

BATCH_SIZE = 5000

DATE_BOUNDS = {
    "Date": (date(1970, 1, 1), date(2149, 6, 6)),
    "Date32": (date(1900, 1, 1), date(2299, 12, 31)),
}
MAX_DATETIME = datetime(2099, 12, 31, 23, 59, 59)
MIN_DATETIME = datetime(1970, 1, 1, 0, 0, 0)

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


def cap_datetime(val, base_type=None):
    if val is None:
        return None

    if isinstance(val, datetime):
        if val.tzinfo is not None:
            val = val.replace(tzinfo=None)
        if val > MAX_DATETIME:
            return MAX_DATETIME
        if val < MIN_DATETIME:
            return MIN_DATETIME
        return val

    if isinstance(val, date):
        min_d, max_d = DATE_BOUNDS.get(base_type, DATE_BOUNDS["Date"])
        if val > max_d:
            return max_d
        if val < min_d:
            return min_d
        return val

    return val


def find_pg_table_schema(table: str):
    sql = """
        SELECT table_schema
        FROM information_schema.tables
        WHERE LOWER(table_name) = LOWER(%s)
          AND table_schema = ANY(%s)
        LIMIT 1
    """
    with get_pg_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, (table, PG_SCHEMAS))
            row = cur.fetchone()
            if row:
                return row[0]
    return None


def get_pg_columns(schema: str, table: str):
    sql = """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = %s
          AND LOWER(table_name) = LOWER(%s)
        ORDER BY ordinal_position
    """
    with get_pg_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, (schema, table))
            rows = cur.fetchall()

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
    return {name: col_type for name, col_type in result.result_rows}


def get_ch_tables(database: str):
    ch = get_ch_client()
    result = ch.query(
        "SELECT name FROM system.tables WHERE database = {db:String}",
        parameters={"db": database},
    )
    return [r[0] for r in result.result_rows]


def normalize_ch_type(ch_type: str):
    if ch_type.startswith("Nullable(") and ch_type.endswith(")"):
        return True, ch_type[len("Nullable(") : -1]
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
            return cap_datetime(val.date(), base_type)
        return cap_datetime(val, base_type)

    if "DateTime" in base_type:
        if isinstance(val, date) and not isinstance(val, datetime):
            val = datetime(val.year, val.month, val.day)
        return cap_datetime(val, base_type)

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


def fetch_pg_batches(
    schema: str, table: str, ch_columns: dict, batch_size: int = 5000
):
    pg_columns = get_pg_columns(schema, table)
    common_columns = [col for col in pg_columns if col in ch_columns]

    if not common_columns:
        log.warning("SKIP: Aucune colonne commune entre PG (%s.%s) et CH", schema, table)
        return

    select_cols = ", ".join(quote_ident(c) for c in common_columns)
    sql = f"SELECT {select_cols} FROM {quote_ident(schema)}.{quote_ident(table)}"

    conn = get_pg_conn()
    conn.autocommit = False
    cur_name = f"streamcur_{table.lower()}"

    with conn.cursor(
        name=cur_name, cursor_factory=psycopg2.extras.RealDictCursor
    ) as cur:
        cur.itersize = batch_size
        cur.execute(sql)

        while True:
            raw_rows = cur.fetchmany(batch_size)
            if not raw_rows:
                break

            batch = [
                [
                    sanitize_value(raw[col], ch_columns[col])
                    for col in common_columns
                ]
                for raw in raw_rows
            ]
            yield common_columns, batch

    conn.close()


def load_table(table: str, truncate: bool = True):
    schema = find_pg_table_schema(table)

    if not schema:
        log.warning("SKIP: '%s' introuvable dans PostgreSQL", table)
        return

    ch_columns = get_ch_columns(CH_DATABASE, table)
    if not ch_columns:
        log.warning("SKIP: '%s' introuvable dans ClickHouse", table)
        return

    log.info("Chargement %s.%s -> %s.%s", schema, table, CH_DATABASE, table)

    ch = get_ch_client()
    if truncate:
        try:
            ch.command(f"TRUNCATE TABLE {CH_DATABASE}.{table}")
        except Exception as e:
            log.warning("Truncate ignoré pour %s (moteur PostgreSQL direct): %s", table, str(e).splitlines()[0])

    total_inserted = 0
    try:
        for columns, batch in fetch_pg_batches(
            schema, table, ch_columns, batch_size=BATCH_SIZE
        ):
            if not batch:
                continue

            ch.insert(f"{CH_DATABASE}.{table}", batch, column_names=columns)
            total_inserted += len(batch)

        log.info("OK %s — %d lignes chargées", table, total_inserted)
    except Exception as e:
        log.warning("Insertion ignorée pour %s: %s", table, str(e).splitlines()[0])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--table", help="Specific table to load")
    parser.add_argument("--no-truncate", action="store_true")
    args = parser.parse_args()

    if args.table:
        tables = [args.table]
    else:
        tables = get_ch_tables(CH_DATABASE)
        log.info("Détection automatique de %d tables dans ClickHouse (%s)", len(tables), CH_DATABASE)

    for table in tables:
        load_table(table, truncate=not args.no_truncate)


if __name__ == "__main__":
    main()