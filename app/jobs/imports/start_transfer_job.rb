class Imports::StartTransferJob < ApplicationJob
  queue_as :default

  def perform(import)
    @transfer = import.transfers.create!(status: 'pending')
    import.tables.each do |table|
      table_transfer = @transfer.table_transfers.create!(table: table, status: 'pending')
      Imports::TransferTableJob.perform_later table_transfer
    end
  end
end
