class Imports::Transfer < ApplicationRecord
  enum status: {pending: 0, in_progress: 10, success: 20, failed: 30}

  belongs_to :import, class_name: 'Imports::Import'
  has_many :table_transfers, class_name: 'Imports::TableTransfer'

  validates :import, presence: true

  default_scope { order('created_at DESC') }
end
