# -*- coding: utf-8 -*-
require_relative 'spec_helper'

describe BankgiroInbetalningar, ".parse" do
  context "parsing a minimal file" do
    subject { BankgiroInbetalningar.parse(fixture_path('minimal.txt')) }

    it "finds the timestamp" do
      subject.timestamp.should == "2004 05 25 173035 010331".gsub(' ','').to_i
    end
    it "finds 1 deposit" do
      subject.deposits.count.should == 1
    end
    it "finds 1 payment" do
      subject.deposits.first.payments.count.should == 1
    end
  end
end

describe BankgiroInbetalningar, ".parse_data" do
  context "parsing a minimal file" do
    let(:data) { data_from_file('minimal.txt') }
    subject { BankgiroInbetalningar.parse_data(data) }

    it "finds the timestamp" do
      subject.timestamp.should == "2004 05 25 173035 010331".gsub(' ','').to_i
    end
    it "finds 1 deposit" do
      subject.deposits.count.should == 1
    end
    it "finds 1 payment" do
      subject.deposits.first.payments.count.should == 1
    end
  end

  context "parsing a single deposit" do
    let(:data) { data_from_file('isolated_deposit.txt') }
    subject { BankgiroInbetalningar.parse_data(data) }

    it "finds 1 deposit" do
      subject.deposits.count.should == 1
      subject.deposits.first.currency.should == 'EUR'
    end
    it "finds 2 payments" do
      deposit = subject.deposits.first
      deposit.payments.count.should == 2
      deposit.payments[0].payer.name.should.should == 'Olles färg AB'
      deposit.payments[1].payer.name.should.should == 'Berits Garn'
    end
  end

  context "parsing a single payment" do
    let(:data) { data_from_file('isolated_payment.txt') }
    subject { BankgiroInbetalningar.parse_data(data) }

    it "creates 1 deposit out of thin air" do
      subject.deposits.count.should == 1
      subject.deposits.first.currency.should be_nil
    end
    it "finds 1 payment" do
      deposit = subject.deposits.first
      deposit.payments.count.should == 1
      deposit.payments[0].payer.name.should.should == 'Olles färg AB'
    end
  end
end
