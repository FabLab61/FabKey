# FabKey

Completely opensource Arduino-based access control system for FabLabs/Hackerspaces/any public space wants
cheap access control
Support Wiegand readers with keypad too (like Smartec ST-PR160EK)
Based on software Ardiuno interrupts and timers. 
Easy control it via web browser or Telegram bot
Backend is based on Perl.

## Features

* Two Wiegand readers: one with keypad for entrance and one without keypad for exit
* One door relay
* Multiple pins for alarms
* Support of 7 and 8 bit 
* keypad code both (universal way of detecting end of transmission)
* Email or(and) Telegram notifications and alarms
* Universal (tested at Arduino Duemilanove + OrangePi but can work with any Arduino and single board linux computer)
* highly configurable code

## Possible configuration  

1. Single-board computer only. Use pigpio or WiringPi libraties for working with Wiegand protocol and control relays. This comfiguration strongly needs optoisolation cause diodes can't save SoC from damage by static electricity from Wiegand readers.
2. Arduino-only (Arduino Yun or Arduino Uno + Ethernet shield).
3. Single-board computer + Arduino or Arduino-based board. Database of users can be stored in Arduino (if not so much users) or in single-board computer.

For more information please check [wiki](https://github.com/FabLab61/FabKey/wiki)

## Database structure

```
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created DEFAULT CURRENT_TIMESTAMP,
    card_id INTEGER,
    pin INTEGER,
    name VARCHAR(160),
    surname VARCHAR(160),
    email VARCHAR(160),
    phone VARCHAR(12),
    telegram_id INTEGER,
    is_blocked INTEGER
    )

CREATE TABLE log (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	time DEFAULT CURRENT_TIMESTAMP,
    reader_id INTEGER,
    code INTEGER,
    code_type VARCHAR(4),
    user_id INTEGER
    )
```

## Installation

Check the [wiki](https://github.com/FabLab61/FabKey/wiki)
