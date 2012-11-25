class CRC16
  GX = 0x18005
  LENGTH = 16

  def self.encode(message)
    first_word = message[0...LENGTH].to_i 2
    other_bits = message[LENGTH..-1].split(//).map(&:to_i)

    other_bits.inject(first_word) do |crc, bit|
      crc = (crc << 1) | bit
      (crc >> LENGTH) != 0 ? crc ^ GX : crc
    end
  end
end
