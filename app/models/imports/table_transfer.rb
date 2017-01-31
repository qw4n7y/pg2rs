class Imports::TableTransfer < ApplicationRecord
  enum status: {pending: 0, started: 10, finished: 20, failed: 30}

  belongs_to :transfer, class_name: 'Imports::Transfer'
  belongs_to :table, class_name: 'Imports::Table'

  validates :transfer, presence: true
  validates :table, presence: true
  validates :status, presence: true, inclusion: { in: Imports::TableTransfer.statuses.keys }

  after_commit :update_transfer_status, on: :update

  private

  def update_transfer_status
    transfer.update_status!
  end
end
