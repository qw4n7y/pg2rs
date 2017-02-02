class ImportStarterJob < ApplicationJob
  def perform
    Imports::Import.active.each do |import|
      Import::ServiceIgnitor.new(import: import).do_transfer_if_scheduled
    end
  end
end
