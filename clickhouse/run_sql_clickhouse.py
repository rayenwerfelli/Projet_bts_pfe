"""
run_init_clickhouse.py
======================
Exécute le fichier SQL d'initialisation des tables ClickHouse
"""

import clickhouse_connect
import os
import re

# Connexion ClickHouse
client = clickhouse_connect.get_client(
    host=os.getenv("CLICKHOUSE_HOST", "localhost"),
    port=int(os.getenv("CLICKHOUSE_PORT", "8123")),
    username=os.getenv("CLICKHOUSE_USER", "admin"),
    password=os.getenv("CLICKHOUSE_PASSWORD", "admin123"),
)

# Chemin fichier SQL
base_dir = os.path.dirname(__file__)
sql_path = os.path.join(base_dir, "init", "01_create_dimensions.sql")

# Lire fichier
with open(sql_path, "r", encoding="utf-8") as f:
    sql = f.read()

# ✅ Supprimer les commentaires -- et /* */
sql = re.sub(r'--[^\n]*', '', sql)
sql = re.sub(r'/\*.*?\*/', '', sql, flags=re.DOTALL)

# ✅ Séparer les requêtes correctement
queries = [q.strip() for q in sql.split(";") if q.strip()]

print(f"▶ {len(queries)} requêtes à exécuter")

# Exécution avec gestion d'erreur
errors = []
for i, q in enumerate(queries, 1):
    try:
        print(f"[{i}/{len(queries)}] {q[:80]}...")
        client.command(q)
        print(f"  ✅ OK")
    except Exception as e:
        print(f"  ❌ Erreur : {e}")
        errors.append({"query": q[:80], "error": str(e)})

# Résumé
print(f"\n{'='*50}")
print(f"✅ Succès : {len(queries) - len(errors)}/{len(queries)}")
if errors:
    print(f"❌ Erreurs : {len(errors)}")
    for err in errors:
        print(f"  → {err['query']}")
        print(f"    {err['error']}")
else:
    print("🎉 Toutes les tables créées avec succès !")