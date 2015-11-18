/**
 * Time State Control Simple Library. Prefix for this: TSC_ (tsc_)
 * 
 * Библиотека создания простых конечных автоматов с задержками исполнения по времени
 * в миллисекундах через функцию millis() или через getOvfCount() или через какую ещё.
 * 
 * tsc_getTime() -- макрос, который можно переопределить для замены функции получения тиков времени.
 * 
 * TSC_Time определен как uint16_t -- 16-битное целое, соответственно максимальная задержка = 65.535сек!
 * 
 * Длительность интервалов переопределена для сокращения размера скетчей когда не требуется создавать задержки
 * длительностью более 65.5 секунд. Если надо больше - переопределите этот тип данных.
 * 
 * @author Arhat109 at 2015-07-18
 * @see Arhat.lib::examples/TSC_Blink/TSC_Blink.ino
 */
#ifndef _TSC_
#define _TSC_ 1

#ifdef __cplusplus
extern "C" {
#endif

#define TSC_PERIOD      (1000/1024)             // множитель перевода миллисекунд в тики счетчика

#define tsc_getTime()   ((TSC_Time)getOvfCount())
//#define tsc_getTime()   ((TSC_Time)millis())

typedef uint16_t TSC_Time;              // переопределение интервалов до 65535 мсек
//typedef uint32_t TSC_Time;            // переопределение интервалов до 49.7 дней.

/**
 * Определение типа "команда КА" -- функция, получающая указатель на свой блок данных КА (TSC_Simple,TSC_Control,..)
 * тут как void* для того, чтобы можно было использовать с разными типами КА. Внутри реализации следует приводить к
 * нужному типу явно, например: (TSC_Simple *)ptr
 */
typedef void (*TSC_Command)(void *);

// ****************** Базовый автомат ***************** //
/**
 * Использует 1 функцию и хранит начало интервала, команду и интервал ожидания
 * 
 * Позволяет создавать автономные КА с прямым управлением через запись в структуру данных.
 * Если command == 0, то ничего не вызывает. Можно использовать для однократного или периодического запуска.
 * @example TSC_SimpleHeart_RGB.ino
 */
typedef struct {
  TSC_Time        started_at;           // момент начала текущего интервала ожидания
  TSC_Time        timeout;              // интервал ожидания исполнения команды
  TSC_Command     command;              // команда ожидающая исполнения
} TSC_Simple;

/**
 * функция шага базового автомата для loop(): по завершению интервала вызывает команду из TSC_Simple::command,
 * если она есть. Иначе ничего не делает. Если command не зануляется при исполнении (повторность действий), то
 * время выполнения команды ВХОДИТ в следующий интервал ожидания: сначала фиксирует момент времени и потом
 * вызывает исполнение команды.
 */
void tsc_run( TSC_Simple *_tsc );
void tsc_simple( TSC_Simple *_tsc, TSC_Command command, TSC_Time timeout);

// ****************** Автоматы, управляемые таблицей переходов ***************** //
// @TODO: перевести в С++ класс.
// @TODO: отсюда можно отнаследовать автоматы, возвращающие условия и имеющие более 1 ветки переходов
//        в таблице: бинарные автоматы, автоматы с троичной логикой и т.д.
// @TODO: отсюда же можно отнаследовать автоматы "с памятью" и "стеком исполнения"...

typedef uint16_t TSC_Step_Count;                // размерность нумерации состояний: 16 бит.
//typedef uint8_t TSC_Step_Count;                 // размерность нумерации состояний: 8 бит.

/**
 * Определение типа ячейки хранения состояний автомата во FLASH-памяти программ:
 * 1. сначала вызывается команда, а потом(!) выдерживается указанная в строке пауза до следующей
 * 2. переход на следующее состояние next.
 * Все явные изменения состояний (проверки условий) могут делаться извне через tsc_next()
 * Нумерация состояний с нуля.
 * 
 * Если таблица не задана - ничего не выполняет (отключение автомата)
 * Если в таблице нет команды - производит задержку до следующего выполнения, ничего не вызывает
 * Время команды входит в интервал ожидания следующей.
 */
typedef struct PROGMEM {
  TSC_Command           command;                // команда (метод) для исполнения действий состояния
  TSC_Time              timeout;                // временной интервал следующего состояния (мсек)
  TSC_Step_Count        next;                   // номер следующей команды в таблице состояний КА
} TSC_Step;

// вводим определение типа для хранения текущего состояния конечного автомата (КА) в SRAM:
typedef struct {
  TSC_Time                 started_at;          // момент начала текущего интервала ожидания
  TSC_Time                 timeout;             // интервал до запуска команды по индексу state
  TSC_Step_Count           state;               // номер состояния КА, ожидающий исполнения
  const PROGMEM TSC_Step * table;               // таблица состояний и переходов этого КА
} TSC_Control;

void tsc_init( TSC_Control *_tsc, const PROGMEM TSC_Step * _table, TSC_Step_Count _state );

void tsc_next( TSC_Control *_tsc, TSC_Step_Count _state );

//void tsc_setState( TSC_Control *_tsc, TSC_Step_Count _state );
//void tsc_setWait ( TSC_Control *_tsc, TSC_Time       _wait  );

void tsc_step( TSC_Control *_tsc );

// ================================================================================================================= //
// Определения и реализация конечных автоматов для измерения длительностей сигналов на пинах прерывания PCINT2       //
// Подключаются, только если до вызова #include "tsc.h" определено количество пинов прерывания: MAX_PULSES           //
// , иначе в скетчи будет вставляться процедура обработки прерываний - принудительно.                                //
// ================================================================================================================= //

#ifdef MAX_PULSES

#ifndef _PULSES_H_
#define _PULSES_H_ 1

/**
 * Измерение длительностей импульсов через прерывания PCINT2
 * 
 * Доступные прерывания в Ардуино Мега 2560:
 * INT0..5 отключает I2C:CSL(21),I2C:SDA(20),USART1:RX(19),USART1:TX(18),pwm2 (T3outB),pwm3(T3outC) соответственно.
 * PC_INT0[0..7] отключает SPI:SS(53),SPI:SCK(52),SPI:MOSI(51),SPI:MISO(50),pwm10(T2outA),pwm11(T1outA),pwm12(T1outB),
 *                         (pwm13 - нельзя использовать! Только на выход!)
 * PC_INT1[8..10] отключает USART0:RX(0), USART3:RX(15), USART3:TX(14)
 * PC_INT2[16..23] (Analog8..Analog15)
 * .. остальные ножки прерываний контроллера ATmega2560 в Ардуино - отсутствуют.
 * INT0..7 - каждое прерывание использует свой вектор _VECTOR(1..8)
 * PCINT0..2 - на один вектор - 8 ножек, без контроля с какой ноги прилетело и без управления типом прерываний.
 */
#define PULSE_BUSY      1               // состояние измерителя "занят, идет замер"
#define PULSE_SECOND    2               // измеритель "занят, вычисление длительности"
#define PULSE_OK        3               // "замер произведен, данные верны"
#define PULSE_TIMER     255             // "ошибка по таймауту" нет сигнала или дальность больше предельной
#define PULSE_ERROR     254             // "прочие ошибки измерений"

typedef struct {
  TSC_Simple    ctrl;                   // time-state-control for timeouts
  uint32_t      res;                    // state==PULSE_OK? pulse time in micros : not valid data.
  uint8_t       state;                  // @see PULSE_STATES constants status for this measuring.
  uint8_t       pin;                    // local interrupt pin:[0..7] for this measuring
} Pulse;

uint8_t          pcint2old = 0;         // состояние пинов прерываний "предыдущее"
uint8_t          pcint2numbers[8];      // текущие номера КА из pulses[], измеряющие на пинах 62..69 = 8шт!
Pulse            pulses[MAX_PULSES];    // данные КА измерения длительностей и таймаутов

/**
 * Пишет код ошибки или результата в статус замера и снимает событие таймаута
 * Заодно запрещает перерывание для ноги этого замера.
 */
void pulse_end( Pulse * ptrPulse, uint8_t error)
{
  ptrPulse->state        = error;                       // статус завершения, какой задан.
  ptrPulse->ctrl.command = 0;                           // снимаем команду таймаута.

  PCMSK2 &= ~(((uint8_t)1)<<(ptrPulse->pin));           // запрещаем обработанное прерывание
}

/**
 * Обработчик события таймаута. Вызывается из мененджера событий
 * Устанавливает ошибку таймаута и запрещает прерывание
 */
void pulse_timeout(void *ptrPulse)
{
  pulse_end( (Pulse *)ptrPulse, PULSE_TIMER);
}

/**
 * Обработчик прерывания для замера времени между фронтом и спадом сигнала
 * на ножке прерывания PCINT2 (Analog8..15) "на выбор":
 * 
 * При первом срабатывании - фиксирует "фронт" (сохраняет значение таймера)
 * и изменяет режим своей работы на поиск спада.
 * При втором срабатывании - фиксирует спад сигнала и сохраняет разность времени в микросекундах.
 * Отключается от прерываний.
 * 
 * ISR( PCIBT2_vect ) после подстановок формирует это:
 * 
 * void __vector_ 11(void) __attribute__ ((signal, used, externally_visible));
 * void __vector_ 11(void)
 */
ISR( PCINT2_vect )
{
  uint8_t       regK = PINK;                            // Первым делом читаем ноги регистра К (Analog8..15)
  uint8_t       temp = pcint2old;                       // и предыдущее их состояние
  uint8_t     * ptrNumbers = pcint2numbers;

  pcint2old = regK;                                     // сразу сохраняем новое состояние
  regK = (temp ^ regK) & PCMSK2;                        // ищем разрешенные И сработавшие ножки (нормально 1шт)
  do{
    if( regK & 0x01 )                                   // Если прерывание от этого бита
    {
      Pulse * ptrPulse = pulses+(*ptrNumbers);          // получаем адрес структуры замера

      if( ptrPulse->state == PULSE_BUSY )
      {
        // first measuring! store current micros()
        ptrPulse->res = micros();
        ptrPulse->state = PULSE_SECOND;
      } else {
        // second measuring or mistake: calc pulse time anyone:
        ptrPulse->res = micros() - ptrPulse->res;
        pulse_end(
	  ptrPulse
          , (ptrPulse->state == PULSE_SECOND? PULSE_OK : PULSE_ERROR)
	);
      }
    }
    ptrNumbers++;
    regK = regK >> 1;
  }while(regK);
}

/**
 * Запуск измерения длительности сигнала на ножке через прерывания PCINT2
 * 
 * @param uint8_t  pulseID  -- номер структуры замеров длительности в статическом массиве
 * @param uint8_t  pin      -- номер пина в нумерации Ардуино: [62..69]
 * @param uint16_t timeout  -- [30*1.024 мсек] время ожидания замера основным таймером
 */
void pulse_start(uint8_t pulseID, uint8_t pin, TSC_Time timeout)
{
  uint8_t       intNumber,mskNOT;

  intNumber = pin - 62;                                 // ищем номер прерывания по общему номеру пина
  pcint2numbers[intNumber] = pulseID;                   // сохраняем номер активной структуры
  mskNOT = ~(1<<intNumber);                             // получаем маску для битовых операций {1}0{1}
  pcint2old &= mskNOT;                                  // бит в "было раньше" = 0

  DDRK |= ~mskNOT;                                      // ?надо Pullup? нога "на выход" {0}1{0}
  PORTK |= ~mskNOT;                                     // ?надо Pullup? сброс ножки прерывания в 1 ("echo")
  DDRK &= mskNOT;                                       // нога "на вход"

  pulses[pulseID].state = PULSE_BUSY;                   // закрываем доступ "идет замер"
  pulses[pulseID].pin = intNumber;                      // пригодится для записи ошибки по таймауту
  pulses[pulseID].ctrl.timeout    = timeout;            // Установливаем таймаут КА:
  pulses[pulseID].ctrl.command    = pulse_timeout;
  pulses[pulseID].ctrl.started_at = tsc_getTime();

  PCMSK2 |= ~mskNOT;                                    // и только теперь разрешаем прерывание с этой ноги
  PCICR  |= 4;                                          // и разрешаем вектор PCINT2
}

#endif // _PULSES_H_

#endif // MAX_PULSES


// ================================================================================================================= //
// Определения и реализация конечных автоматов для аналоговой оцифровки сигналов через прерывания от ADC             //
// ================================================================================================================= //
#ifdef MAX_ADC

#ifndef _ADC_H_
#define _ADC_H_ 1

// @TODO: требует окончательного тестирования процедуры обработчика прерываний от АЦП
// для массива потоковой оцифровки через прерывания.
typedef struct {
  uint8_t    pin;
  uint8_t    isReady;
  uint16_t   value;
} ADCvalue;

volatile uint8_t    adcCurrent = 0;
ADCvalue            adcVals[MAX_ADC];

/**
 * Interrupt analog read for array analog pins
 * read current analog value and start reading next values from
 */
ISR(ADC_vect)
{
  ADCvalue * curPtr = &adcVals[adcCurrent];

  curPtr->value = (ADCH<<8) + ADCL;
  curPtr->isReady = 1;

  if( ++adcCurrent > MAX_ADC ) { adcCurrent=0; }        // if next is end, goto start

  curPtr = &adcVals[adcCurrent];                        // get next nanalog to read
  curPtr->isReady = 0;
  ADMUX  |= curPtr->pin & 7;
  ADCSRB |= (curPtr->pin & 8) * 4;
  ADCSRA |= _BV(ADSC);                                  // start next read for next pin
}

#endif // _ADC_H_
#endif // MAX_ADC

#ifdef __cplusplus
}
#endif

#endif // _TSC_