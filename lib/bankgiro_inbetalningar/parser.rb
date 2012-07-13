module BankgiroInbetalningar
  class Parser
    attr_accessor :result

    def initialize(filename)
      @filename = filename
    end

    def run
      @result = Result.new
      parse_lines
    ensure
      @stream.close if @stream
    end

    def parse_lines
      while @line = next_line
        parse_line
        record_line
      end
    end

    def next_line
      stream.eof? ? nil : stream.readline
    end

    def stream
      @stream ||= File.open(@filename, 'r:ISO-8859-1:UTF-8')
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

    def record_line
      if result.deposit && result.payment && @line[0] == '2'
        result.payment.raw << @line
      end
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

  class Tk05 < BgmaxLine
    field :bgno, 3..12, 'N:h0'
    field :currency, 23..25, 'A:b'

    def update(result)
      result.new_deposit
      result.deposit.bgno = bgno
      result.deposit.currency = currency
    end
  end

  class Tk20 < BgmaxLine
    field :sender_bgno, 3..12, 'N:h0'
    field :reference, 13..37, 'A:-'
    field :cents, 38..55, 'N:h0'
    field :reference_type, 56, 'N:-'
    field :number, 58..69, 'A:-'
    field :has_image, 70, 'N:-'

    def update(result)
      payment = result.new_payment
      payment.cents = cents
      payment.currency = result.deposit.currency
      payment.references << reference.strip if reference_type == 2
      payment.sender_bgno = sender_bgno
    end
  end

  class Tk22 < BgmaxLine
    field :reference, 13..37, 'A:-'
    field :cents, 38..55, 'N:h0'
    field :reference_type, 56, 'N:-'

    def update(result)
      result.payment.references << reference if [2,5].include?(reference_type)
    end
  end

  class Tk26 < BgmaxLine
    field :name, 3..37, 'A:vb'
    field :extra_name, 38..72, 'A:vb'

    def update(result)
      payer = result.payment.payer!
      payer.name = name
      payer.extra_name = extra_name
    end
  end

  class Tk27 < BgmaxLine
    field :street, 3..37, 'A:vb'
    field :postal_code, 38..46, 'A:vb'

    def update(result)
      payer = result.payment.payer!
      payer.street = street
      payer.postal_code = postal_code
    end
  end

  class Tk28 < BgmaxLine
    field :city, 3..37, 'A:vb'
    field :country, 38..72, 'A:vb'
    field :country_code, 73..74, 'A:vb'

    def update(result)
      payer = result.payment.payer!
      payer.city = city
      payer.country = country if country != ''
    end
  end

  class Tk29 < BgmaxLine
    field :org_no, 3..14, 'N:h0'

    def update(result)
      payer = result.payment.payer!
      payer.org_no = org_no
    end
  end


  class Result
    attr_accessor :timestamp, :deposits

    def initialize
      @deposits = []
    end

    def new_deposit
      @deposits << Deposit.new
      deposit
    end

    def deposit
      @deposits.last
    end

    def new_payment
      deposit.payments << Payment.new
      payment
    end

    def payment
      deposit.payments.last
    end

    def payments
      deposits.map { |d| d.payments }.flatten
    end

    class Deposit
      attr_accessor :bgno, :currency, :payments
      def initialize
        @payments = []
      end
    end

    class Payment
      attr_accessor :cents, :references, :currency, :raw, :payer, :sender_bgno
      def initialize
        @references = []
        @raw = "".force_encoding('iso-8859-1')
      end

      def payer!
        @payer ||= Payer.new
      end
    end

    Payer = Struct.new(:name, :extra_name, :street, :postal_code, :city, :country, :org_no)
  end
end
