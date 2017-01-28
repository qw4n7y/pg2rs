class Imports::TableTransfer < ApplicationRecord
  enum status: {pending: 0, in_progress: 10, success: 20, failed: 30}

  belongs_to :transfer, class_name: 'Imports::Transfer'
  belongs_to :table, class_name: 'Imports::Table'

  validates :transfer, presence: true
  validates :table, presence: true
  validates :status, presence: true, inclusion: { in: Imports::TableTransfer.statuses.keys }

  def append_log(message)
    ActiveRecord::Base.connection.execute(%Q{
      UPDATE #{Imports::TableTransfer.table_name}
      SET log = COALESCE(log, '') || E#{ActiveRecord::Base.sanitize("[#{Time.now}] #{message}\n")}
      WHERE id = #{id}
    })
  end
end
