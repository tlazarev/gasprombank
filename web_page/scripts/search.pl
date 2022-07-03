#!C:\Strawberry\perl\bin\perl.exe
use warnings;
use strict;
use DBI;
use CGI;

sub search();
sub query_links($);


my $cgi = CGI->new;
print "Content-Type:text/html\r\n\r\n";

my $addr_to_search = $cgi->param('address');
$addr_to_search =~ s/%40/@/g;
search();

sub search() {
    my $db = "DBI:mysql:tlazarevsql";
    my $username = "root";
    my $password = 'test';

    my $dbh = DBI->connect($db, $username, $password);
    query_links($dbh);
    $dbh->disconnect();
}

sub query_links($) {
    my ($dbh) = @_;
    my $sql = "(SELECT created,str,int_id FROM message WHERE str LIKE '%$addr_to_search%')
               UNION
               (SELECT created,str,int_id FROM log WHERE address=\"$addr_to_search\")
               ORDER BY created,int_id";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $max_records_count = 100;
    my $current_records_num = 0;
    while (my @str = $sth->fetchrow_array()) {
        if ($current_records_num < $max_records_count) {
            if ($current_records_num == 0) {
                print("<h1>Search result:</h1>");
            }
            print("${str [ 0 ]} ${str [ 1 ]}");
            print "<br/>";
        }
        else {
            print("<p style=\"color:red\">Warning: max number of records exceeded, only first 100 are displayed!</p>");
            return 1;
        }
        $current_records_num++;
    }
    if ($current_records_num == 0) {
        print("<p style=\"color:red\"><b>E-mail was not found at any tables!</b></p>");
    }
    $sth->finish();
    return 0;
}
