require 'pry'
require 'cod'
require 'shoes'

PORT = 10000 + rand(20000)
$channel = Cod.tcp('localhost:44456')
$ip = rand(256)
$channel.interact ['connect', PORT]

def channel_busy?
  Array.new(2).map do
    mode, busy = $channel.interact ['busy?', PORT]
    sleep 0.10
    p busy.class
    break [false] if busy.is_a?(Array)
    sleep 0.15
    busy
  end.any?
end

def wait
  time = rand(2000) / 1000.0
  p "Waiting for #{time} msec"
  sleep time
end

def send(message)
  message = message.split ''
  while !message.empty?
    wait while channel_busy?
    p "#{message.first} was sent"
    $channel.interact ["send #{PORT}", message.shift]
  end
end

Shoes.app title: "Client", width: 400 do
  para 'Message      '
  @message_line = edit_line width: 300
  @messages = flow width: 400, height: 250, scroll: true

  button 'Send', height: 40 do
    send @message_line.text
    @message_line.text = ''
  end

  Thread.new do
    local_server = Cod.tcp_server("localhost:#{PORT}")
    loop do
      (mode, message), server_channel = local_server.get_ext

      p "Client #{PORT} received: [mode] #{mode} [message] #{message}"
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
