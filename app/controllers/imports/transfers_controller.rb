class Imports::TransfersController < ApplicationController
  before_action :set_imports_import

  def create
    ImportStarterJob.perform_later @imports_import
    redirect_to imports_import_url(@imports_import), notice: "You've started a new transfer!"
  end

  def update
    @transfer = @imports_import.transfers.find(params[:id])

    TransferStarterJob.perform_later @transfer
    redirect_to imports_import_url(@imports_import), notice: "You've restarted the transfer!"
  end

  def show
    @transfer = @imports_import.transfers.find(params[:id])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_imports_import
      @imports_import = Imports::Import.find(params[:imports_import_id])
    end
end
