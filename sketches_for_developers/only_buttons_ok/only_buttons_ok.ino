#include <WIEGAND26.h>
#include <PCATTACH.h>           // Pcint.h implementation, allows for >2 software interupts.

#define CARDFORMAT 1                    // 0 -> first 25 raw bytes from card, 1 -> first and second parity bits stripped (default for most systems)
#define R2ZERO          4 //D0    
#define R2ONE           5 //D1      
      
PCATTACH pcattach;          // Software interrupt library - https://github.com/zyphlar/Open_Access_Control_Ethernet/tree/master/PCATTACH
WIEGAND26 wiegand26;        // Wiegand26 library - https://github.com/zyphlar/Open_Access_Control_Ethernet/tree/master/Wiegand26

volatile long reader2 = 0;               
volatile int  reader2Count = 0;           // Reader received bits counter
uint8_t reader2Pins[]={R2ZERO, R2ONE};    // pin definition (required by library)

void callReader2Zero(){wiegand26.reader2Zero();}  // callbacks
void callReader2One(){wiegand26.reader2One();}

void setup() {
  pcattach.PCattachInterrupt(R2ZERO, callReader2Zero, CHANGE);  
  pcattach.PCattachInterrupt(R2ONE, callReader2One,  CHANGE);
  wiegand26.initReaderTwo();        //Set up Reader and clear buffers.
  Serial.begin(57600);              
}

void loop() {
   if(reader2Count >= 8){                     // When button pressed. unable to decode '8' and '9' buttons for now cause they have 7 bits code
      Serial.print("Plain:");
      Serial.print(reader2,BIN);
      Serial.print(",decoded:");
      Serial.println(decodeButton(reader2));
      wiegand26.initReaderTwo();                     // Reset for next tag scan
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
