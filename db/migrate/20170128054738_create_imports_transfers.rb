class CreateImportsTransfers < ActiveRecord::Migration[5.0]
  def change
    create_table :imports_transfers do |t|

      t.integer :status, null: false
      t.timestamp :finished_at
      t.references :import

      t.timestamps
    end
  end
end
