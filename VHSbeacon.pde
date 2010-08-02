#include <IRremote.h>

int RECV_PIN = 4;
IRsend irsend;
decode_results results;

#define CAPTURE_RED  0
#define CAPTURE_BLUE 1
#define STATUS_RED   2
#define STATUS_BLUE  3

/* For the Multicolour LEDs */
#define LED_HIGH 64
#define LED_LOW  0
#define LED_R_pin 11
#define LED_G_pin 9
#define LED_B_pin 10

int red   = 0;
int green = 0;
int blue  = 0;

void update_LED () {
  analogWrite(LED_R_pin, red);
  analogWrite(LED_G_pin, green);
  analogWrite(LED_B_pin, blue);
}


void setup() {
   pinMode(LED_R_pin, OUTPUT);
   pinMode(LED_G_pin, OUTPUT);
   pinMode(LED_B_pin, OUTPUT);

   red = 0; green = 0; blue = 0;
   red = LED_HIGH; update_LED(); delay(400);
   red = 0; green = 0; blue = 0;
   green = LED_HIGH; update_LED(); delay(400);
   red = 0; green = 0; blue = 0;
   blue = LED_HIGH; update_LED(); delay(400);

   red = 0; green = 0; blue = 0;
   green = LED_HIGH;
   update_LED();

}

#define NEUTRAL       0
#define CAPTURED_RED  1
#define CAPTURED_BLUE 2
int beacon_state = NEUTRAL;

#define IS_NEUTRAL (beacon_state == NEUTRAL)
#define IS_BLUE    (beacon_state == CAPTURED_BLUE)
#define IS_RED     (beacon_state == CAPTURED_RED)

unsigned long reset_at = 0;


void loop() {
   unsigned long receive_until = millis() + 100;


   IRrecv irrecv(RECV_PIN);
   irrecv.enableIRIn();
   while (millis() < receive_until) {
     if (irrecv.decode(&results)) {
       if ((results.bits == 1) || (results.bits == 2)) {
           switch (results.value) {
               case CAPTURE_RED:
                   beacon_state = CAPTURED_RED;
  //                 reset_at = millis() + 5000;
                   green = blue = 0;
                   red = LED_HIGH;
                   update_LED();
                   break;
               case CAPTURE_BLUE:
                   beacon_state = CAPTURED_BLUE;
 //                  reset_at = millis() + 5000;
                   green = red = 0;
                   blue = LED_HIGH;
                   update_LED();
                   break;
           }
       }
       irrecv.resume(); // Receive the next value
     };
   }

   if ((reset_at != 0) && (millis() >= reset_at)) {
     beacon_state = NEUTRAL;
     red = blue = 0;
     green = LED_HIGH;
     update_LED();
     reset_at = 0;
   }

   receive_until = millis() + 100;
   while (millis() < receive_until) {
     if (IS_NEUTRAL) {
         irsend.sendVHS(STATUS_RED, 2);
     }
     else if (IS_BLUE) {
         irsend.sendVHS(STATUS_RED, 2);
     }
     else if (IS_RED) {
         irsend.sendVHS(STATUS_BLUE, 2);
     }
   }


}
