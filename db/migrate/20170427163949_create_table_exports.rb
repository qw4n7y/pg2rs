class CreateTableExports < ActiveRecord::Migration[5.0]
  def change
    create_table :table_exports do |t|
      t.references :export, null: false
      t.references :table, null: false

      t.integer :status, null: false
      t.timestamp :finished_at

      t.timestamps
    end
  end
end
