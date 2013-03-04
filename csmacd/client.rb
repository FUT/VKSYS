require 'pry'
require 'cod'
require 'shoes'

PORT = 10000 + rand(20000)
$channel = Cod.tcp('localhost:44456')
$ip = rand(256)
$channel.interact ['connect', PORT]

def channel_busy?
  Array.new(2).map do
    sleep 0.25
    mode, busy = $channel.interact ['busy?', PORT]
    p busy.class
    break [false] if busy.is_a?(Array)
    sleep 0.25
    busy
  end.any?
end

def wait
  time = rand(2000) / 1000.0
  $info.para "[BUSY] Waiting for #{time} msec\n"
  sleep time
end

def send(message)
  # p "Sending #{message}"
  message = message.split ''
  while !message.empty?
    wait while channel_busy?
    $info.para "[SEND] #{message.first} was sent\n"
    $channel.interact ["send #{PORT}", message.shift]
  end
end

Shoes.app title: "Client", width: 400 do
  para 'Message      '
  @message_line = edit_line width: 300

  button 'Send', height: 40 do
    text = @message_line.text
    Thread.new { send text }
    @message_line.text = ''
  end

  @messages = flow width: 400, height: 250, scroll: true
  $info = flow width: 400, height: 250, scroll: true

  Thread.new do
    local_server = Cod.tcp_server("localhost:#{PORT}")
    loop do
      (mode, message), server_channel = local_server.get_ext

      # p "Client #{PORT} received: [mode] #{mode} [message] #{message}"
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
