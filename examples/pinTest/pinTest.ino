
// Тестилка портов УНО

#define FIRST_PIN 0 // первый вывод
#define LAST_PIN 19 // последний вывод

void Test1(byte pin)
{
        if(pin < 10) Serial.print(" PIN:  ");
        else         Serial.print(" PIN: ");
        Serial.print(pin);

        pinMode(pin, OUTPUT);
        digitalWrite(pin, LOW);
        Serial.print("    LOW: ");
        if(!digitalRead(pin)) Serial.print("OK  ");
        else                  Serial.print("FAIL");

        digitalWrite(pin, HIGH);
        Serial.print("  HIGH: ");
        if(digitalRead(pin)) Serial.print("OK  ");
        else                 Serial.print("FAIL");

        pinMode(pin, INPUT);
        Serial.print("  PULL UP: ");
        if(digitalRead(pin)) Serial.print("OK  ");
        else                 Serial.print("FAIL");

        digitalWrite(pin, LOW);
}

void Test2(uint8_t pin)
{
        Serial.print("     ");
        pinMode(pin, OUTPUT);
        digitalWrite(pin, 1);
        delay(5);
        if(!digitalRead(pin)) Serial.println("SHORT");
        else                  Serial.println("OK");
        pinMode(pin, INPUT);
        digitalWrite(pin, 0);
}

void setup()
{
    Serial.begin(9600);

    Serial.println("Test of short circuit on GND or VCC and between pins:");
    Serial.println();
    for(uint8_t i = FIRST_PIN; i <= LAST_PIN; i++)
    {
        for(uint8_t j = FIRST_PIN; j <= LAST_PIN; j++)
        {
            pinMode(j, INPUT);
            digitalWrite(j, 0);
        }
        Test1(i);

        for(uint8_t j = FIRST_PIN; j <= LAST_PIN; j++)
        {
            pinMode(j, OUTPUT);
            digitalWrite(j, 0);
        }
        Test2(i);
    }

    for(uint8_t j = FIRST_PIN; j <= LAST_PIN; j++)
    {
        pinMode(j, INPUT);
        digitalWrite(j, 0);
    }
}

void loop() {}
