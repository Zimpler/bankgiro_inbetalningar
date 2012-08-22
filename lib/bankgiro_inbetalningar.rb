require "bankgiro_inbetalningar/version"
require "bankgiro_inbetalningar/bgmax_line"
require "bankgiro_inbetalningar/parser"

module BankgiroInbetalningar
  def self.parse(filename)
    data = File.read(filename)
    parse_data(data)
  end

  def self.parse_data(data)
    parser = Parser.new(data)
    parser.run
    parser.result
  end
end
