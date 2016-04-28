/**
 * Moved from arhat.h:: this is a private definitions ONLY! Not use it!
 * Вынесено из arhat.h:: Это внутренние определения - НЕ ИСПОЛЬЗОВАТЬ!
 */

/* ============= private level 2. NOT USE IT in your sketches !!! ============= */
/* ПРИВАТНАЯ СЕКЦИЯ! НЕ ИСПОЛЬЗОВАТЬ ЭТИ МАКРОСЫ В СКЕТЧАХ. Ну или только сознательно */
#define _d_in(p)        (D##p##_In)
#define _d_out(p)       (D##p##_Out)
#define _d_high(p)      (D##p##_High)
#define _d_low(p)       (D##p##_Low)
#define _d_inv(p)       (D##p##_Inv)
#define _d_read(p)      (D##p##_Read)

#define _pin(p)         (pin##p)

#define pinDirReg(p)    (DREG##p)
#define pinOutReg(p)    (OREG##p)
#define pinInReg(p)     (IREG##p)
#define pinSetMask(p)   (BSET##p)
#define pinClearMask(p) (BCLR##p)

#define _pwmGetTimer(p)         getTimer##p
#define _pwmGetChannel(p)       getTimerChannel##p

#define _timerCount(t)          (TCNT##t)
#define _timerControl(t,r)      (TCCR##t##r)
#define _timerCompare(t,r)      (OCR##t##r)
#define _timerCapture(t)        (ICR##t)
#define _timerIMask(t,v,b)      ((b)? (TIMSK##t |= (TIF_##v)) : (TIMSK##t &= ~(TIF_##v)))
#define _timerIFlag(t,v)        (TIFR##t & (TIF_##v))
#define _ISRtimer(t,v)          (TIMER##t##_##v##_vect)
#define _prescalerMode(pr)      (TCLK_##pr)

#define __pwmMaskMode0(t,c)       (0)
#define __pwmMaskMode1(t,c)       (1<<COM##t##c##0)
#define __pwmMaskMode2(t,c)       (1<<COM##t##c##1)
#define __pwmMaskMode3(t,c)       ((1<<COM##t##c##1)|(1<<COM##t##c##0))

#define _pwmMaskMode0(t,c)        __pwmMaskMode0(t,c)
#define _pwmMaskMode1(t,c)        __pwmMaskMode1(t,c)
#define _pwmMaskMode2(t,c)        __pwmMaskMode2(t,c)
#define _pwmMaskMode3(t,c)        __pwmMaskMode3(t,c)

#define _pwmPinMask(t,c,m)      (_pwmMaskMode##m(t,c))

#define _pwmSet(p)              (setPWM##p)
#define _pwmOff(p)              (offPWM##p)
#define _pwmWrite(p,v)          (outPWM##p(v))

#define _analogPin(p)           (Analog##p)
#define _admuxSrc(s)            (ADC_SRC_##s)

#define _ISRusart(t,v)          (USART##t##_##v##_vect)

#define _pcint_DDR(n)           PCINT##n##_DDR
#define _pcint_PORT(n)          PCINT##n##_PORT
#define _pcint_PIN(n)           PCINT##n##_PIN
#define _pcint_msk(n)           PCMSK##n
#define _pcint_name(n)          PCINT##n##_vect

#define _pcint_tonumber(n,p)    PCINT##n##_pin2number(p)

#define _pcint_numbers(n)       pcint##n##numbers
#define _pcint_old(n)           pcint##n##old
#define _pcint_pulses(n)        pulses##n

