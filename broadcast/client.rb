require 'pry'
require 'cod'
require 'shoes'

MODES = %w{broadcast unicast multicast anycast}
GROUPS = %w{home work university friends}
PORT = rand(1000) + 10000

$channel = Cod.tcp("localhost:44456")
$ip = rand(256)
$channel.interact ["connect", [], PORT, $ip]

Shoes.app title: 'Client', width: 400 do
  @title = title "IP #{$ip}                   "
  para 'Message      '
  @message_line = edit_line width: 300
  para 'My IP            '
  @ip = edit_line width: 300
  para 'Send to IP    '
  @ips = edit_line width: 300
  @messages = flow width: 400, height: 250, scroll: true
  # @type_select = list_box items: MODES, width: 150, height: 40, choose: 'unicast'
  # @group_select = list_box items: GROUPS, width: 150, height: 40 do |list|
  #   $channel.interact ['change_group', '', @group_select.text, $ip]
  # end

  button 'Send', height: 40 do
    $channel.interact ["send",
                        @ips.text.split(' '),
                        @message_line.text,
                        $ip]
    @message_line.text = ''
  end

  button 'Change IP', height: 40 do
    $channel.interact ["change_ip #{$ip} #{@ip.text.to_i}", [], '', $ip]
    $ip = @ip.text.to_i
    @title.text = "IP #{$ip}                   "
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
