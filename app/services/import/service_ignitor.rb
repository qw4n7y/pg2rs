class Import::ServiceIgnitor

  def initialize(import:)
    @import = import
  end

  # if import is about to start then run it
  #
  def do_transfer_if_scheduled
    @transfer = create_transfer
    Import::DoTransfer.new(transfer: @transfer).perform
  end

  private

  # starts new transfer
  #
  def create_transfer
    tables_to_transfer = @import.tables

    transfer = @import.transfers.build(status: 'pending')
    tables_to_transfer.each do |table|
      transfer.table_transfers.build(status: 'pending', table: table)
    end
    transfer.save!

    transfer
  end

end
