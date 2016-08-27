use Device::SerialPort;
use feature 'say';
use Data::Dumper;
use DBI;
use DBD::SQLite;
use WWW::Telegram::BotAPI;
use common::sense;

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;
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


my @ids_to = (218718957,103270583);
my $api = WWW::Telegram::BotAPI->new (
    token => ''
);



while (1) {
  my $string = $port->lookfor();
  if ($string) {
  	say $string;
 	if ($string =~ /^(\w+).Card:(\d+)/) {
 		$h->{reader_where} = $1;
 		$h->{card_id} = $2;

 		if ($h->{reader_where} eq "Entrance") {
 			$res = is_user_in_db($h->{card_id});
 			warn Dumper $res;	
 		}

 		if ($h->{reader_where} eq "Exitway") {
 			$res = is_user_in_db($h->{card_id});
 			if (defined $res) {
 				$res->{suffix} = "ВЫХОД";
 				#$port->write("o"); # open door. you can comment it if in hardware allowed any card for exit
 				log_telegram($res);
 			}
 		}
 	}

 	if ($string =~ /Entrance.Pin:(\d+)/ ) {
 		say "pin:".$1;
 		if ($res->{pin} == $1) {
 			$port->write("o");
 			$res->{suffix} = "ВХОД";
 			log_telegram($res);
 			$res = {};
 			$h = {}
 		} 
 	}

  }
}


sub is_user_in_db {   
	my $card_id = shift;
	my $sth = $dbh->prepare("SELECT id, card_id, pin, name, surname FROM users WHERE card_id = ?")  or die $dbh->errstr;
	$sth->execute($card_id);
	my $hash_ref = $sth->fetchrow_hashref;
	return $hash_ref;
}

sub log_telegram {
	my $res = shift;
	for (@ids_to) {
		$api->sendMessage ({chat_id => $_,text => $res->{suffix}.'. Пользователь '.$res->{name}.' '.$res->{surname}.' ('.$res->{card_id}.')'});
	}
}
