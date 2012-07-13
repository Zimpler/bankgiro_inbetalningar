require "bankgiro_inbetalningar/version"
require "bankgiro_inbetalningar/bgmax_line"
require "bankgiro_inbetalningar/parser"

module BankgiroInbetalningar
  def self.parse(filename)
    parser = Parser.new(filename)
    parser.run
    parser.result
  end
end
