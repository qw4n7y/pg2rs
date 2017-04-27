class Import::Utility

  def self.local_base_dir_for(transfer: nil, export: nil)
    return "/tmp/pg2rs/database-#{transfer.import.postgres['name']}/transfer-#{transfer.id}" if transfer
    return "/tmp/pg2rs/database-#{export.import.postgres_to_export_to['name']}/export-#{export.id}" if export
  end

  def self.aws_object_prefix_for(transfer: nil, export: nil)
    return "database-#{transfer.import.postgres['name']}/transfer-#{transfer.id}" if transfer
    return "database-#{export.import.postgres['name']}/export-#{export.id}" if export
  end

  # Generates a file name for data part
  def self.local_file_name_for(table_transfer: nil, table_export: nil, chunk_number:)
    return File.join [ self.local_base_dir_for(transfer: table_transfer.transfer),
                        "#{table_transfer.table.name}-part#{chunk_number}.csv"
                      ] if table_transfer
    return File.join [ self.local_base_dir_for(export: table_export.export),
                        "#{table_export.table.name}-part#{chunk_number}.csv"
                      ] if table_export
  end

  # Generates the part file name on AWS S3
  def self.aws_s3_object_key_for(table_transfer: nil, table_export: nil, chunk_number:)
    return File.join [ self.aws_object_prefix_for(transfer: table_transfer.transfer),
                        "#{table_transfer.table.name}-part#{chunk_number}.csv"
                      ] if table_transfer
    return File.join [ self.aws_object_prefix_for(export: table_export.export),
                        "#{table_export.table.name}-part#{chunk_number}.csv"
                      ] if table_export
  end

end
