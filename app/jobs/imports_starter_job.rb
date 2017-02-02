class ImportsStarterJob < ApplicationJob
  def perform
    Imports::Import.active.each do |import|
      TransferStarterJob.perform_later import
    end
  end
end
