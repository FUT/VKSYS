require 'cod'
require 'pry'

time_server_channel = Cod.tcp_server('localhost:44446')
@clients = []

def dest(channel)
  channel.instance_eval('@destination').split(':').last
end

def respond(message, ports = [])
  @clients.each do |client|
    client.interact ['append', message] if !block_given? || yield(dest(client))
  end
end

def close_ports(port)
  available_ports = @clients.map { |client| dest(client) }.sort
  port_index = available_ports.index(port.to_s).to_i
  max = available_ports.length
  near = [available_ports[(port_index - 1) % max], available_ports[(port_index + 1) % max]].compact
end

loop do
  (mode, ports, message, client_port), client_channel = time_server_channel.get_ext
  puts "[FROM #{client_port}] Mode #{mode} Message #{message}"

  case mode
  when 'connect'
    @clients << Cod.tcp("localhost:#{message}")
    puts "Client on port #{message} connected"

  when 'unicast'
    respond(message) { |port| port == ports.first }
  when 'multicast'
    respond(message) { |port| ports.include? port }
  when 'broadcast'
    respond(message)
  when 'anycast'
    respond(message) { |port| close_ports(client_port).include? port }
  else
    puts 'ERROR! UNKNOWN REQUEST!'
  end

  client_channel.put Time.now
end
