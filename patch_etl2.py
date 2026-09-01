content = open('clickhouse/etl_pg_to_clickhouse.py', 'r', encoding='utf-8').read()
content = content.replace("'FACT_COMPTE_GELE': (\"public_datamart2\", \"bts_datamart1\")", "'fact_compte_gele': (\"public_datamart2\", \"bts_datamart1\")")
open('clickhouse/etl_pg_to_clickhouse.py', 'w', encoding='utf-8').write(content)
print('Patched')
