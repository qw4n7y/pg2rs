class CreateExports < ActiveRecord::Migration[5.0]
  def change
    create_table :exports do |t|
      t.references :import

      t.integer :status, null: false
      t.text :log

      t.timestamp :finished_at
      t.timestamps
    end
  end
end
