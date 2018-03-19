#include "event_driven.h"
#include "app.h"
#include "pindefs.h"

static bool LED_state = 1;
static unsigned long timer1_previous = 0, timer2_previous = 0;
static unsigned long timert_interval = 1000;


void appinit(void){
  button_listen(KEY1);
  button_listen(KEY2);
  timer_set(1000);
}

void button_changed(int p, int v){
  unsigned long timer_current = millis();
  if(p == KEY1){
   if(v == 0)
      timer1_previous = timer_current;
   else{
      if(timer_current - timer2_previous < 500){
        digitalWrite(LED1,HIGH);
        timer_set(0);
      }
      else{
        timert_interval = timert_interval - 200;
        timer_set(timert_interval);
      }
   }
  }
  if(p == KEY2){
   if(v == 0)
      timer2_previous = timer_current;
   else{
      if(timer_current - timer1_previous < 500){
        digitalWrite(LED1,HIGH);
        timer_set(0);
      }
      else{
        timert_interval = timert_interval + 200;
        timer_set(timert_interval);
      }
   }
  }
}

void timer_expired(void){
  if(LED_state == 1)
    digitalWrite(LED1,LOW);
  else
    digitalWrite(LED1,HIGH);
  LED_state = !LED_state;
}
