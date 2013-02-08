class Formatter
  def self.format(address)
    address -= 10000
    "#{address.to_i / 16}.#{address.to_i % 16}"
  end

  def self.format_back(formatted_address)
    first, second = formatted_address.split('.').map(&:to_i)
    10000 + first * 16 + second
  end
end
