class Imports::TableTransfer < ApplicationRecord
  include StatusAwareConcern

  belongs_to :transfer, class_name: 'Imports::Transfer'
  belongs_to :table, class_name: 'Imports::Table'

  validates :transfer, presence: true
  validates :table, presence: true

  after_commit :update_transfer_status, on: :update

  private

  def update_transfer_status
    transfer.update_status!
  end
end
