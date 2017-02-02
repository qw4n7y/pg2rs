class AddInitScriptToTableTransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :imports_tables, :init_sql_script, :text
  end
end
