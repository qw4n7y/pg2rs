class Connections::Postgres
  attr_accessor :pg

  def initialize(options:)
    @options = options
    @pg = get_connection_from_the_pool
  end

  # Executes SQL and returns result as an array of arrays
  #
  def execute(sql)
    pg_result = @pg.exec(sql)
    pg_result.values
  end

  # Run "COPY TO STDOUT" sql and yield each row
  #
  def copy(sql)
    @pg.copy_data(sql) do
      while row = @pg.get_copy_data
        yield row
      end
    end
  end

  private

  def get_connection_from_the_pool
    @_get_connection_from_the_pool ||= begin
      PG::Connection.new({
          host: @options['host'],
          port: @options['port'] || 5432,
          dbname: @options['name'],
          user: @options['user'],
          password: @options['password'],
          connect_timeout: nil
        })
    end
  end

end
