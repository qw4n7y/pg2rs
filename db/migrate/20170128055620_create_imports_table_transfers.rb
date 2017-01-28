class CreateImportsTableTransfers < ActiveRecord::Migration[5.0]
  def change
    create_table :imports_table_transfers do |t|
      t.references :transfer, null: false
      t.references :table, null: false

      t.text :log
      t.integer :status, null: false
      t.timestamp :finished_at

      t.timestamps
    end
  end
end
