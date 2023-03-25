class CreateStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :statuses do |t|
      t.integer :user_id
      t.string :status
      t.datetime :data_horario_do_status

      t.timestamps
    end
  end
end
