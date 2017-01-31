require 'net/ssh'

class Connections::SshRemote

  def initialize(options:)
    @options = options
  end

  def execute(cmd)
    settings = { key_data: [ @options['ssh']['private_key'] ].compact,
                 port: @options['ssh']['port'] || 22,
                 passphrase: @options['ssh']['passphrase'],
                 password: @options['ssh']['password']
               }.delete_if { |k, v| v.blank? }

    stdout_data = ""
    stderr_data = ""
    exit_code = nil
    exit_signal = nil

    Net::SSH.start(opts['host'], opts['ssh']['user'], settings) do |session|
     session.open_channel do |channel|
       channel.exec(cmd) do |ch, success|
         abort "FAILED: couldn't execute command (session.channel.exec)" unless success
         channel.on_data { |_ch, data| stdout_data += data }
         channel.on_extended_data { |_ch, type, data| stderr_data += data }
         channel.on_request("exit-status") { |_ch, data| exit_code = data.read_long }
         channel.on_request("exit-signal") { |_ch, data| exit_signal = data.read_long }
       end
     end
     session.loop
     [stdout_data, stderr_data, exit_code, exit_signal]
    end

  end

end
