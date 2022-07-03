# Gasprombank interview task implementation

**create_tables directory**

Contains Perl scripts to create and fill tables:
- create.pl to create tables
- fill.pl to fill tables
- out - provided maillog file

**web_page directory**
- webpage.html - HTML page with interface to search specified address<br>
  performs search of specified address in address column of log table and in str column in message table
- scripts/search.pl - script to search and generate output WEB page<br>
  should be located in web_server root
