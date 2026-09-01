import psycopg2
import clickhouse_connect

PG = dict(host='localhost', dbname='Projet_bts', user='postgres', password='admin123', port=5432)
CH = dict(host='localhost', port=8123, username='admin', password='admin123')

TABLES = {
    'fact_demande_financement': 'public_datamart1',
    'fact_recouvrement_client': 'public_datamart1',
    'fact_recouvrement_zac':    'public_datamart1',
    'fact_recouvrement_gov':    'public_datamart1',
    'mart_demande_financement': 'public_datamart1',
    'mart_recouvrement_client': 'public_datamart1',
    'mart_recouvrement_zac':    'public_datamart1',
    'mart_recouvrement_gov':    'public_datamart1',
    'mart_recouvrement':        'public_datamart3',
    'mart_req4_ouverture_comptes': 'public_datamart2',
    'FACT_COMPTE_GELE':         'public_datamart2',
}

PG_TO_CH = {
    'integer': 'Nullable(Int64)',
    'bigint': 'Nullable(Int64)',
    'smallint': 'Nullable(Int32)',
    'numeric': 'Nullable(Float64)',
    'double precision': 'Nullable(Float64)',
    'real': 'Nullable(Float64)',
    'boolean': 'Nullable(UInt8)',
    'text': 'Nullable(String)',
    'varchar': 'Nullable(String)',
    'character varying': 'Nullable(String)',
    'char': 'Nullable(String)',
    'date': 'Nullable(Date)',
    'timestamp without time zone': 'Nullable(DateTime)',
    'timestamp with time zone': 'Nullable(DateTime)',
    'uuid': 'Nullable(String)',
}

def pg_to_ch_type(pg_type):
    return PG_TO_CH.get(pg_type.lower(), 'Nullable(String)')

conn = psycopg2.connect(**PG)
cur = conn.cursor()
ch = clickhouse_connect.get_client(**CH)

for table, schema in TABLES.items():
    cur.execute('''
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = %s AND table_name = %s
        ORDER BY ordinal_position
    ''', (schema, table.lower()))
    cols = cur.fetchall()
    if not cols:
        print(f'SKIP {table} - not found in PG schema {schema}')
        continue
    col_defs = ',\n  '.join(f'{c} {pg_to_ch_type(t)}' for c, t in cols)
    ddl = f'CREATE TABLE IF NOT EXISTS bts_datamart1.{table} ({col_defs}) ENGINE = MergeTree() ORDER BY tuple()'
    ch.command(ddl)
    print(f'OK {table}')

conn.close()
print('All tables created')
