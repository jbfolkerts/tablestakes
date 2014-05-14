#!/usr/bin/ruby -w
#


class Table
  attr_accessor :headers, :table
  @headers =[]
  @table = {}
  @indices = {}
  # Structure of @table hash 
  # { :col1 => [1, 2, 3], :col2 => [1, 2, 3] }
  

  # Instantiate a Table object using a tab-delimited file
  # Params:
  # +filename+:: +String+ to identify the name of the tab-delimited file to read
  def initialize(input=nil)
    @headers = []
    @table = {}
    @indices = {}
    
    if input.respond_to?(:fetch)
      if input[0].respond_to?(:fetch)
        #create table from rows
        add_rows(input)
      end
    elsif input.respond_to?(:upcase)
      # a string, then read_file
      read_file(input)
    end
    # else create empty table
  end
  
  # Return an array of the Table headers
  # Params: none
  def headers
    @headers
  end
  
  # Return a copy of a column from the table, identified by column name
  # Params:
  # +colname+:: +String+ to identify the name of the column
  def column(colname)
    Array(@table[colname])
  end
  
  # Return an internal representation of the Table object
  # Params: none
  def table
    @table
  end
  
  # Converts a Column in the table to a +Date+ type.
  # Returns nil if the column is not found.
  # Params:
  # +colname+:: +String+ to identify the column to convert
  def to_date(colname)
    if @table.has_key?(colname) == false
      return nil
    else
      @table[colname].length.times do |row|
        @table[colname][row] = Time.parse(@table[colname][row])
      end
    end    
  end

  # Converts a Column in the table to an +Integer+ type.
  # Returns nil if the column is not found.
  # Params:
  # +colname+:: +String+ to identify the column to convert
  def to_i(colname)
    if @table.has_key?(colname) == false
      return nil
    else
      @table[colname].length.times do |row|
        @table[colname][row] = @table[colname][row].to_i
      end
    end    
  end

  # Sort a Table, given a column name.  Uses default sorting
  # precedence.  Recognizes Date and Integer values.
  # Returns nil if the column is not found.
  # Params:
  # +colname+:: +String+ to identify the column to sort by
  def sort(colname)
  #convert to int (if possible)
  #convert to date (if possible)
  
  #sort entire table based on values in colname

  end
  
  # Select rows from the table that match a condition for a given column.
  # Returns an instance of Table with the results.
  # Returns nil if the column is not found.
  # Params:
  # +colname+:: +String+ to identify the column to sort by
  # +condition+:: +String+ representing a condition expressed in Ruby (e.g. "> 42")
  def select(colname, condition="==true")
    result = Table.new
    # use eval to construct condition
    @table[colname].each do |row|
      if eval colname + condition 
        result.append(row)
      end
    end
    result
  end
  
  # Converts a Table object to a tab-delimited string.
  # Params:
  # none
  def to_s
    result = @headers.join("\t") << "\n"
    
    @table[@headers.first].length.times do |row|
      @headers.each do |col|
        result << @table[col][row].to_s
        unless col == @headers.last
          result << "\t"
        else
          result << "\n"
        end
      end
    end
    result
  end

  # Counts the number of instances of a particular string, given a column name,
  # and returns an integer >= 0. Returns nil if the column is not found.
  # Params:
  # +colname+:: +String+ to identify the column to count
  # +value+:: +String+ value to count
  def count(colname, value)
    if @table[colname]
      result = 0
      @table[colname].each do |val|
        val == value.to_s ? result += 1 : nil 
      end
      result
    else
      nil 
    end
  end
  
  # Count instances in a particular field/column and return hash of the results.
  # Returns nil if the column is not found.
  # Params:
  # +colname+:: +String+ to identify the column to tally
  def tally(colname)
    unless @table.has_key?(colname)
      return nil
    end
    result = {}
    @table[colname].each do |val|
      unless result.has_key?(val)
        result[val] = self.count(colname, val)
      end
    end
    result
  end

  # Given a particular condition for a given column field/column, return a subtable
  # that matches the condition.
  # Returns nil if the condition is not met or the column is not found.
  # Params:
  # +colname+:: +String+ to identify the column to tally
  # +condition+:: +String+ containing a ruby condition to evaluate
  def where(colname, condition)
    if @table.has_key?(colname)
      result = []
      result << @headers
      @table[colname].each_index do |index|
        eval("#{@table[colname][index]} #{condition}") ? result << get_row(index) : nil
      end
      result.length > 1 ? Table.new(result) : nil
    else
      return nil
    end
  end


  # Write a representation of the Table object to a file (tab delimited).
  # Params:
  # +filename+:: +String+ to identify the name of the file to write
  def write_file(filename)
    file = File.open(filename, "w")
    file.print self.to_s
  end
  
  private

  def read_file(filename)
    file = File.open(filename, "r")
    @headers = file.gets.chomp.split("\t")
    @headers.each {|col| @table.store(col, []) }
    file.each_line do |line|    
      fields = line.chomp.split("\t")
      @headers.each do |col|
        @table[col] << fields.shift
      end
    nil
    end
  end
  
  def add_rows(array_of_rows)
    array_of_rows.each do |r|
      row = r.clone
      if @headers.empty?
        @headers = row
      else
        unless row.length == @headers.length
          raise ArgumentError, "Wrong number of fields in Table input"
        end
        @headers.each do |col|
          @table[col] = [] unless @table[col]
          @table[col] << row.shift
        end
      end
    end
  end
  
  def get_row(index)
    result = []
    @headers.each do |col|
      result << @table[col][index].to_s
    end
    return result
  end
  
end
