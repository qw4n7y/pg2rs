class CreateImportsImports < ActiveRecord::Migration[5.0]
  def change
    create_table :imports_imports do |t|
      t.string :title
      t.json :redshift, default: '{}', null: false
      t.json :postgres, default: '{}', null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
