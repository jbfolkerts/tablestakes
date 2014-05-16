# file: table_spec.rb
#
#
require 'spec_helper'
require_relative '../table'


describe "Table" do
  
  describe ".new" do
    let(:t) { Table.new('test.tab') }
    let(:s) { Table.new() }
    
    it "reads a file and create a table" do
      expect(t).to be_a(Table)
    end
    it "creates a table if no file was given" do
      expect(s).to be_a(Table)
    end
    it "errors when the file is not found" do
      expect{Table.new('sillyfile.txt')}.to raise_error(Errno::ENOENT)
    end

  end
  
  describe ".count" do
    let(:t) { FactoryGirl.build(:table) }
    
    it "counts the number of instances in a column" do
      expect(t.count("Address", "123 Main")).to eq(2)
    end
    
    it "counts total number of rows when no parameters are given" do
      expect(t.count).to eq(3)
    end

    it "returns nil if given column is not found" do
      expect(t.count("Silly", "")).to be_nil
    end
    
    it "returns zero when instance not found" do
      expect(t.count("Address", "")).to eq(0)
    end
    
    it "changes numeric input to a string" do
      expect(t.count("Records", 3)).to eq(2)
    end
  end
  
  describe ".tally" do
    let(:t) { FactoryGirl.build(:table) }
    
    it "returns a hash" do
      expect(t.tally("Address")).to be_a(Hash)
    end
    it "returns nil if the column is not found" do
      expect(t.tally("Silly")).to be_nil
    end
    its "returns a set of keys matched to headers" do
      expect(t.tally("Address").each_value.reduce(:+)).to eq(t.table["Address"].length)
    end
  end
  
  describe ".where" do
    let(:t) { FactoryGirl.build(:table) }
    let(:cities) { Table.new('cities.txt') }
    
    it "returns an instance of Table" do
      expect(t.where("Records", "< '3'")).to be_a(Table)
    end
    #it "selects rows that equal an integer" do
    #  expect(t.where("Records", "==3").count).to eq(2)
    #end
    it "selects rows that equal a string" do
      expect(cities.where("State", "=='Texas'").count).to eq(32)
    end
    it "does not select rows that do not meet the given condition" do
      expect(t.where("Records", "=='3'").count("Records", 1)).to eq(0)
    end
    it "returns all rows when no condition is specified" do
      expect(t.where("Records").count).to eq(3)
    end
    it "returns nil when the given condition is not met" do
      expect(t.where("Records", "< '0'")).to be_nil
    end
  end
  
  describe ".select" do
    let(:t) { FactoryGirl.build(:table) }
    
    it "returns an instance of Table" do
      expect(t.select("Name","Address","Records")).to be_a(Table)
    end
    it "selects columns given as arguments" do
      expect((t.select("Name","Address","Records")).headers).to eq(["Name","Address","Records"])
    end
    it "does not select columns that are not given as arguments" do
      expect((t.select("Name","Address","Records")).headers.include?("Phone")).to be_false
    end
    it "returns nil when the given arguments don't match a column" do
      expect(t.select("Silly")).to be_nil
    end
  end
  
  describe ".join" do
    let(:cities) { Table.new('cities.txt') }
    let(:capitals)  { Table.new('capitals.txt') }
    
    it "returns an instance of Table" do
      expect(capitals.join(cities, "State")).to be_a(Table)
    end
    it "returns only the rows that match" do
      expect(capitals.join(cities, "State").count).to eq(46)
    end
    it "does not return rows that do not match" do
      expect(capitals.join(cities, "State").count("State","West Virginia")).to be_nil
    end
    it "returns nil when the given arguments don't match a column" do
      expect(capitals.join(cities, "Silly")).to be_nil
    end
  end
  
  describe ".sub" do
    let (:cities) { Table.new('cities.txt') }
    
    it "returns an instance of Table" do
      expect(cities.sub("State", /Jersey/, "York")).to be_a(Table)
    end
    it "substitutes the values in a given field" do
      expect((cities.sub("State", /Jersey/, "York")).count("State", "New York")).to eq(9)
    end
    it "returns nil when the given arguments don't match a column" do
      expect(cities.sub("Silly", /NJ/, "NY")).to be_nil
    end
  end
  
  describe ".sub!" do
    let (:cities) { Table.new('cities.txt') }
    
    it "returns the same instance of Table" do
      expect(cities.sub!("State", /Carolina/, "Dakota")).to be_equal(cities)
    end
    it "substitutes the values in a given field" do
      expect((cities.sub!("State", /Jersey/, "York")).count("State", "New York")).to eq(cities.count("State", "New York"))
    end
    it "returns nil when the given arguments don't match a column" do
      expect(cities.sub!("Silly", /NJ/, "NY")).to be_nil
    end
  end

  describe ".sort" do
    let(:t) { FactoryGirl.build(:table) }
    
    it "returns an instance of Table" do
    end
    it "returns nil if the given column does not exist" do
    end
    it "returns a Table sorted by string if the column is a string" do
    end
    it "returns a Table sorted by integer if the column is an integer" do
    end
    it "returns a Table sorted by date if the column is a date" do
    end
  end
end