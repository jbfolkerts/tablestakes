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
  # +input+:: +Array+ of rows or +String+ to identify the
  #     name of the tab-delimited file to read
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
  def count(colname=nil, value=nil)
    if colname.nil? || value.nil?
      if @table.size > 0
        @table.each_key {|e| return @table.fetch(e).length }
      else
        return nil
      end
    end
    
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

  # Select columns from the table, given one or more column names. Returns an instance
  # of Table with the results.  Returns nil if no columns are found.
  # Params:
  # +columns+:: Variable +String+ arguments to identify the columns to select
  def select(*columns)
    result = []
    result_headers = []
    columns.each { |col| @headers.include?(col) ? result_headers << col : nil }
    result << result_headers
    @table[@headers.first].length.times do |row|
      this_row = []
      result_headers.each do |col|
        this_row << @table[col][row]
      end
      result << this_row
    end
    unless result_headers.empty?
      return Table.new(result)
    else
      return nil
    end
  end
  
  # Given a particular condition for a given column field/column, return a subtable
  # that matches the condition. If no condition is given, a new table is returned with
  # all records.
  # Returns nil if the condition is not met or the column is not found.
  # Params:
  # +colname+:: +String+ to identify the column to tally
  # +condition+:: +String+ containing a ruby condition to evaluate
  def where(colname, condition=nil)
    if @table.has_key?(colname)
      result = []
      result << @headers
      @table[colname].each_index do |index|
        if condition
          eval("#{@table[colname][index]} #{condition}") ? result << get_row(index) : nil
        else
          result << get_row(index)
        end
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
