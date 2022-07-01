#!C:\Strawberry\perl\bin\perl.exe
use warnings;
use strict;

use DBI;

sub create_db() {
	my $db = "DBI:mysql:tlazarevsql";
	my $username = "root";
	my $password = 'test';

	my $dbh = DBI->connect($db, $username, $password);

	my @actions = (
		"CREATE TABLE IF NOT EXISTS message (
        created TIMESTAMP(0) NOT NULL,
        id VARCHAR(500) NOT NULL,
        int_id CHAR(16) NOT NULL,
        str VARCHAR(1000) NOT NULL,
        status BOOL,
        CONSTRAINT message_id_pk PRIMARY KEY(id)
		);",
		"CREATE TABLE IF NOT EXISTS log (
	    created TIMESTAMP(0) NOT NULL,
	    int_id  CHAR(16) NOT NULL,
	    str     VARCHAR(1000),
	    address VARCHAR(500)
		);",
		"CREATE INDEX message_created_idx ON message (created);",
		"CREATE INDEX message_int_id_idx ON message (int_id);",
		"CREATE INDEX log_address_idx USING HASH ON log (address);"
	);

	for my $sql (@actions) {
		$dbh->do($sql) or process_error($DBI::errstr, $dbh);
	}
	$dbh->disconnect();
}

sub process_error($;$){
	my ($err_msg, $dbh) = @_;
	if ($err_msg =~ /Duplicate/) {
		print("Warning: Item already exists and won't be processed\n");
	}
	else {
		$dbh->disconnect();
		exit(1);
	}
}

create_db();
print("Tables creation... done\n");