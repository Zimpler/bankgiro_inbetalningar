$: << File.expand_path('../../lib', __FILE__)
require 'bankgiro_inbetalningar'

def data_from_file(name)
  File.read(fixture_path(name)).force_encoding("ISO-8859-1")
end

def fixture_path(name)
  File.expand_path("../fixtures/#{name}", __FILE__)
end
