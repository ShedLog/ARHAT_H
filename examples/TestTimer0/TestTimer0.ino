/**
 * "Тест работы главного таймера времени".
 *
 * Этот тест создавался как контрольный для проверки функций, замещающих типовой файл wiring.c
 * Отличия:
 * 1. Упрощена процедура обработки прерывания от таймера0. Переписана в ассемблер.
 * Это сокращает размер, укоряет её работу (разгружает процессор от фоновой задачи)
 * и уменьшает занимаемый объем оперативной памяти с 9 до 4 байт.
 * Проверка работы процедуры прерывания выполнена в первой части.
 *
 * 2. Добавлена функция консистентного чтения (без ошибок), счетчика вызова процедуры прерываний.
 * Его просто не было.
 *
 * 3. Функция micros() переписана в ассемблер. Уменьшен размер, увеличена скорость. Количество
 * микросекунд теперь уточнено НА МОМЕНТ возврата из этой функции. Проверка работы micros()
 * выполнена во второй части теста.
 *
 * 4. Третья часть содержит проверку работы стандартной функции delay(). Тут проверяются 2 разные
 * реализации этой функции в зависимости от режима компиляции:
 * а) режим совместимости. Проверяется аналог стандартной функции, принимающей 4-х длинное целое
 * значение задержки в миллисекундах (может задерживать работу до 49,7 дней!)
 * б) режим минимальной компиляции: типовая функция delay() в нем ПЕРЕИМЕНОВАНА, так что принимает
 * только 2-х байтовое целое число миллисекунд (только до 65.5сек!). Зато этот режим экономит
 * около 6 байт на каждый вызов delay().
 *
 * 5. Добавлен тест выполнения функций-перехватчиков из процедуры прерывания таймера 0. Тест 10 раз
 * моргает 13 пином по 2 секунды вкл и выкл. Примерно в середине каждой фазы функция перехватчик моргает
 * "инверсно" по 2 раза длительностью по 0.2 сек.
 *
 * !!! Добавлен вывод на LCD1602 или аналогичный дисплей подключаемый на шину I2C (TWI). !!!
 *
 * @author Arhat109 arhat109@mail.ru, +7-(951)-388-2793
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

//#define _ARHAT_ 1
//#include "arhat.h"
#include "lcd1602.h"

#define testPin     13

// quickly blinks 3 times for next test and pause 0.5 sec.
void testBlink3()
{
    testOvfCount(150,150);      // blink1
    testOvfCount(150,150);      // blink2
    testOvfCount(150,500);      // blink3 and pause after
}

//
// test working time interrupt and its overflow count only:
// +1000 timer0_overflow_count == 1024 milli seconds = 1.024sec!
//
static unsigned long curCount=0UL;
void testOvfCount( uint16_t onTicks, uint16_t offTicks )
{
    curCount = getOvfCount();                       // store start value
    digitalWrite(testPin, HIGH);                    // set LED to ON
    while( getOvfCount() - curCount < onTicks );    // wait for ON delay

    curCount = getOvfCount();
    digitalWrite(testPin, LOW);
    while( getOvfCount() - curCount < offTicks );
}

//
// test working microseconds getter
//
static unsigned long    curMicros = 0UL;
void testMicros(unsigned long ticks)
{
    curMicros = micros();                        // store start value
    digitalWrite(testPin, HIGH);                 // set LED to ON
    while( micros() - curMicros < ticks );       // wait for delay

    curMicros = micros();
    digitalWrite(testPin, LOW);
    while( micros() - curMicros < ticks );
}

volatile uint8_t pinLedState = 0;  // we can't read 13 pin!
volatile uint8_t hookCount = 0;

void lcdWrite16(uint8_t x, uint8_t y, uint16_t data)
{
    char outBuf[8];

    lcdSetCursor(x,y);
    utoa(data, outBuf, 10);
    lcdWrite(outBuf, strlen(outBuf));
}

//
// test delay() waiting in milliseconds
//
void testDelay( uint16_t waitON, uint16_t waitOFF)
{
    lcdSetCursor(0,0);
    lcdWrite("Main ", 5);

    digitalWrite(testPin, HIGH);
    pinLedState = 1;
    hookCount = 0;
    delay(waitON);

    lcdSetCursor(0,0);
    lcdWrite("     ", 5);

    digitalWrite(testPin, LOW);
    pinLedState = 0;
    hookCount = 0;
    delay(waitOFF);
}

//
// hook function called from timer interrupt
//
void hookGo()
{
    //  lcdWrite("H", 1);
    if( hookCount < 4 ) {
        //    Serial.write("S",1);
        lcdWrite16(0, 1, SP);
        if(hookCount == 0 ){ lcdWrite(" 1sec. ", 7); delay(1000); }
        else               { lcdWrite(" 200m. ", 7); delay(200);  }
        hookCount++;
        if( pinLedState == 0 ){ digitalWrite(testPin, HIGH); }
        else                  { digitalWrite(testPin, LOW);  }

        pinLedState = 1 - pinLedState;
    }
}

void setup() {
    pinMode(testPin, OUTPUT);
    lcdSetup(0x27, 16, 2, 1);
    lcdWrite("Hello, Arhat!", 13);
}

void loop() {

    uint8_t    i;
    uint32_t   time;

    testBlink3();

    // 1. test interrupt only: 10 times about 0.9994 sec. ON/OFF
    lcdSetCursor(0,1);
    lcdWrite(" :test1: ", 9);
    for(i=10; i>0; i--)  testOvfCount(976, 976);
    testBlink3();

    // 2. test micros(): 10 times each 0.5 seconds ON/OFF
    lcdSetCursor(0,1);
    lcdWrite(" :test2: ", 9);
    for(i=10; i>0; i--)  testMicros(500000);
    testBlink3();

    // 3. test delay16(): 10 times each 1 sec ON and 0.5 sec OFF
    lcdSetCursor(0,1);
    lcdWrite(" :test3: ", 9);
    for(i=10; i>0; i--)  testDelay(1000, 500);
    testBlink3();

    // 4. test timer hook: 10 tines, each 2sec ON and 2sec OFF and 2 times 0.2sec ON/OFF with hook at middle
    setTimerHook(hookGo);
    timer0_hook_run = 0;
    for(i=10; i>0; i--){
        testDelay(2000, 2000);
    }
    timer0_hook_run = 1;
    setTimerHook(0);
    testBlink3();
}