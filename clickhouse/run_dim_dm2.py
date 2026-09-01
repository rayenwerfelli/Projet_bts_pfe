import clickhouse_connect
import os

client = clickhouse_connect.get_client(
    host=os.getenv("CLICKHOUSE_HOST", "localhost"),
    port=int(os.getenv("CLICKHOUSE_PORT", "8123")),
    username=os.getenv("CLICKHOUSE_USER", "admin"),
    password=os.getenv("CLICKHOUSE_PASSWORD", "admin123"),
    database="bts_datamart2"
)

base_dir = os.path.dirname(__file__)
sql_path = os.path.join(base_dir, "init", "01_create_dimensions_datamart2.sql")

with open(sql_path, "r", encoding="utf-8") as f:
    sql = f.read()

queries = [q.strip() for q in sql.split(";") if q.strip()]

for q in queries:
    try:
        print(f"▶ Exécution : {q[:60]}...")
        client.command(q)
    except Exception as e:
        print(f"❌ Erreur sur requête : {q[:80]}")
        print(e)

print("✅ Dimensions bts_datamart2 traitées")