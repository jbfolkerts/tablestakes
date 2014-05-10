# file: table_spec.rb
#
#
gitrequire_relative '../table'

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
    let(:t) { Table.new('test.tab') }
    
    it "counts the number of instances in a column" do
      expect(t.count("Address", "123 Main")).to eq(2)
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
    let(:t) { Table.new('test.tab') }
    
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
  
  
end