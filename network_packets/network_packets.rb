require 'pry'
require 'packet'
require 'printer'

Shoes.app(height: 900, width: 1400) do
  MESSAGE_LENGTH = 16

  @message = edit_box height: 50, width: 1400 do |e|
    if e.text.size == MESSAGE_LENGTH
      encoded = Packet.encode e.text
      Printer.print_by_sections @packets, encoded
      @packets.para '%18s' % e.text, margin: 0, font: 'courier', weight: 'heavy'
      @packets.para "\n\n"

      decoded = Packet.decode encoded.join
      @decoded.para decoded, margin: 0

      @message.text = ''
    end
  end

  @packets = flow height: 650, width: 1400
  @decoded = flow height: 200, width: 1400

  [@packets, @decoded].each { |el| el.border black }
end
