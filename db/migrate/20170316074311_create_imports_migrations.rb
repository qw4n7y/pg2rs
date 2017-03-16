class CreateImportsMigrations < ActiveRecord::Migration[5.0]
  def change
    create_table :imports_migrations do |t|
      t.references :import, null: false
      t.text :sql
      t.text :log
      t.integer :status, null: false
      t.timestamps
    end
  end
end
