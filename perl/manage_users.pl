use DBD::SQLite;
use common::sense;
use Data::Dumper;
my $dbh = DBI->connect('dbi:SQLite:dbname=skud.db',"","");


#my $sth = $dbh->table_info(undef, $schema, $table, $type, \%attr);
#my $sth = $dbh->table_info(undef, '', '', '');
#my $sth = $dbh->table_info(undef, '', '', '');
# my $sth = $dbh->table_info();
# #$sth->fetchall_hashref;
# warn Dumper $sth->fetchall_arrayref;
# The value of $type is a comma-separated list of one or more types of tables to be returned in the result set. 
# Each value may optionally be quoted, e.g.:
# $type = "TABLE";
# $type = "'TABLE','VIEW'";

my $action = $ARGV[0];
chomp($action);
warn $action;

if (not defined $action) {
  die "Usage: manage_users.pl {add|remove|change}\n";
}

if ($action eq 'add') {
	my $ahash = {};
	my @required_fields = ('card_id', 'pin', 'name', 'surname', 'email', 'phone');
	for (@required_fields) {
		print $_.":";
		$ahash->{$_}=<STDIN>;
		chomp($ahash->{$_});
	}
	write_to_db($ahash, 'users');
}

if ($action eq 'remove') {
		print "Please select how to search for user. 1-surname,2-phone,3-email :";
		my $search_type=<STDIN>;
		chomp($search_type);
		my $field;

		if ($search_type == 1) {
			$field = 'surname';
		}
		if ($search_type == 2) {
			$field = 'phone';
		}
		if ($search_type == 3) {
			$field = 'email';
		}

		print "What to search:";
		my $search=<STDIN>;
		chomp($search);
		my $sth = $dbh->prepare("SELECT * FROM users WHERE ".$field." LIKE ?")  or die $dbh->errstr;
		$sth->execute($search);
		my $result = $sth->fetchrow_hashref;
		say "Found row: ".Dumper $result;
		print "Do you really want to remove that user [y/n]:";
		my $answ=<STDIN>;
		chomp($answ);
		if ($answ eq 'y') {
			my $rows_deleted = $dbh->do(q{DELETE FROM users WHERE id = ?}, undef, $result->{id}) or die $dbh->errstr;
			warn Dumper $rows_deleted;
		} else {
			die "You haven't confirm the action. Run script again";
		}
}

sub prepare_sql {
	my $hash = shift;
	my @fields;
	my @values;
	foreach my $key ( keys %$hash ) {
		push @fields, $key;
		push @values, "'".$hash->{$key}."'";
	}
	my $new_hash;
	$new_hash->{'fields'} = join(", ", @fields);
	$new_hash->{'values'} = join(", ", @values);
	return $new_hash;
}

sub write_to_db {
	my ($hash, $table_name) = @_;
	my $h = prepare_sql($hash);
	# warn Dumper $h;
	my $a = "INSERT INTO ".$table_name." (".$h->{'fields'}.") VALUES (".$h->{'values'}.")";
	warn $a;
	$dbh->do($a) or die $dbh->errstr;
	# return 0;
}