#!/usr/bin/env perl
use Mojolicious::Lite;
use Device::SerialPort;
use feature 'say';
use Data::Dumper;
use DBI;
use DBD::SQLite;
## Added telegram bot api

my $dbh = DBI->connect('dbi:SQLite:dbname=skud.db',"","");
my $port = Device::SerialPort->new("/dev/ttyUSB1");

# $port->user_msg(ON); 
$port->baudrate(57600); # you may change this value
$port->databits(8); # but not this and the two following
$port->parity("none");
$port->stopbits(1);
$port->write_settings;

my $h = {};
my $res = {};


use WWW::Telegram::BotAPI;



get '/' => sub {
  my $c = shift;
  $c->render(json => 'ok');
};



app->start;