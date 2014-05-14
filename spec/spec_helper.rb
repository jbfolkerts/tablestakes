# spec_helper.rb
# rspec config
#
require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  #config.include Capybara::DSL
end

FactoryGirl.find_definitions