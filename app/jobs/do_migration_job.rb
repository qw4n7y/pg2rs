class DoMigrationJob < ApplicationJob
  def perform(migration)
    Import::DoMigration.new(migration: migration).perform
  end
end
