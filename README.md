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

Use the convenience method `BankgiroInbetalningar.parse_file` to parse a file
or `BankgiroInbetalningar.parse_string` to parse a string:

```ruby
res = BankgiroInbetalningar.parse_file("BgMaxfil4.txt")
# Or
data = File.read("BgMaxfil4.txt").force_encoding("ISO-8859-1")
res = BankgiroInbetalningar.parse_string(data)

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

You can also parse isolated deposits or payments which is useful if you store
the raw data along with each deposit or payment in a database.  Note that the
currency name only is available in the deposit:

```ruby
Dir.chdir 'spec/fixtures'
payment_1 = BankgiroInbetalningar.parse_file("BgMaxfil4.txt").payments.first
payment_2 = BankgiroInbetalningar.parse_string(payment_1.raw).payments.first
payment_1.cents    # => 180000
payment_2.cents    # => 180000
payment_1.currency # => "SEK"
payment_2.currency # => nil
```

The `raw` method is also available on deposit objects.
See the specs for more details.

Files are expected to be ISO-8859-1 (as Bankgirot prefers), but data strings
can be in any encoding, as long as `String#encoding` is correct. The library
returns UTF-8. It *is* the 21st century.

## Changes in 1.2.0

* Renamed `parse` and `parse_data` to `parse_file` and `parse_string`.  The old
  method names are still available.
* `parse_string` accepts a string in any encoding that can be converted to UTF-8.
* Added `BankgiroInbetalningar::Result::Deposit#raw`.

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

### Contributors:

* [David Vrensk](https://github.com/dvrensk)
* [Petter Remen](https://github.com/remen)
* [Henrik Nyh](https://github.com/henrik)
