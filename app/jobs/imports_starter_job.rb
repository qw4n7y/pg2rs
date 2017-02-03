class ImportsStarterJob < ApplicationJob
  def perform
    Imports::Import.active.each do |import|
      ImportStarterJob.perform_later import
    end
  end
end
