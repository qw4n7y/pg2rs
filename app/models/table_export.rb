class TableExport < ApplicationRecord
  include StatusAwareConcern

  belongs_to :export, class_name: 'Export'
  belongs_to :table, class_name: 'Imports::Table'

  validates :export, presence: true
  validates :table, presence: true

  after_commit :update_export_status, on: :update

  private

  def update_export_status
    export.update_status!
  end
end
