class Imports::Table < ApplicationRecord
  enum strategy: {incremental: 0, rotate: 10}

  belongs_to :import, class_name: 'Imports::Import'
  has_many :table_transfers, class_name: 'Imports::TableTransfer'

  validates :import, presence: true
  validates :name, presence: true
  validates :strategy, presence: true, inclusion: { in: Imports::Table.strategies.keys }
end
