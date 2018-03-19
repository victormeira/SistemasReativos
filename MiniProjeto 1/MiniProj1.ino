#include "pindefs.h"

#define ONE_MINUTE 6000

unsigned long last_clock_update = 0;
int clock_time = 1200;
int alarm_time = 1159;

/* Declares what mode the alarm is, 0 is off, 1 is on and waiting, 
2 is on and playing, 3 is on and turned by user*/
short alarm_mode = 0;

bool but1_prev_state = 0, but2_prev_state = 0, but3_prev_state = 0;
unsigned long but1_prev_press = 0, but2_prev_press = 0, but3_prev_press = 0;

/*zero for clock 1 for alarm being displayed */
bool time_to_be_displayed = 0;
int displayed_time = 1200;

/* Segment byte maps for numbers 0 to 9 */
const byte DISPLAY_MAP[] = {0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0X80,0X90};
/* Byte maps to select digit 1 to 4 */
const byte DISPLAY_POS[] = {0xF1,0xF2,0xF4,0xF8};

void WriteNumberInDisplay(int Number){
  	WriteDigit(0 , Number / 1000);
  	WriteDigit(1 , (Number / 100) % 10);
  	WriteDigit(2 , (Number / 10) % 10);
  	WriteDigit(3 , Number % 10);
}

void WriteDigit(byte position, byte value){
  	digitalWrite(LATCH,LOW);
  	shiftOut(DATA, CLK, MSBFIRST, DISPLAY_MAP[value]);
  	shiftOut(DATA, CLK, MSBFIRST, DISPLAY_POS[position]);
  	digitalWrite(LATCH,HIGH);
}

int AddMinToTime(int time){
	int minute = time%100;
	int hour = time/100;

	if(minute == 59)
		return AddHrToTime(time - 59);
	else
		minute = minute + 1;

	return ConvertMinHrToTime(hour,minute);
}

int AddHrToTime(int time){
	int minute = time%100;
	int hour = time/100;

	if (hour == 23)
		hour = 0;
	else
		hour = hour + 1;

	return ConvertMinHrToTime(hour,minute);
}

int ConvertMinHrToTime(int hour, int minute){
	return hour*100 + minute;
}

void setup(void){
	pinMode(KEY1, INPUT_PULLUP);
  	pinMode(KEY2, INPUT_PULLUP);
  	pinMode(KEY3, INPUT_PULLUP);
  	pinMode(LED1, OUTPUT);
  	pinMode(BUZZER, OUTPUT);
  	digitalWrite(BUZZER, HIGH);
  	pinMode(LATCH,OUTPUT);
  	pinMode(CLK,OUTPUT);
  	pinMode(DATA,OUTPUT);
  	Serial.begin(9600);

  	WriteNumberInDisplay(1200);
}

void loop(void){
	unsigned timer_now = millis();

	/* current state of the buttons, 1 pressed, 0 not pressed */
	bool but1_state = !digitalRead(KEY1);
	bool but2_state = !digitalRead(KEY2);
	bool but3_state = !digitalRead(KEY3);

	/* if pressing only button 3, change display to alarm*/
	if(but3_state && !but2_state && !but1_state)
		time_to_be_displayed = 1;

	/* if alarm being displayed but button 3 not pressed, show clock */
	if(time_to_be_displayed && !but3_state)
		time_to_be_displayed = 0;


	/* button 2 state changed*/
	if(but2_state != but2_prev_state){
		but2_prev_state = but2_state;

		/* When showing the clock */
		if(time_to_be_displayed == 0){
			/* button 2 was released while button 1 is pressed */
			if(but2_state == 0 && but1_state == 1){
				clock_time = AddHrToTime(clock_time);
			}
		}
		/* When showing the alarm */
		else{
			/* Button 2 was released */
			if(but2_state == 0)
				alarm_time = AddMinToTime(alarm_time);
		}	

	}

	/* button 3 state changed*/
	if(but3_state != but3_prev_state){
		but3_prev_state = but3_state;

		/* When showing the clock */
		if(time_to_be_displayed == 0){
			/* button 3 was released while button 1 is pressed */
			if(but3_state == 0 && but1_state == 1){
				clock_time = AddMinToTime(clock_time);
			}
			/* button 3 released while no other button is pressed */
			else{
				/* Turn alarm from off to on */
				if(alarm_mode == 0){
					alarm_mode = 1;
					digitalWrite(LED1,LOW);
				}
				else{
					/* Turn alarm from on to off */
					if(alarm_mode == 1){
						alarm_mode = 0;
						digitalWrite(LED1,HIGH);
					}
					else{
						/* Stop alarm from playing */
						if(alarm_mode == 2)
							alarm_mode = 3;
					}
				}
			}
		}
	}

	/* button 1 state changed */
	if(but1_state != but1_prev_state){
		but1_prev_state = but1_state;

		/* When showing the alarm */
		if(time_to_be_displayed){
			if(but1_state == 0)
				alarm_time = AddHrToTime(alarm_time);
		}
	}


	/* one minute has elapsed since last update */
	if(timer_now - last_clock_update > 100){
		clock_time = AddMinToTime(clock_time);
		last_clock_update = timer_now;
	}

	/* what time to be displayed*/
	if(time_to_be_displayed == 0)
		displayed_time = clock_time
	else
		displayed_time = alarm_time

	/* Alarm is on and the time has arrived*/
	if(clock_time == alarm_time && alarm_mode == 1)
		alarm_mode = 2;
	
	/* Resets alarm that has stopped playing */
	if(clock_time != alarm_time && alarm_mode == 3)
		alarm_mode = 1;

	/* Alarm is playing */
	if(alarm_mode == 2){
		digitalWrite(LED4,LOW);
		delay(20);
		digitalWrite(LED4,HIGH);
	}

	WriteNumberInDisplay(displayed_time);
}
