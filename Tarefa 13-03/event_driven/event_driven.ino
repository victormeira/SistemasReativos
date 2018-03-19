#include "event_driven.h"
#include "app.h"
#include "pindefs.h"

static bool b1_interest = 0,b2_interest = 0, b3_interest = 0 ;
static bool b1_state = 1, b2_state = 1, b3_state = 1;
static unsigned long timer_interval = 0, timer_current, timer_previous = 0;
  

void button_listen(int pin){
  if (pin == KEY1)
    b1_interest = 1;
  if (pin == KEY2)
    b2_interest = 1;
  if (pin == KEY3)
    b3_interest = 1;
}

void timer_set(int ms){
 timer_interval = ms; 
}

void setup(void){
  pinMode(KEY1, INPUT_PULLUP);
  pinMode(KEY2, INPUT_PULLUP);
  pinMode(KEY3, INPUT_PULLUP);
  pinMode(LED1, OUTPUT);
  appinit();
}

void loop(void){

  bool b1_current, b2_current, b3_current; 
  
  if(b1_interest){
    b1_current = digitalRead(KEY1);
    if(b1_current != b1_state){
      button_changed(KEY1,b1_current);
      b1_state = b1_current;
    }
  }
  if(b2_interest){
    b2_current = digitalRead(KEY2);
    if(b2_current != b2_state){
      button_changed(KEY2,b2_current);
      b2_state = b2_current;
    }
  }
  if(b3_interest){
    b3_current = digitalRead(KEY3);
    if(b3_current != b3_state){
      button_changed(KEY3,b3_current);
      b3_state = b3_current;
    }
  }
  if(timer_interval){
   timer_current = millis();
   if(timer_current - timer_previous > timer_interval){
     timer_expired();
     timer_previous = timer_current; 
   }
  }
  
  
}
