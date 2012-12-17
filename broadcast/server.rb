require 'cod'
require 'pry'

time_server_channel = Cod.tcp_server('localhost:44444')
clients = []

loop do
  request, client_channel = time_server_channel.get_ext

  if /\Aconnect \d{5}\Z/ === request
    clients << Cod.tcp("localhost:#{request[-5..-1]}")
    puts "Client on port #{request[-5..-1]} connected"
    client_channel.put Time.now

  elsif /\Apost/ === request
    client_channel.put Date.today

  else
    client_channel.put 'Unknown request!'
  end

end

