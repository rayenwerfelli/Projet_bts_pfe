import psycopg2
conn = psycopg2.connect(host='localhost', port=5432, dbname='Projet_bts', user='postgres', password='admin123')
cur = conn.cursor()
cur.execute('SELECT schema_name FROM information_schema.schemata ORDER BY schema_name')
for row in cur.fetchall(): print(row[0])
conn.close()
