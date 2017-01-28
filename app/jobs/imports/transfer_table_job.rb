class Imports::TransferTableJob < ApplicationJob
  queue_as :default

  def perform(table_transfer)
    table_transfer.update_attributes!(status: 'in_progress')

    prepare_data
    import_data

    table_transfer.update_attributes!(status: 'sucess')
  rescue Exception => e
    table_transfer.update_attributes!(status: 'failed')
    table_transfer.append_log(e.message)
    raise e
  end

  private

  def prepare_data
  end

  def import_data
  end
end
