class Imports::StartTransferJob < ApplicationJob
  queue_as :default

  def perform(import)
    @transfer = import.transfers.create!(status: 'pending')
    import.tables.each do |table|
      table_transfer = @transfer.table_transfers.create!(table: table, status: 'pending')
    end
  end
end
