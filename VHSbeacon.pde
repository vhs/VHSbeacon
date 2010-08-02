// VHSbeacon - firmware for VHS beacon for blue robot challenge
//

#include <IRremote.h>

#define CAPTURE_RED  0
#define CAPTURE_BLUE 1
#define STATUS_RED   2
#define STATUS_BLUE  3

#define NEUTRAL       0
#define CAPTURED_RED  1
#define CAPTURED_BLUE 2
int beacon_state = NEUTRAL;
int resetEnabled = 0;
int resetTime = 5000;

#define IS_NEUTRAL (beacon_state == NEUTRAL)
#define IS_RED     (beacon_state == CAPTURED_RED)
#define IS_BLUE    (beacon_state == CAPTURED_BLUE)

unsigned long reset_at = 0;

/* For the Multicolour LEDs */
#define LED_LOW 0
#define LED_HIGH 1
#define LED_R_pin 11
#define LED_G_pin 9
#define LED_B_pin 10

#define LED_OFF 0
#define LED_RED 1
#define LED_GREEN 2
#define LED_BLUE 3

IRsend irsend;
decode_results results;
IRrecv irrecv(4); // send ir input pin as argument

void setup() {
  irrecv.enableIRIn(); // initializes irrecv

  pinMode(LED_R_pin, OUTPUT);
  pinMode(LED_G_pin, OUTPUT);
  pinMode(LED_B_pin, OUTPUT);

  update_LED( LED_RED ); 
  delay(400);
  update_LED( LED_BLUE ); 
  delay(400);
  update_LED( LED_GREEN ); 
  delay(400);
  update_LED( LED_OFF );
  delay(400);
  update_LED( LED_GREEN ); // leave led as green at end of setup.
}

void loop() {
   unsigned long do_until = millis() + 100;

   while (millis() < do_until) {
     if (irrecv.decode(&results)) {
       if ((results.bits == 1) || (results.bits == 2)) {
           switch (results.value) {
               case CAPTURE_RED:
                   beacon_state = CAPTURED_RED;
                   update_LED( LED_RED );
                   if (resetEnabled)
                     reset_at = millis() + resetTime;
                   break;
               case CAPTURE_BLUE:
                   beacon_state = CAPTURED_BLUE;
                   update_LED( LED_BLUE );
                   if (resetEnabled)
                     reset_at = millis() + resetTime;
                   break;
           }
       }
       irrecv.resume(); // Receive the next value
     };
   }

   if ((reset_at != 0) && (millis() >= reset_at)) {
     beacon_state = NEUTRAL;
     update_LED( LED_GREEN );
     reset_at = 0;
   }

   do_until = millis() + 100;
   while (millis() < do_until) {
     if (IS_NEUTRAL) {
         irsend.sendVHS(STATUS_RED, 2);
         irsend.sendVHS(STATUS_BLUE, 2);
     }
     else if (IS_BLUE) {
         irsend.sendVHS(STATUS_RED, 2);
     }
     else if (IS_RED) {
         irsend.sendVHS(STATUS_BLUE, 2);
     }
   }
}

void update_LED ( int LED_COLOUR ) {
  int red = 0;
  int green = 0;
  int blue = 0;
  switch( LED_COLOUR ){
    case LED_OFF:
      break;
    case LED_RED:
      red = LED_HIGH;
      break;
    case LED_BLUE:
      blue = LED_HIGH;
      break;
    case LED_GREEN:
      green = LED_HIGH;
      break;
  }
  digitalWrite(LED_R_pin, red);
  digitalWrite(LED_G_pin, green);
  digitalWrite(LED_B_pin, blue);
}

