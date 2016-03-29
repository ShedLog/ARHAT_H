/**
 * Обработка данных с датчиков цвета TCS3200(TCS3210) в стиле конечных автоматов (без потерь времени на ожидания).
 *
 * Предположено:
 * 0. контроллер - Arduino Mega 2560
 * 1. Замер данных методом подсчета периодов частоты внешним входом счетчика Т5 Atmega2560
 * 2. Максимально - 2 датчика, различаемых сигналом !OE (проверять что на плате датчика он не закорочен на землю принудительно!)
 * 3. Сигналы датчиков S0, S2 -- подключены к +5в (лог.1) и задают максимальную скорость счета и предел частоты <=600кгц.
 * 4. Сигналы Out,S2,S3 -- общие от обоих датчиков. Активность датчиков устанавливается сигналом !OE
 *
 * Для подключения большего числа датчиков к счетчику надо (в этом файле!):
 * а) задать доп. номера пинов для сигналов OE доп. датчиков. Каждый такой сигнал должен приходить на свой пин Ардуины;
 * б) увеличить константу количества датчиков TCS_MAX_SENSORS до требуемого количества;
 *
 * Для использования другого 16-и разрядного таймера (1,3 или 4), если у вас есть его "счетный вход" надо переназначить
 * все ноги на новый таймер и указаеть его номер .. первый блок #define
 *
 * Подключение файла:
 * 1. Убедитесь, что ваш датчик(и) соединены с Мегой как тут предположено. Предварительно проверьте, что датчик(и)
 *    управляются сигналом ОЕ .. а то мои оказались закорочены - чуть не спалил;
 *
 * 2. void setup(){
 *      // ... настройки, те что надо вашей программе ..
 *      oldTimerHook = tcsSetup(); // Бывший расширитель прерывания RTC, можно и не сохранять, если не надо.. (def.=0)
 *    }
 *
 * 3. void loop()
 *    {
 *      tcsPrepare({0|1|num}); -- вызов настройки заданного датчика на замеры (номер: число, переменная - все равно)
 *
 *      // ... ваш код основной программы ...
 *      // ... в нем можно пользоваться данными из глобального массива tcsColors[num][color]
 *      // ... поскольку в нем лежат только реальные данные.
 *      // ... узнать что данные обновлены можно, например посмотрев счетчик замеров tcsCount (а надо ли?!?)
 *      // ... режимы замеров можно изменять на лету в tcsModes
 *      // ... повторный запуск того же самого датчика можно делать макросом tcsStart() или просто присваиванием (как в нем)
 *    }
 *
 * !!! Не желательно ускорять замеры шустрее 4мсек, если режим замера предполагает автоподстройку скорости самим датчиком.
 *
 * Остальное - читайте этот файл, пользуйтесь.
 *
 * @author Arhat109, e-mail: arhat109@mail.ru, phone +7-(951)-388-2793
 *
 * Лицензия: полностью бесплатное ПО, в том числе и от любых претензий. Вопросы и пожелания - принимаются на почту.
 * Вы можете его использовать на свой страх и риск любым известным вам способом.
 *
 * Если вам понравился этот код, не возбраняется положить денег на телефон "сколько не жалко".
 *
 * @TODO: прошерстить код на предмет упрощения арифметики (сдвиги вместо *,/)
 */
#include "arhat.h"
#include "tcs3200.h"

volatile int      tcsColors[TCS_MAX_SENSORS][4]; // итоговые и усредненные данные замера
volatile int      tcsTemp[4];                    // внутреннее хранение данных при усреднениях и замерах
volatile int      minVal,maxVal;                 // мин и макс. уровни каналов цвета
volatile uint16_t tcsCount;                      // номер завершенного замера
volatile uint8_t  tcsColor;                      // текущий измеряемый цвет в попытке или состояние КА
volatile uint8_t  tcsMeasure;                    // номер текущей усредняемой попытки замера
volatile uint8_t  tcsWait;                       // текущая длительность одного замера частоты от датчика
volatile uint8_t  tcsIsBright;                   // Пересвет? (и прочие возвращаемые статусы на будущее)
volatile uint8_t  tcsModes;                      // Биты определяют режимы работы драйвера
volatile uint8_t  tcsCurrent;                    // Текущий датчик в режиме 2-х датчиков
volatile uint8_t  tcsCurWait;                    // пропуск заданного числа прерываний таймера @see tcsRun()

/**
 * Настройка таймера и выводов на работу с датчиком
 * @global tcsWait -- настройка времени первого замера
 */
TimerHookProc tcsSetup()
{
  // обе ноги разрешения датчиков на выход и запрет работы
  pinMode(tcsOE1, OUTPUT);
  pinMode(tcsOE2, OUTPUT);
  digitalWrite(tcsOE1, HIGH);
  digitalWrite(tcsOE2, HIGH);

  timerControl(tcsTimer, A) = 0;  // нормальный режим счета, счет по спадающесу(6),нарастающему(7) фронту на входе T5
  timerControl(tcsTimer, B) = 6;  // нормальный режим счета, все выходы счетчика отключены.
  pinMode(tcsOut, INPUT);         // счет импульсов счетчиком T5

  // ноги управления цветом на выход и режим s2=1,s3=0 -- анализ белого
  pinMode(tcsS2, OUTPUT);
  pinMode(tcsS3, OUTPUT);
  digitalWrite(tcsS2, HIGH);
  digitalWrite(tcsS3, LOW);

  tcsWait    = TCS_WAIT;
  tcsColor   = TCS_NOCOLOR;
  tcsCurrent = 0;

  return setTimerHook(tcsRun);
}

/**
 * настройка заданного датчика на чтение данных о цвете
 * @global tcsColor,tcsCurrent
 */
void tcsPrepare(uint8_t num)
{
  switch(num){
    case 0:
      digitalWrite(tcsOE2, HIGH);
      delayMicro8(5);
      digitalWrite(tcsOE1, LOW);
      break;
    case 1:
      digitalWrite(tcsOE1, HIGH);
      delayMicro8(5);
      digitalWrite(tcsOE2, LOW);
      break;
  }
  tcsColor = TCS_START;
  tcsCurrent = num;
}

/**
 * переключение датчика на текущий цвет и сброс таймера для нового замера
 * @global tcsColor -- текущий цвет замера
 */
void tcsNextColor(){
  uint8_t color = tcsColor+2; // изменяем порядок цветов: первым опрашиваем общий канал!

  if( color & 2 ){ pinOutHigh(tcsS2); }else{ pinOutLow(tcsS2); }
  if( color & 1 ){ pinOutHigh(tcsS3); }else{ pinOutLow(tcsS3); }
  timerCount(tcsTimer) = 0;
}

/**
 * Коррекция показаний по усредненной обратной матрице чувствительности из даташит:
 * @global tcsTemp[]
 */
void tcsCorrect()
{
    int      tg = tcsTemp[1]/2
            ,tr = tcsTemp[2]/2
            ,tb = tcsTemp[3]/2
    ;
    tcsTemp[1] += tg;               // 1/2
    tcsTemp[3] += tb;

    tg >>= 1; tr>>=1; tb>>=1;       // 1/4
    tcsTemp[1] -= (tb+tb+tb);
    tcsTemp[2] -= tg;
    tcsTemp[3] -= tg;
    tg >>= 1; tr>>=1; tb>>=1;       // 1/8
    tcsTemp[1] += tg;
    tcsTemp[3] -= tr;
    tg >>= 1; tr>>=1; tb>>=1;       // 1/16
    tcsTemp[2] += tr-tg;
    tcsTemp[3] -= tg-tr;
    tg >>= 1; tb>>=1;               // 1/32
    tcsTemp[1] += tg;
    tcsTemp[3] += tb-tg;
    tcsTemp[2] += tb+tg/4;          // +1/128tg (0.18%), иначе большая ошибка в красном (1.02%)!

    if( tcsTemp[1]<0 ) tcsTemp[1] = 0;  // устраняем отрицательные значения из-за ошибок округления
    if( tcsTemp[2]<0 ) tcsTemp[2] = 0;
    if( tcsTemp[3]<0 ) tcsTemp[3] = 0;
}

/**
 * Усреднение попыток замера, перевод в люксы и подсчет мин/мах уровней каналов цвета
 * @global int minVal,maxVal,tcsTemp[]
 */
void tcsMinMax()
{
    int      val;
    uint8_t    i;

    minVal = 32767; maxVal = 0;
    for(i=3; i>0; i--){
      val = tcsTemp[i];
      if( minVal > val ) minVal = val;
      if( maxVal < val ) maxVal = val;
    }
}

/**
 * коррекция баланса встроенных светодиодов:
 * ! под замену при иных параметрах освещения !
 * @global tcsTemp[]
 */
void tcsWhiteLocal(){
    int      val;

    val = tcsTemp[1];
    tcsTemp[1] = val + val   - val/8;
    val = tcsTemp[2];
    tcsTemp[2] = val + val/2 + val/32;
    val = tcsTemp[3];
    tcsTemp[3] = val - val/8 - val/16;
}

/**
 * повышение контраста
 * @global minVal,maxVal,tcsTemp[]
 */
void tcsContrast()
{
    int     delta;
    uint8_t val = TCS_CONTRAST*2;

    tcsMinMax();
    delta = maxVal - minVal;
         if( delta < minVal   ) val = TCS_CONTRAST;
    else if( delta > 2*minVal ) val = TCS_CONTRAST*4;

    tcsTemp[1] += (tcsTemp[1] - minVal)/val;
    tcsTemp[2] += (tcsTemp[2] - minVal)/val;
    tcsTemp[3] += (tcsTemp[3] - minVal)/val;
}

/**
 * КА датчика: замеры цвета, пересчеты, коррекции и сохранение результата
 * Устанавливается как хук таймера и вызывается каждые 1024мксек.
 */
void tcsRun()
{
  if( tcsColor == TCS_NOCOLOR ) return;  // не запущен замер/останов, выход.

  if( tcsColor == TCS_START )
  {
    // начало очередного замера
    uint8_t c;

    tcsColor = tcsMeasure = tcsIsBright = 0;
    for(c=0; c<4; c++)
            tcsTemp[c] = 0;
    tcsCurWait = tcsWait;                                  // устанавливаем сколько тиков будем считать счетчик
  }else{
    if( --tcsCurWait > 0 ) return;                         // ещё рано.

    // замер: приводим текущий замер к эфф. времени
    uint16_t counter = timerCount(tcsTimer);

    counter *= (TCS_MAX_WAIT / tcsWait);                   // масшабируем счетчик: как-бы считали TCS_MAX_WAIT
    tcsTemp[tcsColor] += counter;
    if( counter > 599*TCS_MAX_WAIT ){ tcsIsBright = 1; }   // Очень ярко! Частота выше 600кГц !!!

    if( tcsColor == 0 && !(tcsModes & TCS_SPEED_CONST) ){
      // первым замеряли яркостный канал: смотрим надо ли менять время замеров (удерживаем точность 0.5%):
           if( counter < 150 ){ tcsWait = TCS_WAIT * 4; }  // совсем темно, макс. длительность.
      else if( counter < 300 ){ tcsWait = TCS_WAIT * 2; }  // темновато, удвоенная длительность.
      else if( tcsWait>1 ){ tcsWait /= 2; }                // пробуем сократить время замера
    }
    tcsCurWait = tcsWait;                                  // установка времени в хуке заново.

    if( (tcsModes & TCS_WB_ONLY) || (++tcsColor) == TCS_NOCOLOR ){
      tcsColor = TCS_NOCOLOR;
      if( tcsMeasure >= TCS_MAX_MEASURES-1 )                     // Завершены все попытки:
      {
        if( tcsModes & TCS_WB_ONLY ){
          tcsTemp[0] /= TCS_MAX_MEASURES;                        // .. ч/б режим: только усреднение, нет коррекций!
        }else{
          if( !(tcsModes & TCS_NOT_CORRECT)  ) tcsCorrect();     // .. восстанавливаем баланс белого (R=0.18%,G=0.41%,B=-0.05%)
          if( !(tcsModes & TCS_NOT_AVERAGE)  ) tcsAvg();         // .. усредняем цвет
          if( !(tcsModes & TCS_NOT_WHITE)    ) tcsWhiteLocal();  // .. коррекция баланса белого от внутренних светодиодов
          if( !(tcsModes & TCS_NOT_CONTRAST) ) tcsContrast();    // .. повышение контрастности цветов
        }
        if( !(tcsModes & TCS_NOT_LUKSES) ) tcsLukses();          // .. масштабируем частоту в люксы

        tcsRaw();                                                // .. переносим значения в результат
        tcsCount++;                                              // .. конец работы, новый номер замера.
        return;
      }else{
        tcsMeasure++;
        tcsColor = 0;
      }
    }
  } // if !START
  tcsNextColor();
}
