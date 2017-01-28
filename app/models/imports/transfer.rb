class Imports::Transfer < ApplicationRecord
  enum status: {pending: 0, in_progress: 10, success: 20, failed: 30}

  belongs_to :import, class_name: 'Imports::Import'
  has_many :table_transfers, class_name: 'Imports::TableTransfer', dependent: :destroy

  validates :import, presence: true

  def update_status!
    table_transfers.reload

    self.status = 'failed' if table_transfers.any? { |tt| tt.failed? }
    self.status = 'success' if table_transfers.all? { |tt| tt.success? }

    save!
  end
end
