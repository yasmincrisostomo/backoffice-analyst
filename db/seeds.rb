require 'smarter_csv'

SmarterCSV.process('db/csv/clientes.csv', col_sep: ',') do |row|
  Cliente.create(row)
end

SmarterCSV.process('db/csv/statuses.csv', col_sep: ',') do |row|
  status = Status.new(row.first)
  status.cliente = Cliente.find_by(user_id: row.first[:user_id])
  status.save!
end
