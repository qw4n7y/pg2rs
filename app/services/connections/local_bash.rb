class Connections::LocalBash
  def self.execute(cmd)
    `#{cmd}`
  end
end
