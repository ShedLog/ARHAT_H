/**
 * Набор примитивов для работы с дисплеем LCD1602 или иными на базе 1,2 контроллеров HD44780
 * 1 контроллер держит дисплеи 8х2 или 16х1; 2 контроллера держат дисплеи 16х2. Программируются вроде как одинаково.
 *
 * !!! Пока только базовые примимтивы .. в развитии.
 *
 * Тайминги циклов шины связи с МК HD44780:
 * 1. Предустановка RS,R/W:          >60нсек от фронта E (>80нсек х2)
 * 2. Длительность строба записи E:  >500нсек (x2 устр.: LCD1602!) с периодом >1мксек
 * 3. Предустановка данных D7..D0:   >300нсек от спада E
 * 4. Удержание D7..D0, RS, R/W:     >20нсек после спада E (1), >300нсек (x2 контроллера!)
 * 5. Время исполнения команд в среднем <=37мксек -- в даташите НЕВЕРНО! Реально около 4.1 миллисекунды !!!
 *
 * Длительность 1 передачи по I2C на 100кГц = 90мксек! В реальности тянет до 800кгц..
 * Нельзя ничего читать с дисплея (R/W===0)! А ведь есть BF - "бит готовности" ..
 *
 * Отсюда передача возможна только побайтная:
 * сразу готовим посылку каждой тетрады в виде 3-х байт: установка, строб, сброс строба,
 * и сразу же отправляем одной пачкой обе тетрады. Итого буфер на передачу 1 байта = 6.
 *
 * @author Arhat109-20160402. arhat109@mail.ru
 * @license:
 *   1. This is a free software for any using and distributing without any warranties.
 *   2. You should keep author tag with any changes. May be with adding.
 *   Это свободное ПО для любого использования без каких-либо гарантий и претензий.
 *   Требуется сохранять тег @author при любых изменениях. Можете дописать свой.
 */
#ifndef _LCD1602_H_

#ifndef _ARHAT_TWI_H_
  #define TWI_ON           TWI_MASTER_TX         // only Master-Transmit mode! Not use other mode in this!
  #include "arhat_twi.h"
#endif // _ARHAT_TWI_H_

#ifndef LCD_I2C_SPEED
  #define LCD_I2C_SPEED    800000
#endif

// LCD on chip HD44780 команды или их коды операций:
#define LCD_CLEAR          0x01
#define LCD_HOME           0x02
#define LCD_SHIFTS         0x04  // часть!
#define LCD_SHOWS          0x08  // часть!
#define LCD_MODES          0x20  // часть!
#define LCD_FONT_RAM       0x40  // адрес в таблицу шрифтов 6бит
#define LCD_SHOW_RAM       0x80  // адрес текущей позиции 7бит

#define LCD_CURSOR_LEFT    0x10  // команда сдвига курсора влево
#define LCD_CURSOR_RIGHT   0x14  // команда сдвига курсора вправо
#define LCD_ROW_LEFT       0x18  // команда сдвига всей строки влево
#define LCD_ROW_RIGHT      0x1C  // команда сдвига всей строки вправо

// for LCD_SHIFTS:
#define LCD_INC            0x02  // Инкремент: сдвиг вправо при записи байта
#define LCD_SHIFT_ON       0x01  // сдвиг и строки тоже при записи байта (в обратную сторону! Курсор как-бы на месте)

// for LCD_SHOWS:
#define LCD_SHOW_ON        0x04  // включить отображение
#define LCD_CURSOR_UL      0x02  // включить курсор подчерком
#define LCD_CURSOR_BLINK   0x01  // включить мигание курсора

// for LCD_MODES:
#define LCD_8BIT           0x10  // шина 8бит/4бит
#define LCD_2LINE          0x08  // память 2/1 строки
#define LCD_5x10           0x04  // фонт 5х10 / 5х8 точек

// Пустышки для полноты картины:
#define LCD_DEC        0 // сдвиг курсора/экрана влево
#define LCD_SHIFT_OFF  0 // сдвиг строки отключен
#define LCD_SHOW_OFF   0 // дисплей выключен
#define LCD_CURSOR_OFF 0 // курсор выключен
#define LCD_5x8        0
#define LCD_1LINE      0 // только одна строка (1 буфер 80символов, иначе 2х40)
#define LCD_4BIT       0 // 4бита: каждый байт идет 2 посылками "подряд" по линиям D7..D4

// Маски бит данных (D3,D2,D1,D0), управляющие сигналами напрямую:
#define LCD_BACK      B00001000  // bit D3 управляет подсветкой экрана при каждом выводе в I2C!
#define LCD_E         B00000100  // Enable bit - Strobe for read/write >230msec.
#define LCD_RW        B00000010  // Read/Write bit - ==0 всегда!
#define LCD_RS        B00000001  // Команда(0) или данные(1)

#define LCD_WAIT_BOOT0       15  // тиков Т0:  >15мсек пауза на включение
#define LCD_WAIT_BOOT1        5  // тиков Т0:  >4,1мсек пауза повторной 0x30
#define LCD_WAIT_BOOT2      400  // (по 250нсек) >100мксек пауза третьей 0x30
#define LCD_WAIT_1            5  // тиков Т0: 4мксек - мало! (>37мксек пауза на команду "в среднем")

/**
 * Отправка буфера дисплею по 4-битному протоколу с "ручным" стробированием
 * и типовой задержкой на выполнение команды
 */
#define lcdSend(len)                               \
{                                                  \
  twiWrite(lcdAddress, lcdBuffer, (uint8_t)(len)); \
  delay(LCD_WAIT_1);                               \
}

#define lcdWrite1(d)     {lcdPrepare((uint8_t)(d), 1); lcdSend(6);}
#define lcdCommand(p)    {lcdPrepare((uint8_t)(p), 0); lcdSend(6);}
#define lcdClear()       {lcdCommand(LCD_CLEAR); delay(16);}
#define lcdHome()         lcdCommand(LCD_HOME)
#define lcdCursorLeft()   lcdCommand(LCD_CURSOR_LEFT)
#define lcdCursorRight()  lcdCommand(LCD_CURSOR_RIGHT)
#define lcdRowLeft()      lcdCommand(LCD_ROW_LEFT)
#define lcdRowRight()     lcdCommand(LCD_ROW_RIGHT)
#define lcdFontAddress(f) lcdCommand(LCD_FONT_RAM | ((uint8_t)(f)&0x3F))
#define lcdShowAddress(a) lcdCommand(LCD_SHOW_RAM | ((uint8_t)(a)&0x7F))

/**
 * Установить абсолютную позицию курсора
 */
#define lcdSetCursor(_col,_row) \
    (lcdCommand(LCD_SHOW_RAM | ((((_row)? 0x40 : 0x00) + (uint8_t)(_col)) & 0x7f)))

/**
 * Установить позицию записи в память шрифтов
 */
#define lcdGoChar5x8(_ch) (lcdCommand(LCD_FONT_RAM | ((((uint8_t)(_ch))<<3)&0x3f)))

#ifdef __cplusplus
  extern "C" {
#endif

    uint8_t lcdModes  = LCD_MODES | LCD_8BIT;               // PowerON: 8bit mode, 1 line, 5x8 font
    uint8_t lcdShifts = LCD_SHIFTS | LCD_INC;               // PowerON: cursor shift to right, not screen!
    uint8_t lcdShows  = LCD_SHOWS;                          // PowerON: show off, cursor off, blink off
    uint8_t lcdBackLight = LCD_BACK;                        // PowerON: Backlight is ON

    uint8_t lcdAddress = 0x27;       // for myLCD1602 parameters as default
    uint8_t lcdCols = 16;
    uint8_t lcdRows = 2;
    uint8_t lcdBuffer[6];            // Буфер для потоковой тетрадной записи в дисплей

    /**
     * Подготовка байта в буфер потоковой записи
     * @param _rs=[0 -- команда,!0 -- данные]
     */
    void lcdPrepare(uint8_t _data, uint8_t _rs)
    {
        uint8_t nibble = (_data&0xf0) | lcdBackLight;

        if( _rs ) nibble |= LCD_RS;
        lcdBuffer[2] = lcdBuffer[0] = nibble;
        nibble |= LCD_E;
        lcdBuffer[1] = nibble;

        nibble = ((_data&0x0f)<<4) | lcdBackLight;

        if( _rs ) nibble |= LCD_RS;
        lcdBuffer[5] = lcdBuffer[3] = nibble;
        nibble |= LCD_E;
        lcdBuffer[4] = nibble;
    }

    /**
     * Вывод строки заданной длины (буфера) на экран.
     * Повторная установка скорости работы дисплея по I2C и режима (мало ли кто и как работает ещё)
     */
    void lcdWrite(const void *buf, uint8_t len)
    {
        uint8_t *_b = (uint8_t *)buf;
        uint8_t  _l = len;

        twiMode |= TWI_SEND_STOP;
        while(_l--)
            lcdWrite1(*_b++);
    }

    /**
     * Полная перенастройка экрана по текущим значениям режимов.
     */
    void lcdInit()
    {
        lcdCommand(lcdModes);           // повторяем режим: 4 бита, но уже + сколько строк и какой шрифт
        lcdCommand(lcdShows);           // включаем дисплей и курсор
        lcdCommand(lcdShifts);          // настройка режимов сдвига курсора/экрана
        lcdClear();                     // очень долго очищаем экран (>15.2мсек)
        lcdHome();
    }

    /**
     * for setup(): powerON initialization for LCD with Hitachi HD44780 (up to 40 cols, 2 rows)
     */
    void lcdSetup(uint8_t _address, uint8_t _cols, uint8_t _rows, uint8_t _backLight)
    {
        lcdAddress   = _address;
        lcdCols      = _cols;
        lcdRows      = _rows;
        lcdBackLight = (_backLight? LCD_BACK : 0);
        lcdModes     = LCD_MODES;
        lcdShifts    = LCD_SHIFTS | LCD_INC;
        lcdShows     = LCD_SHOWS  | LCD_SHOW_ON;

        #ifndef TWI_SETUP
        twiSetup(LCD_I2C_SPEED, TWI_READY|TWI_SEND_STOP); // только если не запущен ранее!
        #define TWI_SETUP "lcd1602.h"                     // фиксим, что I2C инициализируется этой библиотекой
        #endif

        if( _rows>1 )          { lcdModes |= LCD_2LINE; } // else 1 line

        // @see datasheet: power on sequence
        {
            lcdPrepare(0x30, 0);          // HD44780: RS=0 запись в регистр команд дисплея.

            delay(LCD_WAIT_BOOT0);        // powerOn it needs wait from 15 upto 50msec
            lcdSend(3);                   // 1x3 отправка: по включению режим 8-бит - вторая тетрада не нужна!
            delay(LCD_WAIT_BOOT1);        // ждем >4.1ms
            lcdSend(3);                   // вторая отправка согласно даташит 8-бит..
            delayMicro16(LCD_WAIT_BOOT2); // ждем >100us
            lcdSend(3);                   // третья отправка 8-бит..

            lcdPrepare(0x20, 0);          // и только теперь переводим в режим 4-бита
            lcdSend(3);                   // и только теперь режим 4-бита и отправляем тетрады попарно!
        }
        lcdInit();
        delay(500);                     // чтобы было заметно глазом.. один раз.
    }

#ifdef __cplusplus
  } // extern "C"
#endif

#endif // _LCD1602_H_
