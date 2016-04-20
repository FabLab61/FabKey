#!/usr/bin/env perl
use WWW::Telegram::BotAPI;
use common::sense;

my $id_to = 218718957;
my $api = WWW::Telegram::BotAPI->new (
    token => ''
);

log_telegram();

sub log_telegram {
	my $res = shift;
	$api->sendMessage ({chat_id => $id_to,text => 'Пользователь '.$res->{name}.' '.$res->{surname}.' ('.$res->{card_id}.') вошёл'});
}