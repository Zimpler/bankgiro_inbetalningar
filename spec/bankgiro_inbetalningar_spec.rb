require_relative 'spec_helper'

describe BankgiroInbetalningar do
  it "parses a file" do
    res = BankgiroInbetalningar.parse(fixture_path('minimal.txt'))
    res.timestamp.should == "2004 05 25 173035 010331".gsub(' ','').to_i
  end
end
