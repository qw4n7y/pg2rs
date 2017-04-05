class AddSelectSqlToImportsTables < ActiveRecord::Migration[5.0]
  def change
    add_column :imports_tables, :select_sql, :string, null: true, default: nil
  end
end
