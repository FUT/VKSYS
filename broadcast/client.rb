require 'cod'
require 'shoes'


MODES = %w{broadcast simple}
PORT = rand(1000) + 50000

@@channel = Cod.tcp("localhost:44444")
@@server = Cod.tcp_server("localhost:#{PORT}")
@@channel.interact "connect #{PORT}"
@@message = ''

Shoes.app width: 400 do
  @message_line = edit_line width: 400
  @messages = flow width: 400, height: 400, scroll: true

  MODES.each do |mode|
    button mode do
      @messages.para mode
    end
  end

  Thread.new do
    loop do
      request, server_channel = @@channel.get_ext
      if /\Aappend/ === request
        @messages.para request[6..-1]
        server_channel.put Time.now

      elsif
        server_channel.put 'Unknown request!'
      end
    end
  end
end
