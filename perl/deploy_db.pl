#!/usr/bin/env perl
use DBI;
use feature 'say';
use Data::Dumper;

my $dbh = DBI->connect('dbi:SQLite:dbname=skud.db',"","");

create_tables($dbh);

sub create_tables {
	my $dbh = shift;
	my $sql = <<'END_SQL';
CREATE TABLE log (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	time DEFAULT CURRENT_TIMESTAMP,
    reader_id INTEGER,
    code INTEGER,
    code_type VARCHAR(4),
    user_id INTEGER,
    telegram_id INTEGER,
    is_blocked INTEGER
    )
END_SQL
	$dbh->do($sql);

    my $sql = <<'END_SQL';
CREATE TABLE entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    time DEFAULT CURRENT_TIMESTAMP,
    reader_id INTEGER,
    user_id INTEGER
    )
END_SQL
    $dbh->do($sql);

	$sql = <<'END_SQL';
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created DEFAULT CURRENT_TIMESTAMP,
    card_id INTEGER,
    pin INTEGER,
    name VARCHAR(160),
    surname VARCHAR(160),
    email VARCHAR(160),
    phone VARCHAR(12)
    )
END_SQL
    $dbh->do($sql); 
	
	return 0;
}