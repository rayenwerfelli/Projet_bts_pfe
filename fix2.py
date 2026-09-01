import psycopg2
import clickhouse_connect

PG = dict(host='localhost', dbname='Projet_bts', user='postgres', password='admin123', port=5432)
CH = dict(host='localhost', port=8123, username='admin', password='admin123')

PG_TO_CH = {
    'integer': 'Nullable(Int64)', 'bigint': 'Nullable(Int64)',
    'smallint': 'Nullable(Int32)', 'numeric': 'Nullable(Float64)',
    'double precision': 'Nullable(Float64)', 'real': 'Nullable(Float64)',
    'boolean': 'Nullable(UInt8)', 'text': 'Nullable(String)',
    'varchar': 'Nullable(String)', 'character varying': 'Nullable(String)',
    'char': 'Nullable(String)', 'date': 'Nullable(Date)',
    'timestamp without time zone': 'Nullable(DateTime)',
    'timestamp with time zone': 'Nullable(DateTime)', 'uuid': 'Nullable(String)',
}

conn = psycopg2.connect(**PG)
cur = conn.cursor()
ch = clickhouse_connect.get_client(**CH)

cur.execute('''
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'public_datamart2' AND table_name = 'FACT_COMPTE_GELE'
    ORDER BY ordinal_position
''')
cols = cur.fetchall()
print(f'Found {len(cols)} columns')
if cols:
    col_defs = ',\n  '.join(f'{c} {PG_TO_CH.get(t.lower(), "Nullable(String)")}' for c, t in cols)
    ddl = f'CREATE TABLE IF NOT EXISTS bts_datamart1.FACT_COMPTE_GELE ({col_defs}) ENGINE = MergeTree() ORDER BY tuple()'
    ch.command(ddl)
    print('Table created')
conn.close()
