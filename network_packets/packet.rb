class Packet
  DATA_LENGTH = 21

  class << self
    def encode(message)
      packed_data message
    end

    def decode(message)
      decoded_message message
    end

    def valid?(message)
      decoded = decode_data message
      CRC16.encode(decoded[16...-16]) == decoded[-16..-1].to_i(2)
    end

    private
    def packed_data(message)
      data_with_crc = encoded_message(message) + crc(encoded_message(message))
      inject_error data_with_crc

      stuffed_data = [receiver, transmitter, data_with_crc].join.gsub '11111', '111110'
      [start_stop_byte, stuffed_data, start_stop_byte].join
    end

    def inject_error(message)
      message[rand message.size] = '1'
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
      '%016b' % CRC16.encode(message)
    end

    def encoded_message(message)
      message.split(//).map { |c| c.unpack 'b8' }.join
    end

    def decode_data(data)
      data[8...-8].gsub '111110', '11111'
    end

    def decoded_message(message)
      decode_data(message)[16...(16 + DATA_LENGTH * 8)].scan(/.{8}/).pack 'b8' * DATA_LENGTH
    end
  end
end
