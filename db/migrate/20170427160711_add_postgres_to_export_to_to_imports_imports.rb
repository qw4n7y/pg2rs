class AddPostgresToExportToToImportsImports < ActiveRecord::Migration[5.0]
  def change
    add_column :imports_imports, :postgres_to_export_to, :json, default: '{}', null: false
  end
end
