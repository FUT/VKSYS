class Printer
  def self.print_by_sections(flow, message)
    message.scan(/.{8}/).each do |byte|
      flow.para byte, font: 'courier'
    end
  end
end
