require 'active_support/concern'

module LoggableConcern
  extend ActiveSupport::Concern

  def append_log(message)
    ActiveRecord::Base.connection.execute(%Q{
      UPDATE #{self.class.table_name}
      SET log = COALESCE(log, '') || E#{ActiveRecord::Base.sanitize("[#{Time.now}] #{message}\n")}
      WHERE id = #{id}
    })
  end
end
