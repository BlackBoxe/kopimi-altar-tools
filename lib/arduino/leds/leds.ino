enum {
  S_BLINK=0,
  S_IN=1,
  S_OUT=2,
  S_PULSE=3
};

const int LED = 12;
const float GAMMA = 2.1;
int timeON = 1000;
int timeOFF = 0;
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
  for(int i=0; i<timeON; i++){
    float inc = (float) i;
    timeOFF = pow( inc / timeON, GAMMA) * timeON;

    if (timeOFF > 0){
      digitalWrite(LED, HIGH);
      delayMicroseconds(timeOFF);
      digitalWrite(LED, LOW);
      delayMicroseconds(timeON - timeOFF);
    }
  }
  for(int i=timeON - 1; i>=0; i--){
    float inc = (float) i;
    timeOFF = pow( inc / timeON, GAMMA) * timeON;

    if (timeOFF > 0){
      digitalWrite(LED, HIGH);
      delayMicroseconds(timeOFF);
      digitalWrite(LED, LOW);
      delayMicroseconds(timeON - timeOFF);
    }
  }
}

void setup() {
  pinMode(LED, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  char c;
  while( Serial.available() ) {
    c = Serial.read();
    switch(c) {
      case 'B':
        state = S_BLINK;
        break;
      case 'I':
        state = S_IN;
        break;
      case 'O':
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
    case S_IN:
      in();
      break;
    case S_OUT:
      out();
      break;
    case S_PULSE:
      pulse();
      break;
  }
}


