### Описание библиотеки
_(как работает, что содержит, куда пользоваться)_

*Поддерживаемые варианты:*
* Ардуино Мега2560 и аналоги на базе МК Atmel2560/2561, Atmel1280/1281 .. 
* Ардуино UNO,NANO,MINI и аналоги на базе МК Atmel328p, Atmel168p, Atmel48p ..

#### Введение

Первоначально, библиотека создавалась как задача "освоения" Ардуино и Wiring (вспомнить С/С++), но сразу переросла в
решение вопроса минимизации и ускорения скетчей. Дальнейшее развитие направлено на постепенную замену Wiring.

  Недостаток: библиотека *требует* определения номеров используемых пинов только константным способом!
* `int pinForShield = 13;` -- *так работать не будет!*
* `#define pinForShield  13` -- **так правильно**

> _Пожелания по разработке - принимаются, но их реализация только "по мере наличия времени"._

##### Правила нумерации пинов плат:
* а) по возможности сохраняется нумерация контактов на платах Ардуино, начиная с 0;
* б) нумерация аналоговых входов *продолжает* нумерацию остальных контактов платы;

> Как следствие, традиционное макроопределение Analog3 тут имеет номер 57 для Ардуино Мега2560.
> .. и все остальные специальные названия контактов возвращают сквозной номер пина.

### Описание макросов, типов и функций библиотеки
#### Системный таймер, функции времени и задержек

Под учет системного времени (микросекунды, миллисекунды и пр.) выделен таймер 0, также как и у wiring. Его можно изменить,
равно как и частоту учета времени, используя макроопределения:
 * TIME_DEFAULT     -- номер таймера, который будет учитывать время
 * TIME_MAX_COUNTER -- до какого значения считает таймер (только информация для учета! Настраивать таймер самостоятельно!)
 * TIME_PRESCALLER  -- на какой частоте установлен прескалер таймера
 * TIME_MODE        -- режим счета таймера
 * TIME_TICK_MCS    -- константа длительности 1 тика таймера в микросекундах
 * TIME_SHIFT       -- "сдвиг" счетчика от прескалера: пересчет в мксек. Для прескалеров <4мксек - сдвиг вправо, иначе - влево.
 * TIME_MCS2MS      -- множитель: "отношение" длительности в мксек до переполнения счетчика к 1000 мксек 
 * TIME_ISR         -- тип прерывания, обрабатывающего системное время
 Переопределение этих констант - взаимозависимо и требует понимания того, что Вы делаете. Они должны быть определены ДО
включения файла arhat.h

* Макросы и функции времени и задержек:
  * **delayMicro8**()            -- 8бит: короткий цикл по 3 такта (16Мгц = 187.25 наносек.)
  * **delayMicro16**()           -- 16бит: тоже циклом, но по 4 такта (16Мгц = 250 нсек.)
  * **delayMicroSeconds**()      -- аналог предыдущего для привычных к wiring
  * void **time_delay**(ulong);  -- выполнить цикл задержки в миллисекундах .. вплоть до 49.7 дней.
  * void **time_delay16**(uint); -- экономия на вызове, если не надо слишком долго. Тоже задержка в миллисекундах до 65.5 сек.
  * void **delay**(ulong);       -- аналог предыдущей(!) функции для wiring-совместимости

  * uint32_t **time_micros**(void); -- получить текущее время в микросекундах (переполнение через 1.19 часа от старта)
  * uint32_t **time_millis**(void); -- получить текущее время в миллисекундах (переполнение через 49.7 дней)
  * **millis**(), **micros**()      -- аналоги для совместимости 

  * uint32_t **getOvfCount**(void); -- позволяет получить количество текущих тиков консистентно, закрыв прерывания на момент чтения.

  * **everyMillis**() -- "автоматный макрос": позволяет исполнять код через заданные миллисекунды и прописывать его прямо внутри макроса
  * **everyOVF**()   -- облегченная версия. Тоже самое, но учет времени в тиках системного таймера.

  * Исполнение кода в заданное время (sheduller):
 Обработчик системного таймера позволяет указать функцию без параметров, которая будет вызываться каждый раз (каждые 1024мксек)
при его активизации - "хук времени". Процедура хука исполняется с открытыми прерываниями, что не мешает продолжению счета
системного времени или каких ещё обработчиков. В случае длительного исполнения хука - его повторный вызов блокируется до
завершения. То есть, пока хук не завершит свою работу повторно он вызван *не будет*.  
 Для включения компиляции с хуком таймера, в файле arhat.c требуется изменить режим на 3. По умолчанию - хук отсутствует.

  * TimerHookProc **setTimerHook**(TimerHookProc); Установить процедуру хука. Возвращает предыдущее значение (можно организовывать очереди)
  * **pushAllRegs**() -- сохранение текущего контекста исполнения на стеке, с подменой точки возврата для корректного выхода отсюда.
  * **popAllRegs**()  -- восстановление контекста, предварительного сохраненного на стеке пред. функцией (общий уровень исполнения!) 

####  Макросы ногодрыгов (прямой ввод-вывод на ножки платы)

`**ВНИМАНИЕ!** Все макросы прямого управления выводами требуют указания номера вывода константой, не переменная!`

* **pinModeOut**(p)    -- Превращает ножку в ВЫХОД. При включении все ножки настроены на ВВОД
* **pinModeIn**(p)     -- Настраивает ножку на ВВОД. Подтяжка к +5в зависит от текущего значения выведенного на эту ножку ранее
* **pinModePullIn**(p) -- Настройка на ВВОД с подтяжкой к +5в.

* **pinOutHigh**(p) -- Вывод на ножку лог."1". Ножка предварительно должна быть настроена на ВЫВОД.
* **pinOutLow**(p)  -- Вывод на ножку лог."0". Аналогично.
* **pinOut**(p,v)   -- Объединение предыдущих двух макросов: ВЫВОД на ножку заданного уровня (можно из переменной)
* **pinRead**(p)    -- Чтение логического уровня ножки.

* digitalWrite(p,v) -- переопределение на макрос pinOut() с целью прямого импорта скетчей из Wiring
* digitalRead(p)    -- аналогичное переопределение на pinRead() с той же целью.

#### Макросы управления таймерами (прямое управление через регистры)

`**ВНИМАНИЕ!** Все макросы также требуют указания номера таймера константой, не переменная!`
`Регистры таймера так и указываются БУКВАМИ: A,B,C -- это не переменные, а часть макро-имени!`
`Допустимые значения: t:[0,2,[1,3,4,5]], r:[A,B[,C]], то есть для 16-битных таймеров есть ещё и канал "C"`
`Допустимые значения для прерываний от таймеров: t:[0,2[,1,3,4,5]] v:[OVF,COMPA,COMPB[,COMPC,CAPT]], b:[0,1] -- clear/set`

* **timerCount**(t)     -- Установить/получить текущее значение счетчика таймера
* **timerControl**(t,r) -- Установить/получить текущее значение регистра управления таймера (A,B,C)
* **timerCompare**(t,r) -- Установить/получить текущее значение регистра сравнения таймера (A,B,C)
* **timerCapture**(t)   -- Установить/получить значение регистра захвата таймера (только 16-битных: 1,3,4,5)
* **prescalerMode**(pr) -- Получить код для прескалера таймера по числу делителя (64 --> 3 удобства для)

* **timerIMask**(t,v,b) -- Установить/получить маску прерываний таймера (см. третье примечание выше)
* **timerIFlag**(t,v)   -- Получить состояние флага прерывания от таймера
* **ISRtimer**(t,v)     -- Сформировать имя обработчика прерывания для макроса ISR()

#### Макросы работы с аппаратным ШИМ (PWM) выводами

`**ВНИМАНИЕ!** Номер вывода также задается только константно. Не переменная!`
`Допустимые номера выводов для ШИМ mega2560: p:[2..13,44,45,46, T1C]. Имя T1C - для указания 13 вывода как канал С таймера 1`
`Допустимые номера выводов на остальные МК - смотреть в документации к ним`
`Значения режимов работы ШИМ на выводах для pwmPinMode(): m[PWM_DISABLE,PWM_TOGGLE,PWM_NORMAL,PWM_INVERSE]`
`Стандартный режим ШИМ: делитель 1/64 (1 такт = 4 мксек), режим "8-битного fastPWM" для 8/16 таймеров.`

* **pwmGetTimer**(p)   -- (вспом.) получить номер таймера, обслуживающего заданный вывод ШИМ
* **pwmGetChannel**(p) -- (вспом.) получить номер канала, обслуживающего заданный вывод ШИМ

* **pwmPinMode**(p,m)  -- Установить вывод в режим стандартного ШИМ и задать режим вывода
* **pwmSet**(p)        -- Настроить вывод и его таймер на стандартный ШИМ
* **pwmOff**(p)        -- Выключить вывод из ШИМ. Вывод остается "на выход". Весь таймер - не отключаем
* **pwmWrite**(p,v)    -- Вывести заданное значение ШИМ. Значение может быть и из переменной/выражения [0..255]

`"сервоШИМ" для управления типовыми сервомоторами (**только для 16-битных таймеров!**):
 Режим таймера = 14 (FAST-pwm mode with ICP), прескалер = 3 (1/64), ICP=5000
... В результате имеем ШИМ с частотой 50гц (20мсек)`

* **timerSetServo**(t,pwmPinMask) -- Установить заданный таймер в режим "сервоШИМ" и активизировать заданные каналы "оптом"
* **pwmSetServo**(p1) -- Установка **вывода** и его таймера в "сервоШИМ" Для последующего канала этого же таймера достаточно вызвать pwmSet(p).

#### Макросы для работы с аналоговыми сигналами

* **adc_read**(p) -- Читать значение АЦП на заданном входе (константа!). Ожидать завершения оцифровки.

* **admuxSrc**(s) -- Получить маску для опорного напряжения s:[AREF,AVCC,110,256]
* **adcOn**()     -- Включение АЦП отдельной командой и настройка частоты оцифровки: 16Mhz/128 (125kHz)
* **adcOff**()    -- Выключение АЦП. Нормально - выключен, ибо "жрет" - много

* **admux1Channel**(src,pin,adlar)     -- АЦП на заданном входе pin:[0..15] (измерение от 0 - GND)
* **admux2Channel**(src,neg,poz,adlar) -- дифференциальный режим АЦП neg:[1,2|9,10], poz:[0..7|8..15] 
* **admux2Gain**(src,neg,poz,g,adlar)  -- дифф. режим с пред. усилителем neg:[0,2|8,10], poz:[0..3|8..11], g:[GAIN_10,GAIN_200], adlar:[ADC_LEFT|ADC_RIGHT]

 Примеры настройки режимов АЦП:

* admux1Channel(admuxSrc(110), 5, ADC_RIGHT);           -- поставить АЦП в режим сравнения с опорным в 1.1в, читать 5 вход, значения 0..1023
* admux2Channel(admuxSrc(AREF), 10, 11, ADC_LEFT);      -- сравнивать с AREF, дифференциальный режим 10,11, значения домножены на 64 [64..65535].
* admux2Gain(admuxSrc(AVCC), 0, 1, GAIN_200, ADC_LEFT); -- сравнивать с Vсс, предусилитель 200х, дифф. режим 0,1; домножены на 64 [64..65535].

#### Чтение/запись EEPROM:

* unsigned char **EEPROM_read**(unsigned int uiAddress); -- прочитать 1 байт из ЕЕПРОМ по адресу
* void **EEPROM_write**(unsigned int uiAddress, unsigned char ucData) -- записать 1 байт по заданному адресу ЕЕПРОМ

#### Работа с прерываниями PCINT (подсчет срабатываний, чтение длительностей сигналов)

(продолжение следует)