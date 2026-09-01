import psycopg2
conn = psycopg2.connect(host='localhost', dbname='Projet_bts', user='postgres', password='admin123', port=5432)
cur = conn.cursor()
cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public_datamart2' ORDER BY table_name")
for row in cur.fetchall(): print(row[0])
conn.close()
