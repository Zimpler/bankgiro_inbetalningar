require 'date'

module BankgiroInbetalningar
  class Parser
    attr_accessor :result

    def initialize(data)
      @raw_data ||= data.encode('utf-8', 'iso-8859-1')
    end

    def run
      @result = Result.new
      parse_lines
    end

    def parse_lines
      @raw_data.each_line do |line|
        @line = line
        parse_line
        record_line
      end
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
      if result.deposit && result.payment && payment_line?
        result.payment.raw << @line
      end
    end

    def payment_line?
      @line[0] == '2'
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

  class Tk15 < BgmaxLine
    field :deposit_account, 3..37, 'N:h0'
    field :date, 38..45, 'N:-'
    field :date_year, 38..41, 'N:-'
    field :date_month, 42..43, 'N:h0'
    field :date_day, 44..45, 'N:h0'
    field :deposit_no, 46..50, 'N:h0'
    field :cents, 51..68, 'N:h0'

    def update(result)
      deposit = result.deposit
      deposit.date = Date.new(date_year, date_month, date_day)
      deposit.payments.each { |p| p.date = deposit.date }
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
      payment.references << reference if reference_type == 2
      payment.sender_bgno = sender_bgno
      payment.number = number
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

  class Tk25 < BgmaxLine
    field :text, 3..52, 'A:-'
    def update(result)
      payment = result.payment
      payment.text = [payment.text, text].compact.join("\n")
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

  class Tk70 < BgmaxLine
    field :payments_count, 3..10, 'N:h0'
    field :deposits_count, 27..34, 'N:h0'

    def update(result)
      result.valid = true
      unless result.payments.count == payments_count
        result.valid = false
        result.errors << "Found #{result.payments.count} payments but expected #{payments_count}"
      end
      unless result.deposits.count == deposits_count
        result.valid = false
        result.errors << "Found #{result.deposits.count} deposits but expected #{deposits_count}"
      end
    end
  end


  class Result
    attr_accessor :timestamp, :deposits, :valid, :errors

    def initialize
      @deposits = []
      @errors = []
    end

    def valid?
      valid
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
      deposits.map(&:payments).flatten
    end

    class Deposit
      attr_accessor :bgno, :currency, :payments, :date
      def initialize
        @payments = []
      end
    end

    class Payment
      attr_accessor :cents, :references, :currency, :raw, :payer, :sender_bgno, :text, :date, :number
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
