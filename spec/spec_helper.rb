# spec_helper.rb
# rspec config
#
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  #config.include Capybara::DSL
end

FactoryGirl.find_definitions