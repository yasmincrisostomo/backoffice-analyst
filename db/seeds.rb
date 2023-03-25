require 'csv'

CSV.foreach('db/csv/clientes.csv', headers: true) do |row|
  Cliente.create(user_id: row['user_id'], cnpj: row['cnpj'], nome_do_cliente: row['nome_do_cliente'])
end

CSV.foreach('db/csv/statuses.csv', headers: true) do |row|
  Status.create(user_id: row['user_id'], status: row['status'], data_horario_do_status: row['data_horario_do_status'])
end
