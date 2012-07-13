module BankgiroInbetalningar
  class Parser
    attr_accessor :result

    def initialize(filename)
      @filename = filename
    end

    def run
      @result = Result.new
      parse_lines
    end

    def parse_lines
      while @line = next_line
        parse_line
      end
    end

    def next_line
      stream.eof? ? nil : stream.readline.chomp
    end

    def stream
      @stream ||= File.open(@filename)
    end

    def parse_line
      if line_parser_class
        line_parser = line_parser_class.new(@line)
        line_parser.update(@result)
      else
        # skip line
      end
    end

    def line_parser_class
      BgmaxLine.parsers[@line[0..1]]
    end
  end

  class Tk01 < BgmaxLine
    field :layout, 3..22, 'A:vb'
    field :version, 23..24, 'N:h0'
    field :timestamp, 25..44, 'N:-'
    field :testflag, 45, 'A:-'

    def update(result)
      result.timestamp = timestamp
    end
  end

  class Result
    attr_accessor :timestamp, :payments, :deposits
  end
end
