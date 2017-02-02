class Import::DoTableTransfer

  def initialize(table_transfer:)
    @table_transfer = table_transfer
  end

  # Dumping data from Postgres as CSV, packing into chunk files,
  # archiving and uploading to AWS S3
  # Creating table-specific manifest.json
  # Copying data to AWS Redshift
  #
  def perform
    aws_s3_object_keys = []

    log "Preparing"
    @table_transfer.started!
    # Prepare the DB iterator
    data_iterator.prepare!
    aws_redshift.execute(@table_transfer.table.init_sql_script)

    chunk_number = 1
    while !data_iterator.finished?
      local_file_name = Import::Utility.local_file_name_for(table_transfer: @table_transfer, chunk_number: chunk_number)
      aws_s3_object_key = Import::Utility.aws_s3_object_key_for(table_transfer: @table_transfer, chunk_number: chunk_number)

      # Postgres --> Local FS
      log "[Chunk #{chunk_number}] Dumping CSV data from Postgres to #{local_file_name}"
      file = open(local_file_name, 'wb+')
      data_iterator.each_row_for_next_chunk do |row|
        file << row
      end
      file.close

      # Archive file, adding .gz extension to a file
      log "[Chunk #{chunk_number}] Archiving #{local_file_name}"
      success = system("gzip -f #{local_file_name}")
      raise "#{self.class}: #{local_file_name} could not be gziped" unless success
      local_file_name = "#{local_file_name}.gz"
      aws_s3_object_key = "#{aws_s3_object_key}.gz"

      # Local FS -> AWS S3
      log "[Chunk #{chunk_number}] Uploading #{local_file_name} to AWS S3 #{aws_s3_object_key}"
      aws_s3.upload_file(local_file_name: local_file_name, s3_object_key: aws_s3_object_key)

      # Remove from Local FS
      log "[Chunk #{chunk_number}] Removing #{local_file_name}"
      success = system("rm -f #{local_file_name}")
      raise "#{self.class}: #{local_file_name} could not be removed" unless success

      aws_s3_object_keys << aws_s3_object_key

      log "[Chunk #{chunk_number}] OK"
      chunk_number += 1
    end

    # Creating table manifest json in AWS S3
    log "Creating manifest json and uploading to S3"
    manifest_file_content = {
      entries: aws_s3_object_keys.map do |aws_s3_object_key|
        {
          url: "s3://#{@table_transfer.transfer.import.s3['bucket']}/#{aws_s3_object_key}",
          mandatory: true
        }
      end
    }.to_json
    manifest_file_s3_object_key = "#{Import::Utility.aws_object_prefix_for(transfer: @table_transfer.transfer)}/#{@table_transfer.table.name}.json"
    aws_s3.create_object_from_string(s3_object_key: manifest_file_s3_object_key, content: manifest_file_content)

    # Copying data to AWS Redshift
    log "Copying data to AWS Redshift"
    aws_redshift.execute(
%Q{COPY #{@table_transfer.table.name}
FROM 's3://#{@table_transfer.transfer.import.s3['bucket']}/#{manifest_file_s3_object_key}'
CREDENTIALS 'aws_access_key_id=#{@table_transfer.transfer.import.s3['access_key_id']};aws_secret_access_key=#{@table_transfer.transfer.import.s3['secret_access_key']}'
CSV MANIFEST GZIP DELIMITER ',';})
    aws_redshift.execute("VACUUM;")
    aws_redshift.execute("ANALYZE;")

    log "Cleaning up"
    data_iterator.cleanup!

    @table_transfer.update_attributes!(finished_at: Time.now)
    @table_transfer.finished!

    return aws_s3_object_keys
  rescue Exception => e
    @table_transfer.failed!
    raise e
  end

  private

  def log(msg)
    @table_transfer.transfer.append_log("[Table #{@table_transfer.table.name}] #{msg}")
  end

  def aws_s3
    @aws_s3 ||= Connections::AwsS3.new(options: @table_transfer.transfer.import.s3)
  end

  def aws_redshift
    @aws_redshift ||= Connections::AwsRedshift.new(options: @table_transfer.transfer.import.redshift)
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
