Tablestakes
===========

[![Gem Version][GV img]][Gem Version]
[![Dependency Status][DS img]][Dependency Status]

[Gem Version]: https://rubygems.org/gems/tablestakes
[Dependency Status]: https://gemnasium.com/jbfolkerts/tablestakes

[GV img]: https://badge.fury.io/rb/tablestakes.png
[DS img]: https://gemnasium.com/jbfolkerts/tablestakes.png

Tablestakes is a gem for processing tabular data.  It is for people who would rather not meddle with
a spreadsheet, or load their data into a SQL database.  You get the instant gratification of being
able to read a tab-delimited file, with header values, and then do field counts, field modifications, 
selections, joins to your heart's content. Tablestakes operates only in memory, so it
is fast.  Of course that also means that there are some size limitations -- very large tables
should be processed with another library.

Contents
--------
- [How to install](#how-to-install)
- [Philosophy and Conventions](#philosophy-and-conventions)
- [Loading and Writing Files](#loading-and-writing-files)
- [Selecting Data](#selecting-data)
- [Counting Data](#counting-data)
- [Updating Data](#updating-data)
- [Join, Union, and Intersect](#join-union-and-intersect)
- [Sorting Data](#sorting-data)
- [Interacting with your Data](#interacting-with-your-data)

How to Install
--------------

1.  Install the gem

    ```shell
    gem install tablestakes
    ```

2.  Add the `tablestakes` gem to your ruby code

    ```ruby
    require 'tablestakes'
    ```
    
Now you're ready to start slicing and dicing your data tables!


Philosophy and Conventions
--------------------------

Tablestakes is meant to be fast and easy for manipulating your data. It maintains Ruby
conventions, like method chaining and mostly non-destructive methods.

Tablestakes tables also maintain some conventions for simplicity:

* Table column names are always the values in the first row of your data file.
* Fields in the table are always strings (conversion to numbers or dates is a potential enhancement).
* Methods only modify one dimension at a time.  So, for instance, `Table#select` only selects
columns and `Table#where` only selects rows. Chain them together for the desired effect.
* Tables are ordered, both columns and rows, until modified.


Loading and Writing Files
-------------------------
Tables can be created from tab-delimited data files, using the Table constructor:

```ruby
cities = Table.new('cities.txt')
```

Tables can also be created from other tables (useful in saving sub-tables), they can be
created from an Array of rows (embedded Arrays), and the `Table#new` function also
creates a blank table when no parameters (or nil) are given.

Tables are saved as tab-delimited files using the `Table#write_file` method:

```ruby
cities.write_file('new-cities.txt')
```

Tables can also be sent to your favorite I/O channel using the `Table#to_s` function,
which creates a tab-delimited string.


Selecting Data
--------------

Selecting your data happens in two dimensions - rows and columns.  First, you
can create an ordered Array of a row or column just by asking for it by header name.

```ruby
cities.column('State')     # returns ["Texas", "Tennessee", "California", ...]
```

If you're uncertain of your header names, they are accessible as an Array via the
`Table#headers` method.

```ruby
cities.headers    # returns ["2012 rank", "City", "State", ...]
```

Rows can be returned when a numeric index is known.  To return the first data row:

```ruby
cities.row(0)     # returns ["119", "Amarillo", "Texas", "195250", "190695", ...]
```

Table columns can be selected specifically with the `Table#select` method:

```ruby
cities.select("City", "State", "2010 Census")    # returns a table with only those columns
```

In order to select rows, use `Table#where`, which allows you to select rows given a ruby
statement to be evaluated against a given value in a column.  For instance:

```ruby
cities.where("State", "=~ /^N.*/")    # returns a sub-table of cities in states that begin with 'N'
```

Use single quotes when comparing your column value to a string.  Also, note that all
numeric data is stored as a string value unless explicitly converted by your selection
statement.


Counting Data
-------------

One reason to manipulate tables quickly in memory is to get counts for histograms,
pie charts, and other data analysis representations.  Tablestakes gives you simple methods
for counting.

```ruby
cities.size    # returns the number of rows in the cities table
cities.length  # same as cities.size
cities.count   # same as cities.size
cities.count('State', 'New York') # returns the number of entries that have State=='New York'
```

If you want to know the frequency of certain values in your data
set, there are a couple of methods for selecting the most and 
least frequent items.

```ruby
cities.top("State")         # returns the state with the most cities listed
cities.top("State", 5)      # returns the 5 most frequent states
cities.bottom("State", 5)   # returns the 5 least frequent states
```

Additionally, you can create a separate Table object that tallies on a given column

```ruby
cities.tally('State')  # returns a Table of States and the number of times they appear
puts cities.tally('State').to_s # print a table of the frequency that states appear
```


Updating Data
-------------

Sometimes data in a table needs to be cleaned up and modified.  
the `Table#sub` method provides a way to eliminate common garbage from 
your data such as stray characters.

```ruby
cities.sub("2012 land area", /.*sq mi/, '')     # deletes 'sq mi' from the 2012 land area field
``` 

`Table#sub` takes a regular expression and a substitute string, which 
gives some flexibility in how data is updated.  Note that this is 
a method which modifies the table object.

Join, Union, and Intersect
--------------------------

Once your tables are read into memory, it is useful to join them
with other tables or find the common elements.  Tablestakes 
provides a simple join function as follows

```ruby
capitals.join(cities, "Capital", "City")    # create a table which only contains highly populated Capital cities
```

You may also need to quickly compare the elements of one column 
in a table with the elements in another table.  `Table#union` and `Table#intersect` 
are for that situation.

```ruby
capitals.union(cities, "Capitals", "Cities")       # returns an array of all cities in both tables
capitals.intersect(cities, "Capitals", "Cities")   # returns an array of only the cities in both tables
```

Sorting Data
------------

Sorting your data table can be done on any given column (if not specified, it defaults to the first
column). Any blocks passed to the sort function are then used internally to sort the column.  Here 
are some examples:

```ruby
cities.sort("State")                  # Re-orders the cities table based on State name
cities.sort { |a,b| b<=>a }           # Reverse the order of the cities table
cities.sort("State") { |a,b| b<=>a }  # Sort by State in reverse alpha order
```

Of course you don't necessarily want to sort every column by it's String value.  To sort using an
on-the-fly type conversion, supply the sort function with an options Hash as in the following:

```ruby
cities.sort("2012 estimate", :Fixnum)     # Sorts cities by 2012 population
```

Interacting with your Data
--------------------------

Typically, you can accomplish your goals with chained queries of the datatable.  Here
are some examples:

1.  Find all of the cities in New York

    ```ruby
    ny_cities = cities.where("State", "== 'New York'")
    ```
    
2.  Find all of the capitals which are not in the set of most populated cities

    ```ruby
    small_caps = capitals.column("Capital") - capitals.join(cities, 'Capital', 'City').column('Capital')
    ```
    
3.  Read a file, select the columns and rows you want, and write the subtable as a tab-delimited
file.
     
    ```ruby
    Table.new('cities.txt').select('City','State','2012 estimate').where('2012 estimate', ".to_i > 1000000").write_file('big_cities.txt')
    ```
    
Some methods, such as `Table#row` and `Table#column` return Arrays, and of course these are
readily modified using their own native methods.
