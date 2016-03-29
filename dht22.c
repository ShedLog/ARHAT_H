/**
 * Набор функций для работы с датчиком температуры напрямую без использования доп. разработок.
 *
 * Predefined constants:
 *   #define pinDHT    -- pin number for DHT
 *   #define timerDHT  -- timer for DHT .. has need divider for 1.2Mhz outer ..
 *
 * @author Arhat109, arhat109@mail.ru
 *
 * !!! Not tested or compiled yet !!! only writed.. НЕ ТЕСТИРОВАЛОСЬ И НЕ КОМПИЛИРОВАЛОСЬ ЕЩЁ .. идея на будущее ..
 */
#include "arhat.h"
#include "dht22.h"

typedef struct {
    uint16_t Humidity;
    uint16_t Temperature;
    uint8_t  error;
} DHT22struct;

DHT22struct     dht22data;

/**
 * Установка и настройка датчика в setup()
 */
void dht22_setup()
{
    timerControl(timerDHT,A) = 0;                              // Normal mode
    timerControl(timerDHT,B) = prescalerMode(8);               // divider 9600000/8=1200000
}

/**
 * Функция чтения данных с датчика температуры и влажности в глобальные переменные
 * в виде целых чисел *10 (с десятыми: 23.5градуса = 235!)
 *
 * @return global uint16_t Humidity, Temperature
 * @return global uint8_t  error -- код ошибки измерения
 *
 * @author Dimax getted from http://arduino.ru/forum/programmirovanie/attiny13a-101-primenenie?page=14#comment-151629, post #726
 */
void dht22_read()
{
    uint16_t data;

    digitalWrite(pinDHT, LOW); pinMode(pinDHT, OUTPUT);
    delayMicro16(800*4);
    pinMode(pinDHT, INPUT); digitalWrite(pinDHT, HIGH);

    for ( int8_t i = -3 ; i < 2 * 40; i++ ) {
        uint8_t age;

        timerCount(timerDHT) = 0;
        do {
            uint8_t age=timerCount(timerDHT);
            if ( age > 108 ){ error = 1; return; }
        }while( digitalRead(pinDHT) == (i & 1)? 1 : 0  ) ;

        if ( i >= 0 && (i & 1) ){
            data <<= 1;
            if ( age > 36 ){ data |= 1; }
        }
        switch ( i ) {
            case 31: dht22data.Humidity = data;              break;
            case 63: dht22data.Temperature = data; data = 0; break;
        }
    }

    // Verify checksum
    if (
            (uint8_t)(
                ((uint8_t)dht22data.Humidity) + (dht22data.Humidity >> 8)
                + ((uint8_t)dht22data.Temperature) + (dht22data.Temperature >> 8)
            ) != data
    ){
        dht22data.error = 2;
        return;
    }
    if ( dht22data.Temperature & 0x8000 ) {
        dht22data.Temperature = -(int16_t)(dht22data.Temperature & 0x7FFF);
    }
    dht22data.error = 0;
}
/**
 * FOR Example:

void loop()
{
    // не опрашивать DHT чаще чем раз в 2 сек (1952*1.024=2000)
    everyOVF(1952, {
        dht22data.error = 0;
        dht_read();

        if( dht22data.error == 0 ){
            Serial.print("Temperature (*10) = ");
            Serial.print(dht22data.Temperature, DEC);
            Serial.print(", Humidity (*10) = ");
            Serial.println(dht22data.Humidity, DEC);
        } else {
            Serial.print("error = ");
            Serial.println(dht22data.error, DEC);
        }
    });
    // .. тут что-нибудь, чего можно делать когда не опрашиваем датчик
}
*/
