# BankgiroInbetalningar

This gem parses [Bankgirot's](http://bankgirot.se) payments received files
([BgMax](http://www.bgc.se/Default____5641.aspx)) and returns the payment
data in a relatively provider-agnostic format.

## Installation

Add this line to your application's Gemfile:

    gem 'bankgiro_inbetalningar'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bankgiro_inbetalningar

## Usage

Use the convenience method `BankgiroInbetalningar.parse` to parse a file:

```ruby
res = BankgiroInbetalningar.parse('BgMaxfil4.txt')
# Or
data = File.read("BgMaxfil4.txt")
res = BankgiroInbetalningar.parse_data(data)

raise "oops" unless res.valid?
# You can process deposit by deposit...
res.deposits.each do |d|
  puts "Received to BG #{d.bgno}:"
  d.payments.each do |p|
    puts "%10.2f %s" % [(p.cents / 100.0), p.currency]
  end
end

# ...or payment by payment
res.payments.each do |p|
  puts "%10.2f %s" % [(p.cents / 100.0), p.currency]
  puts "From #{p.payer.name}, #{p.payer.city}" if p.payer
end
```

See the specs for more details.  Note that all text is in UTF-8, as it should be,
and not in ISO-8859-1 as Bankgirot prefers.  It is the 21st century.

## Todo / Missing features

`BankgiroInbetalningar` works well enough for our needs, so there are no plans for
further development.  Pull requests are welcome.

The gem has only been tested with `BgMaxfil4.txt`, the sample file for
users that have requested extended OCR registration.  I see no reason
why it wouldn't work with other settings, but YMMV.

Some attributes in the files are not reported since we didn't need them.
I'll be happy to add them if you don't want to do it yourself.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
