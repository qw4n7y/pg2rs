#  Class for providing whole data flow process
#
class Import::DoTransfer

  def initialize(transfer:)
    @transfer = transfer
  end

  #  Performing the data flow
  #
  def perform
    log "Starting"
    @transfer.started!

    log "Preparing"
    prepare

    log "Running"
    @transfer.table_transfers.each do |table_transfer|
      Import::DoTableTransfer.new(table_transfer: table_transfer).perform
      begin


        table_transfer.finished!
      rescue Exception => e
        table_transfer.failed!
        raise e
      end
    end

    log "Cleaning up"
    cleanup

    log "Finishing"
    @transfer.update_attributes!(status: 'finished', finished_at: Time.now)

    log "OK"

  rescue Exception => e
    log "#{e.class}: #{e.message}"
    log e.backtrace
    raise e
  end

  private

  def log(message)
    @transfer.append_log("[Transfer] #{message}")
  end

  def prepare
    # Creating local FS working dir
    local_base_dir = Import::Utility.local_base_dir_for(transfer: @transfer)
    ok = system("mkdir -p #{local_base_dir}")
    raise "#{self.class}: #{local_base_dir} dir could not be created" unless ok
  end

  def cleanup
    # Removing local FS working dir
    local_base_dir = Import::Utility.local_base_dir_for(transfer: @transfer)
    ok = system("rm -rf #{local_base_dir}")
    raise "#{self.class}: #{local_base_dir} dir could not be removed" unless ok
  end

end
