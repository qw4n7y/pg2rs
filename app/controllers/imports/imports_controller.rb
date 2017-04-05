class Imports::ImportsController < ApplicationController
  before_action :set_imports_import, only: [:show, :edit, :update, :destroy]

  # GET /imports/imports
  # GET /imports/imports.json
  def index
    @imports_imports = Imports::Import.all
  end

  # GET /imports/imports/1
  # GET /imports/imports/1.json
  def show
  end

  # GET /imports/imports/new
  def new
    @imports_import = Imports::Import.new(postgres: {}, s3: {}, redshift: {})
  end

  # GET /imports/imports/1/edit
  def edit
  end

  # POST /imports/imports
  # POST /imports/imports.json
  def create
    @imports_import = Imports::Import.new(imports_import_params)

    respond_to do |format|
      if @imports_import.save
        format.html { redirect_to imports_imports_url, notice: "#{@imports_import.title} was successfully created." }
        format.json { render :show, status: :created, location: @imports_import }
      else
        format.html { render :new }
        format.json { render json: @imports_import.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /imports/imports/1
  # PATCH/PUT /imports/imports/1.json
  def update
    respond_to do |format|
      if @imports_import.update(imports_import_params)
        format.html { redirect_to imports_imports_url, notice: "#{@imports_import.title} was successfully updated." }
        format.json { render :show, status: :ok, location: @imports_import }
      else
        format.html { render :edit }
        format.json { render json: @imports_import.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /imports/imports/1
  # DELETE /imports/imports/1.json
  def destroy
    @imports_import.destroy
    respond_to do |format|
      format.html { redirect_to imports_imports_url, notice: 'Import was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_imports_import
      @imports_import = Imports::Import.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def imports_import_params
      attrs = params.require(:imports_import).permit(
                :title, :redshift, :postgres, :s3, :status, :private_ssh_key_to_postgres_server,
                tables_attributes: [:id, :name, :strategy, :init_sql_script, :select_sql, :_destroy])

      attrs[:redshift] = JSON.parse(attrs[:redshift] || '{}')
      attrs[:postgres] = JSON.parse(attrs[:postgres] || '{}')
      attrs[:s3] = JSON.parse(attrs[:s3] || '{}')

      attrs
    end
end
