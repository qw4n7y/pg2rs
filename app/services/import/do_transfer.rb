#  Class for providing whole data flow process
#
class Import::DoTransfer

  def initialize(transfer:)
    @transfer = transfer
  end

  #  Performing the data flow
  #
  def perform
    log "Transfer started"

    log "Uploading data from Postgres to AWS S3"
    aws_s3_object_keys = []
    @transfer.table_transfers.each do |table_transfer|
      begin
        aws_s3_object_keys += Import::DumpTableAndUploadToS3.new(table_transfer: table_transfer).perform
        table_transfer.finished!
      rescue Exception => e
        table_transfer.failed!
        raise e
      end
    end

    log "Creating manifest.json file in AWS S3"
    manifest_file_content = {
      entries: aws_s3_object_keys.map do |aws_s3_object_key|
        {
          url: "s3://#{@transfer.import.s3['bucket']}/#{aws_s3_object_key}",
          mandatory: true
        }
      end
    }.to_json
    manifest_file_s3_object_key = "#{Import::Utility.aws_object_prefix_for(transfer: @transfer)}/manifest.json"
    aws_s3.create_object_from_string(s3_object_key: manifest_file_s3_object_key, content: manifest_file_content)

    log "Copying data from AWS S3 to Redshift"
    # TODO

    @transfer.update_attributes!(status: 'finished', finished_at: Time.now)
    log "Transfer finished"

  rescue Exception => e
    log "#{e.class}: #{e.message}"
    log e.backtrace
    raise e
  end

  private

  def log(message)
    @transfer.append_log(message)
  end

  def aws_s3
    @aws_s3 ||= Connections::AwsS3.new(options: @transfer.import.s3)
  end

end
