class Imports::Transfer < ApplicationRecord
  enum status: {pending: 0, started: 10, finished: 20, failed: 30}

  belongs_to :import, class_name: 'Imports::Import'
  has_many :table_transfers, class_name: 'Imports::TableTransfer', dependent: :destroy
  has_many :tables, class_name: 'Imports::Table', through: :table_transfers

  validates :import, presence: true

  def update_status!
    table_transfers.reload

    self.status = 'failed' if table_transfers.any? { |tt| tt.failed? }
    # self.status = 'finished' if table_transfers.all? { |tt| tt.finished? }

    save!
  end

  def append_log(message)
    ActiveRecord::Base.connection.execute(%Q{
      UPDATE #{Imports::Transfer.table_name}
      SET log = COALESCE(log, '') || E#{ActiveRecord::Base.sanitize("[#{Time.now}] #{message}\n")}
      WHERE id = #{id}
    })
  end
end
