require 'pry'
require 'cod'
require 'shoes'


MODES = %w{broadcast unicast multicast anycast}
PORT = rand(1000) + 50000

$channel = Cod.tcp("localhost:44446")
$channel.interact ['connect', [], PORT]

Shoes.app title: PORT.to_s, width: 400 do
  para 'Message'
  @message_line = edit_line width: 400
  para 'Ports'
  @ports = edit_line width: 400
  @messages = flow width: 400, height: 300, scroll: true

  MODES.each do |mode|
    button mode do
      $channel.interact [mode, @ports.text.split(' '), @message_line.text, PORT]
      @message_line.text = ''
    end
  end

  Thread.new do
    local_server = Cod.tcp_server("localhost:#{PORT}")
    loop do
      (mode, message), server_channel = local_server.get_ext

      case mode
      when 'append'
        @messages.para message
        server_channel.put Time.now

      else
        server_channel.put 'Unknown request!'
      end
    end
  end
end
