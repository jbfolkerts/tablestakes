# file: table_spec.rb
#
#
require 'spec_helper'
require_relative '../lib/tablestakes'


describe "Table" do
  
  describe ".new" do
    let(:t) { Table.new('test.tab') }
    let(:empty) { Table.new() }
    
    it "reads a file and create a table" do
      expect(t).to be_a(Table)
    end
    it "creates a table if no file was given" do
      expect(empty).to be_a(Table)
    end
    it "errors when the file is not found" do
      expect{Table.new('sillyfile.txt')}.to raise_error(Errno::ENOENT)
    end

  end
  
  describe ".empty?" do
    let(:test) { Table.new('test.tab') }
    let(:empty) { Table.new() }
    
    it "recognizes an empty table" do
      expect(empty).to be_empty()
    end
    it "recognizes a populated table" do
      expect(test).not_to be_empty()
    end
  end

  describe ".add_column" do
    let(:test) { FactoryGirl.build(:table) }
    let(:newcol) { ["A", "B", "C"] }
    let(:headercol) { ["TestCol", "A", "B", "C"] }
    let(:empty) { Table.new() }

    it "returns a Table" do
      expect(test.add_column("TestCol", newcol)).to be_a(Table)
    end
    it "adds a column to an empty table" do
      expect(empty.add_column("TestCol", newcol).headers[0]).to eq("TestCol")
    end
    it "adds a column to a populated table" do
      expect(test.add_column("TestCol", newcol).headers).to include("TestCol")
    end
    it "raises an ArgumentError when given a duplicate header" do
      expect { test.add_column("Name", newcol) }.to raise_error(ArgumentError)
    end
    it "raises an ArgumentError when given a column with the wrong length" do
      expect { test.add_column("Name", newcol << "D") }.to raise_error(ArgumentError)
    end
    it "adds a column when given an Array" do
      expect(test.add_column(headercol).headers).to include("TestCol")      
    end
  end

  describe ".del_column" do
    let(:test) { FactoryGirl.build(:table) }
    let(:empty) { Table.new() }
    let(:remaining_headers) { ["Address", "Phone", "Records"] }

    it "returns a Table" do
      expect(test.del_column("Name")).to be_a(Table)
    end
    it "removes the correct column from the Table" do
      expect(test.del_column("Name").headers).not_to include("Name")
    end
    it "retains the other columns from the Table" do
      expect(test.del_column("Name").headers - remaining_headers).to be_empty
    end
    it "raises an ArgumentError when given an invalid header" do
      expect { test.del_column("Silly") }.to raise_error(ArgumentError)
    end
  end

  describe ".add_row(s)" do
    let(:test) { FactoryGirl.build(:table) }
    let(:empty) { Table.new() }
    let(:newheaders) { ["Name", "Address", "Phone", "Records"]}
    let(:newrow) { ["Phil", "567 Vine", "567-432-1234", "3"] }
    let(:newrow2) { ["Harry", "57 Maple", "567-555-4321", "2"] }

    it "returns a Table" do
      expect(test.add_row(newrow)).to be_a(Table)
    end
    it "adds a row to a populated table" do
      expect(test.add_row(newrow).count).to eq(4)
    end
    it "adds headers to an empty table" do
      expect(test.add_row(newheaders).headers.length).to eq(4)
    end
    it "raises an ArgumentError when given a row with the wrong length" do
      expect { test.add_row(newrow << "extra") }.to raise_error(ArgumentError)
    end
    it "adds a header and row to an empty table" do
      expect(empty.add_rows([newheaders] << newrow).headers.length).to eq(4)
    end
    it "adds row elements with specified headers to a populated table" do
      expect(test.add_rows([newrow] << newrow2).count).to eq(5)
    end
  end

  describe ".del_row" do
    let(:test) { FactoryGirl.build(:table) }
    let(:empty) { Table.new() }

    it "returns a Table" do
      expect(test.del_row(0)).to be_a(Table)
    end
    it "removes the correct row from the Table" do
      expect(test.del_row(0).column("Name")).not_to include("John")
    end
    it "retains the other rows from the Table" do
      expect(test.del_row(0).column("Name")).to include("Jerry")
    end
    it "raises an ArgumentError when given an index that is out of bounds" do
      expect { test.del_row(10) }.to raise_error(ArgumentError)
    end
  end

  describe ".count" do
    let(:t) { FactoryGirl.build(:table) }
    let(:empty) { Table.new() }

    it "counts the number of instances in a column" do
      expect(t.count("Address", "123 Main")).to eq(2)
    end
    
    it "counts total number of rows when no parameters are given" do
      expect(t.count).to eq(3)
    end

    it "raises ArgumentError if given column is not found" do
      expect {t.count("Silly", "") }.to raise_error(ArgumentError)
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
      expect(t.tally("Address")).to be_a(Table)
    end
    it "raises ArgumentError if the column is not found" do
      expect { t.tally("Silly") }.to raise_error(ArgumentError)
    end
    its "returns a set of keys matched to headers" do
      expect(t.tally("Address").column("Count").each.reduce(:+)).to eq(t.column("Address").length)
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
    it "raise ArgumentError when the given arguments don't match a column" do
      expect { t.select("Silly") }.to raise_error(ArgumentError)
    end
  end
  
  describe ".join" do
    let(:cities) { Table.new('cities.txt') }
    let(:capitals)  { Table.new('capitals.txt') }
    
    it "returns an instance of Table" do
      expect(capitals.join(cities, "State")).to be_a(Table)
    end
    it "returns only the rows that match" do
      expect(capitals.join(cities, "State").count).to eq(45)
    end
    it "returns the correct rows when tables have matching column names" do
      expect((capitals.join(cities, "State").headers.select { |v| v =="State" }).size).to eq(1)
    end
    it "returns the correct headers when tables do not have matching column names" do
      expect(cities.join(capitals, "City", "Capital").headers).to eq(cities.headers + capitals.headers )
    end
    it "does not return rows that do not match" do
      expect(capitals.join(cities, "State").count("State","West Virginia")).to eq(0)
    end
    it "raises ArgumentError when the given arguments don't match a column" do
      expect {capitals.join(cities, "Silly") }.to raise_error(ArgumentError)
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
    it "raises ArgumentError when the given arguments don't match a column" do
      expect {cities.sub("Silly", /NJ/, "NY") }.to raise_error(ArgumentError)
    end
  end
  
  describe ".union" do
    let (:cities) { Table.new('cities.txt') }
    let(:capitals)  { Table.new('capitals.txt') }
    
    it "returns an instance of Array" do
      expect(capitals.union(cities, "Capital", "City")).to be_a(Array)
    end
    it "returns instances in table 1, but not in table 2" do
      expect(capitals.union(cities,"Capital", "City")).to include("Montpelier")
    end
    it "returns instances in table 2, but not in table 1" do
      expect(capitals.union(cities,"Capital", "City")).to include("El Monte")
    end
    it "raises ArgumentError for invalid values" do
      expect {capitals.union(cities,"Silly") }.to raise_error(ArgumentError)
    end
  end
  
  describe ".intersect" do
    let(:cities) { Table.new('cities.txt') }
    let(:capitals)  { Table.new('capitals.txt') }
    
    it "returns an instance of Array" do
      expect(capitals.intersect(cities, "Capital", "City")).to be_a(Array)
    end
    it "does not return instances in table 1, but not in table 2" do
      expect(capitals.intersect(cities,"Capital", "City")).not_to include("Montpelier")
    end
    it "does not return instances in table 2, but not in table 1" do
      expect(capitals.intersect(cities,"Capital", "City")).not_to include("El Monte")
    end
    it "raises ArgumentError for invalid values" do
      expect {capitals.intersect(cities,"Silly") }.to raise_error(ArgumentError)
    end
  end

  describe ".top/.bottom" do
    let (:cities) { Table.new('cities.txt') }

    it "returns a Table" do
      expect(cities.top("State")).to be_a(Table)
    end
    it "returns the top element" do
      expect(cities.top("State").row(0)[0]).to eq("California")
    end
    it "returns the top 10 elements when requested" do
      expect(cities.top("State", 10).count).to eq(10)
    end
    it "returns an ArgumentError when invalid number of elements" do
      expect {cities.top }.to raise_error(ArgumentError)
    end
    it "returns the bottom element" do
      expect(cities.bottom("State").row(0)[1]).to eq("1")
    end
  end

  describe ".sort" do
    let(:test) { Table.new('test.tab') }
    let(:empty) { Table.new() }


    it "returns an instance of Table" do
      expect(test.sort.row(0)).to eq(["Jerry", "212 Vine", "123-456-7890", "1"])
    end
    it "can sort by first element (default)" do
      expect(test.sort.row(0)).to eq(["Jerry", "212 Vine", "123-456-7890", "1"])
    end
    it "can sort by given element" do
      expect(test.sort("Records").row(0)).to eq(["Jerry", "212 Vine", "123-456-7890", "1"])
    end
    it "returns empty Table when given empty Table" do
      expect(Table.new().sort).to eq(Table.new())
    end
    it "accepts a block as input" do
      expect(test.sort { |a| a.reverse }.row(0)).to eq(["John", "123 Vine", "098-765-4321", "3"])
    end

  end
  
end