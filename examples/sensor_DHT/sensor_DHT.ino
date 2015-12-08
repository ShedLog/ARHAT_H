/**
 * "Датчик DHT22"
 * размер компилированного скетча = 1022байт. SRAM=4байта
 *
 * Пример переработки кода Attiny13 под библиотеку. Использована оригинальная процедура чтения датчика
 * напрямую, без использования библиотек.
 *
 * @author Arhat109 arhat109@mail.ru, +7-(951)-388-2793
 * @thanks Dimax, origin code getted from
 * http://arduino.ru/forum/programmirovanie/attiny13a-101-primenenie?page=14#comment-151629, post #726
 *
 * Лицензия:
 * 1. Полностью свободное и бесплатное программное обеспечение. В том числе и от претензий.
 * 2. Вы вправе использовать его на свои нужды произвольным образом и на свой риск.
 * 3. Вы не вправе удалять из него строку с тегом @author или изменять её.
 * 4. Изменяя этот файл, Вы вправе дописать свои авторские данные и/или пояснения.
 *
 * Если Вам это оказалось полезным, то Вы можете по-достоинству оценить мой труд
 * "на свое усмотрение" (напр. кинуть денег на телефон "сколько не жалко")
 */

#include "arhat.h"
#define pinDHT pin52 // для Мега2560 сохранен PB1

uint16_t Humidity;
uint16_t Temperature;
uint8_t  error;

/**
 * Функция чтения данных с датчика температуры и влажности в глобальные переменные
 * в виде целых чисел *10 (с десятыми: 23.5градуса = 235!)
 *
 * @return global uint16_t Humidity, Temperature
 * @return global uint8_t  error -- код ошибки измерения
 *
 * @author Dimax getted from http://arduino.ru/forum/programmirovanie/attiny13a-101-primenenie?page=14#comment-151629, post #726
 */
void dht_read()
{
    uint16_t data;

    digitalWrite(pinDHT, LOW); pinMode(pinDHT, OUTPUT);
    delayMicro16(800*4);
    pinMode(pinDHT, INPUT); digitalWrite(pinDHT, HIGH);

    for ( int8_t i = -3 ; i < 2 * 40; i++ ) {
        uint8_t age;

        timerCount(0) = 0;
        do {
            uint8_t age=timeCount(0);
            if ( age > 108 ){ error = 1; return; }
        }while( digitalRead(pinDHT) == (i & 1)? 1 : 0  ) ;

        if ( i >= 0 && (i & 1) ){
            data <<= 1;
            if ( age > 36 ){ data |= 1; }
        }
        switch ( i ) {
            case 31: Humidity = data;              break;
            case 63: Temperature = data; data = 0; break;
        }
    }

    // Verify checksum
    if ( (uint8_t)(((uint8_t)Humidity) + (Humidity >> 8) + ((uint8_t)Temperature) + (Temperature >> 8)) != data ) {
        error = 2;
        return;
    }
    if ( Temperature & 0x8000 ) {
        Temperature = -(int16_t)(Temperature & 0x7FFF);
    }
    error = 0;
}

void setup()
{
    timerControl(0,A) = 0;                              // Normal mode
    timerControl(0,B) = prescalerMode(8);               // divider 9600000/8=1200000

    Serial.begin(9600);
}

void loop()
{
    // не опрашивать DHT чаще чем раз в 2 сек (1952*1.024=2000)
    everyOVF(1952, {
        error = 0;
        dht_read();

        if( error == 0 ){
            Serial.print("Temperature (*10) = ");
            Serial.print(Temperature, DEC);
            Serial.print(", Humidity (*10) = ");
            Serial.println(Humidity, DEC);
        } else {
            Serial.print("error = ");
            Serial.println(error, DEC);
        }
    });
    // .. тут что-нибудь, чего можно делать когда не опрашиваем датчик
}
