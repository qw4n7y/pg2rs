class Imports::ExportsController < ApplicationController
  before_action :set_import
  before_action :set_export, only: [:show, :edit, :update, :destroy]

  def index
    @exports = @import.exports
  end

  def new
    @export = @import.exports.build
  end

  def show
  end

  def edit
  end

  def start
    DoExportJob.perform_later(@export)
    redirect_to [@import, :exports], notice: "Export started!"
  end

  def create
    @export = @import.exports.build({})
    @export.status = :pending

    @import.tables.each do |table|
      @export.table_exports.build(status: 'pending', table: table)
    end

    respond_to do |format|
      if @export.save
        format.html { redirect_to [@import, :exports], notice: "Export was successfully created." }
        format.json { render :show, status: :created, location: @export }
      else
        format.html { render :new }
        format.json { render json: @export.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
  end

  def destroy
    @export.destroy
    respond_to do |format|
      format.html { redirect_to [@import, :exports], notice: 'Export was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_import
      @import = Imports::Import.find(params[:imports_import_id])
    end

    def set_export
      @export = @import.exports.find(params[:id])
    end
end
