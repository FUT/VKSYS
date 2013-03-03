require 'cod'
require 'pry'

time_server_channel = Cod.tcp_server('localhost:44456')
@clients = []
@last_message_time = -1
@last_port = -1

def busy?
  (Time.now.to_f - @last_message_time < 0.5)
end

def update_post_time
  @list_message_time = Time.now.to_f
end

loop do
  (mode, message), client_channel = time_server_channel.get_ext
  puts "Mode #{mode} Message #{message}"

  case mode.split.first
  when 'connect'
    p mode, message
    @clients << Cod.tcp("localhost:#{message}")
    puts "Client on port #{message} connected"
    client_channel.put Time.now
  when 'busy?'
    p 'TEST', message, @last_port
    if (message.to_s == @last_port.to_s)
      client_channel.put ['busy?', [true]]
    else
      client_channel.put ['busy?', busy?]
    end
  when 'send'
    @clients.each { |c| c.interact ['append', message] }
    update_post_time
    @last_port = mode.split.last
    client_channel.put Time.now
  else
    puts 'ERROR! UNKNOWN REQUEST!'
    client_channel.put Time.now
  end
end
