#!C:\Strawberry\perl\bin\perl.exe
use warnings;
use strict;

use DBI;
use Cwd;
use Data::Dumper;

sub parse_logfile();
sub fill_tables();

my @new_msgs;
my @new_logs;
parse_logfile();
print("Parsing maillog file... done\n");

fill_tables();
print("Filling tables with new log data... done");

sub parse_logfile() {
	my $maillog = cwd()."/out";
	open(my $LOG, $maillog) or die("Can not open maillog file $maillog: $!");
	while (<$LOG>) {
		if ($_ =~ /^.+\s(<=)\s([\d\w.-]+\@[\d\w.-]+)\s.+/) {
			$_ =~ /(?<created>\d\d\d\d-\d\d-\d\d\s\d\d:\d\d:\d\d)\s(?<str>(?<int_id>[\w\d]+-[\w\d]+-[\w\d]+)\s.+\s(?<id>id=[\d\w.-]+\@?[\d\w.-]+))/;
			my @table_rows = ($+{created}, $+{id}, $+{int_id},$+{str});
			push(@new_msgs, \@table_rows);
		}
		else {
			$_ =~ /(?<created>\d\d\d\d-\d\d-\d\d\s\d\d:\d\d:\d\d)\s(?<str>.+)/;
			my $created = $+{created};
			my $str = $+{str};
			$str =~ /(?<int_id>[\w\d]+-[\w\d]+-[\w\d]+)\s.+/;
			my $int_id = defined $+{int_id} ? $+{int_id} : "";
			$str =~ /.+\s(?<flag><=|=>|->|\*\*|==)?\s(?<address>[\d\w.-]+\@[\d\w.-]+)?\s/;
			my $address = defined $+{address} ? $+{address} : "";
			my @table_rows = ($created, $int_id, $str, $address);
			push(@new_logs, \@table_rows);
		}
	}
	close($LOG);
}

sub fill_tables(){
    my $db = "DBI:mysql:tlazarevsql";
	my $username = "root";
	my $password = 'test';

	my $dbh = DBI->connect($db, $username, $password);
	foreach my $msg (@new_msgs) {
		my $sth = $dbh->prepare("INSERT INTO message (created, id, int_id, str) values (?,?,?,?)");
		$sth->execute( @{$msg}) or process_error($DBI::errstr, $dbh);
		$sth->finish();
	}
	print("Filling message table... done\n");
	foreach my $log (@new_logs) {
		my $sth = $dbh->prepare("INSERT INTO log (created, int_id, str, address) values (?,?,?,?)");
		$sth->execute(@{$log}) or process_error($DBI::errstr, $dbh);
		$sth->finish();
	}
	print("Filling log table... done\n");
	$dbh->disconnect();
}

sub process_error($;$){
	my ($err_msg, $dbh) = @_;
	if ($err_msg =~ /Duplicate entry/) {
		print("Warning: Seems current maillog was already added to tables\n");
	}
	$dbh->disconnect();
	exit(1);
}