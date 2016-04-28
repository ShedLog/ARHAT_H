/**
 * Реализация функций для создания и управления конечными автоматами
 *
 * Внимание! Вычисление времени интервалов производится через счетчик переполнений таймера,
 * соответственно все интервалы кратны 1.024 миллисекунды. НЕ МИЛЛИСЕКУНДА!
 * Чтобы правильно указать интервал в тиках надо время в миллисекундах умножить на 0.976
 * лучше на калькуляторе, чем в программе.
 */
#include "arhat.h"
#include "tsc.h"

// .. Методы, исполняемые при изменении состояния КА:
void empty(void *_tsc) { return; }      // пропуск действия

// для loop(): выполнение шага базового автомата. Если нет команды, то и делать нечего
void tsc_run( TSC_Simple *_tsc )
{
  if(
      _tsc->command
      && (tsc_getTime() - _tsc->started_at > _tsc->timeout)
  ){
    _tsc->started_at = tsc_getTime();
    // команда: длительность исполнения команды ВХОДИТ в интервал!
    (*_tsc->command)(_tsc);
  }
}

/**
 * Устанавливает исполнение команды через заданный таймаут.
 * Удобства для.
 */
void tsc_simple( TSC_Simple *_tsc, TSC_Command command, TSC_Time timeout)
{
  _tsc->command = command;
  _tsc->timeout = timeout;
  _tsc->started_at = (TSC_Time)tsc_getTime();
}

/**
 * метод перехода к следующему шагу табличного КА во flash:
 *
 * Читает из flash текущий интервал ожидания и устанавливает номер следующего состояния,
 */
void tsc_next( TSC_Control *_tsc, TSC_Step_Count _state )
{
  // определяем место хранения структуры текущего состояния КА
  const TSC_Step * current PROGMEM = _tsc->table + _tsc->state;

  _tsc->timeout    = (TSC_Time)pgm_read_word_near( &(current->timeout) );

  _tsc->state      = _state;                            // устанавливаем следующее состояние
  _tsc->started_at = (TSC_Time)tsc_getTime();           // и его стартовое время

}

// setup() метод сохранения текущих данных для конечного автомата:
void tsc_init( TSC_Control *_tsc, const PROGMEM TSC_Step * _table, TSC_Step_Count _state )
{
    _tsc->table = _table;                               // сохраняем таблицу переходов для этого КА
    tsc_next(_tsc, _state);                             // устанавливаем заданное состояние
    _tsc->timeout = 0;                                  // сбрасываем интервал, для первого вызова без задержки
}

// метод "шаг цикла КА":
// параметр - указатель на состояние заданного КА.
void tsc_step( TSC_Control *_tsc )
{
  // если задана таблица (нет - выключен!)
  if( _tsc->table ){
    // если событие, переключающее КА - наступило:
    if( (TSC_Time)tsc_getTime() - _tsc->started_at >= _tsc->timeout )
    {
      // определяем место хранения структуры состояния КА
      const TSC_Step * current PROGMEM = _tsc->table + _tsc->state;

      // читаем и исполняем команду и получаем номер следующего состояния или нуль(+=1):
      TSC_Command    command = (TSC_Command)pgm_read_word_near( &(current->command) );
      TSC_Step_Count    next = (TSC_Step_Count)pgm_read_word_near( &(current->next) );

      // и сразу устанавливаем следующий шаг КА и начало периода
      tsc_next(_tsc, next);

      // исполнение команды - последним. Её время выполнения ВХОДИТ в ожидание,
      // допускается вызов tsc_next() из самой команды - принудительная смена состояния в команде
      if( command ) { command(_tsc); }
    }
  }
}

/**
 * метод перехода к следующему шагу табличного КА во flash с микросекундными задержками
 * на основании данных только от счетчика таймера кратно 4мксек:
 *
 * Читает из flash текущий интервал ожидания и устанавливает номер следующего состояния,
 */
void tsc_micro_next( TSC_Control *_tsc, TSC_Step_Count _state )
{
  // определяем место хранения структуры текущего состояния КА
  const TSC_Step * current PROGMEM = _tsc->table + _tsc->state;

  _tsc->timeout    = (TSC_Time)pgm_read_word_near( &(current->timeout) );

  _tsc->state      = _state;                            // устанавливаем следующее состояние
  _tsc->started_at = (TSC_Time)time_micros();           // и его стартовое время

}

// метод "шаг цикла КА" в микросекундах по 4мксек [0..65535] @see TSC_Time:
// параметр - указатель на состояние заданного КА.
void tsc_micro_step( TSC_Control *_tsc )
{
  // если задана таблица (нет - выключен!)
  if( _tsc->table ){
    // если событие, переключающее КА - наступило:
    if( (TSC_Time)time_micros() - _tsc->started_at >= _tsc->timeout )
    {
      // определяем место хранения структуры состояния КА
      const TSC_Step * current PROGMEM = _tsc->table + _tsc->state;

      // читаем и исполняем команду и получаем номер следующего состояния или нуль(+=1):
      TSC_Command    command = (TSC_Command)pgm_read_word_near( &(current->command) );
      TSC_Step_Count    next = (TSC_Step_Count)pgm_read_word_near( &(current->next) );

      // и сразу устанавливаем следующий шаг КА и начало периода
      tsc_micro_next(_tsc, next);

      // исполнение команды - последним. Её время выполнения ВХОДИТ в ожидание,
      // допускается вызов tsc_next() из самой команды - принудительная смена состояния в команде
      if( command ) { command(_tsc); }
    }
  }
}

