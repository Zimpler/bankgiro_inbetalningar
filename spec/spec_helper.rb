$: << File.expand_path('../../lib', __FILE__)
require 'bankgiro_inbetalningar'

def fixture_path(name)
  File.expand_path("../fixtures/#{name}", __FILE__)
end
