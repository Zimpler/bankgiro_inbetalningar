# -*- encoding: utf-8 -*-
require File.expand_path('../lib/bankgiro_inbetalningar/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Vrensk"]
  gem.email         = ["david@vrensk.com"]
  gem.description   = %q{Parse BgMax transaction files from Bankgirot and return a simple data structure}
  gem.summary       = %q{Bankgirot has changed its file format, making the +rbankgiro+ gem unusable for new clients.}
  gem.homepage      = "https://github.com/spnab/bankgiro_inbetalningar"

  gem.add_development_dependency "rspec", '~> 2.9.0'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "bankgiro_inbetalningar"
  gem.require_paths = ["lib"]
  gem.version       = BankgiroInbetalningar::VERSION
end
