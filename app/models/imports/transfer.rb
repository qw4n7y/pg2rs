class Imports::Transfer < ApplicationRecord
  include StatusAwareConcern
  include LoggableConcern

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
end
