require 'pry'
require 'cod'
require 'shoes'


MODES = %w{broadcast unicast multicast anycast}
GROUPS = %w{home work university friends}
PORT = rand(1000) + 50000

$channel = Cod.tcp("localhost:44440")
$channel.interact ['connect', [], PORT]

Shoes.app title: PORT.to_s, width: 400 do
  para 'Message'
  @message_line = edit_line width: 400
  para 'Port'
  @ports = edit_line width: 400
  @messages = flow width: 400, height: 300, scroll: true
  @type_select = list_box items: MODES, width: 150, height: 40, choose: 'unicast'
  @group_select = list_box items: GROUPS, width: 150, height: 40 do |list|
    $channel.interact ['change_group', '', @group_select.text, PORT]
  end

  button 'Send', height: 40 do
    $channel.interact ["#{@type_select.text} #{@group_select.text}", @ports.text.split(' '), @message_line.text, PORT]
    @message_line.text = ''
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
