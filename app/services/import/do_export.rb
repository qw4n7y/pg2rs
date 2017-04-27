class Import::DoExport

  def initialize(export:)
    @export = export
    @import = @export.import
  end

  def perform
    log 'Starting'
    @export.started!
    @export.update_attributes!(created_at: Time.now)
    prepare

    @export.table_exports.each do |table_export|
      table_name = table_export.table.name

      log "[Table #{table_name}] Starting"
      table_export.started!

      # RS -> S3
      aws_s3_object_key = Import::Utility.aws_s3_object_key_for(table_export: table_export, chunk_number: 1)
      sql = %Q{UNLOAD ('SELECT * FROM #{table_name}')
        TO 's3://#{@import.s3['bucket']}/#{aws_s3_object_key}'
        MANIFEST ALLOWOVERWRITE DELIMITER ','
        access_key_id '#{@import.s3['access_key_id']}'
        secret_access_key '#{@import.s3['secret_access_key']}'}.squish
      redshift.execute(sql)

      # S3 -> FS

      # FS -> PG
    end

    log "Cleaning up"
    cleanup

    log "Finishing"
    @export.update_attributes!(finished_at: Time.now)
    @export.finished! unless @export.table_exports.any?(&:failed?)

    log "OK"
  rescue Exception => e
    log "#{e.class}: #{e.message}"
    log e.backtrace
    raise e
  end

  private

  def log(msg)
    @export.append_log("[Export] #{msg}")
  end

  def s3
    @s3 ||= Connections::AwsS3.new(options: @import.s3)
  end

  def redshift
    @redshift ||= Connections::AwsRedshift.new(options: @import.redshift)
  end

  def postgres
    @postgres ||= Connections::Postgres.new(options: @import.postgres_to_export_to)
  end

  def prepare
    # Creating local FS working dir
    local_base_dir = Import::Utility.local_base_dir_for(export: @export)
    ok = system("mkdir -p #{local_base_dir}")
    raise "#{self.class}: #{local_base_dir} dir could not be created" unless ok
  end

  def cleanup
    # Removing local FS working dir
    local_base_dir = Import::Utility.local_base_dir_for(export: @export)
    ok = system("rm -rf #{local_base_dir}")
    raise "#{self.class}: #{local_base_dir} dir could not be removed" unless ok
  end

end
