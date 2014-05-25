#!/usr/bin/ruby -w
#
require 'factory_girl'

FactoryGirl.define do
  factory :table do
    rows = []
    rows << ["Name", "Address", "Phone", "Records"]
    rows << ["John", "123 Main", "098-765-4321", "3" ]
    rows << ["Sharon", "123 Main", "098-765-4321", "3" ]
    rows << ["Jerry", "212 Vine", "123-456-7890", "1" ]
    
    initialize_with { Table.new(rows) }
  end

end