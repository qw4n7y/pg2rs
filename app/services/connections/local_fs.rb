class Connections::LocalFs

  def self.write_to_file(data:, file_name:)
    file = open(filename, 'w+')
    file.truncate(0)
    file.write(data)
    file.close
  end

end
