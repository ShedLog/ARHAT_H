/**
 * Чтение температуры и влажности с датчика DHT22 напрямую, без использования сторонних библиотек
 *
 * Возможно встраивание в конечный автоматы everyOvfCount(), etc.
 * Для использования надо определить константы
 * Predefined constants:
 *   #define pinDHT    -- pin number for DHT
 *   #define timerDHT  -- timer for DHT .. has need divider for 1.2Mhz outer ..
 *
 * , например:
 *
 * #define pinDHT      52       // сюда подключен датчик
 * #define timerDHT     0       // и этот счетчик будет его обслуживать
 * #include "dht22.h"
 *
 * @examples sensor_DHT.ino
 *
 * @author Arhat109, arhat109@mail.ru
 * Thanks for Dimax getted from http://arduino.ru/forum/programmirovanie/attiny13a-101-primenenie?page=14#comment-151629, post #726
 */

typedef struct {
    uint16_t Humidity;
    uint16_t Temperature;
    uint8_t  error;
} DHT22struct;

extern DHT22struct     dht22data;

void dht22_setup();     // for setup(). Установка и настройка датчика для setup()

/**
 * Функция чтения данных с датчика температуры и влажности в глобальные переменные
 * в виде целых чисел *10 (с десятыми: 23.5градуса = 235!)
 */
void dht22_read();
