class Imports::MigrationsController < ApplicationController
  before_action :set_import
  before_action :set_migration, only: [:show, :edit, :update, :destroy, :start]

  def index
    @migrations = @import.migrations
  end

  def new
    @migration = @import.migrations.build
  end

  def show
  end

  def edit
  end

  def start
    DoMigrationJob.perform_later(@migration)
    redirect_to [@import, :migrations], notice: "Migration started!"
  end

  def create
    @migration = @import.migrations.build(migration_params)
    @migration.status = :pending

    respond_to do |format|
      if @migration.save
        format.html { redirect_to [@import, :migrations], notice: "Migration was successfully created." }
        format.json { render :show, status: :created, location: @migration }
      else
        format.html { render :new }
        format.json { render json: @migration.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @migration.update(migration_params)
        format.html { redirect_to [@import, :migrations], notice: "Migration was successfully updated." }
        format.json { render :show, status: :ok, location: @migration }
      else
        format.html { render :edit }
        format.json { render json: @migration.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @migration.destroy
    respond_to do |format|
      format.html { redirect_to [@import, :migrations], notice: 'Migration was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_import
      @import = Imports::Import.find(params[:imports_import_id])
    end

    def set_migration
      @migration = @import.migrations.find(params[:id])
    end

    def migration_params
      params.require(:imports_migration).permit(:sql)
    end
end
