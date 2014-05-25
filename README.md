Tablestakes
===========
Tablestakes is a gem for processing tabular data.  It is for people who would rather not meddle with
a spreadsheet, or load their data into a SQL database.  You get the instant gratification of being
able to read a tab-delimited file, with header values, and then do field counts, field modifications, 
selections, joins, and sorts to your heart's content. Tablestakes operates only in memory, so it
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
- [Interacting with your Data](#interacting-with-your-data)

How to Install
--------------

Tablestakes also does well in the IRB interactive shell, you can make use of:

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

Tablestakes is meant to be fast and easy for manipulating your data. It maintains ruby
conventions, like use of Enumerators, method chaining, and mostly non-destructive methods.

Tablestakes tables also maintain some conventions for simplicity:

* Table column names are always the values in the first row of your data file.
* Fields in the table are always strings (although you can treat them as numbers or dates
when needed).
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
cities.column('State') # returns ["Texas", "Tennessee", "California", ...]
```

If you're uncertain of your header names, they are accessible as an Array via the
`Table#headers` method.

```ruby
cities.headers # returns ["2012 rank", "City", "State", ...]
```

Rows can be returned when a numeric index is known.  To return the first data row:

```ruby
cities.row(0) # returns ["119", "Amarillo", "Texas", "195250", "190695", ...]
```

Table columns can be selected specifically with the `Table#select` method:

```ruby
cities.select("City", "State", "2010 Census") # returns a table with only those columns
```

In order to select rows, use `Table#where`, which allows you to select rows given a ruby
statement to be evaluated against a given value in a column.  For instance:

```ruby
cities.where("State", "=~ /^N.*/") # returns a sub-table of cities in states that begin with 'N'
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

Additionally, you can create a separate Table object that tallies on a given column

```ruby
cities.tally('State')  # returns a Table of States and the number of times they appear
```


Updating Data
-------------

_To be added_


Join, Union, and Intersect
--------------------------

_To be added_


Interacting with your Data
--------------------------

Typically, you can accomplish your goals with chained queries of the datatable.  Here
are some examples:

1.  Create a new table by reading it from a file

    ```ruby
    cities = Table.new('cities.txt')
    capitals = Table.new('capitals.txt')
    ```
    
2.  Find all of the cities in New York

    ```ruby
    ny_cities = cities.where("State", "== 'New York'")
    ```
    
3.  Find all of the capitals which are not in the set of most populated cities

    ```ruby
    small_caps = capitals.column("Capital") - capitals.join(cities, 'Capital', 'City').column('Capital')
    ```
    
4.  Read a file, select the columns and rows you want, and write the subtable as a tab-delimited
file.
    
    ```ruby
    Table.new('cities.txt').select('City','State','2012 Population').where('2012 Population',".to_i > 1000000").write_file('big_cities.txt')
    ```
    
Some methods, such as `Table#row` and `Table#column` return Arrays, and of course these are
readily modified using their own native methods.

