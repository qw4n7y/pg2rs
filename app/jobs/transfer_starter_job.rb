class TransferStarterJob < ApplicationJob
  def perform(transfer)
    Import::DoTransfer.new(transfer: transfer).perform
  end
end
