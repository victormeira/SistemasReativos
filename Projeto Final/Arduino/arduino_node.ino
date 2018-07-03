#include <Wire.h>

#define NODE_ADDR 0x77

struct sensor{

  int id;
  int active;
  int sensor_pin;
  int sensor_state;
  int led_pin;
  int led_state;
  
};typedef struct sensor Sensor;

Sensor optic;
Sensor hall;
Sensor button;
Sensor metal;
int led_control1 = 3;
int led_control2 = 4;
int led_control3 = 5;

char send_str[61] = "";

Sensor initialize_sensor(int id, int sensor_pin, int led_pin)
{
  Sensor new_sensor;

  new_sensor.id = id;
  new_sensor.active = 1;
  new_sensor.sensor_pin = sensor_pin;
  new_sensor.sensor_state = 0;
  new_sensor.led_pin = led_pin;
  new_sensor.led_state = 0;

  pinMode(new_sensor.sensor_pin, INPUT);
  pinMode(new_sensor.led_pin, OUTPUT);

  return new_sensor;
}

int check_sensor_state(Sensor sensor)
{
  if (sensor.active == 1)
  {
    sensor.sensor_state = digitalRead(sensor.sensor_pin);
  }
  
  return sensor.sensor_state;
}

void read_string(char* str_received)
{
  if(str_received[0] == 'l')
  {
    if(str_received[1] == '1')
    {
      if(str_received[2] == 'n')
        digitalWrite(led_control1, HIGH);
      else if(str_received[2] == 'f')
        digitalWrite(led_control1, LOW);
      else if(str_received[2] == 't')
      {
        char state = digitalRead(led_control1);
        state = !state;
        digitalWrite(led_control1, state);
      }
    }
    else if(str_received[1] == '2')
    {
      if(str_received[2] == 'n')
        digitalWrite(led_control2, HIGH);
      else if(str_received[2] == 'f')
        digitalWrite(led_control2, LOW); 
      else if(str_received[2] == 't')
      {
        char state = digitalRead(led_control2);
        state = !state;
        digitalWrite(led_control2, state);
      }
    }
    else if(str_received[1] == '3')
    {
      if(str_received[2] == 'n')
        digitalWrite(led_control3, HIGH);
      else if(str_received[2] == 'f')
        digitalWrite(led_control3, LOW); 
      else if(str_received[2] == 't')
      {
        char state = digitalRead(led_control3);
        state = !state;
        digitalWrite(led_control3, state);
      }
    }
  }
}

void setup() {
  Serial.begin(9600);

  Wire.begin(NODE_ADDR);
  Wire.onReceive(receiveEvent);
  Wire.onRequest(requestEvent);

  pinMode(led_control1, OUTPUT);
  pinMode(led_control2, OUTPUT);
  pinMode(led_control3, OUTPUT);

  digitalWrite(led_control1, LOW);
  digitalWrite(led_control2, LOW);
  digitalWrite(led_control3, LOW);

  optic = initialize_sensor(0, 8, 12);
  hall = initialize_sensor(1, 9, 13);
  button = initialize_sensor(2, 7, 11);
  metal = initialize_sensor(3, 6, 10);
  
}

void loop() {
 delay(100);
}


void receiveEvent(int howMany)
{  
  char j;
  char str_received[4] = "";
  int i = 0;
  
  while(Wire.available())
  {
    j = Wire.read();
    
    str_received[i] = str_received[i] + j;
    i++;
  }
  str_received[i] = '\0';

  read_string(str_received);
  
  Serial.println(str_received);
}

void requestEvent()
{
  String send_String;
  int led1_state = digitalRead(led_control1);
  int led2_state = digitalRead(led_control2);
  int led3_state = digitalRead(led_control3);
      
  hall.sensor_state = check_sensor_state(hall);
  optic.sensor_state = check_sensor_state(optic);
  button.sensor_state = check_sensor_state(button);    
  metal.sensor_state = check_sensor_state(metal);

  send_String = "h " + String(hall.sensor_state) + ";o " + String(optic.sensor_state) + ";b " + String(button.sensor_state)
  + ";m " + String(metal.sensor_state) + ";" + String(led1_state) + String(led2_state) + String(led3_state);

  send_String.toCharArray(send_str, 20); 
  
  Wire.write(send_str);       
}
