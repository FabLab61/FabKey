#include <WIEGAND26.h>
#include <PCATTACH.h>           // Pcint.h implementation, allows for >2 software interupts.

#define CARDFORMAT 1                    // 0 -> first 25 raw bytes from card, 1 -> first and second parity bits stripped (default for most systems)
#define R2ZERO          4 //D0    
#define R2ONE           5 //D1      
      
PCATTACH pcattach;          // Software interrupt library
WIEGAND26 wiegand26;  			// Wiegand26 (RFID reader serial protocol) library

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
	if(reader2Count >= 26){                     // When tag presented to reader
      Serial.print("Plain:");
      Serial.print(reader2,BIN);
      Serial.print(",decoded:");
	    Serial.println(decodeCard(reader2));
	    wiegand26.initReaderTwo();                     // Reset for next tag scan
    } 
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
