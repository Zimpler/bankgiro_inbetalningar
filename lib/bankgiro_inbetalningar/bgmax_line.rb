module BankgiroInbetalningar
  class BgmaxLine
    class << self
      attr_reader :parsers
      def inherited(klass)
        lead = klass.name[/\d+/]
        (@parsers ||= {})[lead] = klass
      end

      def field(name, position, format)
        define_method name do
          value = " #{@line}"[position]
          case format
          when 'N:h0', 'N:-'
            value.sub(/^0+/,'').to_i
          else
            value.strip
          end
        end
      end
    end

    def initialize(line)
      @line = line
    end
  end
end
