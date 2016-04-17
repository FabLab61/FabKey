#include <WIEGAND26.h>
#include <PCATTACH.h>           // Pcint.h implementation, allows for >2 software interupts.
#include <Adafruit_MCP23017.h>  // Library for the MCP23017 i2c I/O expander
#include "Timer.h"

#define CARDFORMAT 1                    // 1=First and second parity bits stripped
#define R1ZERO          2
#define R1ONE           3
#define R2ZERO          4 //DO
#define R2ONE           5 //D1  
#define SAMPLE_PERIOD 3 // sampling interval in ms. must be > data period
#define PIN_LENGTH 4 // sampling interval in ms. must be > data period
#define DOORPIN1       6                // Define the pin for electrified door 1 hardware. (MCP)
#define DOOR_DELAY 2500

Adafruit_MCP23017 mcp;
PCATTACH pcattach; 
WIEGAND26 wiegand26;  							

uint8_t reader1Pins[]={R1ZERO, R1ONE};           // Reader 1 pin definition
uint8_t reader2Pins[]={R2ZERO, R2ONE};   
volatile long reader1 = 0;
volatile int  reader1Count = 0;
volatile long reader2 = 0;
volatile int  reader2Count = 0;

Timer t;
//int t_id; // t.every timer id
boolean is_changed = false; // state flag
boolean card_was_presented = false;
int reader2Count_real;
String pin_code;

void callReader1Zero(){wiegand26.reader1Zero();}
void callReader1One(){wiegand26.reader1One();}
void callReader2Zero(){wiegand26.reader2Zero();}
void callReader2One(){wiegand26.reader2One();}

void setup() {
  pcattach.PCattachInterrupt(reader1Pins[0], callReader1Zero, CHANGE); 
  pcattach.PCattachInterrupt(reader1Pins[1], callReader1One,  CHANGE); 
  pcattach.PCattachInterrupt(reader2Pins[0], callReader2Zero, CHANGE);  
  pcattach.PCattachInterrupt(reader2Pins[1], callReader2One,  CHANGE);
  wiegand26.initReaderTwo();
	Serial.begin(57600);
  mcp.begin();
  mcp.pinMode(DOORPIN1, OUTPUT);
  mcp.digitalWrite(DOORPIN1, LOW);       // Sets the relay outputs to LOW (relays off)	            
  t.every(SAMPLE_PERIOD,sampling);
}

void sampling() {
  //is_first_interrupt = false;
  if(reader2Count > 0) {    // bit is coming
    is_changed = true;
    t.after(SAMPLE_PERIOD+1,transfer_stop_callback); // SAMLE_PERIOD+1 for safety
    reader2Count_real += reader2Count;
    reader2Count = 0;
  } else {
    is_changed = false;
  }
}

void transfer_stop_callback() {
  if (is_changed == false) { // transfer stoped
    if ((card_was_presented == true) && ((reader2Count_real == 7) || (reader2Count_real == 8))) { // button
      //Serial.print("Button:");
      //Serial.println(decodeButton(reader2));
      pin_code += decodeButton(reader2);
    }
    if (reader2Count_real == 26) {
      Serial.print("Entrance.Card:");
      Serial.println(decodeCard(reader2));
      card_was_presented = true;
    }
    reader2Count_real = 0;
    wiegand26.initReaderTwo();
    
    if (pin_code.length()==PIN_LENGTH) {
      Serial.print("Entrance.Pin:");
      Serial.println(pin_code);
      card_was_presented = false;
      pin_code = "";
    }
  }
}

void loop() {
  t.update();
  readCommand();
  monitor_exit();
}
    
long decodeCard(long input)
{
  if(CARDFORMAT==0)
 {
    return(input);
 }
  
  if(CARDFORMAT==1)
  {
    bool parityHigh;
    bool parityLow;
    parityLow=bitRead(input,0);
    parityHigh=bitRead(input,26);
    bitWrite(input,25,0);        // Set highest (parity bit) to zero
    input=(input>>1);            // Shift out lowest bit (parity bit)
    return(input);
  }
}


int decodeButton(int input) {  // unable to decode 'esc' and 'enter' button for now. plan to use http://playground.arduino.cc/Code/HashMap for its support
  int matches[10] = {240, 225, 210, 195, 180, 165, 150, 135, 120, 105}; 
  int pos = -1;  // position to return
  for (int i=0;i<10;i++) {
    if (matches[i]==input) {
      pos = i;
      break;
    }
  }
  return pos;
}

void readCommand() {   
  if (Serial.available()) {
    char cmd=0;                                        
    cmd = Serial.read();                                           
    switch(cmd) {
      case 'o': {
       open_door();
       break;
      }                      
    }
  } 
}

void open_door() {
  mcp.digitalWrite(DOORPIN1, HIGH);
  Serial.println("Door unlocked");
  delay(DOOR_DELAY); 
  mcp.digitalWrite(DOORPIN1, LOW);
  Serial.println("Door locked");
}

void monitor_exit() {   
  if(reader1Count >= 26){               // When tag presented to reader1 (exit reader)
      Serial.print("Exitway.Card:");
      Serial.println(decodeCard(reader1));
      //open_door();  //  uncomment it if you want to open door by any card (not only authorized)     
      wiegand26.initReaderOne();       // Reset for next tag scan
  }
}

