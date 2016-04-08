#!/usr/bin/env perl
use DBI;
use feature 'say';
use Data::Dumper;

my $dbh = DBI->connect('dbi:SQLite:dbname=skud.db',"","");

my %user = (
       card_id=>'7357893', 
       pin=>'1234', 
       name=>'DemoName', 
       surname=>'DemoSurname', 
       email=>'pavel@fablab61.ru', 
       phone=>'+79885851900'
    );

add_to_db( \%user ,'users');

sub add_to_db {
    my ($hash, $table_name) = @_;
    my $h = prepare_sql($hash);
    $dbh->do("INSERT INTO ".$table_name." (".$h->{'fields'}.") VALUES (".$h->{'values'}.")");
    return 0;
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