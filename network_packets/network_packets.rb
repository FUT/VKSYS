require 'pry'
require 'packet'
require 'crc16'
require 'printer'

Shoes.app(height: 900, width: 1400) do
  MESSAGE_LENGTH = 21

  @message = edit_box height: 50, width: 1400 do |e|
    if e.text.size == MESSAGE_LENGTH
      encoded = Packet.encode e.text
      Printer.print_by_sections @packets, encoded
      @packets.para '%18s' % e.text, margin: 0, font: 'courier', weight: 'heavy'
      @packets.para "\n\n"

      decoded = Packet.decode encoded
      @decoded.para decoded, margin: 0
      @decoded.para (Packet.valid?(encoded) ? '[VALID]' : '[ERROR]'), margin: 0, stroke: rgb(128,0,0)

      @message.text = ''
    end
  end

  @packets = flow height: 650, width: 1400, scroll: true
  @decoded = flow height: 200, width: 1400, scroll: true

  [@packets, @decoded].each { |el| el.border black }

  keypress do |e|
    if e == :escape
      @message.text = ''
      [@packets, @decoded].each { |container| container.children[1..-1].each(&:remove) }
    end
  end
end
