class Import::DoMigration

  def initialize(migration:)
    @migration = migration
  end

  def perform
    @migration.started!

    @migration.sql.split( /\r?\n/ ).each do |sql_line|
      log("[SQL] #{sql_line}")
      result = aws_redshift.execute(sql_line)
      log("[OUTPUT] #{result}")
    end

    @migration.finished!
  rescue Exception => e
    log("[ERROR] #{e.message}")
    @migration.failed!
    raise e
  end

  private

  def log(msg)
    @migration.append_log(msg)
  end

  def aws_redshift
    @aws_redshift ||= Connections::AwsRedshift.new(options: @migration.import.redshift)
  end

end
