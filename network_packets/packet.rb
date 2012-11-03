require 'digest/crc16'

class Packet
  DATA_LENGTH = 21

  class << self
    def encode(message)
      packed_data message
    end

    def decode(message)
      decoded_message message
    end

    private
    def packed_data(message)
      data = [receiver, transmitter, encoded_message(message), crc(message)].join.gsub '11111', '111110'
      [start_stop_byte, data, start_stop_byte].join
    end

    def start_stop_byte
      '01111110'
    end

    def receiver
      '11111111' # '%08b' % rand(256)
    end

    def transmitter
      receiver
    end

    def crc(message)
      Digest::CRC16.digest(message).bytes.map { |byte| '%08b' % byte }.join
    end

    def encoded_message(message)
      message.split(//).map { |c| c.unpack 'b8' }.join
    end

    def decoded_message(message)
      counter = 0 # steps after last bit stuffing found
      bytes = message[8...-8].split(//).inject('') do |data, bit|
        counter -= 1 if counter > 0

        if data[-7..-1] == '1111101' && counter = 0
          data[-2] = ''
          counter = 5
        end

        data << bit
      end

      bytes[16...(16 + DATA_LENGTH * 8)].scan(/.{8}/).pack 'b8' * DATA_LENGTH
    end
  end
end
