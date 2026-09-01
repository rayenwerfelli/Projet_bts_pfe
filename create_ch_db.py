import clickhouse_connect
client = clickhouse_connect.get_client(host='localhost', port=8123, user='admin', password='admin123')
client.command('CREATE DATABASE IF NOT EXISTS bts_datamart1')
print('bts_datamart1 created')
