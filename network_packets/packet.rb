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
      [start_stop_byte, receiver, transmitter, encoded_message(message), crc(message), start_stop_byte]
    end

    def start_stop_byte
      '01111110'
    end

    def receiver
      '%08b' % rand(256)
    end

    def transmitter
      receiver
    end

    def crc(message)
      Digest::CRC16.digest(message).bytes.map { |byte| '%08b' % byte }.join
    end

    def encoded_message(message)
      encoded = message.split(//).map { |c| c.unpack 'b8' }.join.gsub '11111', '111110'
      encoded << '0' * (8 * DATA_LENGTH - encoded.length)
    end

    def decoded_message(message)
      bytes = message[24..(24 + 8 * DATA_LENGTH)].gsub('1111101', '111111').scan(/.{8}/).reject { |b| b == '00000000' }
      bytes.pack 'b8' * bytes.count
    end
  end
end
