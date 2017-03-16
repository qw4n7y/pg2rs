class Imports::Migration < ApplicationRecord
  include StatusAwareConcern
  include LoggableConcern

  belongs_to :import, class_name: 'Imports::Import', inverse_of: :migrations

  validates :import, presence: true
  validates :sql, presence: true, length: { minimum: 10 }
end
