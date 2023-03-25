class CreateClientes < ActiveRecord::Migration[7.0]
  def change
    create_table :clientes do |t|
      t.integer :user_id
      t.string :cnpj
      t.string :nome_do_cliente

      t.timestamps
    end
  end
end
