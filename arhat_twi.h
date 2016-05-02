/**
 * Работа с TWI (I2C, 2-Wire) интерфейсом через аппаратные прерывания.
 *
 * ! Аппаратно не бывает одновременно режима Master-RX и Slave-RX - поэтому тут используется ОДИН буфер.
 * ! Нет никаких "проверок", настройка глобалов - обязательна до каждого запуска автомата:
 * Master-Transmitter: twiMT_Ptr, twiMT_Count                  -- откуда и сколько байт свистеть;
 * Master-Receiver:    twiRX_Ptr, twiRX_Count, twiMasterReader -- куда и сколько принять и (опц.)что потом сделать;
 * Slave-Receiver:     twiRX_Ptr, twiRX_Count, twiSlaveReader  -- куда и сколько принять и (обяз.)что сделать;
 * Slave-Transmitter:  twiST_Ptr, twiST_Count, twiSlaveWriter  -- откуда и сколько отдать и (обяз.)что потом сделать;
 *
 * Особенности и отличия от типовых разработок (собрано многое вместе):
 * 1. Возможность одновременной работы как в режиме Master так и в режиме Slave;
 * 2. Внешняя буферизация данных при необходимости. Размер памяти определяется вашей программой, а не тут;
 * 3. Возможность ведения статистики - управляется константами компиляции;
 * 4. Произвольная настройка скорости работы интерфейса от 490гц до 1Мгц с авто вычислением прескалера и регистра скорости
 * 5. Возможность уменьшенной комплиции, если не требуются все режимы сразу.
 *
 * Константы компиляции #define:
 * #define TWI_ON   1 // если не определено, то обработчик прерывания I2C останется, но практически ПУСТОЙ!
 * Перед включением этого файла надо определить TWI_ON значениями:
 *
 * #define TWI_ON 1  // Master-Transmitter only: компилировать как режим Мастера-передатчика    ,ISR(TWI)=190 байт
 * #define TWI_ON 2  // Master-Receiver only:    компилировать как режим Мастер-приемник        ,ISR(TWI)=224 байт
 * #define TWI_ON 4  // Slave-Receiver only:     компилировать как режим Ожидающий получатель   ,ISR(TWI)=202 байт
 * #define TWI_ON 8  // Slave-Transmitter only:  компилировать как режим Отправитель по запросу ,ISR(TWI)=188 байт
 *
 * @TODO: #define TWI_ON 16 // + Logging: Включить в компиляцию логирование работы интерфейса.
 *
 * !!! Допускается компиляция нескольких режимов одновременно:
 * #define TWI_ON (1+2+4+8) // Включить в компиляцию ВСЕ режимы. ,ISR(TWI)=424 байт.
 *
 * @author Arhat109-20160402. arhat109@mail.ru
 * @license:
 *   1. This is a free software for any using and distributing without any warranties.
 *   2. You should keep author tag with any changes. May be with adding.
 *   Это свободное ПО для любого использования без каких-либо гарантий и претензий.
 *   Требуется сохранять тег @author при любых изменениях. Можете дописать свой.
 */
#ifndef _ARHAT_TWI_H_
#define _ARHAT_TWI_H_ 1

#include "arhat.h"

// If not defined - use as Master Transmitter only!
// Если нет ничего, то только управляющий мастер!
#ifndef TWI_ON
#  define TWI_ON TWI_MASTER_TX
#endif // TWI_ON

// ------------ All states TWI status register AND twiState: ------------- //
// Misc
#define TWI_ERROR                  0x00 // Misc: illegal start or stop condition
#define TWI_NO_INFO                0xF8 // Misc: no state information available

// I am Master
#define TWI_START                  0x08 // start condition transmitted
#define TWI_REP_START              0x10 // repeated start condition transmitted
#define TWI_MTR_ARB_LOST           0x38 // arbitration lost in SLA+W or data

// Master Transmitter
#define TWI_MT_SLA_ACK             0x18 // address: SLA+W transmitted, ACK received
#define TWI_MT_SLA_NACK            0x20 // address: SLA+W transmitted, NACK received
#define TWI_MT_DATA_ACK            0x28 // data: transmitted, ACK received
#define TWI_MT_DATA_NACK           0x30 // data: transmitted, NACK received

// Master Receiver
#define TWI_MR_SLA_ACK             0x40 // address: SLA+R transmitted, ACK received
#define TWI_MR_SLA_NACK            0x48 // address: SLA+R transmitted, NACK received
#define TWI_MR_DATA_ACK            0x50 // data: received, ACK returned
#define TWI_MR_DATA_NACK           0x58 // data: received, NACK returned

// I am Slave
// Slave Receiver
#define TWI_SR_SLA_ACK             0x60 // address: SLA+W received, ACK returned
#define TWI_SR_ARB_LOST_SLA_ACK    0x68 // arbitration lost in SLA+RW, SLA+W received, ACK returned
#define TWI_SR_GCALL_ACK           0x70 // general call received, ACK returned
#define TWI_SR_ARB_LOST_GCALL_ACK  0x78 // arbitration lost in SLA+RW, general call received, ACK returned
#define TWI_SR_DATA_ACK            0x80 // data: received, ACK returned
#define TWI_SR_DATA_NACK           0x88 // data: received, NACK returned
#define TWI_SR_GCALL_DATA_ACK      0x90 // general call data received, ACK returned
#define TWI_SR_GCALL_DATA_NACK     0x98 // general call data received, NACK returned
#define TWI_SR_STOP                0xA0 // stop or repeated start condition received while selected

// Slave Transmitter
#define TWI_ST_SLA_ACK             0xA8 // address: SLA+R received, ACK returned
#define TWI_ST_ARB_LOST_SLA_ACK    0xB0 // arbitration lost in SLA+RW, SLA+R received, ACK returned
#define TWI_ST_DATA_ACK            0xB8 // data: transmitted, ACK received
#define TWI_ST_DATA_NACK           0xC0 // data: transmitted, NACK received
#define TWI_ST_LAST_DATA           0xC8 // last data byte transmitted, ACK received

// ------------ Macros for TWI ------------- //

#define TWI_STATUS_MASK (_BV(TWS7)|_BV(TWS6)|_BV(TWS5)|_BV(TWS4)|_BV(TWS3)) // Two LSB are prescaler bits
#define TWI_STATUS      (TWSR & TWI_STATUS_MASK)                            // Get status from TWSR

#define TWI_READ    1                   // for SLA+R address
#define TWI_WRITE   0                   // SLA+W address
#define TWI_ACK     1
#define TWI_NACK    0

#define twiOn()       (PRR0 &= ~_BV(7)) // =0: TWI power is On (default on power!)
#define twiOff()      (PRR0 |= _BV(7))  // =1: TWI power is Off

/**
 * Set twi bit rate and prescaler: _twbr:[0..255], _twsr:[0..3]
 * ------------------------------------------------------------
 * _twsr = 3: scl freq. = [   490 .. 111_111] hz
 * _twsr = 2: scl freq. = [ 1_960 .. 333_333] hz
 * _twsr = 1: scl freq. = [ 7_782 .. 666_667] hz
 * _twsr = 0: scl freq. = [30_418 .. 888_889] hz
 * IF _twbr = 0: frequency equal 1 Mhz with any _twsr!
 *
 * @example twiSetRate(72,0) : use 100_000hz standart mode
 * @example twiSetRate(12,0) : use 400_000hz standart mode
 * @example twiSetRate(0,0)  : use 1 Mhz mode
 */
#define twiSetRate(_twbr, _twsr)      \
{                                     \
  _SFR_BYTE(TWSR) = (uint8_t)(_twsr); \
  TWBR = (uint8_t)(_twbr);            \
}
/**
 * Макросы управления автоматом TWI: последняя команда везде - запись в TWCR
 *
 * @param bool ack -- есть ли режимы Slave, надо ли слушать шину?
 *
 * twiStart()      -- включаем, разрешаем, сброс прерывание(запуск КА) и выставляем старт на шину.
 * twiReply()      -- оно же, только без старта
 * twiReleaseBus() -- включаем, сброс прерывание(запуск КА), а вот прерывание разрешаем только если есть Slave
 * twiStop()       -- оно же, только ещё и отправляем "стоп" в шину и ждем исполнения.
 */
#define twiStart(ack)                   (_BV(TWEN)|_BV(TWINT)|_BV(TWIE)|_BV(TWSTA)|((ack)?_BV(TWEA):0))
#define twiReply(ack)                   (_BV(TWEN)|_BV(TWINT)|_BV(TWIE)|((ack)? _BV(TWEA):0))
#define twiReleaseBus(ack)              (_BV(TWEN)|_BV(TWINT)|((ack)? _BV(TWEA)|_BV(TWIE):0))
#define twiSetAddress(address, isGcall) (TWAR  = (uint8_t)(((address) << 1)|((isGcall)&0x01)))
#define twiSetMaskAddress(mask)         (TWAMR = (uint8_t)(mask))
#define twiStop(ack)                    \
{                                       \
  TWCR = _BV(TWSTO)|twiReleaseBus(ack); \
  while(TWCR & _BV(TWSTO));             \
  twiMode |= TWI_READY;                 \
}

#ifdef __cplusplus
    extern "C" {
#endif
// ------------ TWI internal variables ------------- //

enum TwiModes {
     TWI_IS_SLAVE  = 1                                  // have I slave mode too?
    ,TWI_SEND_STOP = 2                                  // is need send stop when Master is ending?
    ,TWI_READY     = 4                                  // previous work is ended
};

volatile uint8_t    twiMode;
volatile uint8_t    twiState;                           // state TWI automat
volatile uint8_t    twiSLARW;                           // address for send to (SLARW)

volatile uint8_t   twiMT_Count;                         // остаток байт для передачи мастеров
volatile uint8_t  * twiMT_Ptr;                          // указатель текущего байта внешнего буфера передачи мастером

volatile uint8_t   twiRX_Count;                         // остаток байт для приема мастером/слейвом
volatile uint8_t  * twiRX_Ptr;                          // указатель текущего байта внешнего буфера приема мастером/слейвом

volatile uint8_t   twiST_Count;                         // остаток байт для передачи слейвом
volatile uint8_t  * twiST_Ptr;                          // указатель текущего байта внешнего буфера передачи слейвом

volatile void    (* twiHookRestart)(void) = 0;          // указатель на функцию перезапуска мастера без освобождения шины (TWI_SEND_STOP)
volatile void    (* twiMasterReader)(void) = 0;         // указатель на функцию "Master принял данные, куда их?"
volatile void    (* twiSlaveReader)(void) = 0;          // указатель на функцию "Slave принял данные, куда их?"
volatile void    (* twiSlaveWriter)(void) = 0;          // указатель на функцию "Slave всё отправил, что дальше?"

/*
#if defined(TWI_ON) && (TWI_ON & TWI_LOG_ON)

typedef struct {
    uint16_t   starts,restarts,stops,losts,noslarw,mtx,mrx,srx,grx,stx;
} TwiStat;
#define ptrTwiStat(ptr)  ((TWI_Stat *)(ptr))
static volatile TwiStat    twiStatistic;

#endif // TWI_ON::TWI_LOG_ON
*/
// ------------ TWI functions ------------- //

/**
 * Autocalculate and set twi prescaler and bit rate
 * 1Mhz      .. 30.418khz : TWSR=0!
 * 30.42khz  ..  7.782khz : TWSR=1
 *  7.782khz ..  1.960khz : TWSR=2
 *  1/960khz ..  0.490khz : TWSR=3
 */
void twiSpeed(uint32_t freq)
{
    uint16_t bitRate = (F_CPU / freq) - 16;
    uint8_t  bitMul  = 0;

    while( (bitRate > 511) && (bitMul < 3) ){
        bitRate /= 4; bitRate += 1; bitMul++;
    }
    bitRate /= 2;
    if( bitRate > 255 ) return;
    twiSetRate(bitRate, bitMul);
}

/**
 * for Arduino setup() as Master or Slave or Both modes
 * freq:[490 .. 1 000 000], mode:[0,TWI_IS_SLAVE]
 */
void twiSetup(uint32_t freq, uint8_t mode)
{
    digitalWrite(I2C_SDA, HIGH);                                  // internal pullup is ON.
    digitalWrite(I2C_SCL, HIGH);
    twiSpeed(freq);                                               // set bitrate and prescaler for frequency
    twiMode = mode;
    TWCR = _BV(TWEN)|_BV(TWIE)|((mode&TWI_IS_SLAVE)?_BV(TWEA):0); // module, acks, and interrupt is ON
}

/**
 * for ISR(TWI): control restart conditions in all modes:
 * ! if only 1 mode -- this is a MACRO with next RETURN into ISR, else - function !
 *
 * 1. Освобождать шину, или надо ещё (напр. прием после передачи)?
 * да: Сеанс завершен. Ждем прямо тут прохождения стопа! Выходим из обработчика тут!
 * нет, рестарт:
 * .. есть Хук? процедура подготовки след. посылки: указатели, размеры, адрес, режим..
 * .. а нет Хука! Типовой режим "чтение после записи"
 * в любом случае отправляем restart
 *
 */
#if ((TWI_ON & 0x0F)!=1) && ((TWI_ON & 0x0F)!=2) && ((TWI_ON & 0x0F)!=4) && ((TWI_ON & 0x0F)!=8)
void twiSendStop(uint8_t _md)
{
    if (_md & TWI_SEND_STOP)
    {
        TWCR = _BV(TWSTO)|twiReleaseBus(_md & TWI_IS_SLAVE);
        while(TWCR & _BV(TWSTO));
        twiMode |= TWI_READY;
    }else{
        if( twiHookRestart ){
            twiHookRestart();
        } else {
            twiSLARW |= TWI_READ;
        }
        TWCR = twiStart(_md & TWI_IS_SLAVE);
    }
}
#else
#define twiSendStop(_md)                                   \
{                                                          \
    TWCR = _BV(TWSTO)|twiReleaseBus((_md) & TWI_IS_SLAVE); \
    while(TWCR & _BV(TWSTO));                              \
    twiMode |= TWI_READY;                                  \
}
#endif

/**
 * ISR for TWI interface: realised master and slave modes
 * ------------------------------------------------------
 */
ISR(TWI_vect)
{
    uint8_t _cr = twiReply(0);
    uint8_t _md = twiMode;
    uint8_t _st = twiState=TWI_STATUS;

#if defined(TWI_ON) && ((TWI_ON & TWI_IS_SLAVE_TX)||(TWI_ON & TWI_IS_SLAVE_RX))
    if( _st >= TWI_SR_SLA_ACK )
    {
#if (TWI_ON & TWI_IS_SLAVE_TX)
        if( (_st == TWI_ST_DATA_NACK) || (_st == TWI_ST_LAST_DATA) )
        {
            // ST: Был последний байт, мастер наелся ..
            // ST: Был наш последний байт: предупреждали мастера twiReply(NACK)
            twiSlaveWriter();                                   // Хук - обязателен! Дальше нечего передавать..
            _md=twiMode;                                        // возможно изменение режимов в хуке!
            twiSendStop(_md); return;
        }else{
            if( (_st == TWI_ST_ARB_LOST_SLA_ACK) || (_st == TWI_ST_SLA_ACK || _st == TWI_ST_DATA_ACK) )
            {
                // ST: Моего мастера заткнули и просят данные ..
                // ST: Мой адрес, начинаем ..
                // ST: Отправлено успешно, продолжаем ..
                TWDR = *twiST_Ptr++;
                _cr = twiReply(--twiST_Count);
            }else{
#endif // TWI_ON::TWI_IS_SLAVE_TX
#if (TWI_ON & TWI_IS_SLAVE_RX)
                if( (_st == TWI_SR_GCALL_DATA_NACK) || (_st == TWI_SR_DATA_NACK) || (_st == TWI_SR_STOP) )
                {
                    if( (_st == TWI_SR_GCALL_DATA_NACK) || (_st == TWI_SR_DATA_NACK) )
                    {
                        // SR: УПС. GCall - туда же.
                        // SR: УПС. Получен байт, мастеру уже был отправлен NACK
                        *twiRX_Ptr = TWDR;
                    }
                    // SR: Обнаружен stop или restart в процессе приема .. это всё?
                    twiSlaveReader();                           // Хук обязателен! это последний, дальше некуда складывать!
                    _md=twiMode;                                // возможно изменение режимов в хуке!
                    twiSendStop(_md); return;
                }else{
                    if( (_st == TWI_SR_GCALL_DATA_ACK) || (_st == TWI_SR_DATA_ACK) )
                    {
                        // SR: пришел байт всем - аналогично
                        // SR: пришел байт, можно ещё принять
                        *(twiRX_Ptr++) = TWDR;
                    }
                    // TWI_SR_ARB_LOST_SLA_ACK   SR: Мастер потерял шину: нет данных ..
                    // TWI_SR_ARB_LOST_GCALL_ACK SR: Вызов всем потерял шину (как это?) --""--
                    // TWI_SR_SLA_ACK            SR: Адрес принят, ещё только ждем данные
                    // TWI_SR_GCALL_ACK          SR: Вызов всем принят оно же
                    _cr = twiReply(--twiRX_Count);              // .. приняли байт и отправляем NACK если осталось 1 место.
                }
#endif // TWI_ON::TWI_IS_SLAVE_RX
#if (TWI_ON & TWI_IS_SLAVE_TX)
            }
        }
#endif // TWI_ON::TWI_IS_SLAVE_TX
    }else{

#endif // TWI_ON::TWI_SLAVE..
#if defined(TWI_ON) && (TWI_ON & TWI_MASTER_TX)
        // Master Transmiter or Reciever modes
        if( (_st == TWI_START) || (_st == TWI_REP_START) )
        {
            // MT,MR:: Прошла отправка стартовой посылки
            // MT,MR:: Прошла отправка повторного старта
            TWDR = twiSLARW;
            _cr = twiReply(_md & TWI_IS_SLAVE);
        }else{
            if( (_st == TWI_MT_SLA_NACK) || (_st == TWI_MT_DATA_NACK) )
            {
                // TWI_MT_DATA_NACK MT:: Упс. data NACK: Получатель не хотит?
                // TWI_MT_SLA_NACK  MT:: Упс. Получатель NACK .. не откликается зараза.
                twiSendStop(_md); return;
            }
            if( (_st == TWI_MT_SLA_ACK)  || (_st == TWI_MT_DATA_ACK) )
            {
                // MT: Адрес получателя отправлен успешно, начинаем
                // MT: Байт данных отправлен, продолжаем
                if( twiMT_Count-- ){
                    TWDR = *twiMT_Ptr++;
                    _cr = twiReply(_md & TWI_IS_SLAVE);
                }else{
                    twiSendStop(_md); return;
                }
            }else{
#endif // TWI_ON::TWI_MASTER_TX
#if defined(TWI_ON) && (TWI_ON & TWI_MASTER_RX)
                if( _st == TWI_MTR_ARB_LOST )
                {
                    // MT,MR: Упс. Мастер потерял шину: освобождаем и ждем/слушаем.
                    _md |= TWI_READY;
                    _cr = twiReleaseBus(_md & TWI_IS_SLAVE);
                }else{
                    if( (_st == TWI_MR_DATA_ACK) || (_st == TWI_MR_SLA_ACK) )
                    {
                        if( _st == TWI_MR_DATA_ACK ){
                            // MR: байт принят, ACK отправлен
                            *(twiRX_Ptr++) = TWDR;
                        }
                        // MR: Отправитель найден, начинаем прием
                        _cr = twiReply( --twiRX_Count );        // .. Можно ещё принять? Или Отправителю - NACK
                    }else{
                        if( _st == TWI_ERROR ) return;
                        if( _st == TWI_MR_DATA_NACK )
                        {
                            // MR: Упс. Получен последний байт дальше принимать некуда.
                            *twiRX_Ptr = TWDR;
                            if( twiMasterReader ) twiMasterReader();
//                            goto TWI_RET_HOOK;
                            _md=twiMode;                        // возможно изменение режимов в хуке!
                        }
                        // All other Master states: stop/restart if need
                        // TWI_MR_SLA_NACK  MR:: Упс. Отправитель NACK .. не откликается зараза.
                        twiSendStop(_md); return;
                    }
                }
#endif // TWI_ON::TWI_MASTER_RX
#if defined(TWI_ON) && (TWI_ON&TWI_MASTER_TX)
            }
        }
#endif // TWI_ON::TWI_MASTER_TX
#if defined(TWI_ON) && ((TWI_ON & TWI_IS_SLAVE_TX)||(TWI_ON & TWI_IS_SLAVE_RX))
    }
#endif // TWI_SLAVE_ON
    twiMode = _md;
    TWCR = _cr;
} //end ISR()

// -------------------------              (PROTECTED)             ------------------------- //
// Внутренние методы интерфейса, могут пригодится для создания внешних уровней работы с I2C //
// ---------------------------------------------------------------------------------------- //

/**
 * INTERNAL:: Простая передача. Запись адреса собеседника и запуск автомата TWI
 *
 * @see twiWrite(), twiRead()
 */
void _twiStartTo(uint8_t address)
{
    twiSLARW = address;                                 // Режим поставляется вместе с адресом!
    twiMode |= TWI_SEND_STOP;                           // только 1 бит! Могли быть иные режимы..
    TWCR = twiStart(twiMode & TWI_IS_SLAVE);
}

/**
 * INTERNAL:: Передача с рестартом. Запись адреса собеседника и запуск автомата TWI
 *
 * @see twiWrite(), twiRead()
 */
void _twiStartRe(uint8_t address)
{
    twiSLARW = address;                                 // Режим поставляется вместе с адресом!
    twiMode &= ~TWI_SEND_STOP;                          // только 1 бит! Могли быть иные режимы..
    TWCR = twiStart(twiMode & TWI_IS_SLAVE);
}

#define _twiWaitReady()             {while(!(TWI_READY & twiMode)); twiMode &= ~TWI_READY;}
#define _twiMT_Buffer(data, length) (twiMT_Ptr=(volatile uint8_t *)(data), twiMT_Count=(volatile uint8_t)(length))
#define _twiRX_Buffer(data, length) (twiRX_Ptr=(volatile uint8_t *)(data), twiRX_Count=(volatile uint8_t)(length))
#define _twiST_Buffer(data, length) (twiST_Ptr=(volatile uint8_t *)(data), twiST_Count=(volatile uint8_t)(length))

// -------------------------                PUBLIC                ------------------------- //
// ---------------------------------------------------------------------------------------- //

/**
 * Master-TX:: Передача length байт по адресу получателя. Только запуск!
 */
void twiWrite(uint8_t address, const uint8_t * data, uint8_t length)
{
    _twiWaitReady();                                    // Ждем завершения предыдущей работы
    _twiMT_Buffer(data, length);
    _twiStartTo( (address<<1) | TWI_WRITE );            // Режим передачи!
}

/**
 * MASTER-RX:: Прием length байт из адреса отправителя. Только запуск!
 */
void twiRead(uint8_t address, uint8_t * data, uint8_t length)
{
    _twiWaitReady();                                    // Ждем завершения предыдущей работы
    _twiRX_Buffer(data, length);
    _twiStartTo( (address<<1) | TWI_READ );             // Режим приема данных!
}

/**
 * Master Read-after-Write:: Чтение данных после отправки команды. Только запуск.
 * !!! Не совместимо с Slave Receive Mode - буфер приема общий !!!
 */
void twiRAW(uint8_t address                             // адрес устройства
, uint8_t* command, uint8_t clength                     // команда и её длина
, uint8_t* data, uint8_t dlength                        // буфер приема данных и его длина
){
    _twiWaitReady();                                    // Ждем завершения предыдущей работы
    _twiMT_Buffer(command, clength);
    _twiRX_Buffer(data, dlength);

    twiHookRestart = 0;                                 // типовой переход на чтение этого же Slave
    twiMode |= TWI_SEND_STOP;                           // рестарт после отправки команды
    twiSLARW = (address<<1 | TWI_WRITE);                // Сначала режим передачи!
    TWCR = twiStart(twiMode & TWI_IS_SLAVE);
}

/**
 * @example: Пример реализации обработчика "SLAVE отправил всё, что дальше?"
 * для случая, когда текущий буфер можно отправлять повторно по следующему запросу
 *
 * !!! Использует доп. глобалы (должны быть определены в вашем скетче):
 *  uint8_t * stBuffer;
 *  uint8_t   stBufferSize;
 *//*
 void twiSlaveRewriter(void)
 {
     _twiST_Buffer(stBuffer, stBufferSize);             // просто перенастраиваем буфер на повторную передачу.
 }
*/
#ifdef __cplusplus
    }
#endif

#endif // _ARHAT_TWI_H_