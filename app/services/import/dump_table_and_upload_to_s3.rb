class Import::DumpTableAndUploadToS3

  def initialize(table_transfer:)
    @table_transfer = table_transfer
  end

  # Dumping data from Postgres as CSV, packing into chunk files,
  # archiving and uploading to AWS S3
  # Returns the array of uploaded AWS S3 objects
  #
  def perform
    aws_s3_object_keys = []

    log "Preparing for transfering '#{@table_transfer.table.name}'"

    # Prepare the DB iterator
    data_iterator.prepare!

    # Prepare the LocalFS
    local_base_dir = Import::Utility.local_base_dir_for(transfer: @table_transfer.transfer)
    ok = system("mkdir -p #{local_base_dir}")
    raise "#{self.class}: #{local_base_dir} dir could not be created" unless ok

    chunk_number = 1
    while !data_iterator.finished?
      local_file_name = Import::Utility.local_file_name_for(table_transfer: @table_transfer, chunk_number: chunk_number)
      aws_s3_object_key = Import::Utility.aws_s3_object_key_for(table_transfer: @table_transfer, chunk_number: chunk_number)

      # Postgres --> LocalFS
      log "Dumping '#{@table_transfer.table.name}' part #{chunk_number} to #{local_file_name}"
      file = open(local_file_name, 'wb+')
      data_iterator.each_row_for_next_chunk do |row|
        file << row
      end
      file.close

      # Archive file, adding .gz extension to a file
      log "Archiving #{local_file_name}"
      success = system("gzip -f #{local_file_name}")
      raise "#{self.class}: #{local_file_name} could not be gziped" unless success
      local_file_name = "#{local_file_name}.gz"
      aws_s3_object_key = "#{aws_s3_object_key}.gz"

      # LocalFS -> AWS S3
      log "Uploading #{local_file_name} to AWS S3 #{aws_s3_object_key}"
      aws_s3.upload_file(local_file_name: local_file_name, s3_object_key: aws_s3_object_key)

      # Remove from LocalFS
      log "Removing #{local_file_name}"
      success = system("rm -f #{local_file_name}")
      raise "#{self.class}: #{local_file_name} could not be removed" unless success

      log "'#{@table_transfer.table.name}' part #{chunk_number} moved to AWS S3"
      aws_s3_object_keys << aws_s3_object_key
      chunk_number += 1
    end

    log "Cleaning up after transfering '#{@table_transfer.table.name}'"
    data_iterator.cleanup!

    local_base_dir = Import::Utility.local_base_dir_for(transfer: @table_transfer.transfer)
    ok = system("rm -rf #{local_base_dir}")
    raise "#{self.class}: #{local_base_dir} dir could not be removed" unless ok

    return aws_s3_object_keys
  rescue Exception => e
    @table_transfer.failed!
    raise e
  end

  private

  def log(msg)
    @table_transfer.transfer.append_log(msg)
  end

  def aws_s3
    @aws_s3 ||= Connections::AwsS3.new(options: @table_transfer.transfer.import.s3)
  end

  def data_iterator
    date_interval = nil
    if (@table_transfer.table.strategy == 'incremental') && previous_table_transfer
      date_interval = (previous_table_transfer.created_at..@table_transfer.created_at)
    end

    @data_iterator ||= Import::PostgresDataIterator.new({
                        postgres_options: @table_transfer.transfer.import.postgres,
                        table_name: @table_transfer.table.name,
                        strategy: @table_transfer.table.strategy,
                        date_interval: date_interval
                      })
  end

  # Finds the previous table transfer
  def previous_table_transfer
    @__previous_table_transfer ||= begin
      @table_transfer.table.table_transfers.finished.
           where('created_at < ?', @table_transfer.created_at).
           order('created_at DESC').first
    end
  end

end