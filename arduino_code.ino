#include <SoftwareSerial.h>

SoftwareSerial BT(10, 11);

const int PIR_PIN = 7;
const int MQ2_PIN = A0;

const int LED_PIN = 5;
const int BUZZER_PIN = 6;

const int SMOKE_THRESHOLD = 400;

void setup() {

  pinMode(PIR_PIN, INPUT);

  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  digitalWrite(LED_PIN, LOW);
  digitalWrite(BUZZER_PIN, LOW);

  Serial.begin(9600);
  BT.begin(9600);
}

void loop() {

  int motion = digitalRead(PIR_PIN);

  if (motion == HIGH) {

    digitalWrite(LED_PIN, HIGH);

    tone(BUZZER_PIN, 1000);

    Serial.println("MOTION DETECTED");
    BT.println("MOTION DETECTED");

    delay(2000);

    digitalWrite(LED_PIN, LOW);
    noTone(BUZZER_PIN);
  }

  int smokeValue = analogRead(MQ2_PIN);

  if (smokeValue > SMOKE_THRESHOLD) {

    digitalWrite(LED_PIN, HIGH);

    tone(BUZZER_PIN, 1500);

    Serial.println("SMOKE ALERT");
    BT.println("SMOKE ALERT");

    delay(3000);

    digitalWrite(LED_PIN, LOW);
    noTone(BUZZER_PIN);
  }

  delay(200);
}
