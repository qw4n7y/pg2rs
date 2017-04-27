class DoExportJob < ApplicationJob
  def perform(export)
    Import::DoExport.new(export: export).perform
  end
end
