class TransferStarterJob < ApplicationJob
  def perform(import)
    Import::ServiceIgnitor.new(import: import).do_transfer_if_scheduled
  end
end
