import clickhouse_connect
client = clickhouse_connect.get_client(host='localhost', port=8123, user='admin', password='admin123')
result = client.query('SHOW DATABASES')
for row in result.result_rows: print(row[0])
