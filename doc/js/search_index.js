var search_data = {"index":{"searchIndex":["table","add_column()","add_row()","bottom()","column()","count()","del_column()","del_row()","get_columns()","get_rows()","intersect()","join()","length()","new()","row()","select()","size()","sub()","sub!()","tally()","to_a()","to_s()","top()","union()","where()","write_file()"],"longSearchIndex":["table","table#add_column()","table#add_row()","table#bottom()","table#column()","table#count()","table#del_column()","table#del_row()","table#get_columns()","table#get_rows()","table#intersect()","table#join()","table#length()","table::new()","table#row()","table#select()","table#size()","table#sub()","table#sub!()","table#tally()","table#to_a()","table#to_s()","table#top()","table#union()","table#where()","table#write_file()"],"info":[["Table","","Table.html","","<p>This class is a Ruby representation of a table. All data is captured as\ntype <code>String</code> by default. Columns …\n"],["add_column","Table","Table.html#method-i-add_column","(colname, column_vals)","<p>Add a column to the Table. Returns nil if the column name is already taken \nor there are not the correct …\n"],["add_row","Table","Table.html#method-i-add_row","(row_vals)","<p>Add a row to the Table, appending it to the end. Returns nil if  there are\nnot the correct number of …\n"],["bottom","Table","Table.html#method-i-bottom","(colname, num=1)","<p>Counts the number of instances of a particular string, given a column name,\nand returns an integer &gt;= …\n"],["column","Table","Table.html#method-i-column","(colname)","<p>Return a copy of a column from the table, identified by column name.\nReturns <code>nil</code> if column name not found. …\n"],["count","Table","Table.html#method-i-count","(colname=nil, value=nil)","<p>Counts the number of instances of a particular string, given a column name,\nand returns an integer &gt;= …\n"],["del_column","Table","Table.html#method-i-del_column","(colname)","<p>Delete a column from the Table. Returns nil if the column name does not\nexist.\n<p>colname &mdash; <code>String</code> to identify …\n\n"],["del_row","Table","Table.html#method-i-del_row","(rownum)","<p>Delete a row from the Table. Returns nil if  the row number is not found.\n<p>rownum &mdash; <code>FixNum</code> to hold the row …\n\n"],["get_columns","Table","Table.html#method-i-get_columns","(*columns)",""],["get_rows","Table","Table.html#method-i-get_rows","(colname, condition=nil)",""],["intersect","Table","Table.html#method-i-intersect","(table2, colname, col2name=nil)","<p>Return the intersection of columns from different tables, eliminating\nduplicates. Return nil if a column …\n"],["join","Table","Table.html#method-i-join","(table2, colname, col2name=nil)","<p>Given a second table to join against, and a field/column, return a\n<code>Table</code> which contains a join of the …\n"],["length","Table","Table.html#method-i-length","(colname=nil, value=nil)",""],["new","Table","Table.html#method-c-new","(input=nil)","<p>Instantiate a <code>Table</code> object using a tab-delimited file\n<p>input &mdash; OPTIONAL <code>Array</code> of rows or <code>String</code> to identify …\n\n"],["row","Table","Table.html#method-i-row","(index)","<p>Return a copy of a row from the table as an <code>Array</code>, given an\nindex (i.e. row number). Returns empty Array …\n"],["select","Table","Table.html#method-i-select","(*columns)","<p>Select columns from the table, given one or more column names. Returns an\ninstance of <code>Table</code> with the …\n"],["size","Table","Table.html#method-i-size","(colname=nil, value=nil)",""],["sub","Table","Table.html#method-i-sub","(colname, re, replace)","<p>Given a field/column, and a regular expression to match against, and a\nreplacement string, update the …\n"],["sub!","Table","Table.html#method-i-sub-21","(colname, re, replace)",""],["tally","Table","Table.html#method-i-tally","(colname)","<p>Count instances in a particular field/column and return a\n<code>Table</code> of the results. Returns <code>nil</code> if the column …\n"],["to_a","Table","Table.html#method-i-to_a","()","<p>Converts a <code>Table</code> object to an array of arrays (each row)\n<p>none\n"],["to_s","Table","Table.html#method-i-to_s","()","<p>Converts a <code>Table</code> object to a tab-delimited string.\n<p>none\n"],["top","Table","Table.html#method-i-top","(colname, num=1)","<p>Counts the number of instances of a particular string, given a column name,\nand returns an integer &gt;= …\n"],["union","Table","Table.html#method-i-union","(table2, colname, col2name=nil)","<p>Return the union of columns from different tables, eliminating duplicates.\nReturn nil if a column is …\n"],["where","Table","Table.html#method-i-where","(colname, condition=nil)","<p>Given a particular condition for a given column field/column, return a\nsubtable that matches the condition. …\n"],["write_file","Table","Table.html#method-i-write_file","(filename)","<p>Write a representation of the <code>Table</code> object to a file (tab\ndelimited).\n<p>filename &mdash; <code>String</code> to identify the …\n\n"]]}}