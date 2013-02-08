require 'cod'
require 'pry'

time_server_channel = Cod.tcp_server('localhost:44456')
@clients = {}
@groups = Hash.new{[]}

IP = {
  unicast:  (0...128),
  multi1: (128...160),
  multi2: (160...192),
  multi3: (192...224),
  multi4: (224...254),
  any:    (254..254),
  broad:  (255..255)
}

def respond(message, ips = [])
  p message
  p @clients
  @clients.each_pair do |ip, client|
    p ip
    client.interact ['append', message] if !block_given? || yield(ip.to_i)
  end
end

def close_ip
  @clients.sort.first
end

loop do
  (mode, ips, message, client_ip), client_channel = time_server_channel.get_ext
  puts "[FROM #{client_ip}] Mode #{mode} Message #{message}"

  to_ip = ips.first.to_i

  case mode.split.first
  # when 'change_group'
  #   @groups.each_pair { |key, value| @groups[key] = value - [client_ip] }
  #   @groups[message] += [client_ip]
  when 'connect'
    p mode, ips, message, client_ip
    @clients[client_ip.to_i] = Cod.tcp("localhost:#{message}") unless @clients[client_ip.to_i]
    puts "Client on port #{message} connected"
  when 'change_ip'
    old, new = mode.split[1..2].map(&:to_i)
    unless @clients[new]
      @clients[new] = @clients[old]
      @clients.delete old
    end
  when 'send'
    case true
    when IP[:unicast].include?(to_ip) #'unicast'
      respond(message) { |ip| ip.to_i == to_ip.to_i }
    when IP[:multi1].include?(to_ip) #'multicast'
      respond(message) { |ip| IP[:multi1].include? ip }
    when IP[:multi2].include?(to_ip) #'multicast'
      respond(message) { |ip| IP[:multi2].include? ip }
    when IP[:multi3].include?(to_ip) #'multicast'
      respond(message) { |ip| IP[:multi3].include? ip }
    when IP[:multi4].include?(to_ip) #'multicast'
      respond(message) { |ip| IP[:multi4].include? ip }
    when IP[:broad].include?(to_ip) #'broadcast'
      respond(message)
    when IP[:any].include?(to_ip) #'anycast'
      respond(message) { |ip| close_ip.first.to_i == ip.to_i }
    else
      puts 'ERROR! UNKNOWN SEND REQUEST!'
    end
  else
    puts 'ERROR! UNKNOWN REQUEST!'
  end

  client_channel.put Time.now
end
