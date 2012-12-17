require 'cod'
require 'pry'

time_server_channel = Cod.tcp_server('localhost:44446')
clients = []

def dest(channel)
  channel.instance_eval('@destination').split(':').last
end

loop do
  (mode, ports, message), client_channel = time_server_channel.get_ext
  puts mode, ports, message

  case mode
  when 'connect'
    clients << Cod.tcp("localhost:#{message}")
    puts "Client on port #{message} connected"
    client_channel.put Time.now

  when 'unicast'
    client_channel.put Time.now
    clients.each do |client|
      client.interact ['append', message] if dest(client) == ports.first
    end
  when 'multicast'
    client_channel.put Time.now
    clients.each do |client|
      client.interact ['append', message] if dest(client).in? ports
    end

  when 'broadcast'
    client_channel.put Time.now
    clients.each do |client|
      client.interact ['append', message]
    end

  when 'anycast'
    available_ports = clients.map { |client| dest(client) }.sort
    current_port_index = available_ports.index dest(client_channel)
    near = [available_ports[current_port_index - 1], availabe_ports[current_port_index + 1]]

    client_channel.put Time.now
    clients.each do |client|
      client.interact ['append', message] if dest(client).in? near
    end

  else
    puts 'ERROR! UNKNOWN REQUEST!'
    client_channel.put 'Unknown request!'
  end
end
