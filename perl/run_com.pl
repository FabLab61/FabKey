#!/usr/bin/env perl
# Script to check real card id (in case if it's not printer)

use Device::SerialPort;
use feature 'say';

my $port = Device::SerialPort->new("/dev/ttyUSB1");
$port->baudrate(57600);
$port->databits(8);
$port->parity("none");
$port->stopbits(1);
$port->write_settings;

while (1) {
  my $string = $port->lookfor();
  if ($string) {
  	say $string;
  }
}