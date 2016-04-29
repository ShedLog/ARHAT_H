/**
 * Simple function for calc time and delays.
 *
 * use timer0 as default and prescaler 1/64 for each 4 microseconds with 16Mhz CLK.
 * By default timer0 is overflowing each 256 ticks at 1024 microseconds.
 *
 * For use other timer you need predefine all constants in block TIME_DEFAULT
 * and recompile this file.
 *
 * For simple use, you may rename this file to wiring.c and replace it.
 *
 * @author Arhat109: arhat109@mail.ru
 *
 * license agreement:
 * You use this software on own your risks. No claims will be accepted.
 * You may use this file any way, but cannot change
 * or delete tag @author above (you may append your tag @author) and must keeping this rows:
 *
 * This is free software, not any pay. But you may donate some money to phone +7-951-388-2793
 */

#define ARHAT_MODE 2        // need in this file!
#include "arhat.h"

// defaults timer0 timers functions and interrupts such in wiring
// Константы настройки таймера 0 совместимые с wiring: таймер работает по 4мксек.
#ifndef TIME_DEFAULT                    /* all defaults for F_CPU=16Mhz ONLY! */
#  define TIME_DEFAULT             0
#  define TIME_MAX_COUNTER       256    /* max conter+1                                               */
#  define TIME_PRESCALLER         64
#  define TIME_MODE                3    /* WGM10 = 1, WGM00 = 1 fast-PWM mode for timer0              */
#  define TIME_TICK_MCS            4    /* 1 tick by prescaler:[0.25, 0.5, 4, 16, 64] in microseconds */
#  define TIME_SHIFT               2    /* From prescaller: 1=>4, 8=>1, 64=>2, 256=>4, 1024=>6        */
#  define TIME_MCS2MS      1024/1000    /* ==[16,128,1024,4096,16384]/1000 by prescaler               */
#  define TIME_ISR               OVF    /* what interrupt name using for this timer                   */
#endif

volatile uint32_t       timer0_overflow_count   = 0UL;  // timer overflow counter. Счетчик переполнений таймера 0 "тиков" по 1024мксек.
void        (* volatile timer0_hook)(void)      = 0;    // hook function pointer. функция "хук", вызываемая из обработчика, если надо.
uint8_t                 timer0_hook_run         = 1;    // hook is running. Blocking twice calling. защелка, запрещающая повторный вызов.

/**
 * Volatile read count TOV interrupt
 * 24 bytes, 19 cycles (1.1875mcsec.)
 */
uint32_t getOvfCount()
{
  uint8_t       _sreg = SREG;
  uint32_t      _count;

  cli();
  _count = timer0_overflow_count;
  SREG = _sreg;

  return _count;
}

/**
 * Atomic set timer0_hook
 * @return TimerHookProc -- previous proc | 0
 */
TimerHookProc setTimerHook(TimerHookProc proc)
{
  uint8_t       _sreg = SREG;
  TimerHookProc _res;

  cli();
  _res = timer0_hook;
  timer0_hook = proc;
  SREG = _sreg;

  return _res;
}

/**
 * Return microseconds 0..up to 1 hours 11.4 minutes are identical with wiring.c
 * "C" code = 76 bytes, "Asm" = 56 bytes and 42 cycles.
 */
uint32_t time_micros()             // return in r22..r25
{
/*
 * register struct{ uint8_t timer, uint24_t micro } retVal; -- can't compile right!
 * retVal must be in r22,r23,r24,r25 registers for right return avr-gcc convention!
 *
    uint8_t     oldSREG = SREG;         // r27
    uint8_t     timer, tov;             // r22, r26
    uint32_t    micro;                  // r23,r24,r25

    // read all into local: volatile!
    cli();
      micro = timer0_overflow_count;		// not use h-byte!
      timer = timerCount(TIME_DEFAULT);
//      tov = timerIFlag(TIME_DEFAULT,OVF);	// bit0! =={0,1} only!
      if ( timerIFlag(TIME_DEFAULT,OVF) && (timer<255) ){ micro++; }
    SREG = oldSREG;

    // this is a precompiler #IF because is constants:
    if( TIME_TICK_MCS>1 ) {
      return (((micro<<8)+timer)<<TIME_SHIFT)+3;	// +3 microsec. fot this routine
    } else {
      return (((micro<<8)+timer)>>TIME_SHIFT)+3;
    }
*/
  asm volatile (
    "  push r26                 ;1\n\t"
    "  in r26,__SREG__          ;1 oldSREG = SREG\n\t"
    "  cli                      ;1\n\t"
    "  in r22,0x26              ;1 timer = timerCount(TIME_DEFAULT)\n\t"
    "  lds r23,timer0_overflow_count        ;3 micro = (uint24_t)timer0_overflow_count;\n\t"
    "  lds r24,timer0_overflow_count+1      ;3\n\t"
    "  lds r25,timer0_overflow_count+2      ;3 now: {r22..25}=(micro<<8)+timer!\n\t"
    "  sbis 0x15,0              ;1/2 TOV==1? ->PС+1\n\t"
    "   rjmp .skip1\n\t"
    "  cpi  r22,lo8(-1)         ;1 ?!? timer == 255?\n\t"
    "  breq .skip1\n\t"
    "    sec                    ;1 set carry flag\n\t"
    "    adc   r23,__zero_reg__ ;1 micro++\n\t"
    "    adc   r24,__zero_reg__ ;1\n\t"
    "    adc   r25,__zero_reg__ ;1\n\t"
    ".skip1:\n\t"
    "  out __SREG__,r26         ;1 SREG = oldSREG, tmp_reg not use!\n\t"

    "  ldi  r26,2               ;3 load TIME_SHIFT counter\n\t"
    ".shift1: \n\t"
  ::);
  if( TIME_TICK_MCS>1 ) {
    asm volatile (
      "  lsl r22                ;1*2 retVal<<TIME_SHIFT\n\t"
      "  rol r23                ;1*2\n\t"
      "  rol r24                ;1*2\n\t"
      "  rol r25                ;1*2\n\t"
    ::);
  } else {
    asm volatile (
      "  lsr r22                ;1*2 retVal>>TIME_SHIFT\n\t"
      "  ror r23                ;1*2\n\t"
      "  ror r24                ;1*2\n\t"
      "  ror r25                ;1*2\n\t"
    ::);
  }
  asm volatile (
    "  dec r26                  ;1*2 TIME_SHIFT counter--\n\t"
    "  brne .shift1             ;1+2\n\t"
//    "  subi r22,-2              ;1 retVal += 2[.25] mcsec for this routine\n\t"
//    "  sbci r23,-1              ;1\n\t"
//    "  sbci r24,-1              ;1\n\t"
//    "  sbci r25,-1              ;1\n\t"
    "  pop  r26                 ;1\n\t"
  ::);
}

/**
 * Return current time into milliseconds upto 49.7 days
 * corrected for timer counter current value and fract data
 * 102 bytes, long time: use udiv libc function!
 */
uint32_t time_millis()
{
    uint16_t    timer;
    uint8_t     oldSREG = SREG, tov=0;

    cli();
      timer = timerCount(TIME_DEFAULT);
      if ( timerIFlag(TIME_DEFAULT,OVF) ){ tov++; }
    SREG = oldSREG;

    timer = (TIME_TICK_MCS>1 ? timer<<TIME_SHIFT : timer>>TIME_SHIFT);
    return (timer0_overflow_count * TIME_MCS2MS)+tov+(timer>1000? 1 : 0);
}

/**
 * identical with wiring.c
 * @deprecated: big parameter (uint32_t) @see time_delay16()
 */
void time_delay(uint32_t interval)
{
    uint16_t start = (uint16_t)micros();

    while (interval > 0) {
      if (((uint16_t)micros() - start) >= 1000) {
        interval--;
        start += 1000;
      }
    }
}

/**
 * for smaller parameter size: only 65535 milli seconds
 * 52 bytes.
 */
void time_delay16(uint16_t interval)
{
    uint16_t start = (uint16_t)micros();

    while (interval > 0) {
      if (((uint16_t)micros() - start) >= 1000) {
        interval--;
        start += 1000;
      }
    }
}

/**
 * (re)start timer for time functions
 * @see TIME_DEFAULT define section
 * 26 bytes
 */
void time_init()
{
    sei();
    timerControl(TIME_DEFAULT, A) |= TIME_MODE;
    timerControl(TIME_DEFAULT, B) |= prescalerMode(TIME_PRESCALLER);
    timerIMask(TIME_DEFAULT, OVF, 1);
}

/**
 * Timer interrupt by Overflow Flag up each (TIMER_TICK_MCS*TIMER_MAX_COUNT) microseconds.
 *
 * Пользуемся побайтовой арифметикой: считали - добавили - сохранили.
 * Экономим регистры и команды:
 * "С" verison   = 158 bytes;
 * "ASM" version = 102 bytes, 46/51/75 cycles: 2.875mcsec for timer0_hook=0 and 4.6875 mcsec for empty call
 *
 * ISR(timerISR(TIME_DEFAULT, TIME_ISR), ISR_NAKED)
 *
 * equal this:
 *
 * void __vector_23(void) __attribute__ ((signal, used, externally_visible)) __attribute__((naked));
 * void __vector_23(void)
 */
ISR(timerISR(TIME_DEFAULT, TIME_ISR), ISR_NAKED)
//ISR(timerISR(TIME_DEFAULT, TIME_ISR))
{
/* C version:

    timer0_overflow_count++;

    if( timer0_hook && !timer0_hook_run ){
        timer0_hook_run = 1;
        sei();
        timer0_hook();
        cli();
        timer0_hook_run = 0;
    }
}
*/
    asm volatile(
        "    push r30          \n\t"
        "    push r31          \n\t"
        "    in r30,__SREG__   \n\t"
        "    push r30          \n\t"

        "    lds r30,timer0_overflow_count   \n\t"
        "    lds r31,timer0_overflow_count+1 \n\t"
        "    adiw r30,1                      \n\t"
        "    sts timer0_overflow_count,r30   \n\t"
        "    sts timer0_overflow_count+1,r31 \n\t"
        "    clr r31                         \n\t"
        "    lds r30,timer0_overflow_count+2 \n\t"
        "    adc r30,r31                     \n\t"
        "    sts timer0_overflow_count+2,r30 \n\t"
        "    lds r30,timer0_overflow_count+3 \n\t"
        "    adc r30,r31                     \n\t"
        "    sts timer0_overflow_count+3,r30 \n\t"

#if defined(ARHAT_MODE) && (ARHAT_MODE == 3)

        "    lds r30,timer0_hook_run                          \n\t"
        "    tst r30                 ; timer0_hook_run != 0?  \n\t"
        "    brne .END_PROC                                   \n\t"
        "    lds r30,timer0_hook     ; Z=timer_hook           \n\t"
        "    lds r31,timer0_hook+1                            \n\t"
        "    or  r30,r31             ; timer0_hook == 0?      \n\t"
        "    breq .END_PROC                                   \n\t"
        "    sts timer0_hook_run,r30 ; r30 не нуль!           \n\t"

        "    in   r30,__RAMPZ__ \n\t"
        "    push r30           \n\t"
        "    push r0            \n\t"
        "    push r1            \n\t"
        "    push r18           \n\t"
        "    push r19           \n\t"
        "    push r20           \n\t"
        "    push r21           \n\t"
        "    push r22           \n\t"
        "    push r23           \n\t"
        "    push r24           \n\t"
        "    push r25           \n\t"
        "    push r26           \n\t"
        "    push r27           \n\t"

        "    lds r30,timer0_hook     ; восстанавливаем адрес \n\t"
        "    sei                \n\t"
        "    eicall             \n\t"
        "    cli                \n\t"
        "    clr r31            \n\t"
        "    sts timer0_hook_run,r31 ; timer0_hook_run = 0; \n\t"

        "    pop  r27           \n\t"
        "    pop  r26           \n\t"
        "    pop  r25           \n\t"
        "    pop  r24           \n\t"
        "    pop  r23           \n\t"
        "    pop  r22           \n\t"
        "    pop  r21           \n\t"
        "    pop  r20           \n\t"
        "    pop  r19           \n\t"
        "    pop  r18           \n\t"
        "    pop  r1            \n\t"
        "    pop  r0            \n\t"
        "    pop  r30           \n\t"
        "    out  __RAMPZ__,r30 \n\t"

        ".END_PROC:             \n\t"

#endif // ARHAT_MODE == 3
        "    pop  r30           \n\t"
        "    out  __SREG__,r30  \n\t"
        "    pop  r31           \n\t"
        "    pop  r30           \n\t"
        "    reti               \n\t"
        ::
    );

}

// ======================== ADC ======================== //

/** Input multiplexer channels (@deprecated: not need more!) */
#define ADMUX_0		0	/* from Analog0 */
#define ADMUX_1		1	/* from Analog1 */
#define ADMUX_2		2	/* from Analog2 */
#define ADMUX_3		3	/* from Analog3 */
#define ADMUX_4		4	/* from Analog4 */
#define ADMUX_5		5	/* from Analog5 */
#define ADMUX_6		6	/* from Analog6 */
#define ADMUX_7		7	/* from Analog7 */
#define ADMUX_8		32	/* from Analog8 */
#define ADMUX_9		33	/* from Analog9 */
#define ADMUX_10	34	/* from Analog10 */
#define ADMUX_11	35	/* from Analog11 */
#define ADMUX_12	36	/* from Analog12 */
#define ADMUX_13	37	/* from Analog13 */
#define ADMUX_14	38	/* from Analog14 */
#define ADMUX_15	39	/* from Analog15 */
#define ADMUX_M10_a0a0		8
#define ADMUX_M10_a0a1		9
#define ADMUX_M200_a0a0		10
#define ADMUX_M200_a0a1		11
#define ADMUX_M10_a2a2		12
#define ADMUX_M10_a2a3		13
#define ADMUX_M200_a2a2		14
#define ADMUX_M200_a2a3		15
#define ADMUX_M10_a8a8		40
#define ADMUX_M10_a8a9		41
#define ADMUX_M200_a8a8		42
#define ADMUX_M200_a8a9		43
#define ADMUX_M10_a10a10	44
#define ADMUX_M10_a10a11	45
#define ADMUX_M200_a10a10	46
#define ADMUX_M200_a10a11	47
#define ADMUX_M1_a1a0		16
#define ADMUX_M1_a1a1		17
#define ADMUX_M1_a1a2		18
#define ADMUX_M1_a1a3		19
#define ADMUX_M1_a1a4		20
#define ADMUX_M1_a1a5		21
#define ADMUX_M1_a1a6		22
#define ADMUX_M1_a1a7		23
#define ADMUX_M1_a2a0		24
#define ADMUX_M1_a2a1		25
#define ADMUX_M1_a2a2		26
#define ADMUX_M1_a2a3		27
#define ADMUX_M1_a2a4		28
#define ADMUX_M1_a2a5		29
#define ADMUX_M1_a9a8		48
#define ADMUX_M1_a9a9		49
#define ADMUX_M1_a9a10		50
#define ADMUX_M1_a9a11		51
#define ADMUX_M1_a9a12		52
#define ADMUX_M1_a9a13		53
#define ADMUX_M1_a9a14		54
#define ADMUX_M1_a9a15		55
#define ADMUX_M1_a10a8		56
#define ADMUX_M1_a10a9		57
#define ADMUX_M1_a10a10		58
#define ADMUX_M1_a10a11		59
#define ADMUX_M1_a10a12		60
#define ADMUX_M1_a10a13		61

/**
 * AnalogRead
 * ==========
 * 1. ADC clock [50..200]kHz. for F_CPU = 16Mhz ADC prescaler = 160(opt.): ADPS2:0 = 111 = F_CPU/128
 * 2. set in default mode: 1 channel, ADLAR=right,src=AVCC
 *
 * 3. !!! before use it must be adcOn() with delay=108micros !!!
 */
uint16_t adcRead(uint8_t anPin)
{
//  uint8_t    oreg, anh;

  admux1Channel(admuxSrc(AVCC), anPin, ADC_RIGHT);      // set registers: ADMUX, ADCSRB
  ADCSRA |= _BV(ADSC);                                  // start analog read
  while (ADCSRA & (1 << ADSC));                         // wait as ADC is done

//  oreg = SREG;
//  cli();
//    anPin = ADCL;
//    anh = ADCH;
//  SREG = oreg;
//  return (ADCH<<8) + ADCL;
  asm volatile (
    "in  __tmp_reg__, __SREG__\n\t"
    "cli\n\t"
    "lds r24,120    ; retL = ADCL\n\t"
    "lds r25,121    ; retH = ADCH\n\t"
    "out __SREG__,__tmp_reg__\n\t"
  ::);
}

// ======================== EEPROM ======================== //
// Thanks DeGlucker from cyber-place.ru                     //
// ======================================================== //
unsigned char EEPROM_read(unsigned int uiAddress)
{
  while(EECR & (1<<EEPE));
  EEARL = uiAddress & 0xFF;
  EEARH = (uiAddress>>8) & 0xFF;
  EECR |= (1<<EERE);
  return EEDR;
}

void EEPROM_write(unsigned int uiAddress, unsigned char ucData)
{
  while(EECR & (1<<EEPE));
  EEARL = uiAddress & 0xFF;
  EEARH = (uiAddress>>8) & 0xFF;
  EEDR = (ucData);
  uint8_t oreg = SREG;
  cli();
  EECR |= (1<<EEMPE);
  EECR |= (1<<EEPE);
  SREG = oreg;
}

// ======================== RTOS simple ======================== //
// Small functions for future RTOS: save/load context            //
// ============================================================= //

/**
 * Save all register file and SREG on stack and right return to caller
 * Сохранение полного контекста на стеке и корректный возврат в точку вызова
 */
void pushAllRegs()
{
  asm volatile(
    "    push r31               \n\t"
    "    push r30               \n\t"
    "    in   r31,__SP_H__      \n\t"
    "    in   r30,__SP_L__      \n\t"
    "    push r0                \n\t"
    "    in   r0,__SREG__       \n\t"
    "    push r0                \n\t"
    "    push r1                \n\t"
    "    push r2                \n\t"
    "    push r3                \n\t"
    "    push r4                \n\t"
    "    push r5                \n\t"
    "    push r6                \n\t"
    "    push r7                \n\t"
    "    push r8                \n\t"
    "    push r9                \n\t"
    "    push r10               \n\t"
    "    push r11               \n\t"
    "    push r12               \n\t"
    "    push r13               \n\t"
    "    push r14               \n\t"
    "    push r15               \n\t"
    "    push r16               \n\t"
    "    push r17               \n\t"
    "    push r18               \n\t"
    "    push r19               \n\t"
    "    push r20               \n\t"
    "    push r21               \n\t"
    "    push r22               \n\t"
    "    push r23               \n\t"
    "    push r24               \n\t"
    "    push r25               \n\t"
    "    push r26               \n\t"
    "    push r27               \n\t"
    "    push r28               \n\t"
    "    push r29               \n\t"
    "    ldd  r0,Z+3            \n\t"
    "    ldd  r1,Z+4            \n\t"
    "    push r1                \n\t"
    "    push r0                \n\t"
    "    clr  r1                \n\t"
    ::
    );
}

/**
 * Load all register file and SREG from stack and right return to caller
 * Обратная задача: восстановление контекста регистров и битов состояния из стека
 * с подменой старой точки возрата (@see pushAllRegs()) на корректный возврат отсюда
 */
void popAllRegs()
{
asm volatile(
    "    pop r1           \n\t"
    "    pop r0           \n\t"
    "    pop r29          \n\t"
    "    pop r28          \n\t"
    "    pop r27          \n\t"
    "    pop r26          \n\t"
    "    pop r25          \n\t"
    "    pop r24          \n\t"
    "    pop r23          \n\t"
    "    pop r22          \n\t"
    "    pop r21          \n\t"
    "    pop r20          \n\t"
    "    pop r19          \n\t"
    "    pop r18          \n\t"
    "    pop r17          \n\t"
    "    pop r16          \n\t"
    "    pop r15          \n\t"
    "    pop r14          \n\t"
    "    pop r13          \n\t"
    "    pop r12          \n\t"
    "    pop r11          \n\t"
    "    pop r10          \n\t"
    "    pop r9           \n\t"
    "    pop r8           \n\t"
    "    pop r7           \n\t"
    "    pop r6           \n\t"
    "    pop r5           \n\t"
    "    pop r4           \n\t"
    "    pop r3           \n\t"
    "    pop r2           \n\t"
    "    in  r31,__SP_H__ \n\t"
    "    in  r30,__SP_L__ \n\t"
    "    std Z+7,r0       \n\t"
    "    std Z+6,r1       \n\t"
    "    pop r1           \n\t"
    "    pop r0           \n\t"
    "    out __SREG__,r0  \n\t"
    "    pop r0           \n\t"
    "    pop r30          \n\t"
    "    pop r31          \n\t"
    ::
    );
}

// ==================== for pcint.h functions ========================= //

/**
 * Пишет код ошибки или результата в статус замера и снимает событие таймаута
 * Заодно запрещает перерывание (только для ноги этого замера, а не всего уровня!).
 */
void pcint_end(Pulse * ptrPulse, uint8_t error)
{
    uint8_t     rpin = ptrPulse->pin;

    ptrPulse->state        = error;                             // статус завершения, какой задан.

    switch( rpin & 0xc0 ){                                      // запрещаем прерывание от текущей ноги
        case 0x80: PCMSK2 &= ~(((uint8_t)1)<<(rpin&0x3f)); break;
        case 0x40: PCMSK1 &= ~(((uint8_t)1)<<(rpin&0x3f)); break;
        case 0:    PCMSK0 &= ~(((uint8_t)1)<<(rpin&0x3f)); break;
    }
}

/**
 * Часть обработчика прерывания PCINT, измеряющая длительность импульса в микросекундах
 * выключает обработчик прерывания и изменяет статус структуры - самостоятельно!
 *
 * @return ptrPulse(ptr)->res; -- state==PULSE_OK? pulse time in micros : not valid data.
 */
void pcint_micros( void *ptr, uint8_t oldBit )
{
    if( ptrPulse(ptr)->state == PULSE_BUSY )
    {
        // first measuring! store current micros()
        ptrPulse(ptr)->res   = micros();
        ptrPulse(ptr)->state = PULSE_SECOND;
    } else {
        // second measuring or mistake: calc pulse time anyone:
        ptrPulse(ptr)->res = micros() - ptrPulse(ptr)->res;

        pcint_end(
            ptrPulse(ptr)
            , (ptrPulse(ptr)->state == PULSE_SECOND? PULSE_OK : PULSE_ERROR)
        );
    }
}

/**
 * Часть обработчика прерывания PCINT увеличивающая счетчик числа импульсов
 * продолжает подсчет до истечения таймаута или по изменению статуса c PULSE_BUSY на любой другой.
 * также выключает обработчик самостоятельно. Только по изменению статуса или таймауту.
 *
 * @param  uint8_t oldBit      -- предыдущее состояние ноги прерывания "было до"
 * @return ptrPulse(ptr)->res; -- число накопленных импульсов
 *
 */
void pcint_encoder( void *ptr, uint8_t oldBit )
{
    uint8_t addition;

    switch( ptrPulse(ptr)->state )
    {
        case PULSE_RAISING: addition = 1-(int8_t)oldBit; break;         // прирост если был 0 и стало 1
        case PULSE_FAILING: addition = oldBit;           break;         // только из 1 в 0
        case PULSE_BOTH:    addition = 1;                break;         // пофиг как было
        default:
            // статус изменен извне: останов измерений без изменения статуса
            pcint_end( ptrPulse(ptr), ptrPulse(ptr)->state);
            return;
    }
    ptrPulse(ptr)->res += addition;
}
