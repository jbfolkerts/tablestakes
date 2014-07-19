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
  attr_reader :headers
  @headers =[]
  @table = {}
  @indices = {}
  # Structure of @table hash 
  # { :col1 => [1, 2, 3], :col2 => [1, 2, 3] }
  

  # Instantiate a +Table+ object using a tab-delimited file
  # 
  # +input+:: OPTIONAL +Array+ of rows or +String+ to identify the name of the tab-delimited file to read
  def initialize(input=nil)
    @headers = []
    @table = {}
    @indices = {}
    
    if input.respond_to?(:fetch)
      if input[0].respond_to?(:fetch)
        #create +Table+ from rows
        add_rows(input)
      end
    elsif input.respond_to?(:upcase)
      # a string, then read_file
      read_file(input)
    elsif input.respond_to?(:headers)
      init(input)
    end
    # else create empty +Table+
  end
    
  # Return a copy of a column from the table, identified by column name.
  # Returns +nil+ if column name not found.
  # 
  # +colname+:: +String+ to identify the name of the column
  def column(colname)
    # check arguments
    return nil unless @table.has_key?(colname)

    Array(@table[colname])
  end
  
  # Return a copy of a row from the table as an +Array+, given an index
  # (i.e. row number). Returns empty Array if the index is out of bounds.
  # 
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
  # +colname+:: +String+ to identify the name of the column
  # +column_vals+:: +Array+ to hold the column values
  # Examples:
  #     add_column("Header", [e1, e2, e3])
  #     add_column(array_including_header)
  #     add_column("Header", "e1", "e2", ...)
  def add_column(*args)
    if args.kind_of? Array
      args = args.flatten
      colname = args.shift
      column_vals = args
    else
      raise ArgumentError, "Invalid Arguments to add_column"
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
  # +array_of_rows+:: +Array+ of +Arrays+ to hold the rows values
  # Examples:
  #     add_rows([ [e1, e2, e3], [e1, e2, e3] ])
  def add_rows(array_of_rows)
    array_of_rows.each do |r|
      add_row(r.clone)
    end
    return self
  end

  # Add a row to the Table, appending it to the end. Raises ArgumentError if 
  # there are not the correct number of values.
  #
  # +row+:: +Array+ to hold the row values
  # Examples:
  #     add_row([e1, e2, e3])
  #     add_row("e1", "e2", "e3", ...)
  def add_row(*row)
    if row.kind_of? Array
      row = row.flatten
    else
      raise ArgumentError, "Invalid Arguments to add_row"
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

  # Delete a column from the Table. Raises ArgumentError if the column name does not exist. 
  #
  # +colname+:: +String+ to identify the name of the column
  def del_column(colname)
    # check arguments
    raise ArgumentError, "Column name does not exist!" unless @table.has_key?(colname)
    
    @headers.delete(colname)
    @table.delete(colname)
    return self
  end

  # Delete a row from the Table. Raises ArgumentError if
  # the row number is not found.
  #
  # +rownum+:: +FixNum+ to hold the row number
  def del_row(rownum)
    # check arguments
    raise ArgumentError, "Row number does not exist!" unless rownum <= @table[@headers.first].length

    @headers.each do |col|
      @table[col].delete_at(rownum)
    end
    return self
  end


  # Converts a +Table+ object to a tab-delimited string.
  # 
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
  
  # Converts a +Table+ object to an array of arrays (each row)
  # 
  # none
  def to_a
    result = [ Array(@headers) ]
    
    @table[@headers.first].length.times do |row|
      items = []
      @headers.each do |col|
        items << @table[col][row]
      end
      result << items
    end
    result
  end

  # Counts the number of instances of a particular string, given a column name,
  # and returns an integer >= 0. Returns +nil+ if the column is not found. If
  # no parameters are given, returns the number of rows in the table.
  # 
  # +colname+:: OPTIONAL +String+ to identify the column to count
  # +value+:: OPTIONAL +String+ value to count
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
  
  alias :size :count
  alias :length :count
  
  # Counts the number of instances of a particular string, given a column name,
  # and returns an integer >= 0. Returns +nil+ if the column is not found. If
  # no parameters are given, returns the number of rows in the table.
  # 
  # +colname+:: +String+ to identify the column to count
  # +num+:: OPTIONAL +String+ number of values to return
  def top(colname, num=1)
    freq = tally(colname).to_a[1..-1].sort_by {|k,v| v }.reverse
    return Table.new(freq[0..num-1].unshift([colname,"Count"]))
  end


  # Counts the number of instances of a particular string, given a column name,
  # and returns an integer >= 0. Returns +nil+ if the column is not found. If
  # no parameters are given, returns the number of rows in the table.
  # 
  # +colname+:: +String+ to identify the column to count
  # +num+:: OPTIONAL +String+ number of values to return
  def bottom(colname, num=1)
    freq = tally(colname).to_a[1..-1].sort_by {|k,v| v }
    return Table.new(freq[0..num-1].unshift([colname,"Count"]))
  end



  # Count instances in a particular field/column and return a +Table+ of the results.
  # Returns +nil+ if the column is not found.
  # 
  # +colname+:: +String+ to identify the column to tally
  def tally(colname)
    # check arguments
    return nil unless @table.has_key?(colname)

    result = {}
    @table[colname].each do |val|
      result.has_key?(val) ? result[val] += 1 : result[val] = 1
    end
    return Table.new([[colname,"Count"]] + result.to_a)
  end

  # Select columns from the table, given one or more column names. Returns an instance
  # of +Table+ with the results.  Returns nil if any column is not valid.
  # 
  # +columns+:: Variable +String+ arguments to identify the columns to select
  def select(*columns)
    # check arguments
    columns.each do |c|
      return nil unless @table.has_key?(c)
    end

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
  
  alias :get_columns :select
  
  # Given a particular condition for a given column field/column, return a subtable
  # that matches the condition. If no condition is given, a new +Table+ is returned with
  # all records.
  # Returns +nil+ if the condition is not met or the column is not found.
  # 
  # +colname+:: +String+ to identify the column to tally
  # +condition+:: OPTIONAL +String+ containing a ruby condition to evaluate
  def where(colname, condition=nil)
    # check arguments
    return nil unless @table.has_key?(colname)

    result = []
    result << @headers
    @table[colname].each_index do |index|
      if condition
        eval(%q["#{@table[colname][index]}"] << "#{condition}") ? result << get_row(index) : nil
      else
        result << get_row(index)
      end
    end
    result.length > 1 ? Table.new(result) : nil
  end

  alias :get_rows :where

  # Given a second table to join against, and a field/column, return a +Table+ which
  # contains a join of the two tables. Join only lists the common column once, under
  # the column name of the first table (if different from the name of thee second).
  # All columns from both tables are returned. Returns +nil+ if the column is not found.
  # 
  # +table2+:: +Table+ to identify the secondary table in the join
  # +colname+:: +String+ to identify the column to join on
  # +col2name+:: OPTIONAL +String+ to identify the column in the second table to join on
  def join(table2, colname, col2name=nil)
    # check arguments
    raise ArgumentError, "Invalid table!" unless table2.is_a?(Table)
    return nil unless @table.has_key?(colname)
    if col2name.nil?   # Assume colname applies for both tables
      col2name = colname
    end
    t2_col_index = table2.headers.index(col2name)
    return nil unless t2_col_index # is not nil

    
    # ensure no duplication of header values
    table2.headers.each do |h|
      if @headers.include?(h)
        update_header(h, '_' << h )
        if h == colname
          colname = '_' << colname
        end
      end
    end

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
  # update the table such that it substitutes the column data with the replacement string.
  # Returns +nil+ if the column is not found.
  # 
  # +colname+:: +String+ to identify the column to join on
  # +re+:: +Regexp+ to match the value in the selected column
  # +replace+:: +String+ to specify the replacement text for the given +Regexp+
  def sub(colname, re, replace)
    # check arguments
    raise ArgumentError, "No regular expression to match against" unless re
    raise ArgumentError, "No replacement string specified" unless replace
    return nil unless @table.has_key?(colname)
    
    @table[colname].each do |item|
      item.sub!(re, replace)
    end
    return self
  end

  # Return the union of columns from different tables, eliminating duplicates.
  # Return nil if a column is not found.
  #
  # +table2+:: +Table+ to identify the secondary table in the union
  # +colname+:: +String+ to identify the column to union
  # +col2name+:: OPTIONAL +String+ to identify the column in the second table to union
  def union(table2, colname, col2name=nil)
    # check arguments
    raise ArgumentError, "Invalid table!" unless table2.is_a?(Table)
    return nil unless @table.has_key?(colname)
    if col2name.nil?   # Assume colname applies for both tables
      col2name = colname
    end
    return nil unless table2.headers.include?(col2name)

    return self.column(colname) | table2.column(col2name)
  end

  # Return the intersection of columns from different tables, eliminating duplicates.
  # Return nil if a column is not found.
  #
  # +table2+:: +Table+ to identify the secondary table in the intersection
  # +colname+:: +String+ to identify the column to intersection
  # +col2name+:: OPTIONAL +String+ to identify the column in the second table to intersection
  def intersect(table2, colname, col2name=nil)
    # check arguments
    raise ArgumentError, "Invalid table!" unless table2.is_a?(Table)
    return nil unless @table.has_key?(colname)
    if col2name.nil?   # Assume colname applies for both tables
      col2name = colname
    end
    return nil unless table2.headers.include?(col2name)

    return self.column(colname) & table2.column(col2name)
  end

  alias :sub! :sub  
  
  # Write a representation of the +Table+ object to a file (tab delimited).
  # 
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
      if fields.length < @headers.length
        (@headers.length - fields.length).times { fields << "" } 
      elsif fields.length > @headers.length
        $stderr.write "INVALID NUMBER OF FIELDS: #{fields.join(';')}\n"
      else    
        @headers.each { |col|  @table[col] << fields.shift }
      end
    nil
    end
  end
  
  def get_row(index)
    result = []
    @headers.each do |col|
      result << @table[col][index].to_s
    end
    return result
  end
  
  def append_row(row)
    @headers.each do |col|
      @table[col] = [] unless @table[col]
      @table[col] << row.shift
    end
  end  

  def get_col(colname)
    Array.new(@table[colname])
  end
  
  def append_col(colname, column_vals)
    @headers << colname
    @table[colname] = Array.new(column_vals)
    return self
  end

  def copy
    result = []
    result << @headers
    @table[@headers.first].each_index do |index|
      result << get_row(index)
    end
    result.length > 1 ? Table.new(result) : Table.new()
  end
  
  def update_header(item, new_item)
    i = @headers.index(item)    
    @headers[i] = new_item unless i.nil?
    @table.fetch(item,nil).nil? ? nil : @table[new_item] = @table[item] 
  end
  
  def init(table)
    @headers = table.headers.map {|x| x }
    @headers.each do |key|
      @table[key] = table.table[key].map {|x| x }
    end
    @indices = {}
  end
end
