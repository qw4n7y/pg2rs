class Import::PostgresDataIterator

  def initialize(postgres_options:, table_name:, strategy:, date_interval:, select_sql:)
    @postgres_options = postgres_options
    @table_name = table_name
    @strategy = strategy
    @date_interval = date_interval
    @select_sql = select_sql
  end

  # Prepare the data to be consumed, calculating total number of scope
  #
  def prepare!
    prepare_once
    @total_rows_number = postgres.execute("SELECT COUNT('id') FROM #{data_table_name} WHERE #{data_where_scope}")[0][0].to_i
    @iteration_number = 0
    @finished = false
    @prepared = true
  end

  # Returns is the any data or not
  #
  def any?
    raise "#{self.class}: instance not prepared before doing any move" unless @prepared

    @total_rows_number > 0
  end

  # Fetch the data and process it row by row
  #
  def each_row_for_next_chunk
    return nil if finished?
    raise "#{self.class}: instance not prepared before running the iteration" unless @prepared

    select_sql = @select_sql.present? ? @select_sql : '*'
    sql = "SELECT #{select_sql} FROM #{data_table_name} WHERE #{data_where_scope} ORDER BY id ASC LIMIT #{Import::CHUNK_ROWS_COUNT} OFFSET #{@iteration_number * Import::CHUNK_ROWS_COUNT}"
    pg_result = postgres.copy("COPY (#{sql}) TO STDOUT WITH CSV DELIMITER ','") do |row|
      yield row
    end

    @iteration_number += 1
    check_if_finished
  end

  def check_if_finished
    @finished = true if @iteration_number*Import::CHUNK_ROWS_COUNT > @total_rows_number
    @finished = true if !any?
  end

  # Cleanup: droping temporary tables (DATA LOSS!)
  #
  def cleanup!
    check_if_finished
    raise "#{self.class}: instance not prepared before doing any move" unless @prepared
    raise "#{self.class}: not all data was iterated over" unless @finished

    case @strategy
      when 'incremental'
        # notinh we need to do

      when 'rotate'
        postgres.execute("DROP TABLE #{@tmp_table_name}")

    end
  end


  def finished?
    @finished
  end

  private

  def prepare_once
    # so it could be run only once
    @_prepare_once ||= begin
      case @strategy
        when 'incremental'
          # no need to prepare

        when 'rotate'
          # creating a new empty table for data
          old_table_name = @table_name
          @tmp_table_name = "#{@table_name}_tmp"
          new_table_name = "#{@table_name}_new"

          postgres.execute("CREATE TABLE #{new_table_name} (LIKE #{old_table_name} INCLUDING ALL);")
          postgres.execute("ALTER TABLE #{old_table_name} RENAME TO #{@tmp_table_name};")
          postgres.execute("ALTER TABLE #{new_table_name} RENAME TO #{old_table_name};")
      end

      true
    end
  end

  def data_table_name
    prepare_once

    case @strategy
      when 'incremental'
        @table_name
      when 'rotate'
        @tmp_table_name
    end
  end

  def data_where_scope
    case @strategy
      when 'incremental'
        sql = '(1 = 1)'
        if @date_interval
          sql  = %Q{
            (
              (created_at >= '#{@date_interval.first}' AND created_at < '#{@date_interval.last}')
              OR
              (updated_at >= '#{@date_interval.first}' AND updated_at < '#{@date_interval.last}')
            )
          }.gsub(/[ ]{2,}/, ' ')
        end
        sql

      when 'rotate'
        '(1 = 1)'
    end
  end

  # Keeps a connection to PG
  def postgres
    @postgres ||= Connections::Postgres.new(options: @postgres_options)
  end

end
