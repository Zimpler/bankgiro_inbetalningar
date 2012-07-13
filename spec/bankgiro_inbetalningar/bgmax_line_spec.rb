require_relative '../spec_helper'

module BankgiroInbetalningar
  class Tk00 < BgmaxLine
    field :currency, 3..5, 'A:h'
    field :cents, 6..11, 'N:h0'
    field :flag, 12, 'N:-'
  end
  describe BgmaxLine do
    it "knows its children" do
      BgmaxLine.parsers['00'].should == Tk00
    end
    context "fields" do
      subject { Tk00.new("00SEK0001234") }

      it "can be strings" do
        subject.currency.should == 'SEK'
      end
      it "can be a 0-padded number" do
        subject.cents.should == 123
      end
      it 'can be a numeric flag' do
        subject.flag.should == 4
      end
    end
  end
end
