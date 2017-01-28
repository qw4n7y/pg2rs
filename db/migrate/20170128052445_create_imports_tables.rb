class CreateImportsTables < ActiveRecord::Migration[5.0]
  def change
    create_table :imports_tables do |t|
      t.references :import

      t.string :name
      t.integer :strategy, null: false

      t.timestamps
    end
  end
end
