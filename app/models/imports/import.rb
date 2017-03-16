class Imports::Import < ApplicationRecord
  enum status: {active: 0, disabled: 10}

  has_many :tables, class_name: 'Imports::Table', inverse_of: :import
  has_many :transfers, class_name: 'Imports::Transfer', inverse_of: :import
  has_many :migrations, class_name: 'Imports::Migration', inverse_of: :import

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: Imports::Import.statuses.keys }

  accepts_nested_attributes_for :tables, :reject_if => :all_blank, :allow_destroy => true
end
