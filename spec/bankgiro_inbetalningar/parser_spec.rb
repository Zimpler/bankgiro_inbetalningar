# -*- coding: utf-8 -*-
require_relative '../spec_helper'

module BankgiroInbetalningar
  describe Parser do
    context "parsing sample file 4" do
      let(:data) { File.read(fixture_path('BgMaxfil4.txt')) }
      let(:parser) { Parser.new(data) }
      let(:result) { parser.run ; parser.result }

      it "returns valid results" do
        result.should be_valid
      end

      it "finds 4 deposits" do
        result.deposits.count.should == 4
      end
      it "finds 9 payments" do
        result.payments.count.should == 9
      end

      context "simplest OCR payment" do
        let(:payment) { result.payments[5] }
        it "has one reference" do
          payment.references.should == ['535765']
          payment.currency.should == 'SEK'
          payment.cents.should == 500_00
          payment.raw.should == "200000000000                   535765000000000000050000230000000000230          \r\n"
        end
        it "has a date" do
          payment.date.should == Date.civil(2004,5,25)
        end
        it "has a number" do
          payment.number.should == "000000000023"
        end
      end

      context "simple OCR payment with address" do
        let(:payment) { result.payments[1] }
        let(:payer) { payment.payer }
        it "has one reference" do
          payment.references.should == ['524967']
          payment.currency.should == 'SEK'
          payment.cents.should == 1900_00
          payment.sender_bgno.should == 97012333
        end
        it "has a payer (in UTF-8!)" do
          payer.name.should == "Olles färg AB"
          payer.street.should == 'Lillagatan 3'
          payer.postal_code.should == '12345'
          payer.city.should == "Storåker"
          payer.country.should be_nil
          # TODO: talk to BGC and see if they really meant this org_no to have 9 digits.
          payer.org_no.should == 550000432
        end
      end

      context "OCR payment with several references and text" do
        let(:payment) { result.payments[0] }
        it "has four references" do
          payment.references.should =~ %w[665869 657775 665661 665760]
        end
        it "has text" do
          payment.text.should == "Betalning med extra refnr 665869 657775 665661\n665760"
        end
      end

      context "OCR payment with two good references, one bad and one revert" do
        let(:payment) { result.payments[6] }
        it "has three references" do
          payment.references.should =~ %w[7495575 695668 8988777]
        end
      end

    end
    context "parsing a broken sample file 4" do
      let(:data) { File.read(fixture_path('BgMaxfil4_broken.txt')) }
      let(:parser) { Parser.new(data) }
      let(:result) { parser.run ; parser.result }

      it "returns invalid results" do
        result.should_not be_valid
      end

      it "reports the payments count as being off" do
        result.errors.should include("Found 9 payments but expected 8")
      end

      it "reports the deposits count as being off" do
        result.errors.should include("Found 4 deposits but expected 5")
      end
    end
  end
end
