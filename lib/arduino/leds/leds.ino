enum {
  S_BLINK=0,
  S_IN=1,
  S_OUT=2,
  S_PULSE=3
};

const int LED = 13;
const float GAMMA = 2.1;
const int TIME_ON = 1000;
int pulse_index = 0;
int pulse_inc = +1;
int state = S_PULSE;

void blink() {
  int i = random(50, 200);
  int o = random(25, 75);
  digitalWrite(LED, HIGH);
  delay(i);
  digitalWrite(LED, LOW);
  delay(o);
}

void in() {
  digitalWrite(LED, HIGH);
}

void out() {
  digitalWrite(LED, LOW);
}

void pulse() {
  int time_on = pow((float)pulse_index / TIME_ON, GAMMA) * TIME_ON;
  if (time_on > 0) {
    digitalWrite(LED, HIGH);
    delayMicroseconds(time_on);
    digitalWrite(LED, LOW);
    delayMicroseconds(TIME_ON - time_on);
  }
  pulse_index += pulse_inc;
  if ((pulse_index < 0) || (pulse_index > (TIME_ON - 1))) {
    pulse_inc *= -1;
    pulse_index += pulse_inc;
  }
}

void setup() {
  pinMode(LED, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  while( Serial.available() ) {
    char c = Serial.read();
    switch(c) {
      case 'B':
        state = S_BLINK;
        break;
      case 'I':
        in();
        state = S_IN;
        break;
      case 'O':
        out();
        state = S_OUT;
        break;
      case 'P':
        state = S_PULSE;
        break;
    }
  }
  switch(state) {
    case S_BLINK:
      blink();
      break;
    case S_PULSE:
      pulse();
      break;
  }
}


