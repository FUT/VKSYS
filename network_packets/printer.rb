class Printer
  def self.print_by_sections(flow, sections)
    sections.each_with_index do |section, i|
      options = i % 2 == 0 ? {} : { underline: 'single' }
      section.scan(/.{8}/).each do |byte|
        flow.para byte, options.merge(font: 'courier')
      end
    end
  end
end
