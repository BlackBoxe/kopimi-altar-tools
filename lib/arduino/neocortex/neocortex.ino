enum {
  LED_BLINK=0,
  LED_IN=1,
  LED_OUT=2,
  LED_PULSE=3
};

const int BUT_PIN = 12;
const int LED_PIN = 13;
const float LED_GAMMA = 2.1;
const int LED_TIME_ON = 1000;
int but_pressed = 0;
int led_pulse_index = 0;
int led_pulse_inc = +1;
int led_state = LED_PULSE;

void led_blink() {
  int i = random(50, 200);
  int o = random(25, 75);
  digitalWrite(LED_PIN, HIGH);
  delay(i);
  digitalWrite(LED_PIN, LOW);
  delay(o);
}

void led_in() {
  digitalWrite(LED_PIN, HIGH);
}

void led_out() {
  digitalWrite(LED_PIN, LOW);
}

void led_pulse() {
  int led_time_on = pow((float)led_pulse_index / LED_TIME_ON, LED_GAMMA) * LED_TIME_ON;
  if (led_time_on > 0) {
    digitalWrite(LED_PIN, HIGH);
    delayMicroseconds(led_time_on);
    digitalWrite(LED_PIN, LOW);
    delayMicroseconds(LED_TIME_ON - led_time_on);
  }
  led_pulse_index += led_pulse_inc;
  if ((led_pulse_index < 0) || (led_pulse_index > (LED_TIME_ON - 1))) {
    led_pulse_inc *= -1;
    led_pulse_index += led_pulse_inc;
  }
}

void but_test() {
  Serial.println(but_pressed);
  if (but_pressed) {
    but_pressed = 0;
  }
}

void setup() {
  pinMode(BUT_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  while( Serial.available() ) {
    char c = Serial.read();
    switch(c) {
      case 'B':
        led_state = LED_BLINK;
        break;
      case '1':
        led_in();
        led_state = LED_IN;
        break;
      case '0':
        led_out();
        led_state = LED_OUT;
        break;
      case 'P':
        led_state = LED_PULSE;
        break;
      case 'T':
        but_test();
        break;
    }
  }
  switch(led_state) {
    case LED_BLINK:
      led_blink();
      break;
    case LED_PULSE:
      led_pulse();
      break;
  }
  if (digitalRead(BUT_PIN) != HIGH) {
    but_pressed = 1;
  }
}


