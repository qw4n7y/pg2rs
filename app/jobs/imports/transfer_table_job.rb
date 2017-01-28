require 'net/ssh'

class Imports::TransferTableJob < ApplicationJob
  queue_as :default

  def perform(table_transfer)
    @table_transfer = table_transfer

    setup
    transfer
  end

  private

  # Returns connection to Postgres DB
  #
  def pg
    @pg ||= begin
      opts = @table_transfer.transfer.import.postgres

      PG::Connection.new({
          host: opts['host'],
          port: opts['db']['port'] || 5432,
          dbname: opts['db']['name'],
          user: opts['db']['user'],
          password: opts['db']['password'],
          connect_timeout: nil
        })
    end
  end

  # Yielding the SSH session to PG server
  #
  def ssh(cmd)
    opts = @table_transfer.transfer.import.postgres

    settings = { key_data: [ opts['ssh']['private_key'] ].compact,
                 port: opts['ssh']['port'] || 22,
                 passphrase: opts['ssh']['passphrase'],
                 password: opts['ssh']['password']
               }.delete_if { |k, v| v.blank? }

    stdout_data = ""
    stderr_data = ""
    exit_code = nil
    exit_signal = nil

    Net::SSH.start(opts['host'], opts['ssh']['user'], settings) do |session|
      session.open_channel do |channel|
        channel.exec(cmd) do |ch, success|
          abort "FAILED: couldn't execute command (session.channel.exec)" unless success
          channel.on_data { |ch, data| stdout_data += data }
          channel.on_extended_data { |ch, type, data| stderr_data += data }
          channel.on_request("exit-status") { |ch, data| exit_code = data.read_long }
          channel.on_request("exit-signal") { |ch, data| exit_signal = data.read_long }
        end
      end
      session.loop
      [stdout_data, stderr_data, exit_code, exit_signal]
    end
  end

  def setup
    # Get previous table transfer
    @previous_table_transfer = @table_transfer.table.table_transfers.success.
                                 where('created_at < ?', @table_transfer.created_at).
                                 order('created_at DESC').first

    # Set tmp file name for data to transfer
    @tmp_file = "/tmp/transfer-#{@table_transfer.table.name}-#{@table_transfer.id}.csv"
  end

  def transfer
    @table_transfer.update_attributes!(status: 'in_progress')

    import_data_to_csv
    @table_transfer.append_log('Data was imported to CSV successfully')

    archive_data
    @table_transfer.append_log('Data was archived')

    export_data_to_redshift
    @table_transfer.append_log('Data was exported to RedShift')

    clean_up
    @table_transfer.append_log('Cleaned up')

    @table_transfer.update_attributes!(status: 'success')
  rescue Exception => e
    @table_transfer.update_attributes!(status: 'failed')
    @table_transfer.append_log(e.message)
    @table_transfer.append_log(e.backtrace)

    raise e
  end

  def import_data_to_csv
    case @table_transfer.table.strategy
    when 'incremental'
      unless @previous_table_transfer
        pg.exec("COPY (SELECT * FROM #{@table_transfer.table.name}) TO '#{@tmp_file}' WITH CSV DELIMITER ',';")
      else
        pg.exec("COPY (SELECT * FROM #{@table_transfer.table.name} WHERE created_at >= '#{@previous_table_transfer.created_at}' AND created_at < '#{@table_transfer.created_at}') TO '#{@tmp_file}' WITH CSV DELIMITER ',';")
      end
    when 'rotate'
      old_table_name = @table_transfer.table.name
      @tmp_table_name = "#{@table_transfer.table.name}_tmp"
      new_table_name = "#{@table_transfer.table.name}_new"

      pg.exec("CREATE TABLE #{new_table_name} (LIKE #{old_table_name} INCLUDING ALL);")
      pg.exec("ALTER TABLE #{old_table_name} RENAME TO #{@tmp_table_name};")
      pg.exec("ALTER TABLE #{new_table_name} RENAME TO #{old_table_name};")

      pg.exec("COPY (SELECT * FROM #{@tmp_table_name}) TO '#{@tmp_file}' WITH CSV DELIMITER ',';")
    end
  end

  def archive_data
    _, stderr_data, _, _ = ssh("gzip #{@tmp_file}")
    raise stderr_data unless stderr_data.blank?
    @tmp_file = "#{@tmp_file}.gz" # adding .gz extension to a file
  end

  def export_data_to_redshift
    # create_a_manifest_file
    # upload_manifest_to_s3
    # copy_to_redshift
  end

  def clean_up
    ssh("rm -f #{@tmp_file}")
    pg.exec("DROP TABLE #{@tmp_table_name};") if @tmp_table_name
  end
end
