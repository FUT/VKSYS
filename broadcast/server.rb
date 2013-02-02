require 'cod'
require 'pry'

time_server_channel = Cod.tcp_server('localhost:44440')
@clients = []
@groups = Hash.new []

def dest(channel)
  channel.instance_eval('@destination').split(':').last
end

def get_client_by_port(port)
  @clients.find { |client| dest(client) == port }
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

  case mode.split.first
  when 'change_group'
    @groups.each_pair { |key, value| @groups[key] = value - [client_port] }
    @groups[message] += [client_port]
  when 'connect'
    @clients << Cod.tcp("localhost:#{message}")
    puts "Client on port #{message} connected"
  when 'unicast'
    respond(message) { |port| port == ports.first }
  when 'multicast'
    puts @groups, client_port, message
    respond(message) { |port| @groups[mode.split[1]].include? port.to_i }
  when 'broadcast'
    respond(message)
  when 'anycast'
    pp = close_ports(client_port)[rand(close_ports(client_port).length)]
    respond(message) { |port| pp == port }
  else
    puts 'ERROR! UNKNOWN REQUEST!'
  end

  client_channel.put Time.now
end
