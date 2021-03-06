#!/usr/bin/ruby -w
#
# Tablestakes is an implementation of a generic table class
# which takes input from a tab-delimited file and creates a
# generic table data structure that can be manipulated with
# methods similar to the way a database table may be manipulated.
#
# Author:: J.B. Folkerts  (mailto:jbf@pentambic.com)
# Copyright:: Copyright (c) 2014 J.B. Folkerts
# License:: Distributes under the same terms as Ruby

# This class is a Ruby representation of a table. All data is captured as
# type +String+ by default. Columns are referred to by their +String+ headers
# which are assumed to be identified in the first row of the input file.
# Output is written by default to tab-delimited files with the first row
# serving as the header names. 

class Table

  # The headers attribute contains the table headers used to reference
  # columns in the +Table+.  All headers are represented as +String+ types.
  # 
  attr_reader :headers
  @headers =[]
  @table = {}
  @indices = {}
  # Structure of @table hash 
  # { :col1 => [1, 2, 3], :col2 => [1, 2, 3] }
  

  # Instantiate a +Table+ object using a tab-delimited file
  # 
  # ==== Attributes
  # +input+:: OPTIONAL +Array+ of rows or +String+ to identify the name of the tab-delimited file to read
  #
  # ==== Examples
  #     cities = Table.new() # empty table
  #     cities = Table.new([ ["City", "State], ["New York", "NY"], ["Dallas", "TX"] ]) # create from Array of rows
  #     cities = Table.new("cities.txt") # read from file
  #     cities = Table.new(capitals)  # create from table
  #
  def initialize(input=nil)
    @headers = []
    @table = {}
    @indices = {}
    
    if input.respond_to?(:fetch)
      if input[0].respond_to?(:fetch)
        #create Table from rows
        add_rows(input)
      end
    elsif input.respond_to?(:upcase)
      # a string, then read_file
      read_file(input)
    elsif input.respond_to?(:headers)
      @headers = input.headers.dup
      input.each {|row| add_row(row) }
    end
    # else create empty +Table+
  end

  # Defines an iterator for +Table+ which produces rows of data (headers omitted)
  # for its calling block.
  #
  def each

    if block_given?
      @table[@headers.first].each_index do |index|
        nextrow = []
        @headers.each do |col|
          begin
            nextrow << @table[col][index].clone 
          rescue
            nextrow << @table[col][index]
          end
        end
        yield nextrow
      end
    else
      self.to_enum(:each)
    end

  end
    
  # Return a copy of a column from the table, identified by column name.
  # Returns empty Array if column name not found.
  # 
  # ==== Attributes
  # +colname+:: +String+ to identify the name of the column
  def column(colname)
    Array(get_col(colname))
  end
  
  # Return a copy of a row from the table as an +Array+, given an index
  # (i.e. row number). Returns empty Array if the index is out of bounds.
  # 
  # ==== Attributes
  # +index+:: +FixNum+ indicating index of the row.
  def row(index)    
    Array(get_row(index))
  end

  # Return true if the Table is empty, false otherwise.
  # 
  def empty?
    @headers.length == 0 && @table.length == 0
  end
  
  # Add a column to the Table. Raises ArgumentError if the column name is already taken 
  # or there are not the correct number of values.
  #
  # ==== Attributes
  # +args+:: Array of +String+ to identify the name of the column (see examples)
  #
  # ==== Examples
  #     cities.add_column("City", ["New York", "Dallas", "San Franscisco"])
  #     cities.add_column(["City","New York", "Dallas", "San Franscisco"])
  #     cities.add_column("City", "New York", "Dallas", "San Franscisco")
  def add_column(*args)
    if args.kind_of? Array
      args.flatten!
      colname = args.shift
      column_vals = args
    end
    # check arguments
    raise ArgumentError, "Duplicate Column Name!" if @table.has_key?(colname)
    unless self.empty?
      if column_vals.length != @table[@headers.first].length
        raise ArgumentError, "Number of elements in column does not match existing table"
      end
    end
    append_col(colname, column_vals)    
  end

  # Add one or more rows to the Table, appending it to the end. Raises ArgumentError if 
  # there are not the correct number of values.  The first row becomes the table headers
  # if currently undefined.
  #
  # ==== Attributes
  # +array_of_rows+:: +Array+ of +Arrays+ to hold the rows values
  #
  # ==== Examples
  #     cities.add_rows([ ["New York", "NY"], ["Austin", "TX"] ])
  def add_rows(array_of_rows)
    array_of_rows.each do |r|
      add_row(r.clone)
    end
    return self
  end

  # Append one Table object to another. Raises ArgumentError if the header values and order do not 
  # align with the destination Table. Return self if appending an empty table. Return given table if 
  # appending to an empty table.
  #
  # ==== Attributes
  # +a_table+:: +Table+ to be added
  #
  # ==== Examples
  #     cities.append(more_cities)
  def append(a_table)
    if !a_table.kind_of? Table 
      raise ArgumentError, "Argument to append is not a Table"
    end
    if self.empty? 
      return a_table
    elsif a_table.empty? 
      return self
    end
    if a_table.headers != @headers 
      raise ArgumentError, "Argument to append does not have matching headers"
    end

    a_table.each do |r|
        add_row(r.clone)
    end
    return self
  end

  # Add a row to the Table, appending it to the end. Raises ArgumentError if 
  # there are not the correct number of values.
  #
  # ==== Attributes
  # +row+:: +Array+ to hold the row values
  #
  # ==== Examples
  #     cities = Table.new.add_row( ["City", "State"] ) # create new Table with headers
  #     cities.add_row("New York", "NY") # add data row to Table
  #
  def add_row(*row)
    if row.kind_of? Array
      row = row.flatten
    end
    if @headers.empty?
        @headers = row
    else
      unless row.length == @headers.length
        raise ArgumentError, "Wrong number of fields in Table input"
      end
      append_row(row)
    end
    return self
  end

  alias :<< :add_row

  # Delete a column from the Table. Raises ArgumentError if the column name does not exist. 
  #
  # ==== Attributes
  # +colname+:: +String+ to identify the name of the column
  #
  # ==== Examples
  #     cities.del_column("State") # returns table without "State" column
  def del_column(colname)
    # check arguments
    raise ArgumentError, "Column name does not exist!" unless @table.has_key?(colname)
    
    @headers.delete(colname)
    @table.delete(colname)
    return self
  end

  # Delete a row from the Table. Raises ArgumentError if
  # the row number is not found
  #
  # ==== Attributes
  # +rownum+:: +FixNum+ to hold the row number
  #
  # ==== Examples
  #     cities.del_row(3)  # deletes row with index 3 (4th row)
  #     cities.del_row(-1) # deletes last row (per Ruby convention)
  def del_row(rownum)
    # check arguments
    if self.empty? || rownum >= @table[@headers.first].length
      raise ArgumentError, "Row number does not exist!" 
    end
    @headers.each do |col|
      @table[col].delete_at(rownum)
    end
    return self
  end


  # Rename a header value for this +Table+ object.
  # 
  # ==== Attributes
  # +orig_name+:: +String+ current header name
  # +new_name+:: +String+ indicating new header name
  def rename_header(orig_name, new_name)
    raise ArgumentError, "Original Column name type invalid" unless orig_name.kind_of? String
    raise ArgumentError, "New Column name type invalid" unless new_name.kind_of? String
    raise ArgumentError, "Column Name does not exist!" unless @headers.include? orig_name

    update_header(orig_name, new_name)
    return self
  end

  # Converts a +Table+ object to a tab-delimited string.
  # 
  # ==== Attributes
  # none
  def to_s
    result = @headers.join("\t") << "\n"
    
    @table[@headers.first].each_index do |index|
      @headers.each do |col|
        result << @table[col][index].to_s
        unless col == @headers.last
          result << "\t"
        else
          result << "\n"
        end
      end
    end
    result
  end
  
  # Converts a +Table+ object to an array of arrays (each row). The first
  # entry are the table headers.
  # 
  # ==== Attributes
  # none
  def to_a
    result = [ Array(@headers) ]
    
    @table[@headers.first].each_index do |index|
      items = []
      @headers.each do |col|
        items << @table[col][index]
      end
      result << items
    end
    result
  end

  # Counts the number of instances of a particular string, given a column name,
  # and returns an integer >= 0. Returns +nil+ if the column is not found. If
  # no parameters are given, returns the number of rows in the table.
  # 
  # ==== Attributes
  # +colname+:: OPTIONAL +String+ to identify the column to count
  # +value+:: OPTIONAL +String+ value to count
  #
  # ==== Examples
  #     cities.count  # returns number of rows in cities Table
  #     cities.size   # same as cities.count
  #     cities.length # same as cities.count
  #     cities.count("State", "NY")  # returns the number of rows with State == "NY"
  #
  def count(colname=nil, value=nil)
    if colname.nil? || value.nil?
      if @table.size > 0
        @table.each_key {|e| return @table.fetch(e).length }
      else
        return 0
      end
    end
    raise ArgumentError, "Invalid column name" unless @headers.include?(colname)
    
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
  
  alias :size :count
  alias :length :count
  
  # Returns counts of the most frequent values found in a given column in the form of a
  # Table.  Raises ArgumentError if the column is not found.  If no limit is given
  # to the number of values, only the top value will be returned.
  # 
  # ==== Attributes
  # +colname+:: +String+ to identify the column to count
  # +num+:: OPTIONAL +String+ number of values to return
  #
  # ==== Examples
  #     cities.top("State")  # returns a Table with the most frequent state in the cities Table
  #     cities.top("State", 10)  # returns a Table with the 10 most frequent states in the cities Table
  #
  def top(colname, num=1)
    freq = tally(colname).to_a[1..-1].sort_by {|k,v| v }.reverse
    return Table.new(freq[0..num-1].unshift([colname,"Count"]))
  end


  # Returns counts of the least frequent values found in a given column in the form of a
  # Table.  Raises ArgumentError if the column is not found.  If no limit is given
  # to the number of values, only the least frequent value will be returned.
  # 
  # ==== Attributes
  # +colname+:: +String+ to identify the column to count
  # +num+:: OPTIONAL +String+ number of values to return
  #
  # ==== Examples
  #     cities.bottom("State")  # returns a Table with the least frequent state in the cities Table
  #     cities.bottom("State", 10)  # returns a Table with the 10 least frequent states in the cities Table
  #
  def bottom(colname, num=1)
    freq = tally(colname).to_a[1..-1].sort_by {|k,v| v }
    return Table.new(freq[0..num-1].unshift([colname,"Count"]))
  end



  # Count instances in a particular field/column and return a +Table+ of the results.
  # Raises ArgumentError if the column is not found.
  # 
  # ==== Attributes
  # +colname+:: +String+ to identify the column to tally
  #
  # ==== Examples
  #     cities.tally("State")  # returns each State in the cities Table with number of occurences
  #
  def tally(colname)
    # check arguments
    raise ArgumentError, "Invalid column name"  unless @table.has_key?(colname)

    result = {}
    @table[colname].each do |val|
      result.has_key?(val) ? result[val] += 1 : result[val] = 1
    end
    return Table.new([[colname,"Count"]] + result.to_a)
  end

  # Select columns from the table, given one or more column names. Returns an instance
  # of +Table+ with the results.  Raises ArgumentError if any column is not valid.
  # 
  # ==== Attributes
  # +columns+:: Variable +String+ arguments to identify the columns to select
  #
  # ==== Examples
  #     cities.select("City", "State")  # returns a Table of "City" and "State" columns
  #     cities.select(cities.headers)  # returns a new Table that is a duplicate of cities
  #
  def select(*columns)
    # check arguments
    raise ArgumentError, "Invalid column name(s)" unless columns
    columns.kind_of?(Array) ? columns.flatten! : nil
    columns.each do |c|
      raise ArgumentError, "Invalid column name" unless @table.has_key?(c)
    end

    result = []
    result_headers = []
    columns.each { |col| @headers.include?(col) ? result_headers << col : nil }
    result << result_headers
    @table[@headers.first].each_index do |index|
      this_row = []
      result_headers.each do |col|
        this_row << @table[col][index]
      end
      result << this_row
    end
    result_headers.empty? ? Table.new() : Table.new(result)
  end
  
  alias :get_columns :select
  
  # Given a particular condition for a given column field/column, return a subtable
  # that matches the condition. If no condition is given, a new +Table+ is returned with
  # all records.
  # Returns an empty table if the condition is not met or the column is not found.
  # 
  # ==== Attributes
  # +colname+:: +String+ to identify the column to tally
  # +condition+:: OPTIONAL +String+ containing a ruby condition to evaluate
  #
  # ==== Examples
  #     cities.where("State", "=='NY'")  # returns a Table of cities in New York state 
  #     cities.where("State", "=~ /New.*/")  # returns a Table of cities in states that start with "New"
  #     cities.where("Population", ".to_i > 1000000")  # returns a Table of cities with population over 1 million
  #
  def where(colname, condition=nil)
    # check arguments
    raise ArgumentError, "Invalid Column Name" unless @headers.include?(colname)

    result = []
    result << @headers
    self.each do |row|
      if condition
        eval(%q["#{row[headers.index(colname)]}"] << "#{condition}") ? result << row : nil
      else
        result << row
      end
    end
    result.length > 1 ? Table.new(result) : Table.new()
  end

  alias :get_rows :where

  # Given a second table to join against, and a field/column, return a +Table+ which
  # contains a join of the two tables. Join only lists the common column once, under
  # the column name of the first table (if different from the name of thee second).
  # All columns from both tables are returned. Returns +nil+ if the column is not found.
  # 
  # ==== Attributes
  # +table2+:: +Table+ to identify the secondary table in the join
  # +colname+:: +String+ to identify the column to join on
  # +col2name+:: OPTIONAL +String+ to identify the column in the second table to join on
  #
  # ==== Examples
  #     cities.join(capitals, "City", "Capital")  # returns a Table of cities that are also state capitals
  #     capitals.join(cities, "State")  # returns a Table of capital cities with populations info from the cities table
  #
  def join(table2, colname, col2name=colname)
    # check arguments
    raise ArgumentError, "Invalid table!" unless table2.is_a?(Table)
    raise ArgumentError, "Invalid column name" unless @table.has_key?(colname)
    raise ArgumentError, "Invalid column name" unless table2.headers.include?(col2name)
    
    dedupe_headers(table2, colname)

    result = [ Array(@headers) + Array(table2.headers) ]
    @table[colname].each_index do |index|
      t2_index = table2.column(col2name).find_index(@table[colname][index])
      unless t2_index.nil?
        result << self.row(index) + table2.row(t2_index)
      end
    end
    if result.length == 1 #no rows selected
      return nil
    else
      return Table.new(result) 
    end
  end
  

  # Given a field/column, and a regular expression to match against, and a replacement string,
  # create a new table which performs a substitute operation on column data.  In the case that the
  # given replacement is a +String+, a direct substitute is performed. In the case that it is a +Hash+
  # and the matched text is one of its keys, the corresponding +Hash+ value will be substituted.
  #
  # Optionally takes a block containing an operation to perform on all matching data elements 
  # in the given column. Raises ArgumentError if the column is not found.
  # 
  # ==== Attributes
  # +colname+:: +String+ to identify the column to substitute on
  # +match+:: OPTIONAL +String+ or +Regexp+ to match the value in the selected column
  # +replace+:: OPTIONAL +String+ or +Hash+ to specify the replacement text for the given match value
  # +&block+:: OPTIONAL block to execute against matching values
  #
  # ==== Examples
  #     cities.sub("Population", /(.*?),(.*?)/, '\1\2')  # eliminate commas
  #     capitals.sub("State", /NY/, "New York")  # replace acronym with full name
  #     capitals.sub("State", /North|South/, {"North" => "South", "South" => "North"}) # Northern states for Southern and vice-versa
  #     capitals.sub("State") { |state| state.downcase } # Lowercase for all values
  #
  def sub(colname, match=nil, replace=nil, &block)
    # check arguments
    raise ArgumentError, "No regular expression to match against" unless match || block_given?
    raise ArgumentError, "Invalid column name" unless @table.has_key?(colname)

    if ! block_given?
      if ! (String.try_convert(match) || Regexp.try_convert(match))
    	   raise ArgumentError, "Match expression must be String or Regexp"
      elsif ! (replace.respond_to?(:fetch) || replace.respond_to?(:to_str))
         raise ArgumentError, "Replacement must be String or Hash"
      end
    end

    result = Table.new([@headers])
    col_index = @headers.index(colname)

    self.each do |row|
      if block_given?
        row[col_index] = block.call row[col_index]
      else
        row[col_index] = row[col_index].sub(match, replace)
      end  
      result.add_row(row)
    end
    return result
  end

  # alias :sub! :sub  

  # Return Array with the union of elements columns in the given tables, eliminating duplicates.
  # Raises an ArgumentError if a column is not found.
  #
  # ==== Attributes
  # +table2+:: +Table+ to identify the secondary table in the union
  # +colname+:: +String+ to identify the column to union
  # +col2name+:: OPTIONAL +String+ to identify the column in the second table to union
  #
  # ==== Examples
  #     cities.union(capitals, "City", "Capital")  # returns Array with all cities in both tables
  #
  def union(table2, colname, col2name=colname)
    # check arguments
    raise ArgumentError, "Invalid table!" unless table2.is_a?(Table)
    raise ArgumentError, "Invalid column name" unless @table.has_key?(colname)
    raise ArgumentError, "Invalid column name" unless table2.headers.include?(col2name)

    return self.column(colname) | table2.column(col2name)
  end

  # Return an Array with the intersection of columns from different tables, eliminating duplicates.
  # Return nil if a column is not found.
  #
  # ==== Attributes
  # +table2+:: +Table+ to identify the secondary table in the intersection
  # +colname+:: +String+ to identify the column to intersection
  # +col2name+:: OPTIONAL +String+ to identify the column in the second table to intersection
  #
  # ==== Examples
  #     cities.intersect(capitals, "City", "Capital")  # returns Array with all capitals that are also in the cities table
  #
  def intersect(table2, colname, col2name=colname)
    # check arguments
    raise ArgumentError, "Invalid table!" unless table2.is_a?(Table)
    raise ArgumentError, "Invalid column name" unless @table.has_key?(colname)
    raise ArgumentError, "Invalid column name" unless table2.headers.include?(col2name)

    return self.column(colname) & table2.column(col2name)
  end

  # Sort the table based on given column. Uses precedence as defined in the 
  # column. By default will sort by the value in the first column.
  #
  # ==== Attributes
  # +args+:: OPTIONAL +String+ to identify the column on which to sort
  #
  # ==== Options
  #     datatype => :Fixnum
  #     datatype => :Float
  #     datatype => :Date
  #
  # ==== Examples
  #     cities.sort("State")  # Re-orders the cities table based on State name
  #     cities.sort { |a,b| b<=>a }  # Reverse the order of the cities table
  #     cities.sort("State") { |a,b| b<=>a }  # Sort by State in reverse alpha order
  #
  def sort(column=nil, &block)
    col_index = 0
    if column.kind_of? String
      col_index = @headers.index(column)
    elsif column.kind_of? Fixnum
      col_index = column 
    end
    # return empty Table if empty
    if self.empty? 
      return Table.new() 
    end

    neworder = []
    self.each { |row| neworder << OrderedRow.new(row,col_index) }

    result = [neworder.shift.data] # take off headers
    block_given? ? neworder.sort!(&block) : neworder.sort!
    neworder.each { |row| result << row.data }

    return Table.new(result)
  end

  alias :sort! :sort

  # Write a representation of the +Table+ object to a file (tab delimited).
  # 
  # ==== Attributes
  # +filename+:: +String+ to identify the name of the file to write
  def write_file(filename)
    file = File.open(filename, "w")
    file.print self.to_s
  end
  
  private

  def read_file(filename)
    file = File.open(filename, "r")
    result = []
    file.each_line do |line|
      result << line.chomp.split("\t")
    end
    result.each do |row|
      begin
        add_row(row)
      rescue ArgumentError
        if row.length < @headers.length 
          (@headers.length - row.length).times { row << "" }
          add_row(row)
        else
          $stderr.puts "ArgumentError: #{row.length} fields --> #{row.join(";")}"
        end
      end
    end
  end
  
  def get_row(index)
    result = []
    if index >= @table[@headers.first].length || 
          index < -(@table[@headers.first].length)
      return result
    end 
    @headers.each { |col| result << @table[col][index].to_s }
    return result
  end
  
  def append_row(row)
    @headers.each do |col|
      @table[col] = [] unless @table[col]
      @table[col] << row.shift
    end
  end  

  def get_col(colname)
    # return empty Array if column name not found
    unless @table.has_key?(colname) 
      Array.new()
    else
      Array(@table[colname])
    end
  end
  
  def append_col(colname, column_vals)
    @headers << colname
    @table[colname] = Array.new(column_vals)
    return self
  end
  
  def update_header(item, new_item)
    i = @headers.index(item)    
    @headers[i] = new_item unless i.nil?
    @table.fetch(item,nil).nil? ? nil : @table[new_item] = @table[item] 
  end

  def dedupe_headers(table2, colname)
    # ensure no duplication of header values
    table2.headers.each do |header|
      if @headers.include?(header)
        update_header(header, '_' << header )
        if header == colname
          colname = '_' << colname
        end
      end
    end
  end

end #Table

# This class functions as a temporary representation of a row. The OrderedRow
# contains information about which column it should be sorted on, so that 
# Comparable can be implemented.

class OrderedRow
  # Contains data elements of the row
  @data = []
  # Indicates which row element (column) on which to sort
  @sort_index = 0

  # Creates a new OrderedRow. Callers must specify the index of the row
  # element which will be used for order comparisons.
  # 
  # ==== Attributes
  # +my_array+:: An array representing a row from +Table+
  # +index+:: A Fixnum value which represents the comparison value
  #
  def initialize(my_array, index)
    @data = my_array
    @sort_index = index
  end

  # Returns the row elements in an +Array+
  #
  # ==== Attributes
  # none
  def data
    return @data
  end

  # Implements comparable
  # 
  # ==== Attributes
  # +other+:: The row to be compared
  def <=>(other)
    self.data[@sort_index] <=> other.data[@sort_index]
  end

end