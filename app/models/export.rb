class Export < ApplicationRecord
  include StatusAwareConcern
  include LoggableConcern

  belongs_to :import, class_name: 'Imports::Import'
  has_many :table_exports, dependent: :destroy
  has_many :tables, class_name: 'Imports::Table', through: :table_exports

  def update_status!
    table_exports.reload
    self.status = 'failed' if table_exports.any? { |te| te.failed? }
    save!
  end
end
