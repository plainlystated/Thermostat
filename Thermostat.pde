bool heatingStatus;

const int off = false;
const int on = true;

const float temperature_correction = -6;

const int desiredTemp = 68;

unsigned long nextLogTime;

unsigned long lastStatusChangeRequest;

int heatPin = 13;

void setup(void) {
  Serial.begin(9600);
  pinMode(heatPin, OUTPUT);
  heatingStatus = off;
  nextLogTime = 0;
  lastStatusChangeRequest = 0;
}

void loop(void) {
  float temp_f = currentTemp();
  if (heatingStatus == on && shouldTurnOffHeat(temp_f)) {
    setHeatStatus(off);
  } else if (heatingStatus == off && shouldTurnOnHeat(temp_f)) {
    setHeatStatus(on);
  }

  if (nextLogTime <= millis()) {
    logToSerial(temp_f);
    nextLogTime += 15000;
  }
  delay(1000);
}

float currentTemp() {
  float temp_volt = analogRead(A0) * 5.0 / 1023.0;
  float temp_c = 100 * temp_volt - 50;
  return (9.0 / 5) * temp_c + 32 + temperature_correction;
}

void logToSerial(float temp_f) {
  Serial.print(temp_f);
  Serial.print(" ");
  if (heatingStatus == on) {
    Serial.println("heat-on");
  } else {
    Serial.println("heat-off");
  }
}

void setHeatStatus(bool status) {
  Serial.print("setting heat: ");
  Serial.println(status);

  if (status == on) {
    digitalWrite(heatPin, HIGH);
  } else {
    digitalWrite(heatPin, LOW);
  }
  heatingStatus = status;
}

bool shouldTurnOffHeat(float temp) {
  if (temp > (desiredTemp + 4)) {
    if (changeRequestTimelyEnough(lastStatusChangeRequest)) {
      return true;
    }
    lastStatusChangeRequest = millis();
  }

  return false;
}

bool shouldTurnOnHeat(float temp) {
  if (temp < (desiredTemp - 2)) {
    if (changeRequestTimelyEnough(lastStatusChangeRequest)) {
      return true;
    }
    lastStatusChangeRequest = millis();
  }

  return false;
}

bool changeRequestTimelyEnough(unsigned long previousRequest) {
  if (previousRequest > (millis() - 3000)) {
    return true;
  } else {
    return false;
  }
}
