require "bankgiro_inbetalningar/version"
require "bankgiro_inbetalningar/bgmax_line"
require "bankgiro_inbetalningar/parser"

module BankgiroInbetalningar
  def self.parse(filename)
    data = File.read(filename).force_encoding("ISO-8859-1")
    parse_data(data)
  end

  def self.parse_data(data)
    parser = Parser.new(data)
    parser.run
    parser.result
  end

  class << self
    alias parse_file parse
    alias parse_string parse_data
  end
end
