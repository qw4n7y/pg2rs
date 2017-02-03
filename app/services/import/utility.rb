class Import::Utility

  def self.local_base_dir_for(transfer:)
    "/tmp/pg2rs/database-#{transfer.import.postgres['name']}/transfer-#{transfer.id}"
  end

  def self.aws_object_prefix_for(transfer:)
    "database-#{transfer.import.postgres['name']}/transfer-#{transfer.id}"
  end

  # Generates a file name for data part
  def self.local_file_name_for(table_transfer:, chunk_number:)
    File.join [ self.local_base_dir_for(transfer: table_transfer.transfer),
                "#{table_transfer.table.name}-part#{chunk_number}.csv"
              ]
  end

  # Generates the part file name on AWS S3
  def self.aws_s3_object_key_for(table_transfer:, chunk_number:)
    File.join [ self.aws_object_prefix_for(transfer: table_transfer.transfer),
                "#{table_transfer.table.name}-part#{chunk_number}.csv"
              ]
  end

end
