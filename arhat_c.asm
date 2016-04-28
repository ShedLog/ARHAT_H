GAS LISTING /tmp/ccOr00ZN.s 			page 1


   1               		.file	"arhat.c"
   2               	__SP_H__ = 0x3e
   3               	__SP_L__ = 0x3d
   4               	__SREG__ = 0x3f
   5               	__RAMPZ__ = 0x3b
   6               	__tmp_reg__ = 0
   7               	__zero_reg__ = 1
   8               		.text
   9               	.Ltext0:
  10               		.cfi_sections	.debug_frame
  11               		.section	.text.getOvfCount,"ax",@progbits
  12               	.global	getOvfCount
  13               		.type	getOvfCount, @function
  14               	getOvfCount:
  15               	.LFB1:
  16               		.file 1 "/home/arhat109/Arduino/libraries/Arhat/arhat.c"
   1:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
   2:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Simple function for calc time and delays.
   3:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
   4:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * use timer0 as default and prescaler 1/64 for each 4 microseconds with 16Mhz CLK.
   5:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * By default timer0 is overflowing each 256 ticks at 1024 microseconds.
   6:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
   7:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * For use other timer you need predefine all constants in block TIME_DEFAULT
   8:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * and recompile this file.
   9:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
  10:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * For simple use, you may rename this file to wiring.c and replace it.
  11:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
  12:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * @author Arhat109: arhat109@mail.ru
  13:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
  14:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * license agreement:
  15:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * You use this software on own your risks. No claims will be accepted.
  16:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * You may use this file any way, but cannot change
  17:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * or delete tag @author above (you may append your tag @author) and must keeping this rows:
  18:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
  19:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * This is free software, not any pay. But you may donate some money to phone +7-951-388-2793
  20:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
  21:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
  22:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ARHAT_C 1           // need for includes interrupt function in this file only.
  23:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ARHAT_MODE 3        // need in this file!
  24:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #include "arhat.h"
  25:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
  26:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** // defaults timer0 timers functions and interrupts such in wiring
  27:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** // Константы настройки таймера 0 совместимые с wiring: тай�
  28:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #ifndef TIME_DEFAULT                    /* all defaults for F_CPU=16Mhz ONLY! */
  29:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #  define TIME_DEFAULT             0
  30:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #  define TIME_MAX_COUNTER       256    /* max conter+1                                            
  31:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #  define TIME_PRESCALLER         64
  32:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #  define TIME_MODE                3    /* WGM10 = 1, WGM00 = 1 fast-PWM mode for timer0           
  33:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #  define TIME_TICK_MCS            4    /* 1 tick by prescaler:[0.25, 0.5, 4, 16, 64] in microsecon
  34:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #  define TIME_SHIFT               2    /* From prescaller: 1=>4, 8=>1, 64=>2, 256=>4, 1024=>6     
  35:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #  define TIME_MCS2MS      1024/1000    /* ==[16,128,1024,4096,16384]/1000 by prescaler            
  36:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #  define TIME_ISR               OVF    /* what interrupt name using for this timer                
  37:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #endif
  38:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
  39:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** volatile uint32_t       timer0_overflow_count   = 0UL;  // timer overflow counter. Счетчик �
  40:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** volatile void        (* timer0_hook)(void)      = 0;    // hook function pointer. функция "�
  41:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** uint8_t                 timer0_hook_run         = 0;    // hook is running. Blocking twice calling.
GAS LISTING /tmp/ccOr00ZN.s 			page 2


  42:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
  43:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
  44:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Volatile read count TOV interrupt
  45:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * 24 bytes, 19 cycles (1.1875mcsec.)
  46:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
  47:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** uint32_t getOvfCount()
  48:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
  17               		.loc 1 48 0
  18               		.cfi_startproc
  19               	/* prologue: function */
  20               	/* frame size = 0 */
  21               	/* stack size = 0 */
  22               	.L__stack_usage = 0
  49:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   uint8_t       _sreg = SREG;
  23               		.loc 1 49 0
  24 0000 2FB7      		in r18,__SREG__
  25               	.LVL0:
  50:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   uint32_t      _count;
  51:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
  52:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   cli();
  26               		.loc 1 52 0
  27               	/* #APP */
  28               	 ;  52 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
  29 0002 F894      		cli
  30               	 ;  0 "" 2
  53:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   _count = timer0_overflow_count;
  31               		.loc 1 53 0
  32               	/* #NOAPP */
  33 0004 6091 0000 		lds r22,timer0_overflow_count
  34 0008 7091 0000 		lds r23,timer0_overflow_count+1
  35 000c 8091 0000 		lds r24,timer0_overflow_count+2
  36 0010 9091 0000 		lds r25,timer0_overflow_count+3
  37               	.LVL1:
  54:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   SREG = _sreg;
  38               		.loc 1 54 0
  39 0014 2FBF      		out __SREG__,r18
  55:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
  56:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   return _count;
  57:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
  40               		.loc 1 57 0
  41 0016 0895      		ret
  42               		.cfi_endproc
  43               	.LFE1:
  44               		.size	getOvfCount, .-getOvfCount
  45               		.section	.text.setTimerHook,"ax",@progbits
  46               	.global	setTimerHook
  47               		.type	setTimerHook, @function
  48               	setTimerHook:
  49               	.LFB2:
  58:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
  59:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
  60:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Atomic set timer0_hook
  61:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * @return TimerHookProc -- previous proc | 0
  62:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
  63:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** TimerHookProc setTimerHook(TimerHookProc proc)
  64:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
  50               		.loc 1 64 0
GAS LISTING /tmp/ccOr00ZN.s 			page 3


  51               		.cfi_startproc
  52               	.LVL2:
  53               	/* prologue: function */
  54               	/* frame size = 0 */
  55               	/* stack size = 0 */
  56               	.L__stack_usage = 0
  57 0000 9C01      		movw r18,r24
  65:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   uint8_t       _sreg = SREG;
  58               		.loc 1 65 0
  59 0002 4FB7      		in r20,__SREG__
  60               	.LVL3:
  66:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   TimerHookProc _res;
  67:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
  68:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   cli();
  61               		.loc 1 68 0
  62               	/* #APP */
  63               	 ;  68 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
  64 0004 F894      		cli
  65               	 ;  0 "" 2
  69:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   _res = timer0_hook;
  66               		.loc 1 69 0
  67               	/* #NOAPP */
  68 0006 8091 0000 		lds r24,timer0_hook
  69 000a 9091 0000 		lds r25,timer0_hook+1
  70               	.LVL4:
  70:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   timer0_hook = proc;
  71               		.loc 1 70 0
  72 000e 3093 0000 		sts timer0_hook+1,r19
  73 0012 2093 0000 		sts timer0_hook,r18
  71:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   SREG = _sreg;
  74               		.loc 1 71 0
  75 0016 4FBF      		out __SREG__,r20
  72:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
  73:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   return _res;
  74:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
  76               		.loc 1 74 0
  77 0018 0895      		ret
  78               		.cfi_endproc
  79               	.LFE2:
  80               		.size	setTimerHook, .-setTimerHook
  81               		.section	.text.time_micros,"ax",@progbits
  82               	.global	time_micros
  83               		.type	time_micros, @function
  84               	time_micros:
  85               	.LFB3:
  75:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
  76:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
  77:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Return microseconds 0..up to 1 hours 11.4 minutes are identical with wiring.c
  78:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * "C" code = 76 bytes, "Asm" = 56 bytes and 42 cycles.
  79:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
  80:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** uint32_t time_micros()             // return in r22..r25
  81:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
  86               		.loc 1 81 0
  87               		.cfi_startproc
  88               	/* prologue: function */
  89               	/* frame size = 0 */
  90               	/* stack size = 0 */
GAS LISTING /tmp/ccOr00ZN.s 			page 4


  91               	.L__stack_usage = 0
  82:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /*
  83:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * register struct{ uint8_t timer, uint24_t micro } retVal; -- can't compile right!
  84:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * retVal must be in r22,r23,r24,r25 registers for right return avr-gcc convention!
  85:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
  86:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     uint8_t     oldSREG = SREG;         // r27
  87:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     uint8_t     timer, tov;             // r22, r26
  88:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     uint32_t    micro;                  // r23,r24,r25
  89:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
  90:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     // read all into local: volatile!
  91:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     cli();
  92:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       micro = timer0_overflow_count;		// not use h-byte!
  93:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       timer = timerCount(TIME_DEFAULT);
  94:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** //      tov = timerIFlag(TIME_DEFAULT,OVF);	// bit0! =={0,1} only!
  95:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       if ( timerIFlag(TIME_DEFAULT,OVF) && (timer<255) ){ micro++; }
  96:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     SREG = oldSREG;
  97:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
  98:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     // this is a precompiler #IF because is constants:
  99:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     if( TIME_TICK_MCS>1 ) {
 100:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       return (((micro<<8)+timer)<<TIME_SHIFT)+3;	// +3 microsec. fot this routine
 101:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     } else {
 102:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       return (((micro<<8)+timer)>>TIME_SHIFT)+3;
 103:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     }
 104:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** */
 105:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   asm volatile (
  92               		.loc 1 105 0
  93               	/* #APP */
  94               	 ;  105 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
  95 0000 AF93      		  push r26                 ;1
  96 0002 AFB7      		  in r26,__SREG__          ;1 oldSREG = SREG
  97 0004 F894      		  cli                      ;1
  98 0006 66B5      		  in r22,0x26              ;1 timer = timerCount(TIME_DEFAULT)
  99 0008 7091 0000 		  lds r23,timer0_overflow_count        ;3 micro = (uint24_t)timer0_overflow_count;
 100 000c 8091 0000 		  lds r24,timer0_overflow_count+1      ;3
 101 0010 9091 0000 		  lds r25,timer0_overflow_count+2      ;3 now: {r22..25}=(micro<<8)+timer!
 102 0014 A89B      		  sbis 0x15,0              ;1/2 TOV==1? ->PС+1
 103 0016 00C0      		   rjmp .skip1
 104 0018 6F3F      		  cpi  r22,lo8(-1)         ;1 ?!? timer == 255?
 105 001a 01F0      		  breq .skip1
 106 001c 0894      		    sec                    ;1 set carry flag
 107 001e 711D      		    adc   r23,__zero_reg__ ;1 micro++
 108 0020 811D      		    adc   r24,__zero_reg__ ;1
 109 0022 911D      		    adc   r25,__zero_reg__ ;1
 110               		.skip1:
 111 0024 AFBF      		  out __SREG__,r26         ;1 SREG = oldSREG, tmp_reg not use!
 112 0026 A2E0      		  ldi  r26,2               ;3 load TIME_SHIFT counter
 113               		.shift1: 
 114               		
 115               	 ;  0 "" 2
 106:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  push r26                 ;1\n\t"
 107:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  in r26,__SREG__          ;1 oldSREG = SREG\n\t"
 108:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  cli                      ;1\n\t"
 109:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  in r22,0x26              ;1 timer = timerCount(TIME_DEFAULT)\n\t"
 110:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  lds r23,timer0_overflow_count        ;3 micro = (uint24_t)timer0_overflow_count;\n\t"
 111:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  lds r24,timer0_overflow_count+1      ;3\n\t"
 112:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  lds r25,timer0_overflow_count+2      ;3 now: {r22..25}=(micro<<8)+timer!\n\t"
 113:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  sbis 0x15,0              ;1/2 TOV==1? ->PС+1\n\t"
GAS LISTING /tmp/ccOr00ZN.s 			page 5


 114:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "   rjmp .skip1\n\t"
 115:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  cpi  r22,lo8(-1)         ;1 ?!? timer == 255?\n\t"
 116:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  breq .skip1\n\t"
 117:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    sec                    ;1 set carry flag\n\t"
 118:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    adc   r23,__zero_reg__ ;1 micro++\n\t"
 119:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    adc   r24,__zero_reg__ ;1\n\t"
 120:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    adc   r25,__zero_reg__ ;1\n\t"
 121:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     ".skip1:\n\t"
 122:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  out __SREG__,r26         ;1 SREG = oldSREG, tmp_reg not use!\n\t"
 123:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 124:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  ldi  r26,2               ;3 load TIME_SHIFT counter\n\t"
 125:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     ".shift1: \n\t"
 126:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   ::);
 127:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   if( TIME_TICK_MCS>1 ) {
 128:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     asm volatile (
 116               		.loc 1 128 0
 117               	 ;  128 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
 118 0028 660F      		  lsl r22                ;1*2 retVal<<TIME_SHIFT
 119 002a 771F      		  rol r23                ;1*2
 120 002c 881F      		  rol r24                ;1*2
 121 002e 991F      		  rol r25                ;1*2
 122               		
 123               	 ;  0 "" 2
 129:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       "  lsl r22                ;1*2 retVal<<TIME_SHIFT\n\t"
 130:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       "  rol r23                ;1*2\n\t"
 131:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       "  rol r24                ;1*2\n\t"
 132:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       "  rol r25                ;1*2\n\t"
 133:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     ::);
 134:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   } else {
 135:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     asm volatile (
 136:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       "  lsr r22                ;1*2 retVal>>TIME_SHIFT\n\t"
 137:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       "  ror r23                ;1*2\n\t"
 138:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       "  ror r24                ;1*2\n\t"
 139:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       "  ror r25                ;1*2\n\t"
 140:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     ::);
 141:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   }
 142:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   asm volatile (
 124               		.loc 1 142 0
 125               	 ;  142 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
 126 0030 AA95      		  dec r26                  ;1*2 TIME_SHIFT counter--
 127 0032 01F4      		  brne .shift1             ;1+2
 128 0034 AF91      		  pop  r26                 ;1
 129               		
 130               	 ;  0 "" 2
 143:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  dec r26                  ;1*2 TIME_SHIFT counter--\n\t"
 144:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  brne .shift1             ;1+2\n\t"
 145:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** //    "  subi r22,-2              ;1 retVal += 2[.25] mcsec for this routine\n\t"
 146:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** //    "  sbci r23,-1              ;1\n\t"
 147:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** //    "  sbci r24,-1              ;1\n\t"
 148:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** //    "  sbci r25,-1              ;1\n\t"
 149:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "  pop  r26                 ;1\n\t"
 150:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   ::);
 151:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
 131               		.loc 1 151 0
 132               	/* #NOAPP */
 133 0036 0895      		ret
 134               		.cfi_endproc
GAS LISTING /tmp/ccOr00ZN.s 			page 6


 135               	.LFE3:
 136               		.size	time_micros, .-time_micros
 137               		.section	.text.time_millis,"ax",@progbits
 138               	.global	time_millis
 139               		.type	time_millis, @function
 140               	time_millis:
 141               	.LFB4:
 152:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 153:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
 154:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Return current time into milliseconds upto 49.7 days
 155:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * corrected for timer counter current value and fract data
 156:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * 102 bytes, long time: use udiv libc function!
 157:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
 158:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** uint32_t time_millis()
 159:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
 142               		.loc 1 159 0
 143               		.cfi_startproc
 144 0000 CF93      		push r28
 145               	.LCFI0:
 146               		.cfi_def_cfa_offset 4
 147               		.cfi_offset 28, -3
 148 0002 DF93      		push r29
 149               	.LCFI1:
 150               		.cfi_def_cfa_offset 5
 151               		.cfi_offset 29, -4
 152               	/* prologue: function */
 153               	/* frame size = 0 */
 154               	/* stack size = 2 */
 155               	.L__stack_usage = 2
 160:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     uint16_t    timer;
 161:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     uint8_t     oldSREG = SREG, tov=0;
 156               		.loc 1 161 0
 157 0004 8FB7      		in r24,__SREG__
 158               	.LVL5:
 162:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 163:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     cli();
 159               		.loc 1 163 0
 160               	/* #APP */
 161               	 ;  163 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
 162 0006 F894      		cli
 163               	 ;  0 "" 2
 164:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       timer = timerCount(TIME_DEFAULT);
 164               		.loc 1 164 0
 165               	/* #NOAPP */
 166 0008 D6B5      		in r29,0x26
 167               	.LVL6:
 165:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       if ( timerIFlag(TIME_DEFAULT,OVF) ){ tov++; }
 168               		.loc 1 165 0
 169 000a C5B3      		in r28,0x15
 170               	.LVL7:
 166:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     SREG = oldSREG;
 171               		.loc 1 166 0
 172 000c 8FBF      		out __SREG__,r24
 173               	.LVL8:
 167:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 168:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     timer = (TIME_TICK_MCS>1 ? timer<<TIME_SHIFT : timer>>TIME_SHIFT);
 169:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     return (timer0_overflow_count * TIME_MCS2MS)+tov+(timer>1000? 1 : 0);
GAS LISTING /tmp/ccOr00ZN.s 			page 7


 174               		.loc 1 169 0
 175 000e 6091 0000 		lds r22,timer0_overflow_count
 176 0012 7091 0000 		lds r23,timer0_overflow_count+1
 177 0016 8091 0000 		lds r24,timer0_overflow_count+2
 178 001a 9091 0000 		lds r25,timer0_overflow_count+3
 165:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     SREG = oldSREG;
 179               		.loc 1 165 0
 180 001e C170      		andi r28,lo8(1)
 181               	.LVL9:
 182               		.loc 1 169 0
 183 0020 2AE0      		ldi r18,10
 184               		1:
 185 0022 660F      		lsl r22
 186 0024 771F      		rol r23
 187 0026 881F      		rol r24
 188 0028 991F      		rol r25
 189 002a 2A95      		dec r18
 190 002c 01F4      		brne 1b
 191 002e 28EE      		ldi r18,lo8(-24)
 192 0030 33E0      		ldi r19,lo8(3)
 193 0032 40E0      		ldi r20,0
 194 0034 50E0      		ldi r21,0
 195 0036 0E94 0000 		call __udivmodsi4
 196 003a 2C0F      		add r18,r28
 197 003c 311D      		adc r19,__zero_reg__
 198 003e 411D      		adc r20,__zero_reg__
 199 0040 511D      		adc r21,__zero_reg__
 200 0042 81E0      		ldi r24,lo8(1)
 201 0044 90E0      		ldi r25,0
 202 0046 A0E0      		ldi r26,0
 203 0048 B0E0      		ldi r27,0
 204               	.LVL10:
 205 004a DB3F      		cpi r29,lo8(-5)
 206 004c 00F4      		brsh .L5
 207 004e 80E0      		ldi r24,0
 208 0050 90E0      		ldi r25,0
 209 0052 DC01      		movw r26,r24
 210               	.L5:
 211 0054 BC01      		movw r22,r24
 212 0056 CD01      		movw r24,r26
 213 0058 620F      		add r22,r18
 214 005a 731F      		adc r23,r19
 215 005c 841F      		adc r24,r20
 216 005e 951F      		adc r25,r21
 217               	/* epilogue start */
 170:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
 218               		.loc 1 170 0
 219 0060 DF91      		pop r29
 220               	.LVL11:
 221 0062 CF91      		pop r28
 222               	.LVL12:
 223 0064 0895      		ret
 224               		.cfi_endproc
 225               	.LFE4:
 226               		.size	time_millis, .-time_millis
 227               		.section	.text.time_delay,"ax",@progbits
 228               	.global	time_delay
GAS LISTING /tmp/ccOr00ZN.s 			page 8


 229               		.type	time_delay, @function
 230               	time_delay:
 231               	.LFB5:
 171:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 172:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
 173:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * identical with wiring.c
 174:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * @deprecated: big parameter (uint32_t) @see time_delay16()
 175:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
 176:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** void time_delay(uint32_t interval)
 177:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
 232               		.loc 1 177 0
 233               		.cfi_startproc
 234               	.LVL13:
 235 0000 CF92      		push r12
 236               	.LCFI2:
 237               		.cfi_def_cfa_offset 4
 238               		.cfi_offset 12, -3
 239 0002 DF92      		push r13
 240               	.LCFI3:
 241               		.cfi_def_cfa_offset 5
 242               		.cfi_offset 13, -4
 243 0004 EF92      		push r14
 244               	.LCFI4:
 245               		.cfi_def_cfa_offset 6
 246               		.cfi_offset 14, -5
 247 0006 FF92      		push r15
 248               	.LCFI5:
 249               		.cfi_def_cfa_offset 7
 250               		.cfi_offset 15, -6
 251 0008 CF93      		push r28
 252               	.LCFI6:
 253               		.cfi_def_cfa_offset 8
 254               		.cfi_offset 28, -7
 255 000a DF93      		push r29
 256               	.LCFI7:
 257               		.cfi_def_cfa_offset 9
 258               		.cfi_offset 29, -8
 259               	/* prologue: function */
 260               	/* frame size = 0 */
 261               	/* stack size = 6 */
 262               	.L__stack_usage = 6
 263 000c 6B01      		movw r12,r22
 264 000e 7C01      		movw r14,r24
 178:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     uint16_t start = (uint16_t)micros();
 265               		.loc 1 178 0
 266 0010 0E94 0000 		call time_micros
 267               	.LVL14:
 268 0014 EB01      		movw r28,r22
 269               	.LVL15:
 270               	.L8:
 179:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 180:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     while (interval > 0) {
 271               		.loc 1 180 0 discriminator 1
 272 0016 C114      		cp r12,__zero_reg__
 273 0018 D104      		cpc r13,__zero_reg__
 274 001a E104      		cpc r14,__zero_reg__
 275 001c F104      		cpc r15,__zero_reg__
GAS LISTING /tmp/ccOr00ZN.s 			page 9


 276 001e 01F0      		breq .L11
 181:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       if (((uint16_t)micros() - start) >= 1000) {
 277               		.loc 1 181 0
 278 0020 0E94 0000 		call time_micros
 279               	.LVL16:
 280 0024 6C1B      		sub r22,r28
 281 0026 7D0B      		sbc r23,r29
 282 0028 683E      		cpi r22,-24
 283 002a 7340      		sbci r23,3
 284 002c 00F0      		brlo .L8
 182:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         interval--;
 285               		.loc 1 182 0
 286 002e 81E0      		ldi r24,1
 287 0030 C81A      		sub r12,r24
 288 0032 D108      		sbc r13,__zero_reg__
 289 0034 E108      		sbc r14,__zero_reg__
 290 0036 F108      		sbc r15,__zero_reg__
 291               	.LVL17:
 183:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         start += 1000;
 292               		.loc 1 183 0
 293 0038 C851      		subi r28,24
 294 003a DC4F      		sbci r29,-4
 295               	.LVL18:
 296 003c 00C0      		rjmp .L8
 297               	.L11:
 298               	/* epilogue start */
 184:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       }
 185:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     }
 186:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
 299               		.loc 1 186 0
 300 003e DF91      		pop r29
 301 0040 CF91      		pop r28
 302               	.LVL19:
 303 0042 FF90      		pop r15
 304 0044 EF90      		pop r14
 305 0046 DF90      		pop r13
 306 0048 CF90      		pop r12
 307               	.LVL20:
 308 004a 0895      		ret
 309               		.cfi_endproc
 310               	.LFE5:
 311               		.size	time_delay, .-time_delay
 312               		.section	.text.time_delay16,"ax",@progbits
 313               	.global	time_delay16
 314               		.type	time_delay16, @function
 315               	time_delay16:
 316               	.LFB6:
 187:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 188:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
 189:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * for smaller parameter size: only 65535 milli seconds
 190:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * 52 bytes.
 191:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
 192:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** void time_delay16(uint16_t interval)
 193:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
 317               		.loc 1 193 0
 318               		.cfi_startproc
 319               	.LVL21:
GAS LISTING /tmp/ccOr00ZN.s 			page 10


 320 0000 0F93      		push r16
 321               	.LCFI8:
 322               		.cfi_def_cfa_offset 4
 323               		.cfi_offset 16, -3
 324 0002 1F93      		push r17
 325               	.LCFI9:
 326               		.cfi_def_cfa_offset 5
 327               		.cfi_offset 17, -4
 328 0004 CF93      		push r28
 329               	.LCFI10:
 330               		.cfi_def_cfa_offset 6
 331               		.cfi_offset 28, -5
 332 0006 DF93      		push r29
 333               	.LCFI11:
 334               		.cfi_def_cfa_offset 7
 335               		.cfi_offset 29, -6
 336               	/* prologue: function */
 337               	/* frame size = 0 */
 338               	/* stack size = 4 */
 339               	.L__stack_usage = 4
 340 0008 EC01      		movw r28,r24
 194:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     uint16_t start = (uint16_t)micros();
 341               		.loc 1 194 0
 342 000a 0E94 0000 		call time_micros
 343               	.LVL22:
 344 000e 8B01      		movw r16,r22
 345               	.LVL23:
 346               	.L13:
 195:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 196:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     while (interval > 0) {
 347               		.loc 1 196 0 discriminator 1
 348 0010 2097      		sbiw r28,0
 349 0012 01F0      		breq .L16
 197:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       if (((uint16_t)micros() - start) >= 1000) {
 350               		.loc 1 197 0
 351 0014 0E94 0000 		call time_micros
 352               	.LVL24:
 353 0018 601B      		sub r22,r16
 354 001a 710B      		sbc r23,r17
 355 001c 683E      		cpi r22,-24
 356 001e 7340      		sbci r23,3
 357 0020 00F0      		brlo .L13
 198:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         interval--;
 358               		.loc 1 198 0
 359 0022 2197      		sbiw r28,1
 360               	.LVL25:
 199:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         start += 1000;
 361               		.loc 1 199 0
 362 0024 0851      		subi r16,24
 363 0026 1C4F      		sbci r17,-4
 364               	.LVL26:
 365 0028 00C0      		rjmp .L13
 366               	.L16:
 367               	/* epilogue start */
 200:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****       }
 201:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     }
 202:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
GAS LISTING /tmp/ccOr00ZN.s 			page 11


 368               		.loc 1 202 0
 369 002a DF91      		pop r29
 370 002c CF91      		pop r28
 371               	.LVL27:
 372 002e 1F91      		pop r17
 373 0030 0F91      		pop r16
 374               	.LVL28:
 375 0032 0895      		ret
 376               		.cfi_endproc
 377               	.LFE6:
 378               		.size	time_delay16, .-time_delay16
 379               		.section	.text.init,"ax",@progbits
 380               	.global	init
 381               		.type	init, @function
 382               	init:
 383               	.LFB7:
 203:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 204:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
 205:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * (re)start timer for time functions
 206:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * @see TIME_DEFAULT define section
 207:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * 26 bytes
 208:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
 209:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** void time_init()
 210:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
 384               		.loc 1 210 0
 385               		.cfi_startproc
 386               	/* prologue: function */
 387               	/* frame size = 0 */
 388               	/* stack size = 0 */
 389               	.L__stack_usage = 0
 211:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     sei();
 390               		.loc 1 211 0
 391               	/* #APP */
 392               	 ;  211 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
 393 0000 7894      		sei
 394               	 ;  0 "" 2
 212:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     timerControl(TIME_DEFAULT, A) |= TIME_MODE;
 395               		.loc 1 212 0
 396               	/* #NOAPP */
 397 0002 84B5      		in r24,0x24
 398 0004 8360      		ori r24,lo8(3)
 399 0006 84BD      		out 0x24,r24
 213:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     timerControl(TIME_DEFAULT, B) |= prescalerMode(TIME_PRESCALLER);
 400               		.loc 1 213 0
 401 0008 85B5      		in r24,0x25
 402 000a 8360      		ori r24,lo8(3)
 403 000c 85BD      		out 0x25,r24
 214:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     timerIMask(TIME_DEFAULT, OVF, 1);
 404               		.loc 1 214 0
 405 000e EEE6      		ldi r30,lo8(110)
 406 0010 F0E0      		ldi r31,0
 407 0012 8081      		ld r24,Z
 408 0014 8160      		ori r24,lo8(1)
 409 0016 8083      		st Z,r24
 410 0018 0895      		ret
 411               		.cfi_endproc
 412               	.LFE7:
GAS LISTING /tmp/ccOr00ZN.s 			page 12


 413               		.size	init, .-init
 414               		.section	.text.adc_read,"ax",@progbits
 415               	.global	adc_read
 416               		.type	adc_read, @function
 417               	adc_read:
 418               	.LFB9:
 215:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
 216:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 217:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
 218:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Timer interrupt by Overflow Flag up each (TIMER_TICK_MCS*TIMER_MAX_COUNT) microseconds.
 219:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
 220:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Пользуемся побайтовой арифметикой: считали - добави�
 221:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Экономим регистры и команды:
 222:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * "С" verison   = 158 bytes;
 223:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * "ASM" version = 102 bytes, 46/51/75 cycles: 2.875mcsec for timer0_hook=0 and 4.6875 mcsec for em
 224:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
 225:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * ISR(ISRtimer(TIME_DEFAULT, TIME_ISR), ISR_NAKED)
 226:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
 227:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * equal this:
 228:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
 229:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * void __vector_ 23(void) __attribute__ ((signal, used, externally_visible)) __attribute__((naked)
 230:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * void __vector_ 23(void)
 231:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
 232:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** ISR(ISRtimer(TIME_DEFAULT, TIME_ISR), ISR_NAKED)
 233:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** //ISR(ISRtimer(TIME_DEFAULT, TIME_ISR))
 234:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
 235:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /* C version:
 236:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 237:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     timer0_overflow_count++;
 238:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 239:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     if( timer0_hook && !timer0_hook_run ){
 240:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         timer0_hook_run = 1;
 241:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         sei();
 242:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         timer0_hook();
 243:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         cli();
 244:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         timer0_hook_run = 0;
 245:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     }
 246:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
 247:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** */
 248:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     asm volatile(
 249:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    push r30               \n\t"
 250:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    push r31               \n\t"
 251:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    in r30,__SREG__        \n\t"
 252:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    push r30               \n\t"
 253:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 254:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    lds r30,timer0_overflow_count   \n\t"
 255:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    lds r31,timer0_overflow_count+1 \n\t"
 256:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    adiw r30,1                      \n\t"
 257:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    sts timer0_overflow_count,r30   \n\t"
 258:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    sts timer0_overflow_count+1,r31 \n\t"
 259:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    clr r31                         \n\t"
 260:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    lds r30,timer0_overflow_count+2 \n\t"
 261:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    adc r30,r31                     \n\t"
 262:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    sts timer0_overflow_count+2,r30 \n\t"
 263:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    lds r30,timer0_overflow_count+3 \n\t"
 264:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    adc r30,r31                     \n\t"
 265:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    sts timer0_overflow_count+3,r30 \n\t"
GAS LISTING /tmp/ccOr00ZN.s 			page 13


 266:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 267:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #if defined(ARHAT_MODE) && (ARHAT_MODE == 3)
 268:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /*
 269:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    lds r30,timer0_hook                 ; if( timer0_hook && !timer0_hook_run ){\n\t"
 270:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    lds r31,timer0_hook+1                                                       \n\t"
 271:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    or  r30,r31                         ; (LByte | HByte) == 0?                 \n\t"
 272:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    breq .L1                                                                    \n\t"
 273:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    lds r30,timer0_hook_run                                                     \n\t"
 274:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    tst r30                             ; r30 & r30 != 0?                       \n\t"
 275:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    brne .L1                                                                    \n\t"
 276:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    inc r30                             ; timer0_hook_run = 1; \n\t"
 277:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    sts timer0_hook_run,r30                                    \n\t"
 278:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    lds r30,timer0_hook                 ; timer0_hook();       \n\t"
 279:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    lds r31,timer0_hook+1                                      \n\t"
 280:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    sei   \n\t"
 281:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** */
 282:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         ::
 283:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     );
 284:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 285:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     if( timer0_hook && !timer0_hook_run ){
 286:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         timer0_hook_run = 1;
 287:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         pushAllRegs();
 288:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         sei();
 289:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         timer0_hook();
 290:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         cli();
 291:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         timer0_hook_run = 0;
 292:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /*
 293:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     asm volatile(
 294:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    icall \n\t"
 295:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         ::
 296:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     );
 297:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** */
 298:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         popAllRegs();
 299:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     }
 300:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     asm volatile(
 301:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /*
 302:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    cli   \n\t"
 303:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    clr r31                                                    \n\t"
 304:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    sts timer0_hook_run,r31             ; timer0_hook_run = 0; \n\t"
 305:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         ".L1:                  \n\t"
 306:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** */
 307:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #endif // ARHAT_MODE == 3
 308:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    pop r30           \n\t"
 309:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    out __SREG__,r30  \n\t"
 310:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    pop r31           \n\t"
 311:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    pop r30           \n\t"
 312:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    reti              \n\t"
 313:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         ::
 314:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     );
 315:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 316:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
 317:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 318:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** // ======================== ADC ======================== //
 319:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 320:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /** Input multiplexer channels (@deprecated: not need more!) */
 321:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_0		0	/* from Analog0 */
 322:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_1		1	/* from Analog1 */
GAS LISTING /tmp/ccOr00ZN.s 			page 14


 323:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_2		2	/* from Analog2 */
 324:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_3		3	/* from Analog3 */
 325:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_4		4	/* from Analog4 */
 326:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_5		5	/* from Analog5 */
 327:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_6		6	/* from Analog6 */
 328:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_7		7	/* from Analog7 */
 329:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_8		32	/* from Analog8 */
 330:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_9		33	/* from Analog9 */
 331:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_10	34	/* from Analog10 */
 332:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_11	35	/* from Analog11 */
 333:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_12	36	/* from Analog12 */
 334:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_13	37	/* from Analog13 */
 335:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_14	38	/* from Analog14 */
 336:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_15	39	/* from Analog15 */
 337:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M10_a0a0		8
 338:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M10_a0a1		9
 339:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M200_a0a0		10
 340:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M200_a0a1		11
 341:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M10_a2a2		12
 342:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M10_a2a3		13
 343:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M200_a2a2		14
 344:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M200_a2a3		15
 345:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M10_a8a8		40
 346:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M10_a8a9		41
 347:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M200_a8a8		42
 348:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M200_a8a9		43
 349:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M10_a10a10	44
 350:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M10_a10a11	45
 351:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M200_a10a10	46
 352:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M200_a10a11	47
 353:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a1a0		16
 354:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a1a1		17
 355:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a1a2		18
 356:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a1a3		19
 357:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a1a4		20
 358:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a1a5		21
 359:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a1a6		22
 360:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a1a7		23
 361:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a2a0		24
 362:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a2a1		25
 363:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a2a2		26
 364:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a2a3		27
 365:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a2a4		28
 366:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a2a5		29
 367:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a9a8		48
 368:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a9a9		49
 369:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a9a10		50
 370:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a9a11		51
 371:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a9a12		52
 372:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a9a13		53
 373:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a9a14		54
 374:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a9a15		55
 375:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a10a8		56
 376:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a10a9		57
 377:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a10a10		58
 378:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a10a11		59
 379:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a10a12		60
GAS LISTING /tmp/ccOr00ZN.s 			page 15


 380:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** #define ADMUX_M1_a10a13		61
 381:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 382:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
 383:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * AnalogRead
 384:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * ==========
 385:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * 1. ADC clock [50..200]kHz. for F_CPU = 16Mhz ADC prescaler = 160(opt.): ADPS2:0 = 111 = F_CPU/12
 386:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * 2. set in default mode: 1 channel, ADLAR=right,src=AVCC
 387:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
 388:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * 3. !!! before use it must be adcOn() with delay=108micros !!!
 389:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
 390:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** uint16_t adc_read(uint8_t anPin)
 391:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
 419               		.loc 1 391 0
 420               		.cfi_startproc
 421               	.LVL29:
 422               	/* prologue: function */
 423               	/* frame size = 0 */
 424               	/* stack size = 0 */
 425               	.L__stack_usage = 0
 392:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** //  uint8_t    oreg, anh;
 393:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 394:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   admux1Channel(admuxSrc(AVCC), anPin, ADC_RIGHT);      // set registers: ADMUX, ADCSRB
 426               		.loc 1 394 0
 427 0000 982F      		mov r25,r24
 428 0002 9770      		andi r25,lo8(7)
 429 0004 292F      		mov r18,r25
 430 0006 2064      		ori r18,lo8(64)
 431 0008 2093 7C00 		sts 124,r18
 432 000c 2091 7B00 		lds r18,123
 433 0010 8870      		andi r24,lo8(8)
 434               	.LVL30:
 435 0012 282B      		or r18,r24
 436 0014 2093 7B00 		sts 123,r18
 437 0018 8823      		tst r24
 438 001a 01F0      		breq .L19
 439               		.loc 1 394 0 is_stmt 0 discriminator 1
 440 001c 8091 7D00 		lds r24,125
 441 0020 892B      		or r24,r25
 442 0022 8093 7D00 		sts 125,r24
 443 0026 00C0      		rjmp .L20
 444               	.L19:
 445               		.loc 1 394 0 discriminator 2
 446 0028 8091 7E00 		lds r24,126
 447 002c 892B      		or r24,r25
 448 002e 8093 7E00 		sts 126,r24
 449               	.L20:
 395:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   ADCSRA |= _BV(ADSC);                                  // start analog read
 450               		.loc 1 395 0 is_stmt 1
 451 0032 8091 7A00 		lds r24,122
 452 0036 8064      		ori r24,lo8(64)
 453 0038 8093 7A00 		sts 122,r24
 454               	.L22:
 396:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   while (ADCSRA & (1 << ADSC));                         // wait as ADC is done
 455               		.loc 1 396 0 discriminator 1
 456 003c 8091 7A00 		lds r24,122
 457 0040 86FD      		sbrc r24,6
 458 0042 00C0      		rjmp .L22
GAS LISTING /tmp/ccOr00ZN.s 			page 16


 397:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 398:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** //  oreg = SREG;
 399:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** //  cli();
 400:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** //    anPin = ADCL;
 401:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** //    anh = ADCH;
 402:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** //  SREG = oreg;
 403:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** //  return (ADCH<<8) + ADCL;
 404:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   asm volatile (
 459               		.loc 1 404 0
 460               	/* #APP */
 461               	 ;  404 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
 462 0044 0FB6      		in  __tmp_reg__, __SREG__
 463 0046 F894      		cli
 464 0048 8091 7800 		lds r24,120    ; retL = ADCL
 465 004c 9091 7900 		lds r25,121    ; retH = ADCH
 466 0050 0FBE      		out __SREG__,__tmp_reg__
 467               		
 468               	 ;  0 "" 2
 405:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "in  __tmp_reg__, __SREG__\n\t"
 406:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "cli\n\t"
 407:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "lds r24,120    ; retL = ADCL\n\t"
 408:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "lds r25,121    ; retH = ADCH\n\t"
 409:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "out __SREG__,__tmp_reg__\n\t"
 410:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   ::);
 411:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
 469               		.loc 1 411 0
 470               	/* #NOAPP */
 471 0052 0895      		ret
 472               		.cfi_endproc
 473               	.LFE9:
 474               		.size	adc_read, .-adc_read
 475               		.section	.text.EEPROM_read,"ax",@progbits
 476               	.global	EEPROM_read
 477               		.type	EEPROM_read, @function
 478               	EEPROM_read:
 479               	.LFB10:
 412:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 413:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** // ======================== EEPROM ======================== //
 414:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** // Thanks DeGlucker from cyber-place.ru                     //
 415:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** // ======================================================== //
 416:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** unsigned char EEPROM_read(unsigned int uiAddress)
 417:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
 480               		.loc 1 417 0
 481               		.cfi_startproc
 482               	/* prologue: function */
 483               	/* frame size = 0 */
 484               	/* stack size = 0 */
 485               	.L__stack_usage = 0
 486               	.LVL31:
 487               	.L25:
 418:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   while(EECR & (1<<EEPE));
 488               		.loc 1 418 0 discriminator 1
 489 0000 F999      		sbic 0x1f,1
 490 0002 00C0      		rjmp .L25
 419:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   EEARL = uiAddress & 0xFF;
 491               		.loc 1 419 0
 492 0004 81BD      		out 0x21,r24
GAS LISTING /tmp/ccOr00ZN.s 			page 17


 420:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   EEARH = (uiAddress>>8) & 0xFF;
 493               		.loc 1 420 0
 494 0006 92BD      		out 0x22,r25
 421:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   EECR |= (1<<EERE);
 495               		.loc 1 421 0
 496 0008 F89A      		sbi 0x1f,0
 422:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   return EEDR;
 497               		.loc 1 422 0
 498 000a 80B5      		in r24,0x20
 499               	.LVL32:
 423:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
 500               		.loc 1 423 0
 501 000c 0895      		ret
 502               		.cfi_endproc
 503               	.LFE10:
 504               		.size	EEPROM_read, .-EEPROM_read
 505               		.section	.text.EEPROM_write,"ax",@progbits
 506               	.global	EEPROM_write
 507               		.type	EEPROM_write, @function
 508               	EEPROM_write:
 509               	.LFB11:
 424:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 425:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** void EEPROM_write(unsigned int uiAddress, unsigned char ucData)
 426:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
 510               		.loc 1 426 0
 511               		.cfi_startproc
 512               	/* prologue: function */
 513               	/* frame size = 0 */
 514               	/* stack size = 0 */
 515               	.L__stack_usage = 0
 516               	.LVL33:
 517               	.L28:
 427:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   while(EECR & (1<<EEPE));
 518               		.loc 1 427 0 discriminator 1
 519 0000 F999      		sbic 0x1f,1
 520 0002 00C0      		rjmp .L28
 428:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   EEARL = uiAddress & 0xFF;
 521               		.loc 1 428 0
 522 0004 81BD      		out 0x21,r24
 429:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   EEARH = (uiAddress>>8) & 0xFF;
 523               		.loc 1 429 0
 524 0006 92BD      		out 0x22,r25
 430:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   EEDR = (ucData);
 525               		.loc 1 430 0
 526 0008 60BD      		out 0x20,r22
 431:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   uint8_t oreg = SREG;
 527               		.loc 1 431 0
 528 000a 8FB7      		in r24,__SREG__
 529               	.LVL34:
 432:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   cli();
 530               		.loc 1 432 0
 531               	/* #APP */
 532               	 ;  432 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
 533 000c F894      		cli
 534               	 ;  0 "" 2
 433:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   EECR |= (1<<EEMPE);
 535               		.loc 1 433 0
GAS LISTING /tmp/ccOr00ZN.s 			page 18


 536               	/* #NOAPP */
 537 000e FA9A      		sbi 0x1f,2
 434:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   EECR |= (1<<EEPE);
 538               		.loc 1 434 0
 539 0010 F99A      		sbi 0x1f,1
 435:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   SREG = oreg;
 540               		.loc 1 435 0
 541 0012 8FBF      		out __SREG__,r24
 542 0014 0895      		ret
 543               		.cfi_endproc
 544               	.LFE11:
 545               		.size	EEPROM_write, .-EEPROM_write
 546               		.section	.text.pushAllRegs,"ax",@progbits
 547               	.global	pushAllRegs
 548               		.type	pushAllRegs, @function
 549               	pushAllRegs:
 550               	.LFB12:
 436:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
 437:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 438:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** // ======================== RTOS simple ======================== //
 439:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** // Small functions for future RTOS: save/load context            //
 440:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** // ============================================================= //
 441:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 442:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
 443:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Save all register file and SREG on stack and right return to caller
 444:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Сохранение полного контекста на стеке и корректный �
 445:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
 446:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** void pushAllRegs()
 447:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
 551               		.loc 1 447 0
 552               		.cfi_startproc
 553               	/* prologue: function */
 554               	/* frame size = 0 */
 555               	/* stack size = 0 */
 556               	.L__stack_usage = 0
 448:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****   asm volatile(
 557               		.loc 1 448 0
 558               	/* #APP */
 559               	 ;  448 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
 560 0000 FF93      		    push r31               
 561 0002 EF93      		    push r30               
 562 0004 FEB7      		    in   r31,__SP_H__      
 563 0006 EDB7      		    in   r30,__SP_L__      
 564 0008 0F92      		    push r0                
 565 000a 0FB6      		    in   r0,__SREG__       
 566 000c 0F92      		    push r0                
 567 000e 1F92      		    push r1                
 568 0010 2F92      		    push r2                
 569 0012 3F92      		    push r3                
 570 0014 4F92      		    push r4                
 571 0016 5F92      		    push r5                
 572 0018 6F92      		    push r6                
 573 001a 7F92      		    push r7                
 574 001c 8F92      		    push r8                
 575 001e 9F92      		    push r9                
 576 0020 AF92      		    push r10               
 577 0022 BF92      		    push r11               
GAS LISTING /tmp/ccOr00ZN.s 			page 19


 578 0024 CF92      		    push r12               
 579 0026 DF92      		    push r13               
 580 0028 EF92      		    push r14               
 581 002a FF92      		    push r15               
 582 002c 0F93      		    push r16               
 583 002e 1F93      		    push r17               
 584 0030 2F93      		    push r18               
 585 0032 3F93      		    push r19               
 586 0034 4F93      		    push r20               
 587 0036 5F93      		    push r21               
 588 0038 6F93      		    push r22               
 589 003a 7F93      		    push r23               
 590 003c 8F93      		    push r24               
 591 003e 9F93      		    push r25               
 592 0040 AF93      		    push r26               
 593 0042 BF93      		    push r27               
 594 0044 CF93      		    push r28               
 595 0046 DF93      		    push r29               
 596 0048 0380      		    ldd  r0,Z+3            
 597 004a 1480      		    ldd  r1,Z+4            
 598 004c 1F92      		    push r1                
 599 004e 0F92      		    push r0                
 600 0050 1124      		    clr  r1                
 601               		
 602               	 ;  0 "" 2
 603               	/* #NOAPP */
 604 0052 0895      		ret
 605               		.cfi_endproc
 606               	.LFE12:
 607               		.size	pushAllRegs, .-pushAllRegs
 608               		.section	.text.popAllRegs,"ax",@progbits
 609               	.global	popAllRegs
 610               		.type	popAllRegs, @function
 611               	popAllRegs:
 612               	.LFB13:
 449:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r31               \n\t"
 450:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r30               \n\t"
 451:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    in   r31,__SP_H__      \n\t"
 452:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    in   r30,__SP_L__      \n\t"
 453:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r0                \n\t"
 454:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    in   r0,__SREG__       \n\t"
 455:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r0                \n\t"
 456:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r1                \n\t"
 457:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r2                \n\t"
 458:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r3                \n\t"
 459:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r4                \n\t"
 460:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r5                \n\t"
 461:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r6                \n\t"
 462:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r7                \n\t"
 463:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r8                \n\t"
 464:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r9                \n\t"
 465:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r10               \n\t"
 466:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r11               \n\t"
 467:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r12               \n\t"
 468:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r13               \n\t"
 469:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r14               \n\t"
 470:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r15               \n\t"
GAS LISTING /tmp/ccOr00ZN.s 			page 20


 471:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r16               \n\t"
 472:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r17               \n\t"
 473:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r18               \n\t"
 474:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r19               \n\t"
 475:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r20               \n\t"
 476:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r21               \n\t"
 477:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r22               \n\t"
 478:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r23               \n\t"
 479:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r24               \n\t"
 480:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r25               \n\t"
 481:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r26               \n\t"
 482:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r27               \n\t"
 483:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r28               \n\t"
 484:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r29               \n\t"
 485:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    ldd  r0,Z+3            \n\t"
 486:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    ldd  r1,Z+4            \n\t"
 487:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r1                \n\t"
 488:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    push r0                \n\t"
 489:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    clr  r1                \n\t"
 490:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     ::
 491:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     );
 492:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
 493:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 494:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
 495:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Load all register file and SREG from stack and right return to caller
 496:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Обратная задача: восстановление контекста регистро�
 497:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * с подменой старой точки возрата (@see pushAllRegs()) на корре�
 498:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
 499:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** void popAllRegs()
 500:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
 613               		.loc 1 500 0
 614               		.cfi_startproc
 615               	/* prologue: function */
 616               	/* frame size = 0 */
 617               	/* stack size = 0 */
 618               	.L__stack_usage = 0
 501:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** asm volatile(
 619               		.loc 1 501 0
 620               	/* #APP */
 621               	 ;  501 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
 622 0000 1F90      		    pop r1           
 623 0002 0F90      		    pop r0           
 624 0004 DF91      		    pop r29          
 625 0006 CF91      		    pop r28          
 626 0008 BF91      		    pop r27          
 627 000a AF91      		    pop r26          
 628 000c 9F91      		    pop r25          
 629 000e 8F91      		    pop r24          
 630 0010 7F91      		    pop r23          
 631 0012 6F91      		    pop r22          
 632 0014 5F91      		    pop r21          
 633 0016 4F91      		    pop r20          
 634 0018 3F91      		    pop r19          
 635 001a 2F91      		    pop r18          
 636 001c 1F91      		    pop r17          
 637 001e 0F91      		    pop r16          
 638 0020 FF90      		    pop r15          
GAS LISTING /tmp/ccOr00ZN.s 			page 21


 639 0022 EF90      		    pop r14          
 640 0024 DF90      		    pop r13          
 641 0026 CF90      		    pop r12          
 642 0028 BF90      		    pop r11          
 643 002a AF90      		    pop r10          
 644 002c 9F90      		    pop r9           
 645 002e 8F90      		    pop r8           
 646 0030 7F90      		    pop r7           
 647 0032 6F90      		    pop r6           
 648 0034 5F90      		    pop r5           
 649 0036 4F90      		    pop r4           
 650 0038 3F90      		    pop r3           
 651 003a 2F90      		    pop r2           
 652 003c FEB7      		    in  r31,__SP_H__ 
 653 003e EDB7      		    in  r30,__SP_L__ 
 654 0040 0782      		    std Z+7,r0       
 655 0042 1682      		    std Z+6,r1       
 656 0044 1F90      		    pop r1           
 657 0046 0F90      		    pop r0           
 658 0048 0FBE      		    out __SREG__,r0  
 659 004a 0F90      		    pop r0           
 660 004c EF91      		    pop r30          
 661 004e FF91      		    pop r31          
 662               		
 663               	 ;  0 "" 2
 664               	/* #NOAPP */
 665 0050 0895      		ret
 666               		.cfi_endproc
 667               	.LFE13:
 668               		.size	popAllRegs, .-popAllRegs
 669               		.section	.text.__vector_23,"ax",@progbits
 670               	.global	__vector_23
 671               		.type	__vector_23, @function
 672               	__vector_23:
 673               	.LFB8:
 234:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /* C version:
 674               		.loc 1 234 0
 675               		.cfi_startproc
 676               	/* prologue: naked */
 677               	/* frame size = 0 */
 678               	/* stack size = 0 */
 679               	.L__stack_usage = 0
 248:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         "    push r30               \n\t"
 680               		.loc 1 248 0
 681               	/* #APP */
 682               	 ;  248 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
 683 0000 EF93      		    push r30               
 684 0002 FF93      		    push r31               
 685 0004 EFB7      		    in r30,__SREG__        
 686 0006 EF93      		    push r30               
 687 0008 E091 0000 		    lds r30,timer0_overflow_count   
 688 000c F091 0000 		    lds r31,timer0_overflow_count+1 
 689 0010 3196      		    adiw r30,1                      
 690 0012 E093 0000 		    sts timer0_overflow_count,r30   
 691 0016 F093 0000 		    sts timer0_overflow_count+1,r31 
 692 001a FF27      		    clr r31                         
 693 001c E091 0000 		    lds r30,timer0_overflow_count+2 
GAS LISTING /tmp/ccOr00ZN.s 			page 22


 694 0020 EF1F      		    adc r30,r31                     
 695 0022 E093 0000 		    sts timer0_overflow_count+2,r30 
 696 0026 E091 0000 		    lds r30,timer0_overflow_count+3 
 697 002a EF1F      		    adc r30,r31                     
 698 002c E093 0000 		    sts timer0_overflow_count+3,r30 
 699               		
 700               	 ;  0 "" 2
 285:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         timer0_hook_run = 1;
 701               		.loc 1 285 0
 702               	/* #NOAPP */
 703 0030 8091 0000 		lds r24,timer0_hook
 704 0034 9091 0000 		lds r25,timer0_hook+1
 705 0038 0097      		sbiw r24,0
 706 003a 01F0      		breq .L32
 285:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         timer0_hook_run = 1;
 707               		.loc 1 285 0 is_stmt 0 discriminator 1
 708 003c 8091 0000 		lds r24,timer0_hook_run
 709 0040 8111      		cpse r24,__zero_reg__
 710 0042 00C0      		rjmp .L32
 711               	.LBB2:
 286:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         pushAllRegs();
 712               		.loc 1 286 0 is_stmt 1
 713 0044 81E0      		ldi r24,lo8(1)
 714 0046 8093 0000 		sts timer0_hook_run,r24
 287:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         sei();
 715               		.loc 1 287 0
 716 004a 0E94 0000 		call pushAllRegs
 717               	.LVL35:
 288:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         timer0_hook();
 718               		.loc 1 288 0
 719               	/* #APP */
 720               	 ;  288 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
 721 004e 7894      		sei
 722               	 ;  0 "" 2
 289:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         cli();
 723               		.loc 1 289 0
 724               	/* #NOAPP */
 725 0050 E091 0000 		lds r30,timer0_hook
 726 0054 F091 0000 		lds r31,timer0_hook+1
 727 0058 1995      		eicall
 728               	.LVL36:
 290:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         timer0_hook_run = 0;
 729               		.loc 1 290 0
 730               	/* #APP */
 731               	 ;  290 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
 732 005a F894      		cli
 733               	 ;  0 "" 2
 291:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /*
 734               		.loc 1 291 0
 735               	/* #NOAPP */
 736 005c 1092 0000 		sts timer0_hook_run,__zero_reg__
 298:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     }
 737               		.loc 1 298 0
 738 0060 0E94 0000 		call popAllRegs
 739               	.LVL37:
 740               	.L32:
 741               	.LBE2:
GAS LISTING /tmp/ccOr00ZN.s 			page 23


 300:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /*
 742               		.loc 1 300 0
 743               	/* #APP */
 744               	 ;  300 "/home/arhat109/Arduino/libraries/Arhat/arhat.c" 1
 745 0064 EF91      		    pop r30           
 746 0066 EFBF      		    out __SREG__,r30  
 747 0068 FF91      		    pop r31           
 748 006a EF91      		    pop r30           
 749 006c 1895      		    reti              
 750               		
 751               	 ;  0 "" 2
 752               	/* epilogue start */
 316:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 753               		.loc 1 316 0
 754               	/* #NOAPP */
 755               		.cfi_endproc
 756               	.LFE8:
 757               		.size	__vector_23, .-__vector_23
 758               		.section	.text.pcint_end,"ax",@progbits
 759               	.global	pcint_end
 760               		.type	pcint_end, @function
 761               	pcint_end:
 762               	.LFB14:
 502:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r1           \n\t"
 503:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r0           \n\t"
 504:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r29          \n\t"
 505:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r28          \n\t"
 506:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r27          \n\t"
 507:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r26          \n\t"
 508:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r25          \n\t"
 509:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r24          \n\t"
 510:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r23          \n\t"
 511:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r22          \n\t"
 512:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r21          \n\t"
 513:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r20          \n\t"
 514:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r19          \n\t"
 515:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r18          \n\t"
 516:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r17          \n\t"
 517:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r16          \n\t"
 518:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r15          \n\t"
 519:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r14          \n\t"
 520:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r13          \n\t"
 521:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r12          \n\t"
 522:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r11          \n\t"
 523:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r10          \n\t"
 524:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r9           \n\t"
 525:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r8           \n\t"
 526:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r7           \n\t"
 527:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r6           \n\t"
 528:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r5           \n\t"
 529:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r4           \n\t"
 530:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r3           \n\t"
 531:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r2           \n\t"
 532:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    in  r31,__SP_H__ \n\t"
 533:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    in  r30,__SP_L__ \n\t"
 534:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    std Z+7,r0       \n\t"
 535:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    std Z+6,r1       \n\t"
GAS LISTING /tmp/ccOr00ZN.s 			page 24


 536:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r1           \n\t"
 537:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r0           \n\t"
 538:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    out __SREG__,r0  \n\t"
 539:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r0           \n\t"
 540:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r30          \n\t"
 541:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     "    pop r31          \n\t"
 542:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     ::
 543:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     );
 544:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
 545:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 546:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** // ==================== for pcint.h functions ========================= //
 547:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 548:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
 549:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Пишет код ошибки или результата в статус замера и сн�
 550:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Заодно запрещает перерывание (только для ноги этого 
 551:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
 552:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** void pcint_end(Pulse * ptrPulse, uint8_t error)
 553:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
 763               		.loc 1 553 0
 764               		.cfi_startproc
 765               	.LVL38:
 766               	/* prologue: function */
 767               	/* frame size = 0 */
 768               	/* stack size = 0 */
 769               	.L__stack_usage = 0
 554:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     uint8_t     rpin = ptrPulse->pin;
 770               		.loc 1 554 0
 771 0000 FC01      		movw r30,r24
 772 0002 2385      		ldd r18,Z+11
 773               	.LVL39:
 555:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 556:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     ptrPulse->state        = error;                             // статус завершени�
 774               		.loc 1 556 0
 775 0004 6287      		std Z+10,r22
 557:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 558:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     switch( rpin & 0xc0 ){                                      // запрещаем прерыв�
 776               		.loc 1 558 0
 777 0006 822F      		mov r24,r18
 778               	.LVL40:
 779 0008 807C      		andi r24,lo8(-64)
 780 000a 8034      		cpi r24,lo8(64)
 781 000c 01F0      		breq .L38
 782 000e 8038      		cpi r24,lo8(-128)
 783 0010 01F0      		breq .L39
 784 0012 8111      		cpse r24,__zero_reg__
 785 0014 00C0      		rjmp .L36
 559:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         case 0x80: PCMSK2 &= ~(((uint8_t)1)<<(rpin&0x3f)); break;
 560:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         case 0x40: PCMSK1 &= ~(((uint8_t)1)<<(rpin&0x3f)); break;
 561:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         case 0:    PCMSK0 &= ~(((uint8_t)1)<<(rpin&0x3f)); break;
 786               		.loc 1 561 0
 787 0016 3091 6B00 		lds r19,107
 788 001a 81E0      		ldi r24,lo8(1)
 789 001c 90E0      		ldi r25,0
 790 001e 022E      		mov r0,r18
 791 0020 00C0      		rjmp 2f
 792               		1:
 793 0022 880F      		lsl r24
GAS LISTING /tmp/ccOr00ZN.s 			page 25


 794               		2:
 795 0024 0A94      		dec r0
 796 0026 02F4      		brpl 1b
 797 0028 8095      		com r24
 798 002a 8323      		and r24,r19
 799 002c 8093 6B00 		sts 107,r24
 800 0030 00C0      		rjmp .L36
 801               	.L39:
 559:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         case 0x80: PCMSK2 &= ~(((uint8_t)1)<<(rpin&0x3f)); break;
 802               		.loc 1 559 0
 803 0032 3091 6D00 		lds r19,109
 804 0036 2F73      		andi r18,lo8(63)
 805               	.LVL41:
 806 0038 81E0      		ldi r24,lo8(1)
 807 003a 90E0      		ldi r25,0
 808 003c 022E      		mov r0,r18
 809 003e 00C0      		rjmp 2f
 810               		1:
 811 0040 880F      		lsl r24
 812               		2:
 813 0042 0A94      		dec r0
 814 0044 02F4      		brpl 1b
 815 0046 8095      		com r24
 816 0048 8323      		and r24,r19
 817 004a 8093 6D00 		sts 109,r24
 818               	.LVL42:
 819 004e 0895      		ret
 820               	.LVL43:
 821               	.L38:
 560:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         case 0:    PCMSK0 &= ~(((uint8_t)1)<<(rpin&0x3f)); break;
 822               		.loc 1 560 0
 823 0050 3091 6C00 		lds r19,108
 824 0054 2F73      		andi r18,lo8(63)
 825               	.LVL44:
 826 0056 81E0      		ldi r24,lo8(1)
 827 0058 90E0      		ldi r25,0
 828 005a 022E      		mov r0,r18
 829 005c 00C0      		rjmp 2f
 830               		1:
 831 005e 880F      		lsl r24
 832               		2:
 833 0060 0A94      		dec r0
 834 0062 02F4      		brpl 1b
 835 0064 8095      		com r24
 836 0066 8323      		and r24,r19
 837 0068 8093 6C00 		sts 108,r24
 838               	.LVL45:
 839 006c 0895      		ret
 840               	.LVL46:
 841               	.L36:
 842 006e 0895      		ret
 843               		.cfi_endproc
 844               	.LFE14:
 845               		.size	pcint_end, .-pcint_end
 846               		.section	.text.pcint_micros,"ax",@progbits
 847               	.global	pcint_micros
 848               		.type	pcint_micros, @function
GAS LISTING /tmp/ccOr00ZN.s 			page 26


 849               	pcint_micros:
 850               	.LFB15:
 562:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     }
 563:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
 564:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 565:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
 566:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Часть обработчика прерывания PCINT, измеряющая длител�
 567:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * выключает обработчик прерывания и изменяет статус с
 568:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
 569:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * @return ptrPulse(ptr)->res; -- state==PULSE_OK? pulse time in micros : not valid data.
 570:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
 571:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** void pcint_micros( void *ptr, uint8_t oldBit )
 572:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
 851               		.loc 1 572 0
 852               		.cfi_startproc
 853               	.LVL47:
 854 0000 0F93      		push r16
 855               	.LCFI12:
 856               		.cfi_def_cfa_offset 4
 857               		.cfi_offset 16, -3
 858 0002 1F93      		push r17
 859               	.LCFI13:
 860               		.cfi_def_cfa_offset 5
 861               		.cfi_offset 17, -4
 862 0004 CF93      		push r28
 863               	.LCFI14:
 864               		.cfi_def_cfa_offset 6
 865               		.cfi_offset 28, -5
 866 0006 DF93      		push r29
 867               	.LCFI15:
 868               		.cfi_def_cfa_offset 7
 869               		.cfi_offset 29, -6
 870               	/* prologue: function */
 871               	/* frame size = 0 */
 872               	/* stack size = 4 */
 873               	.L__stack_usage = 4
 874 0008 EC01      		movw r28,r24
 573:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     if( ptrPulse(ptr)->state == PULSE_BUSY )
 875               		.loc 1 573 0
 876 000a 8A85      		ldd r24,Y+10
 877               	.LVL48:
 878 000c 8130      		cpi r24,lo8(1)
 879 000e 01F4      		brne .L42
 574:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     {
 575:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         // first measuring! store current micros()
 576:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         ptrPulse(ptr)->res   = micros();
 880               		.loc 1 576 0
 881 0010 0E94 0000 		call time_micros
 882               	.LVL49:
 883 0014 6883      		st Y,r22
 884 0016 7983      		std Y+1,r23
 885 0018 8A83      		std Y+2,r24
 886 001a 9B83      		std Y+3,r25
 577:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         ptrPulse(ptr)->state = PULSE_SECOND;
 887               		.loc 1 577 0
 888 001c 82E0      		ldi r24,lo8(2)
 889 001e 8A87      		std Y+10,r24
GAS LISTING /tmp/ccOr00ZN.s 			page 27


 890               	/* epilogue start */
 578:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     } else {
 579:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         // second measuring or mistake: calc pulse time anyone:
 580:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         ptrPulse(ptr)->res = micros() - ptrPulse(ptr)->res;
 581:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 582:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         pcint_end(
 583:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****             ptrPulse(ptr)
 584:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****             , (ptrPulse(ptr)->state == PULSE_SECOND? PULSE_OK : PULSE_ERROR)
 585:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         );
 586:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     }
 587:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** }
 891               		.loc 1 587 0
 892 0020 DF91      		pop r29
 893 0022 CF91      		pop r28
 894               	.LVL50:
 895 0024 1F91      		pop r17
 896 0026 0F91      		pop r16
 897 0028 0895      		ret
 898               	.LVL51:
 899               	.L42:
 580:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 900               		.loc 1 580 0
 901 002a 0E94 0000 		call time_micros
 902               	.LVL52:
 903 002e 0881      		ld r16,Y
 904 0030 1981      		ldd r17,Y+1
 905 0032 2A81      		ldd r18,Y+2
 906 0034 3B81      		ldd r19,Y+3
 907 0036 601B      		sub r22,r16
 908 0038 710B      		sbc r23,r17
 909 003a 820B      		sbc r24,r18
 910 003c 930B      		sbc r25,r19
 911 003e 6883      		st Y,r22
 912 0040 7983      		std Y+1,r23
 913 0042 8A83      		std Y+2,r24
 914 0044 9B83      		std Y+3,r25
 582:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****             ptrPulse(ptr)
 915               		.loc 1 582 0
 916 0046 8A85      		ldd r24,Y+10
 917 0048 8230      		cpi r24,lo8(2)
 918 004a 01F4      		brne .L45
 919 004c 63E0      		ldi r22,lo8(3)
 920 004e 00C0      		rjmp .L44
 921               	.L45:
 922 0050 61E2      		ldi r22,lo8(33)
 923               	.L44:
 582:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****             ptrPulse(ptr)
 924               		.loc 1 582 0 is_stmt 0 discriminator 3
 925 0052 CE01      		movw r24,r28
 926               	/* epilogue start */
 927               		.loc 1 587 0 is_stmt 1 discriminator 3
 928 0054 DF91      		pop r29
 929 0056 CF91      		pop r28
 930               	.LVL53:
 931 0058 1F91      		pop r17
 932 005a 0F91      		pop r16
 582:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****             ptrPulse(ptr)
GAS LISTING /tmp/ccOr00ZN.s 			page 28


 933               		.loc 1 582 0 discriminator 3
 934 005c 0C94 0000 		jmp pcint_end
 935               	.LVL54:
 936               		.cfi_endproc
 937               	.LFE15:
 938               		.size	pcint_micros, .-pcint_micros
 939               		.section	.text.pcint_encoder,"ax",@progbits
 940               	.global	pcint_encoder
 941               		.type	pcint_encoder, @function
 942               	pcint_encoder:
 943               	.LFB16:
 588:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 589:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** /**
 590:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * Часть обработчика прерывания PCINT увеличивающая счет
 591:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * продолжает подсчет до истечения таймаута или по изм�
 592:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * также выключает обработчик самостоятельно. Только п
 593:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
 594:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * @param  uint8_t oldBit      -- предыдущее состояние ноги прерыван
 595:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  * @return ptrPulse(ptr)->res; -- число накопленных импульсов
 596:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  *
 597:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****  */
 598:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** void pcint_encoder( void *ptr, uint8_t oldBit )
 599:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** {
 944               		.loc 1 599 0
 945               		.cfi_startproc
 946               	.LVL55:
 947               	/* prologue: function */
 948               	/* frame size = 0 */
 949               	/* stack size = 0 */
 950               	.L__stack_usage = 0
 951 0000 262F      		mov r18,r22
 600:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     uint8_t addition;
 601:/home/arhat109/Arduino/libraries/Arhat/arhat.c **** 
 602:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     switch( ptrPulse(ptr)->state )
 952               		.loc 1 602 0
 953 0002 FC01      		movw r30,r24
 954 0004 6285      		ldd r22,Z+10
 955               	.LVL56:
 956 0006 6B30      		cpi r22,lo8(11)
 957 0008 01F0      		breq .L49
 958 000a 6C30      		cpi r22,lo8(12)
 959 000c 01F0      		breq .L50
 960 000e 6A30      		cpi r22,lo8(10)
 961 0010 01F4      		brne .L55
 603:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     {
 604:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         case PULSE_RAISING: addition = 1-(int8_t)oldBit; break;         // прирост если 
 962               		.loc 1 604 0
 963 0012 31E0      		ldi r19,lo8(1)
 964 0014 321B      		sub r19,r18
 965 0016 232F      		mov r18,r19
 966               	.LVL57:
 967 0018 00C0      		rjmp .L49
 968               	.LVL58:
 969               	.L55:
 605:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         case PULSE_FAILING: addition = oldBit;           break;         // только из 1 в 0
 606:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         case PULSE_BOTH:    addition = 1;                break;         // пофиг как был
 607:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         default:
GAS LISTING /tmp/ccOr00ZN.s 			page 29


 608:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****             // статус изменен извне: останов измерений без и�
 609:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****             pcint_end( ptrPulse(ptr), ptrPulse(ptr)->state);
 970               		.loc 1 609 0
 971 001a 0C94 0000 		jmp pcint_end
 972               	.LVL59:
 973               	.L50:
 606:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****         default:
 974               		.loc 1 606 0
 975 001e 21E0      		ldi r18,lo8(1)
 976               	.LVL60:
 977               	.L49:
 610:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****             return;
 611:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     }
 612:/home/arhat109/Arduino/libraries/Arhat/arhat.c ****     ptrPulse(ptr)->res += addition;
 978               		.loc 1 612 0
 979 0020 FC01      		movw r30,r24
 980 0022 4081      		ld r20,Z
 981 0024 5181      		ldd r21,Z+1
 982 0026 6281      		ldd r22,Z+2
 983 0028 7381      		ldd r23,Z+3
 984 002a 420F      		add r20,r18
 985 002c 511D      		adc r21,__zero_reg__
 986 002e 611D      		adc r22,__zero_reg__
 987 0030 711D      		adc r23,__zero_reg__
 988 0032 4083      		st Z,r20
 989 0034 5183      		std Z+1,r21
 990 0036 6283      		std Z+2,r22
 991 0038 7383      		std Z+3,r23
 992 003a 0895      		ret
 993               		.cfi_endproc
 994               	.LFE16:
 995               		.size	pcint_encoder, .-pcint_encoder
 996               	.global	timer0_hook_run
 997               		.section	.bss.timer0_hook_run,"aw",@nobits
 998               		.type	timer0_hook_run, @object
 999               		.size	timer0_hook_run, 1
 1000               	timer0_hook_run:
 1001 0000 00        		.zero	1
 1002               	.global	timer0_hook
 1003               		.section	.bss.timer0_hook,"aw",@nobits
 1004               		.type	timer0_hook, @object
 1005               		.size	timer0_hook, 2
 1006               	timer0_hook:
 1007 0000 0000      		.zero	2
 1008               	.global	timer0_overflow_count
 1009               		.section	.bss.timer0_overflow_count,"aw",@nobits
 1010               		.type	timer0_overflow_count, @object
 1011               		.size	timer0_overflow_count, 4
 1012               	timer0_overflow_count:
 1013 0000 0000 0000 		.zero	4
 1014               		.text
 1015               	.Letext0:
 1016               		.file 2 "/home/arhat109/progs/arduino-1.6.4/hardware/tools/avr/avr/include/stdint.h"
 1017               		.file 3 "/home/arhat109/Arduino/libraries/Arhat/arhat.h"
 1018               		.section	.debug_info,"",@progbits
 1019               	.Ldebug_info0:
 1020 0000 5205 0000 		.long	0x552
GAS LISTING /tmp/ccOr00ZN.s 			page 30


 1021 0004 0200      		.word	0x2
 1022 0006 0000 0000 		.long	.Ldebug_abbrev0
 1023 000a 04        		.byte	0x4
 1024 000b 01        		.uleb128 0x1
 1025 000c 0000 0000 		.long	.LASF52
 1026 0010 01        		.byte	0x1
 1027 0011 0000 0000 		.long	.LASF53
 1028 0015 0000 0000 		.long	.Ldebug_ranges0+0
 1029 0019 0000 0000 		.long	0
 1030 001d 0000 0000 		.long	0
 1031 0021 0000 0000 		.long	.Ldebug_line0
 1032 0025 02        		.uleb128 0x2
 1033 0026 0000 0000 		.long	.LASF0
 1034 002a 02        		.byte	0x2
 1035 002b 79        		.byte	0x79
 1036 002c 3000 0000 		.long	0x30
 1037 0030 03        		.uleb128 0x3
 1038 0031 01        		.byte	0x1
 1039 0032 06        		.byte	0x6
 1040 0033 0000 0000 		.long	.LASF2
 1041 0037 02        		.uleb128 0x2
 1042 0038 0000 0000 		.long	.LASF1
 1043 003c 02        		.byte	0x2
 1044 003d 7A        		.byte	0x7a
 1045 003e 4200 0000 		.long	0x42
 1046 0042 03        		.uleb128 0x3
 1047 0043 01        		.byte	0x1
 1048 0044 08        		.byte	0x8
 1049 0045 0000 0000 		.long	.LASF3
 1050 0049 04        		.uleb128 0x4
 1051 004a 02        		.byte	0x2
 1052 004b 05        		.byte	0x5
 1053 004c 696E 7400 		.string	"int"
 1054 0050 02        		.uleb128 0x2
 1055 0051 0000 0000 		.long	.LASF4
 1056 0055 02        		.byte	0x2
 1057 0056 7C        		.byte	0x7c
 1058 0057 5B00 0000 		.long	0x5b
 1059 005b 03        		.uleb128 0x3
 1060 005c 02        		.byte	0x2
 1061 005d 07        		.byte	0x7
 1062 005e 0000 0000 		.long	.LASF5
 1063 0062 03        		.uleb128 0x3
 1064 0063 04        		.byte	0x4
 1065 0064 05        		.byte	0x5
 1066 0065 0000 0000 		.long	.LASF6
 1067 0069 02        		.uleb128 0x2
 1068 006a 0000 0000 		.long	.LASF7
 1069 006e 02        		.byte	0x2
 1070 006f 7E        		.byte	0x7e
 1071 0070 7400 0000 		.long	0x74
 1072 0074 03        		.uleb128 0x3
 1073 0075 04        		.byte	0x4
 1074 0076 07        		.byte	0x7
 1075 0077 0000 0000 		.long	.LASF8
 1076 007b 03        		.uleb128 0x3
 1077 007c 08        		.byte	0x8
GAS LISTING /tmp/ccOr00ZN.s 			page 31


 1078 007d 05        		.byte	0x5
 1079 007e 0000 0000 		.long	.LASF9
 1080 0082 03        		.uleb128 0x3
 1081 0083 08        		.byte	0x8
 1082 0084 07        		.byte	0x7
 1083 0085 0000 0000 		.long	.LASF10
 1084 0089 05        		.uleb128 0x5
 1085 008a 0000 0000 		.long	.LASF11
 1086 008e 03        		.byte	0x3
 1087 008f B901      		.word	0x1b9
 1088 0091 9500 0000 		.long	0x95
 1089 0095 06        		.uleb128 0x6
 1090 0096 02        		.byte	0x2
 1091 0097 9B00 0000 		.long	0x9b
 1092 009b 07        		.uleb128 0x7
 1093 009c 01        		.byte	0x1
 1094 009d AC00 0000 		.long	0xac
 1095 00a1 08        		.uleb128 0x8
 1096 00a2 AC00 0000 		.long	0xac
 1097 00a6 08        		.uleb128 0x8
 1098 00a7 3700 0000 		.long	0x37
 1099 00ab 00        		.byte	0
 1100 00ac 09        		.uleb128 0x9
 1101 00ad 02        		.byte	0x2
 1102 00ae 0A        		.uleb128 0xa
 1103 00af 0C        		.byte	0xc
 1104 00b0 03        		.byte	0x3
 1105 00b1 BB01      		.word	0x1bb
 1106 00b3 1201 0000 		.long	0x112
 1107 00b7 0B        		.uleb128 0xb
 1108 00b8 7265 7300 		.string	"res"
 1109 00bc 03        		.byte	0x3
 1110 00bd BC01      		.word	0x1bc
 1111 00bf 6900 0000 		.long	0x69
 1112 00c3 02        		.byte	0x2
 1113 00c4 23        		.byte	0x23
 1114 00c5 00        		.uleb128 0
 1115 00c6 0C        		.uleb128 0xc
 1116 00c7 0000 0000 		.long	.LASF12
 1117 00cb 03        		.byte	0x3
 1118 00cc BD01      		.word	0x1bd
 1119 00ce 8900 0000 		.long	0x89
 1120 00d2 02        		.byte	0x2
 1121 00d3 23        		.byte	0x23
 1122 00d4 04        		.uleb128 0x4
 1123 00d5 0C        		.uleb128 0xc
 1124 00d6 0000 0000 		.long	.LASF13
 1125 00da 03        		.byte	0x3
 1126 00db BE01      		.word	0x1be
 1127 00dd 5000 0000 		.long	0x50
 1128 00e1 02        		.byte	0x2
 1129 00e2 23        		.byte	0x23
 1130 00e3 06        		.uleb128 0x6
 1131 00e4 0C        		.uleb128 0xc
 1132 00e5 0000 0000 		.long	.LASF14
 1133 00e9 03        		.byte	0x3
 1134 00ea BF01      		.word	0x1bf
GAS LISTING /tmp/ccOr00ZN.s 			page 32


 1135 00ec 5000 0000 		.long	0x50
 1136 00f0 02        		.byte	0x2
 1137 00f1 23        		.byte	0x23
 1138 00f2 08        		.uleb128 0x8
 1139 00f3 0C        		.uleb128 0xc
 1140 00f4 0000 0000 		.long	.LASF15
 1141 00f8 03        		.byte	0x3
 1142 00f9 C001      		.word	0x1c0
 1143 00fb 3700 0000 		.long	0x37
 1144 00ff 02        		.byte	0x2
 1145 0100 23        		.byte	0x23
 1146 0101 0A        		.uleb128 0xa
 1147 0102 0B        		.uleb128 0xb
 1148 0103 7069 6E00 		.string	"pin"
 1149 0107 03        		.byte	0x3
 1150 0108 C101      		.word	0x1c1
 1151 010a 3700 0000 		.long	0x37
 1152 010e 02        		.byte	0x2
 1153 010f 23        		.byte	0x23
 1154 0110 0B        		.uleb128 0xb
 1155 0111 00        		.byte	0
 1156 0112 05        		.uleb128 0x5
 1157 0113 0000 0000 		.long	.LASF16
 1158 0117 03        		.byte	0x3
 1159 0118 C201      		.word	0x1c2
 1160 011a AE00 0000 		.long	0xae
 1161 011e 05        		.uleb128 0x5
 1162 011f 0000 0000 		.long	.LASF17
 1163 0123 03        		.byte	0x3
 1164 0124 F401      		.word	0x1f4
 1165 0126 2A01 0000 		.long	0x12a
 1166 012a 06        		.uleb128 0x6
 1167 012b 02        		.byte	0x2
 1168 012c 3001 0000 		.long	0x130
 1169 0130 0D        		.uleb128 0xd
 1170 0131 01        		.byte	0x1
 1171 0132 0E        		.uleb128 0xe
 1172 0133 01        		.byte	0x1
 1173 0134 0000 0000 		.long	.LASF20
 1174 0138 01        		.byte	0x1
 1175 0139 2F        		.byte	0x2f
 1176 013a 01        		.byte	0x1
 1177 013b 6900 0000 		.long	0x69
 1178 013f 0000 0000 		.long	.LFB1
 1179 0143 0000 0000 		.long	.LFE1
 1180 0147 03        		.byte	0x3
 1181 0148 92        		.byte	0x92
 1182 0149 20        		.uleb128 0x20
 1183 014a 03        		.sleb128 3
 1184 014b 01        		.byte	0x1
 1185 014c 7601 0000 		.long	0x176
 1186 0150 0F        		.uleb128 0xf
 1187 0151 0000 0000 		.long	.LASF18
 1188 0155 01        		.byte	0x1
 1189 0156 31        		.byte	0x31
 1190 0157 3700 0000 		.long	0x37
 1191 015b 01        		.byte	0x1
GAS LISTING /tmp/ccOr00ZN.s 			page 33


 1192 015c 62        		.byte	0x62
 1193 015d 0F        		.uleb128 0xf
 1194 015e 0000 0000 		.long	.LASF19
 1195 0162 01        		.byte	0x1
 1196 0163 32        		.byte	0x32
 1197 0164 6900 0000 		.long	0x69
 1198 0168 0C        		.byte	0xc
 1199 0169 66        		.byte	0x66
 1200 016a 93        		.byte	0x93
 1201 016b 01        		.uleb128 0x1
 1202 016c 67        		.byte	0x67
 1203 016d 93        		.byte	0x93
 1204 016e 01        		.uleb128 0x1
 1205 016f 68        		.byte	0x68
 1206 0170 93        		.byte	0x93
 1207 0171 01        		.uleb128 0x1
 1208 0172 69        		.byte	0x69
 1209 0173 93        		.byte	0x93
 1210 0174 01        		.uleb128 0x1
 1211 0175 00        		.byte	0
 1212 0176 0E        		.uleb128 0xe
 1213 0177 01        		.byte	0x1
 1214 0178 0000 0000 		.long	.LASF21
 1215 017c 01        		.byte	0x1
 1216 017d 3F        		.byte	0x3f
 1217 017e 01        		.byte	0x1
 1218 017f 1E01 0000 		.long	0x11e
 1219 0183 0000 0000 		.long	.LFB2
 1220 0187 0000 0000 		.long	.LFE2
 1221 018b 03        		.byte	0x3
 1222 018c 92        		.byte	0x92
 1223 018d 20        		.uleb128 0x20
 1224 018e 03        		.sleb128 3
 1225 018f 01        		.byte	0x1
 1226 0190 C301 0000 		.long	0x1c3
 1227 0194 10        		.uleb128 0x10
 1228 0195 0000 0000 		.long	.LASF26
 1229 0199 01        		.byte	0x1
 1230 019a 3F        		.byte	0x3f
 1231 019b 1E01 0000 		.long	0x11e
 1232 019f 0000 0000 		.long	.LLST0
 1233 01a3 0F        		.uleb128 0xf
 1234 01a4 0000 0000 		.long	.LASF18
 1235 01a8 01        		.byte	0x1
 1236 01a9 41        		.byte	0x41
 1237 01aa 3700 0000 		.long	0x37
 1238 01ae 01        		.byte	0x1
 1239 01af 64        		.byte	0x64
 1240 01b0 0F        		.uleb128 0xf
 1241 01b1 0000 0000 		.long	.LASF22
 1242 01b5 01        		.byte	0x1
 1243 01b6 42        		.byte	0x42
 1244 01b7 1E01 0000 		.long	0x11e
 1245 01bb 06        		.byte	0x6
 1246 01bc 68        		.byte	0x68
 1247 01bd 93        		.byte	0x93
 1248 01be 01        		.uleb128 0x1
GAS LISTING /tmp/ccOr00ZN.s 			page 34


 1249 01bf 69        		.byte	0x69
 1250 01c0 93        		.byte	0x93
 1251 01c1 01        		.uleb128 0x1
 1252 01c2 00        		.byte	0
 1253 01c3 11        		.uleb128 0x11
 1254 01c4 01        		.byte	0x1
 1255 01c5 0000 0000 		.long	.LASF54
 1256 01c9 01        		.byte	0x1
 1257 01ca 50        		.byte	0x50
 1258 01cb 01        		.byte	0x1
 1259 01cc 6900 0000 		.long	0x69
 1260 01d0 0000 0000 		.long	.LFB3
 1261 01d4 0000 0000 		.long	.LFE3
 1262 01d8 03        		.byte	0x3
 1263 01d9 92        		.byte	0x92
 1264 01da 20        		.uleb128 0x20
 1265 01db 03        		.sleb128 3
 1266 01dc 01        		.byte	0x1
 1267 01dd 12        		.uleb128 0x12
 1268 01de 01        		.byte	0x1
 1269 01df 0000 0000 		.long	.LASF23
 1270 01e3 01        		.byte	0x1
 1271 01e4 9E        		.byte	0x9e
 1272 01e5 01        		.byte	0x1
 1273 01e6 6900 0000 		.long	0x69
 1274 01ea 0000 0000 		.long	.LFB4
 1275 01ee 0000 0000 		.long	.LFE4
 1276 01f2 0000 0000 		.long	.LLST1
 1277 01f6 01        		.byte	0x1
 1278 01f7 2902 0000 		.long	0x229
 1279 01fb 13        		.uleb128 0x13
 1280 01fc 0000 0000 		.long	.LASF24
 1281 0200 01        		.byte	0x1
 1282 0201 A0        		.byte	0xa0
 1283 0202 5000 0000 		.long	0x50
 1284 0206 0000 0000 		.long	.LLST2
 1285 020a 13        		.uleb128 0x13
 1286 020b 0000 0000 		.long	.LASF25
 1287 020f 01        		.byte	0x1
 1288 0210 A1        		.byte	0xa1
 1289 0211 3700 0000 		.long	0x37
 1290 0215 0000 0000 		.long	.LLST3
 1291 0219 14        		.uleb128 0x14
 1292 021a 746F 7600 		.string	"tov"
 1293 021e 01        		.byte	0x1
 1294 021f A1        		.byte	0xa1
 1295 0220 3700 0000 		.long	0x37
 1296 0224 0000 0000 		.long	.LLST4
 1297 0228 00        		.byte	0
 1298 0229 15        		.uleb128 0x15
 1299 022a 01        		.byte	0x1
 1300 022b 0000 0000 		.long	.LASF28
 1301 022f 01        		.byte	0x1
 1302 0230 B0        		.byte	0xb0
 1303 0231 01        		.byte	0x1
 1304 0232 0000 0000 		.long	.LFB5
 1305 0236 0000 0000 		.long	.LFE5
GAS LISTING /tmp/ccOr00ZN.s 			page 35


 1306 023a 0000 0000 		.long	.LLST5
 1307 023e 01        		.byte	0x1
 1308 023f 7402 0000 		.long	0x274
 1309 0243 10        		.uleb128 0x10
 1310 0244 0000 0000 		.long	.LASF27
 1311 0248 01        		.byte	0x1
 1312 0249 B0        		.byte	0xb0
 1313 024a 6900 0000 		.long	0x69
 1314 024e 0000 0000 		.long	.LLST6
 1315 0252 13        		.uleb128 0x13
 1316 0253 0000 0000 		.long	.LASF14
 1317 0257 01        		.byte	0x1
 1318 0258 B2        		.byte	0xb2
 1319 0259 5000 0000 		.long	0x50
 1320 025d 0000 0000 		.long	.LLST7
 1321 0261 16        		.uleb128 0x16
 1322 0262 0000 0000 		.long	.LVL14
 1323 0266 C301 0000 		.long	0x1c3
 1324 026a 16        		.uleb128 0x16
 1325 026b 0000 0000 		.long	.LVL16
 1326 026f C301 0000 		.long	0x1c3
 1327 0273 00        		.byte	0
 1328 0274 15        		.uleb128 0x15
 1329 0275 01        		.byte	0x1
 1330 0276 0000 0000 		.long	.LASF29
 1331 027a 01        		.byte	0x1
 1332 027b C0        		.byte	0xc0
 1333 027c 01        		.byte	0x1
 1334 027d 0000 0000 		.long	.LFB6
 1335 0281 0000 0000 		.long	.LFE6
 1336 0285 0000 0000 		.long	.LLST8
 1337 0289 01        		.byte	0x1
 1338 028a BF02 0000 		.long	0x2bf
 1339 028e 10        		.uleb128 0x10
 1340 028f 0000 0000 		.long	.LASF27
 1341 0293 01        		.byte	0x1
 1342 0294 C0        		.byte	0xc0
 1343 0295 5000 0000 		.long	0x50
 1344 0299 0000 0000 		.long	.LLST9
 1345 029d 13        		.uleb128 0x13
 1346 029e 0000 0000 		.long	.LASF14
 1347 02a2 01        		.byte	0x1
 1348 02a3 C2        		.byte	0xc2
 1349 02a4 5000 0000 		.long	0x50
 1350 02a8 0000 0000 		.long	.LLST10
 1351 02ac 16        		.uleb128 0x16
 1352 02ad 0000 0000 		.long	.LVL22
 1353 02b1 C301 0000 		.long	0x1c3
 1354 02b5 16        		.uleb128 0x16
 1355 02b6 0000 0000 		.long	.LVL24
 1356 02ba C301 0000 		.long	0x1c3
 1357 02be 00        		.byte	0
 1358 02bf 17        		.uleb128 0x17
 1359 02c0 01        		.byte	0x1
 1360 02c1 0000 0000 		.long	.LASF37
 1361 02c5 01        		.byte	0x1
 1362 02c6 D1        		.byte	0xd1
GAS LISTING /tmp/ccOr00ZN.s 			page 36


 1363 02c7 0000 0000 		.long	.LFB7
 1364 02cb 0000 0000 		.long	.LFE7
 1365 02cf 03        		.byte	0x3
 1366 02d0 92        		.byte	0x92
 1367 02d1 20        		.uleb128 0x20
 1368 02d2 03        		.sleb128 3
 1369 02d3 01        		.byte	0x1
 1370 02d4 18        		.uleb128 0x18
 1371 02d5 01        		.byte	0x1
 1372 02d6 0000 0000 		.long	.LASF30
 1373 02da 01        		.byte	0x1
 1374 02db 8601      		.word	0x186
 1375 02dd 01        		.byte	0x1
 1376 02de 5000 0000 		.long	0x50
 1377 02e2 0000 0000 		.long	.LFB9
 1378 02e6 0000 0000 		.long	.LFE9
 1379 02ea 03        		.byte	0x3
 1380 02eb 92        		.byte	0x92
 1381 02ec 20        		.uleb128 0x20
 1382 02ed 03        		.sleb128 3
 1383 02ee 01        		.byte	0x1
 1384 02ef 0403 0000 		.long	0x304
 1385 02f3 19        		.uleb128 0x19
 1386 02f4 0000 0000 		.long	.LASF31
 1387 02f8 01        		.byte	0x1
 1388 02f9 8601      		.word	0x186
 1389 02fb 3700 0000 		.long	0x37
 1390 02ff 0000 0000 		.long	.LLST11
 1391 0303 00        		.byte	0
 1392 0304 18        		.uleb128 0x18
 1393 0305 01        		.byte	0x1
 1394 0306 0000 0000 		.long	.LASF32
 1395 030a 01        		.byte	0x1
 1396 030b A001      		.word	0x1a0
 1397 030d 01        		.byte	0x1
 1398 030e 4200 0000 		.long	0x42
 1399 0312 0000 0000 		.long	.LFB10
 1400 0316 0000 0000 		.long	.LFE10
 1401 031a 03        		.byte	0x3
 1402 031b 92        		.byte	0x92
 1403 031c 20        		.uleb128 0x20
 1404 031d 03        		.sleb128 3
 1405 031e 01        		.byte	0x1
 1406 031f 3403 0000 		.long	0x334
 1407 0323 19        		.uleb128 0x19
 1408 0324 0000 0000 		.long	.LASF33
 1409 0328 01        		.byte	0x1
 1410 0329 A001      		.word	0x1a0
 1411 032b 5B00 0000 		.long	0x5b
 1412 032f 0000 0000 		.long	.LLST12
 1413 0333 00        		.byte	0
 1414 0334 1A        		.uleb128 0x1a
 1415 0335 01        		.byte	0x1
 1416 0336 0000 0000 		.long	.LASF34
 1417 033a 01        		.byte	0x1
 1418 033b A901      		.word	0x1a9
 1419 033d 01        		.byte	0x1
GAS LISTING /tmp/ccOr00ZN.s 			page 37


 1420 033e 0000 0000 		.long	.LFB11
 1421 0342 0000 0000 		.long	.LFE11
 1422 0346 03        		.byte	0x3
 1423 0347 92        		.byte	0x92
 1424 0348 20        		.uleb128 0x20
 1425 0349 03        		.sleb128 3
 1426 034a 01        		.byte	0x1
 1427 034b 7C03 0000 		.long	0x37c
 1428 034f 19        		.uleb128 0x19
 1429 0350 0000 0000 		.long	.LASF33
 1430 0354 01        		.byte	0x1
 1431 0355 A901      		.word	0x1a9
 1432 0357 5B00 0000 		.long	0x5b
 1433 035b 0000 0000 		.long	.LLST13
 1434 035f 1B        		.uleb128 0x1b
 1435 0360 0000 0000 		.long	.LASF35
 1436 0364 01        		.byte	0x1
 1437 0365 A901      		.word	0x1a9
 1438 0367 4200 0000 		.long	0x42
 1439 036b 01        		.byte	0x1
 1440 036c 66        		.byte	0x66
 1441 036d 1C        		.uleb128 0x1c
 1442 036e 0000 0000 		.long	.LASF36
 1443 0372 01        		.byte	0x1
 1444 0373 AF01      		.word	0x1af
 1445 0375 3700 0000 		.long	0x37
 1446 0379 01        		.byte	0x1
 1447 037a 68        		.byte	0x68
 1448 037b 00        		.byte	0
 1449 037c 1D        		.uleb128 0x1d
 1450 037d 01        		.byte	0x1
 1451 037e 0000 0000 		.long	.LASF38
 1452 0382 01        		.byte	0x1
 1453 0383 BE01      		.word	0x1be
 1454 0385 0000 0000 		.long	.LFB12
 1455 0389 0000 0000 		.long	.LFE12
 1456 038d 03        		.byte	0x3
 1457 038e 92        		.byte	0x92
 1458 038f 20        		.uleb128 0x20
 1459 0390 03        		.sleb128 3
 1460 0391 01        		.byte	0x1
 1461 0392 1D        		.uleb128 0x1d
 1462 0393 01        		.byte	0x1
 1463 0394 0000 0000 		.long	.LASF39
 1464 0398 01        		.byte	0x1
 1465 0399 F301      		.word	0x1f3
 1466 039b 0000 0000 		.long	.LFB13
 1467 039f 0000 0000 		.long	.LFE13
 1468 03a3 03        		.byte	0x3
 1469 03a4 92        		.byte	0x92
 1470 03a5 20        		.uleb128 0x20
 1471 03a6 03        		.sleb128 3
 1472 03a7 01        		.byte	0x1
 1473 03a8 1E        		.uleb128 0x1e
 1474 03a9 01        		.byte	0x1
 1475 03aa 0000 0000 		.long	.LASF40
 1476 03ae 01        		.byte	0x1
GAS LISTING /tmp/ccOr00ZN.s 			page 38


 1477 03af E8        		.byte	0xe8
 1478 03b0 01        		.byte	0x1
 1479 03b1 0000 0000 		.long	.LFB8
 1480 03b5 0000 0000 		.long	.LFE8
 1481 03b9 03        		.byte	0x3
 1482 03ba 92        		.byte	0x92
 1483 03bb 20        		.uleb128 0x20
 1484 03bc 03        		.sleb128 3
 1485 03bd 01        		.byte	0x1
 1486 03be 0704 0000 		.long	0x407
 1487 03c2 1F        		.uleb128 0x1f
 1488 03c3 0000 0000 		.long	.LBB2
 1489 03c7 0000 0000 		.long	.LBE2
 1490 03cb 20        		.uleb128 0x20
 1491 03cc 01        		.byte	0x1
 1492 03cd 0000 0000 		.long	.LASF38
 1493 03d1 01        		.byte	0x1
 1494 03d2 1F01      		.word	0x11f
 1495 03d4 4900 0000 		.long	0x49
 1496 03d8 01        		.byte	0x1
 1497 03d9 DF03 0000 		.long	0x3df
 1498 03dd 21        		.uleb128 0x21
 1499 03de 00        		.byte	0
 1500 03df 20        		.uleb128 0x20
 1501 03e0 01        		.byte	0x1
 1502 03e1 0000 0000 		.long	.LASF39
 1503 03e5 01        		.byte	0x1
 1504 03e6 2A01      		.word	0x12a
 1505 03e8 4900 0000 		.long	0x49
 1506 03ec 01        		.byte	0x1
 1507 03ed F303 0000 		.long	0x3f3
 1508 03f1 21        		.uleb128 0x21
 1509 03f2 00        		.byte	0
 1510 03f3 16        		.uleb128 0x16
 1511 03f4 0000 0000 		.long	.LVL35
 1512 03f8 7C03 0000 		.long	0x37c
 1513 03fc 16        		.uleb128 0x16
 1514 03fd 0000 0000 		.long	.LVL37
 1515 0401 9203 0000 		.long	0x392
 1516 0405 00        		.byte	0
 1517 0406 00        		.byte	0
 1518 0407 1A        		.uleb128 0x1a
 1519 0408 01        		.byte	0x1
 1520 0409 0000 0000 		.long	.LASF41
 1521 040d 01        		.byte	0x1
 1522 040e 2802      		.word	0x228
 1523 0410 01        		.byte	0x1
 1524 0411 0000 0000 		.long	.LFB14
 1525 0415 0000 0000 		.long	.LFE14
 1526 0419 03        		.byte	0x3
 1527 041a 92        		.byte	0x92
 1528 041b 20        		.uleb128 0x20
 1529 041c 03        		.sleb128 3
 1530 041d 01        		.byte	0x1
 1531 041e 5104 0000 		.long	0x451
 1532 0422 19        		.uleb128 0x19
 1533 0423 0000 0000 		.long	.LASF42
GAS LISTING /tmp/ccOr00ZN.s 			page 39


 1534 0427 01        		.byte	0x1
 1535 0428 2802      		.word	0x228
 1536 042a 5104 0000 		.long	0x451
 1537 042e 0000 0000 		.long	.LLST14
 1538 0432 1B        		.uleb128 0x1b
 1539 0433 0000 0000 		.long	.LASF43
 1540 0437 01        		.byte	0x1
 1541 0438 2802      		.word	0x228
 1542 043a 3700 0000 		.long	0x37
 1543 043e 01        		.byte	0x1
 1544 043f 66        		.byte	0x66
 1545 0440 22        		.uleb128 0x22
 1546 0441 0000 0000 		.long	.LASF44
 1547 0445 01        		.byte	0x1
 1548 0446 2A02      		.word	0x22a
 1549 0448 3700 0000 		.long	0x37
 1550 044c 0000 0000 		.long	.LLST15
 1551 0450 00        		.byte	0
 1552 0451 06        		.uleb128 0x6
 1553 0452 02        		.byte	0x2
 1554 0453 1201 0000 		.long	0x112
 1555 0457 23        		.uleb128 0x23
 1556 0458 01        		.byte	0x1
 1557 0459 0000 0000 		.long	.LASF45
 1558 045d 01        		.byte	0x1
 1559 045e 3B02      		.word	0x23b
 1560 0460 01        		.byte	0x1
 1561 0461 0000 0000 		.long	.LFB15
 1562 0465 0000 0000 		.long	.LFE15
 1563 0469 0000 0000 		.long	.LLST16
 1564 046d 01        		.byte	0x1
 1565 046e BC04 0000 		.long	0x4bc
 1566 0472 24        		.uleb128 0x24
 1567 0473 7074 7200 		.string	"ptr"
 1568 0477 01        		.byte	0x1
 1569 0478 3B02      		.word	0x23b
 1570 047a AC00 0000 		.long	0xac
 1571 047e 0000 0000 		.long	.LLST17
 1572 0482 19        		.uleb128 0x19
 1573 0483 0000 0000 		.long	.LASF46
 1574 0487 01        		.byte	0x1
 1575 0488 3B02      		.word	0x23b
 1576 048a 3700 0000 		.long	0x37
 1577 048e 0000 0000 		.long	.LLST18
 1578 0492 16        		.uleb128 0x16
 1579 0493 0000 0000 		.long	.LVL49
 1580 0497 C301 0000 		.long	0x1c3
 1581 049b 16        		.uleb128 0x16
 1582 049c 0000 0000 		.long	.LVL52
 1583 04a0 C301 0000 		.long	0x1c3
 1584 04a4 25        		.uleb128 0x25
 1585 04a5 0000 0000 		.long	.LVL54
 1586 04a9 01        		.byte	0x1
 1587 04aa 0704 0000 		.long	0x407
 1588 04ae 26        		.uleb128 0x26
 1589 04af 06        		.byte	0x6
 1590 04b0 68        		.byte	0x68
GAS LISTING /tmp/ccOr00ZN.s 			page 40


 1591 04b1 93        		.byte	0x93
 1592 04b2 01        		.uleb128 0x1
 1593 04b3 69        		.byte	0x69
 1594 04b4 93        		.byte	0x93
 1595 04b5 01        		.uleb128 0x1
 1596 04b6 03        		.byte	0x3
 1597 04b7 F3        		.byte	0xf3
 1598 04b8 01        		.uleb128 0x1
 1599 04b9 68        		.byte	0x68
 1600 04ba 00        		.byte	0
 1601 04bb 00        		.byte	0
 1602 04bc 1A        		.uleb128 0x1a
 1603 04bd 01        		.byte	0x1
 1604 04be 0000 0000 		.long	.LASF47
 1605 04c2 01        		.byte	0x1
 1606 04c3 5602      		.word	0x256
 1607 04c5 01        		.byte	0x1
 1608 04c6 0000 0000 		.long	.LFB16
 1609 04ca 0000 0000 		.long	.LFE16
 1610 04ce 03        		.byte	0x3
 1611 04cf 92        		.byte	0x92
 1612 04d0 20        		.uleb128 0x20
 1613 04d1 03        		.sleb128 3
 1614 04d2 01        		.byte	0x1
 1615 04d3 1205 0000 		.long	0x512
 1616 04d7 24        		.uleb128 0x24
 1617 04d8 7074 7200 		.string	"ptr"
 1618 04dc 01        		.byte	0x1
 1619 04dd 5602      		.word	0x256
 1620 04df AC00 0000 		.long	0xac
 1621 04e3 0000 0000 		.long	.LLST19
 1622 04e7 19        		.uleb128 0x19
 1623 04e8 0000 0000 		.long	.LASF46
 1624 04ec 01        		.byte	0x1
 1625 04ed 5602      		.word	0x256
 1626 04ef 3700 0000 		.long	0x37
 1627 04f3 0000 0000 		.long	.LLST20
 1628 04f7 22        		.uleb128 0x22
 1629 04f8 0000 0000 		.long	.LASF48
 1630 04fc 01        		.byte	0x1
 1631 04fd 5802      		.word	0x258
 1632 04ff 3700 0000 		.long	0x37
 1633 0503 0000 0000 		.long	.LLST21
 1634 0507 27        		.uleb128 0x27
 1635 0508 0000 0000 		.long	.LVL59
 1636 050c 01        		.byte	0x1
 1637 050d 0704 0000 		.long	0x407
 1638 0511 00        		.byte	0
 1639 0512 28        		.uleb128 0x28
 1640 0513 0000 0000 		.long	.LASF49
 1641 0517 01        		.byte	0x1
 1642 0518 27        		.byte	0x27
 1643 0519 2405 0000 		.long	0x524
 1644 051d 01        		.byte	0x1
 1645 051e 05        		.byte	0x5
 1646 051f 03        		.byte	0x3
 1647 0520 0000 0000 		.long	timer0_overflow_count
GAS LISTING /tmp/ccOr00ZN.s 			page 41


 1648 0524 29        		.uleb128 0x29
 1649 0525 6900 0000 		.long	0x69
 1650 0529 0D        		.uleb128 0xd
 1651 052a 01        		.byte	0x1
 1652 052b 28        		.uleb128 0x28
 1653 052c 0000 0000 		.long	.LASF50
 1654 0530 01        		.byte	0x1
 1655 0531 28        		.byte	0x28
 1656 0532 3D05 0000 		.long	0x53d
 1657 0536 01        		.byte	0x1
 1658 0537 05        		.byte	0x5
 1659 0538 03        		.byte	0x3
 1660 0539 0000 0000 		.long	timer0_hook
 1661 053d 06        		.uleb128 0x6
 1662 053e 02        		.byte	0x2
 1663 053f 2905 0000 		.long	0x529
 1664 0543 28        		.uleb128 0x28
 1665 0544 0000 0000 		.long	.LASF51
 1666 0548 01        		.byte	0x1
 1667 0549 29        		.byte	0x29
 1668 054a 3700 0000 		.long	0x37
 1669 054e 01        		.byte	0x1
 1670 054f 05        		.byte	0x5
 1671 0550 03        		.byte	0x3
 1672 0551 0000 0000 		.long	timer0_hook_run
 1673 0555 00        		.byte	0
 1674               		.section	.debug_abbrev,"",@progbits
 1675               	.Ldebug_abbrev0:
 1676 0000 01        		.uleb128 0x1
 1677 0001 11        		.uleb128 0x11
 1678 0002 01        		.byte	0x1
 1679 0003 25        		.uleb128 0x25
 1680 0004 0E        		.uleb128 0xe
 1681 0005 13        		.uleb128 0x13
 1682 0006 0B        		.uleb128 0xb
 1683 0007 03        		.uleb128 0x3
 1684 0008 0E        		.uleb128 0xe
 1685 0009 55        		.uleb128 0x55
 1686 000a 06        		.uleb128 0x6
 1687 000b 11        		.uleb128 0x11
 1688 000c 01        		.uleb128 0x1
 1689 000d 52        		.uleb128 0x52
 1690 000e 01        		.uleb128 0x1
 1691 000f 10        		.uleb128 0x10
 1692 0010 06        		.uleb128 0x6
 1693 0011 00        		.byte	0
 1694 0012 00        		.byte	0
 1695 0013 02        		.uleb128 0x2
 1696 0014 16        		.uleb128 0x16
 1697 0015 00        		.byte	0
 1698 0016 03        		.uleb128 0x3
 1699 0017 0E        		.uleb128 0xe
 1700 0018 3A        		.uleb128 0x3a
 1701 0019 0B        		.uleb128 0xb
 1702 001a 3B        		.uleb128 0x3b
 1703 001b 0B        		.uleb128 0xb
 1704 001c 49        		.uleb128 0x49
GAS LISTING /tmp/ccOr00ZN.s 			page 42


 1705 001d 13        		.uleb128 0x13
 1706 001e 00        		.byte	0
 1707 001f 00        		.byte	0
 1708 0020 03        		.uleb128 0x3
 1709 0021 24        		.uleb128 0x24
 1710 0022 00        		.byte	0
 1711 0023 0B        		.uleb128 0xb
 1712 0024 0B        		.uleb128 0xb
 1713 0025 3E        		.uleb128 0x3e
 1714 0026 0B        		.uleb128 0xb
 1715 0027 03        		.uleb128 0x3
 1716 0028 0E        		.uleb128 0xe
 1717 0029 00        		.byte	0
 1718 002a 00        		.byte	0
 1719 002b 04        		.uleb128 0x4
 1720 002c 24        		.uleb128 0x24
 1721 002d 00        		.byte	0
 1722 002e 0B        		.uleb128 0xb
 1723 002f 0B        		.uleb128 0xb
 1724 0030 3E        		.uleb128 0x3e
 1725 0031 0B        		.uleb128 0xb
 1726 0032 03        		.uleb128 0x3
 1727 0033 08        		.uleb128 0x8
 1728 0034 00        		.byte	0
 1729 0035 00        		.byte	0
 1730 0036 05        		.uleb128 0x5
 1731 0037 16        		.uleb128 0x16
 1732 0038 00        		.byte	0
 1733 0039 03        		.uleb128 0x3
 1734 003a 0E        		.uleb128 0xe
 1735 003b 3A        		.uleb128 0x3a
 1736 003c 0B        		.uleb128 0xb
 1737 003d 3B        		.uleb128 0x3b
 1738 003e 05        		.uleb128 0x5
 1739 003f 49        		.uleb128 0x49
 1740 0040 13        		.uleb128 0x13
 1741 0041 00        		.byte	0
 1742 0042 00        		.byte	0
 1743 0043 06        		.uleb128 0x6
 1744 0044 0F        		.uleb128 0xf
 1745 0045 00        		.byte	0
 1746 0046 0B        		.uleb128 0xb
 1747 0047 0B        		.uleb128 0xb
 1748 0048 49        		.uleb128 0x49
 1749 0049 13        		.uleb128 0x13
 1750 004a 00        		.byte	0
 1751 004b 00        		.byte	0
 1752 004c 07        		.uleb128 0x7
 1753 004d 15        		.uleb128 0x15
 1754 004e 01        		.byte	0x1
 1755 004f 27        		.uleb128 0x27
 1756 0050 0C        		.uleb128 0xc
 1757 0051 01        		.uleb128 0x1
 1758 0052 13        		.uleb128 0x13
 1759 0053 00        		.byte	0
 1760 0054 00        		.byte	0
 1761 0055 08        		.uleb128 0x8
GAS LISTING /tmp/ccOr00ZN.s 			page 43


 1762 0056 05        		.uleb128 0x5
 1763 0057 00        		.byte	0
 1764 0058 49        		.uleb128 0x49
 1765 0059 13        		.uleb128 0x13
 1766 005a 00        		.byte	0
 1767 005b 00        		.byte	0
 1768 005c 09        		.uleb128 0x9
 1769 005d 0F        		.uleb128 0xf
 1770 005e 00        		.byte	0
 1771 005f 0B        		.uleb128 0xb
 1772 0060 0B        		.uleb128 0xb
 1773 0061 00        		.byte	0
 1774 0062 00        		.byte	0
 1775 0063 0A        		.uleb128 0xa
 1776 0064 13        		.uleb128 0x13
 1777 0065 01        		.byte	0x1
 1778 0066 0B        		.uleb128 0xb
 1779 0067 0B        		.uleb128 0xb
 1780 0068 3A        		.uleb128 0x3a
 1781 0069 0B        		.uleb128 0xb
 1782 006a 3B        		.uleb128 0x3b
 1783 006b 05        		.uleb128 0x5
 1784 006c 01        		.uleb128 0x1
 1785 006d 13        		.uleb128 0x13
 1786 006e 00        		.byte	0
 1787 006f 00        		.byte	0
 1788 0070 0B        		.uleb128 0xb
 1789 0071 0D        		.uleb128 0xd
 1790 0072 00        		.byte	0
 1791 0073 03        		.uleb128 0x3
 1792 0074 08        		.uleb128 0x8
 1793 0075 3A        		.uleb128 0x3a
 1794 0076 0B        		.uleb128 0xb
 1795 0077 3B        		.uleb128 0x3b
 1796 0078 05        		.uleb128 0x5
 1797 0079 49        		.uleb128 0x49
 1798 007a 13        		.uleb128 0x13
 1799 007b 38        		.uleb128 0x38
 1800 007c 0A        		.uleb128 0xa
 1801 007d 00        		.byte	0
 1802 007e 00        		.byte	0
 1803 007f 0C        		.uleb128 0xc
 1804 0080 0D        		.uleb128 0xd
 1805 0081 00        		.byte	0
 1806 0082 03        		.uleb128 0x3
 1807 0083 0E        		.uleb128 0xe
 1808 0084 3A        		.uleb128 0x3a
 1809 0085 0B        		.uleb128 0xb
 1810 0086 3B        		.uleb128 0x3b
 1811 0087 05        		.uleb128 0x5
 1812 0088 49        		.uleb128 0x49
 1813 0089 13        		.uleb128 0x13
 1814 008a 38        		.uleb128 0x38
 1815 008b 0A        		.uleb128 0xa
 1816 008c 00        		.byte	0
 1817 008d 00        		.byte	0
 1818 008e 0D        		.uleb128 0xd
GAS LISTING /tmp/ccOr00ZN.s 			page 44


 1819 008f 15        		.uleb128 0x15
 1820 0090 00        		.byte	0
 1821 0091 27        		.uleb128 0x27
 1822 0092 0C        		.uleb128 0xc
 1823 0093 00        		.byte	0
 1824 0094 00        		.byte	0
 1825 0095 0E        		.uleb128 0xe
 1826 0096 2E        		.uleb128 0x2e
 1827 0097 01        		.byte	0x1
 1828 0098 3F        		.uleb128 0x3f
 1829 0099 0C        		.uleb128 0xc
 1830 009a 03        		.uleb128 0x3
 1831 009b 0E        		.uleb128 0xe
 1832 009c 3A        		.uleb128 0x3a
 1833 009d 0B        		.uleb128 0xb
 1834 009e 3B        		.uleb128 0x3b
 1835 009f 0B        		.uleb128 0xb
 1836 00a0 27        		.uleb128 0x27
 1837 00a1 0C        		.uleb128 0xc
 1838 00a2 49        		.uleb128 0x49
 1839 00a3 13        		.uleb128 0x13
 1840 00a4 11        		.uleb128 0x11
 1841 00a5 01        		.uleb128 0x1
 1842 00a6 12        		.uleb128 0x12
 1843 00a7 01        		.uleb128 0x1
 1844 00a8 40        		.uleb128 0x40
 1845 00a9 0A        		.uleb128 0xa
 1846 00aa 9742      		.uleb128 0x2117
 1847 00ac 0C        		.uleb128 0xc
 1848 00ad 01        		.uleb128 0x1
 1849 00ae 13        		.uleb128 0x13
 1850 00af 00        		.byte	0
 1851 00b0 00        		.byte	0
 1852 00b1 0F        		.uleb128 0xf
 1853 00b2 34        		.uleb128 0x34
 1854 00b3 00        		.byte	0
 1855 00b4 03        		.uleb128 0x3
 1856 00b5 0E        		.uleb128 0xe
 1857 00b6 3A        		.uleb128 0x3a
 1858 00b7 0B        		.uleb128 0xb
 1859 00b8 3B        		.uleb128 0x3b
 1860 00b9 0B        		.uleb128 0xb
 1861 00ba 49        		.uleb128 0x49
 1862 00bb 13        		.uleb128 0x13
 1863 00bc 02        		.uleb128 0x2
 1864 00bd 0A        		.uleb128 0xa
 1865 00be 00        		.byte	0
 1866 00bf 00        		.byte	0
 1867 00c0 10        		.uleb128 0x10
 1868 00c1 05        		.uleb128 0x5
 1869 00c2 00        		.byte	0
 1870 00c3 03        		.uleb128 0x3
 1871 00c4 0E        		.uleb128 0xe
 1872 00c5 3A        		.uleb128 0x3a
 1873 00c6 0B        		.uleb128 0xb
 1874 00c7 3B        		.uleb128 0x3b
 1875 00c8 0B        		.uleb128 0xb
GAS LISTING /tmp/ccOr00ZN.s 			page 45


 1876 00c9 49        		.uleb128 0x49
 1877 00ca 13        		.uleb128 0x13
 1878 00cb 02        		.uleb128 0x2
 1879 00cc 06        		.uleb128 0x6
 1880 00cd 00        		.byte	0
 1881 00ce 00        		.byte	0
 1882 00cf 11        		.uleb128 0x11
 1883 00d0 2E        		.uleb128 0x2e
 1884 00d1 00        		.byte	0
 1885 00d2 3F        		.uleb128 0x3f
 1886 00d3 0C        		.uleb128 0xc
 1887 00d4 03        		.uleb128 0x3
 1888 00d5 0E        		.uleb128 0xe
 1889 00d6 3A        		.uleb128 0x3a
 1890 00d7 0B        		.uleb128 0xb
 1891 00d8 3B        		.uleb128 0x3b
 1892 00d9 0B        		.uleb128 0xb
 1893 00da 27        		.uleb128 0x27
 1894 00db 0C        		.uleb128 0xc
 1895 00dc 49        		.uleb128 0x49
 1896 00dd 13        		.uleb128 0x13
 1897 00de 11        		.uleb128 0x11
 1898 00df 01        		.uleb128 0x1
 1899 00e0 12        		.uleb128 0x12
 1900 00e1 01        		.uleb128 0x1
 1901 00e2 40        		.uleb128 0x40
 1902 00e3 0A        		.uleb128 0xa
 1903 00e4 9742      		.uleb128 0x2117
 1904 00e6 0C        		.uleb128 0xc
 1905 00e7 00        		.byte	0
 1906 00e8 00        		.byte	0
 1907 00e9 12        		.uleb128 0x12
 1908 00ea 2E        		.uleb128 0x2e
 1909 00eb 01        		.byte	0x1
 1910 00ec 3F        		.uleb128 0x3f
 1911 00ed 0C        		.uleb128 0xc
 1912 00ee 03        		.uleb128 0x3
 1913 00ef 0E        		.uleb128 0xe
 1914 00f0 3A        		.uleb128 0x3a
 1915 00f1 0B        		.uleb128 0xb
 1916 00f2 3B        		.uleb128 0x3b
 1917 00f3 0B        		.uleb128 0xb
 1918 00f4 27        		.uleb128 0x27
 1919 00f5 0C        		.uleb128 0xc
 1920 00f6 49        		.uleb128 0x49
 1921 00f7 13        		.uleb128 0x13
 1922 00f8 11        		.uleb128 0x11
 1923 00f9 01        		.uleb128 0x1
 1924 00fa 12        		.uleb128 0x12
 1925 00fb 01        		.uleb128 0x1
 1926 00fc 40        		.uleb128 0x40
 1927 00fd 06        		.uleb128 0x6
 1928 00fe 9742      		.uleb128 0x2117
 1929 0100 0C        		.uleb128 0xc
 1930 0101 01        		.uleb128 0x1
 1931 0102 13        		.uleb128 0x13
 1932 0103 00        		.byte	0
GAS LISTING /tmp/ccOr00ZN.s 			page 46


 1933 0104 00        		.byte	0
 1934 0105 13        		.uleb128 0x13
 1935 0106 34        		.uleb128 0x34
 1936 0107 00        		.byte	0
 1937 0108 03        		.uleb128 0x3
 1938 0109 0E        		.uleb128 0xe
 1939 010a 3A        		.uleb128 0x3a
 1940 010b 0B        		.uleb128 0xb
 1941 010c 3B        		.uleb128 0x3b
 1942 010d 0B        		.uleb128 0xb
 1943 010e 49        		.uleb128 0x49
 1944 010f 13        		.uleb128 0x13
 1945 0110 02        		.uleb128 0x2
 1946 0111 06        		.uleb128 0x6
 1947 0112 00        		.byte	0
 1948 0113 00        		.byte	0
 1949 0114 14        		.uleb128 0x14
 1950 0115 34        		.uleb128 0x34
 1951 0116 00        		.byte	0
 1952 0117 03        		.uleb128 0x3
 1953 0118 08        		.uleb128 0x8
 1954 0119 3A        		.uleb128 0x3a
 1955 011a 0B        		.uleb128 0xb
 1956 011b 3B        		.uleb128 0x3b
 1957 011c 0B        		.uleb128 0xb
 1958 011d 49        		.uleb128 0x49
 1959 011e 13        		.uleb128 0x13
 1960 011f 02        		.uleb128 0x2
 1961 0120 06        		.uleb128 0x6
 1962 0121 00        		.byte	0
 1963 0122 00        		.byte	0
 1964 0123 15        		.uleb128 0x15
 1965 0124 2E        		.uleb128 0x2e
 1966 0125 01        		.byte	0x1
 1967 0126 3F        		.uleb128 0x3f
 1968 0127 0C        		.uleb128 0xc
 1969 0128 03        		.uleb128 0x3
 1970 0129 0E        		.uleb128 0xe
 1971 012a 3A        		.uleb128 0x3a
 1972 012b 0B        		.uleb128 0xb
 1973 012c 3B        		.uleb128 0x3b
 1974 012d 0B        		.uleb128 0xb
 1975 012e 27        		.uleb128 0x27
 1976 012f 0C        		.uleb128 0xc
 1977 0130 11        		.uleb128 0x11
 1978 0131 01        		.uleb128 0x1
 1979 0132 12        		.uleb128 0x12
 1980 0133 01        		.uleb128 0x1
 1981 0134 40        		.uleb128 0x40
 1982 0135 06        		.uleb128 0x6
 1983 0136 9742      		.uleb128 0x2117
 1984 0138 0C        		.uleb128 0xc
 1985 0139 01        		.uleb128 0x1
 1986 013a 13        		.uleb128 0x13
 1987 013b 00        		.byte	0
 1988 013c 00        		.byte	0
 1989 013d 16        		.uleb128 0x16
GAS LISTING /tmp/ccOr00ZN.s 			page 47


 1990 013e 8982 01   		.uleb128 0x4109
 1991 0141 00        		.byte	0
 1992 0142 11        		.uleb128 0x11
 1993 0143 01        		.uleb128 0x1
 1994 0144 31        		.uleb128 0x31
 1995 0145 13        		.uleb128 0x13
 1996 0146 00        		.byte	0
 1997 0147 00        		.byte	0
 1998 0148 17        		.uleb128 0x17
 1999 0149 2E        		.uleb128 0x2e
 2000 014a 00        		.byte	0
 2001 014b 3F        		.uleb128 0x3f
 2002 014c 0C        		.uleb128 0xc
 2003 014d 03        		.uleb128 0x3
 2004 014e 0E        		.uleb128 0xe
 2005 014f 3A        		.uleb128 0x3a
 2006 0150 0B        		.uleb128 0xb
 2007 0151 3B        		.uleb128 0x3b
 2008 0152 0B        		.uleb128 0xb
 2009 0153 11        		.uleb128 0x11
 2010 0154 01        		.uleb128 0x1
 2011 0155 12        		.uleb128 0x12
 2012 0156 01        		.uleb128 0x1
 2013 0157 40        		.uleb128 0x40
 2014 0158 0A        		.uleb128 0xa
 2015 0159 9742      		.uleb128 0x2117
 2016 015b 0C        		.uleb128 0xc
 2017 015c 00        		.byte	0
 2018 015d 00        		.byte	0
 2019 015e 18        		.uleb128 0x18
 2020 015f 2E        		.uleb128 0x2e
 2021 0160 01        		.byte	0x1
 2022 0161 3F        		.uleb128 0x3f
 2023 0162 0C        		.uleb128 0xc
 2024 0163 03        		.uleb128 0x3
 2025 0164 0E        		.uleb128 0xe
 2026 0165 3A        		.uleb128 0x3a
 2027 0166 0B        		.uleb128 0xb
 2028 0167 3B        		.uleb128 0x3b
 2029 0168 05        		.uleb128 0x5
 2030 0169 27        		.uleb128 0x27
 2031 016a 0C        		.uleb128 0xc
 2032 016b 49        		.uleb128 0x49
 2033 016c 13        		.uleb128 0x13
 2034 016d 11        		.uleb128 0x11
 2035 016e 01        		.uleb128 0x1
 2036 016f 12        		.uleb128 0x12
 2037 0170 01        		.uleb128 0x1
 2038 0171 40        		.uleb128 0x40
 2039 0172 0A        		.uleb128 0xa
 2040 0173 9742      		.uleb128 0x2117
 2041 0175 0C        		.uleb128 0xc
 2042 0176 01        		.uleb128 0x1
 2043 0177 13        		.uleb128 0x13
 2044 0178 00        		.byte	0
 2045 0179 00        		.byte	0
 2046 017a 19        		.uleb128 0x19
GAS LISTING /tmp/ccOr00ZN.s 			page 48


 2047 017b 05        		.uleb128 0x5
 2048 017c 00        		.byte	0
 2049 017d 03        		.uleb128 0x3
 2050 017e 0E        		.uleb128 0xe
 2051 017f 3A        		.uleb128 0x3a
 2052 0180 0B        		.uleb128 0xb
 2053 0181 3B        		.uleb128 0x3b
 2054 0182 05        		.uleb128 0x5
 2055 0183 49        		.uleb128 0x49
 2056 0184 13        		.uleb128 0x13
 2057 0185 02        		.uleb128 0x2
 2058 0186 06        		.uleb128 0x6
 2059 0187 00        		.byte	0
 2060 0188 00        		.byte	0
 2061 0189 1A        		.uleb128 0x1a
 2062 018a 2E        		.uleb128 0x2e
 2063 018b 01        		.byte	0x1
 2064 018c 3F        		.uleb128 0x3f
 2065 018d 0C        		.uleb128 0xc
 2066 018e 03        		.uleb128 0x3
 2067 018f 0E        		.uleb128 0xe
 2068 0190 3A        		.uleb128 0x3a
 2069 0191 0B        		.uleb128 0xb
 2070 0192 3B        		.uleb128 0x3b
 2071 0193 05        		.uleb128 0x5
 2072 0194 27        		.uleb128 0x27
 2073 0195 0C        		.uleb128 0xc
 2074 0196 11        		.uleb128 0x11
 2075 0197 01        		.uleb128 0x1
 2076 0198 12        		.uleb128 0x12
 2077 0199 01        		.uleb128 0x1
 2078 019a 40        		.uleb128 0x40
 2079 019b 0A        		.uleb128 0xa
 2080 019c 9742      		.uleb128 0x2117
 2081 019e 0C        		.uleb128 0xc
 2082 019f 01        		.uleb128 0x1
 2083 01a0 13        		.uleb128 0x13
 2084 01a1 00        		.byte	0
 2085 01a2 00        		.byte	0
 2086 01a3 1B        		.uleb128 0x1b
 2087 01a4 05        		.uleb128 0x5
 2088 01a5 00        		.byte	0
 2089 01a6 03        		.uleb128 0x3
 2090 01a7 0E        		.uleb128 0xe
 2091 01a8 3A        		.uleb128 0x3a
 2092 01a9 0B        		.uleb128 0xb
 2093 01aa 3B        		.uleb128 0x3b
 2094 01ab 05        		.uleb128 0x5
 2095 01ac 49        		.uleb128 0x49
 2096 01ad 13        		.uleb128 0x13
 2097 01ae 02        		.uleb128 0x2
 2098 01af 0A        		.uleb128 0xa
 2099 01b0 00        		.byte	0
 2100 01b1 00        		.byte	0
 2101 01b2 1C        		.uleb128 0x1c
 2102 01b3 34        		.uleb128 0x34
 2103 01b4 00        		.byte	0
GAS LISTING /tmp/ccOr00ZN.s 			page 49


 2104 01b5 03        		.uleb128 0x3
 2105 01b6 0E        		.uleb128 0xe
 2106 01b7 3A        		.uleb128 0x3a
 2107 01b8 0B        		.uleb128 0xb
 2108 01b9 3B        		.uleb128 0x3b
 2109 01ba 05        		.uleb128 0x5
 2110 01bb 49        		.uleb128 0x49
 2111 01bc 13        		.uleb128 0x13
 2112 01bd 02        		.uleb128 0x2
 2113 01be 0A        		.uleb128 0xa
 2114 01bf 00        		.byte	0
 2115 01c0 00        		.byte	0
 2116 01c1 1D        		.uleb128 0x1d
 2117 01c2 2E        		.uleb128 0x2e
 2118 01c3 00        		.byte	0
 2119 01c4 3F        		.uleb128 0x3f
 2120 01c5 0C        		.uleb128 0xc
 2121 01c6 03        		.uleb128 0x3
 2122 01c7 0E        		.uleb128 0xe
 2123 01c8 3A        		.uleb128 0x3a
 2124 01c9 0B        		.uleb128 0xb
 2125 01ca 3B        		.uleb128 0x3b
 2126 01cb 05        		.uleb128 0x5
 2127 01cc 11        		.uleb128 0x11
 2128 01cd 01        		.uleb128 0x1
 2129 01ce 12        		.uleb128 0x12
 2130 01cf 01        		.uleb128 0x1
 2131 01d0 40        		.uleb128 0x40
 2132 01d1 0A        		.uleb128 0xa
 2133 01d2 9742      		.uleb128 0x2117
 2134 01d4 0C        		.uleb128 0xc
 2135 01d5 00        		.byte	0
 2136 01d6 00        		.byte	0
 2137 01d7 1E        		.uleb128 0x1e
 2138 01d8 2E        		.uleb128 0x2e
 2139 01d9 01        		.byte	0x1
 2140 01da 3F        		.uleb128 0x3f
 2141 01db 0C        		.uleb128 0xc
 2142 01dc 03        		.uleb128 0x3
 2143 01dd 0E        		.uleb128 0xe
 2144 01de 3A        		.uleb128 0x3a
 2145 01df 0B        		.uleb128 0xb
 2146 01e0 3B        		.uleb128 0x3b
 2147 01e1 0B        		.uleb128 0xb
 2148 01e2 27        		.uleb128 0x27
 2149 01e3 0C        		.uleb128 0xc
 2150 01e4 11        		.uleb128 0x11
 2151 01e5 01        		.uleb128 0x1
 2152 01e6 12        		.uleb128 0x12
 2153 01e7 01        		.uleb128 0x1
 2154 01e8 40        		.uleb128 0x40
 2155 01e9 0A        		.uleb128 0xa
 2156 01ea 9642      		.uleb128 0x2116
 2157 01ec 0C        		.uleb128 0xc
 2158 01ed 01        		.uleb128 0x1
 2159 01ee 13        		.uleb128 0x13
 2160 01ef 00        		.byte	0
GAS LISTING /tmp/ccOr00ZN.s 			page 50


 2161 01f0 00        		.byte	0
 2162 01f1 1F        		.uleb128 0x1f
 2163 01f2 0B        		.uleb128 0xb
 2164 01f3 01        		.byte	0x1
 2165 01f4 11        		.uleb128 0x11
 2166 01f5 01        		.uleb128 0x1
 2167 01f6 12        		.uleb128 0x12
 2168 01f7 01        		.uleb128 0x1
 2169 01f8 00        		.byte	0
 2170 01f9 00        		.byte	0
 2171 01fa 20        		.uleb128 0x20
 2172 01fb 2E        		.uleb128 0x2e
 2173 01fc 01        		.byte	0x1
 2174 01fd 3F        		.uleb128 0x3f
 2175 01fe 0C        		.uleb128 0xc
 2176 01ff 03        		.uleb128 0x3
 2177 0200 0E        		.uleb128 0xe
 2178 0201 3A        		.uleb128 0x3a
 2179 0202 0B        		.uleb128 0xb
 2180 0203 3B        		.uleb128 0x3b
 2181 0204 05        		.uleb128 0x5
 2182 0205 49        		.uleb128 0x49
 2183 0206 13        		.uleb128 0x13
 2184 0207 3C        		.uleb128 0x3c
 2185 0208 0C        		.uleb128 0xc
 2186 0209 01        		.uleb128 0x1
 2187 020a 13        		.uleb128 0x13
 2188 020b 00        		.byte	0
 2189 020c 00        		.byte	0
 2190 020d 21        		.uleb128 0x21
 2191 020e 18        		.uleb128 0x18
 2192 020f 00        		.byte	0
 2193 0210 00        		.byte	0
 2194 0211 00        		.byte	0
 2195 0212 22        		.uleb128 0x22
 2196 0213 34        		.uleb128 0x34
 2197 0214 00        		.byte	0
 2198 0215 03        		.uleb128 0x3
 2199 0216 0E        		.uleb128 0xe
 2200 0217 3A        		.uleb128 0x3a
 2201 0218 0B        		.uleb128 0xb
 2202 0219 3B        		.uleb128 0x3b
 2203 021a 05        		.uleb128 0x5
 2204 021b 49        		.uleb128 0x49
 2205 021c 13        		.uleb128 0x13
 2206 021d 02        		.uleb128 0x2
 2207 021e 06        		.uleb128 0x6
 2208 021f 00        		.byte	0
 2209 0220 00        		.byte	0
 2210 0221 23        		.uleb128 0x23
 2211 0222 2E        		.uleb128 0x2e
 2212 0223 01        		.byte	0x1
 2213 0224 3F        		.uleb128 0x3f
 2214 0225 0C        		.uleb128 0xc
 2215 0226 03        		.uleb128 0x3
 2216 0227 0E        		.uleb128 0xe
 2217 0228 3A        		.uleb128 0x3a
GAS LISTING /tmp/ccOr00ZN.s 			page 51


 2218 0229 0B        		.uleb128 0xb
 2219 022a 3B        		.uleb128 0x3b
 2220 022b 05        		.uleb128 0x5
 2221 022c 27        		.uleb128 0x27
 2222 022d 0C        		.uleb128 0xc
 2223 022e 11        		.uleb128 0x11
 2224 022f 01        		.uleb128 0x1
 2225 0230 12        		.uleb128 0x12
 2226 0231 01        		.uleb128 0x1
 2227 0232 40        		.uleb128 0x40
 2228 0233 06        		.uleb128 0x6
 2229 0234 9742      		.uleb128 0x2117
 2230 0236 0C        		.uleb128 0xc
 2231 0237 01        		.uleb128 0x1
 2232 0238 13        		.uleb128 0x13
 2233 0239 00        		.byte	0
 2234 023a 00        		.byte	0
 2235 023b 24        		.uleb128 0x24
 2236 023c 05        		.uleb128 0x5
 2237 023d 00        		.byte	0
 2238 023e 03        		.uleb128 0x3
 2239 023f 08        		.uleb128 0x8
 2240 0240 3A        		.uleb128 0x3a
 2241 0241 0B        		.uleb128 0xb
 2242 0242 3B        		.uleb128 0x3b
 2243 0243 05        		.uleb128 0x5
 2244 0244 49        		.uleb128 0x49
 2245 0245 13        		.uleb128 0x13
 2246 0246 02        		.uleb128 0x2
 2247 0247 06        		.uleb128 0x6
 2248 0248 00        		.byte	0
 2249 0249 00        		.byte	0
 2250 024a 25        		.uleb128 0x25
 2251 024b 8982 01   		.uleb128 0x4109
 2252 024e 01        		.byte	0x1
 2253 024f 11        		.uleb128 0x11
 2254 0250 01        		.uleb128 0x1
 2255 0251 9542      		.uleb128 0x2115
 2256 0253 0C        		.uleb128 0xc
 2257 0254 31        		.uleb128 0x31
 2258 0255 13        		.uleb128 0x13
 2259 0256 00        		.byte	0
 2260 0257 00        		.byte	0
 2261 0258 26        		.uleb128 0x26
 2262 0259 8A82 01   		.uleb128 0x410a
 2263 025c 00        		.byte	0
 2264 025d 02        		.uleb128 0x2
 2265 025e 0A        		.uleb128 0xa
 2266 025f 9142      		.uleb128 0x2111
 2267 0261 0A        		.uleb128 0xa
 2268 0262 00        		.byte	0
 2269 0263 00        		.byte	0
 2270 0264 27        		.uleb128 0x27
 2271 0265 8982 01   		.uleb128 0x4109
 2272 0268 00        		.byte	0
 2273 0269 11        		.uleb128 0x11
 2274 026a 01        		.uleb128 0x1
GAS LISTING /tmp/ccOr00ZN.s 			page 52


 2275 026b 9542      		.uleb128 0x2115
 2276 026d 0C        		.uleb128 0xc
 2277 026e 31        		.uleb128 0x31
 2278 026f 13        		.uleb128 0x13
 2279 0270 00        		.byte	0
 2280 0271 00        		.byte	0
 2281 0272 28        		.uleb128 0x28
 2282 0273 34        		.uleb128 0x34
 2283 0274 00        		.byte	0
 2284 0275 03        		.uleb128 0x3
 2285 0276 0E        		.uleb128 0xe
 2286 0277 3A        		.uleb128 0x3a
 2287 0278 0B        		.uleb128 0xb
 2288 0279 3B        		.uleb128 0x3b
 2289 027a 0B        		.uleb128 0xb
 2290 027b 49        		.uleb128 0x49
 2291 027c 13        		.uleb128 0x13
 2292 027d 3F        		.uleb128 0x3f
 2293 027e 0C        		.uleb128 0xc
 2294 027f 02        		.uleb128 0x2
 2295 0280 0A        		.uleb128 0xa
 2296 0281 00        		.byte	0
 2297 0282 00        		.byte	0
 2298 0283 29        		.uleb128 0x29
 2299 0284 35        		.uleb128 0x35
 2300 0285 00        		.byte	0
 2301 0286 49        		.uleb128 0x49
 2302 0287 13        		.uleb128 0x13
 2303 0288 00        		.byte	0
 2304 0289 00        		.byte	0
 2305 028a 00        		.byte	0
 2306               		.section	.debug_loc,"",@progbits
 2307               	.Ldebug_loc0:
 2308               	.LLST0:
 2309 0000 0000 0000 		.long	.LVL2
 2310 0004 0000 0000 		.long	.LVL4
 2311 0008 0600      		.word	0x6
 2312 000a 68        		.byte	0x68
 2313 000b 93        		.byte	0x93
 2314 000c 01        		.uleb128 0x1
 2315 000d 69        		.byte	0x69
 2316 000e 93        		.byte	0x93
 2317 000f 01        		.uleb128 0x1
 2318 0010 0000 0000 		.long	.LVL4
 2319 0014 0000 0000 		.long	.LFE2
 2320 0018 0600      		.word	0x6
 2321 001a 62        		.byte	0x62
 2322 001b 93        		.byte	0x93
 2323 001c 01        		.uleb128 0x1
 2324 001d 63        		.byte	0x63
 2325 001e 93        		.byte	0x93
 2326 001f 01        		.uleb128 0x1
 2327 0020 0000 0000 		.long	0
 2328 0024 0000 0000 		.long	0
 2329               	.LLST1:
 2330 0028 0000 0000 		.long	.LFB4
 2331 002c 0000 0000 		.long	.LCFI0
GAS LISTING /tmp/ccOr00ZN.s 			page 53


 2332 0030 0300      		.word	0x3
 2333 0032 92        		.byte	0x92
 2334 0033 20        		.uleb128 0x20
 2335 0034 03        		.sleb128 3
 2336 0035 0000 0000 		.long	.LCFI0
 2337 0039 0000 0000 		.long	.LCFI1
 2338 003d 0300      		.word	0x3
 2339 003f 92        		.byte	0x92
 2340 0040 20        		.uleb128 0x20
 2341 0041 04        		.sleb128 4
 2342 0042 0000 0000 		.long	.LCFI1
 2343 0046 0000 0000 		.long	.LFE4
 2344 004a 0300      		.word	0x3
 2345 004c 92        		.byte	0x92
 2346 004d 20        		.uleb128 0x20
 2347 004e 05        		.sleb128 5
 2348 004f 0000 0000 		.long	0
 2349 0053 0000 0000 		.long	0
 2350               	.LLST2:
 2351 0057 0000 0000 		.long	.LVL6
 2352 005b 0000 0000 		.long	.LVL8
 2353 005f 0600      		.word	0x6
 2354 0061 8D        		.byte	0x8d
 2355 0062 00        		.sleb128 0
 2356 0063 08        		.byte	0x8
 2357 0064 FF        		.byte	0xff
 2358 0065 1A        		.byte	0x1a
 2359 0066 9F        		.byte	0x9f
 2360 0067 0000 0000 		.long	.LVL8
 2361 006b 0000 0000 		.long	.LVL11
 2362 006f 0800      		.word	0x8
 2363 0071 8D        		.byte	0x8d
 2364 0072 00        		.sleb128 0
 2365 0073 08        		.byte	0x8
 2366 0074 FF        		.byte	0xff
 2367 0075 1A        		.byte	0x1a
 2368 0076 32        		.byte	0x32
 2369 0077 24        		.byte	0x24
 2370 0078 9F        		.byte	0x9f
 2371 0079 0000 0000 		.long	0
 2372 007d 0000 0000 		.long	0
 2373               	.LLST3:
 2374 0081 0000 0000 		.long	.LVL5
 2375 0085 0000 0000 		.long	.LVL10
 2376 0089 0100      		.word	0x1
 2377 008b 68        		.byte	0x68
 2378 008c 0000 0000 		.long	.LVL10
 2379 0090 0000 0000 		.long	.LFE4
 2380 0094 0200      		.word	0x2
 2381 0096 08        		.byte	0x8
 2382 0097 5F        		.byte	0x5f
 2383 0098 0000 0000 		.long	0
 2384 009c 0000 0000 		.long	0
 2385               	.LLST4:
 2386 00a0 0000 0000 		.long	.LVL5
 2387 00a4 0000 0000 		.long	.LVL7
 2388 00a8 0200      		.word	0x2
GAS LISTING /tmp/ccOr00ZN.s 			page 54


 2389 00aa 30        		.byte	0x30
 2390 00ab 9F        		.byte	0x9f
 2391 00ac 0000 0000 		.long	.LVL7
 2392 00b0 0000 0000 		.long	.LVL9
 2393 00b4 0500      		.word	0x5
 2394 00b6 8C        		.byte	0x8c
 2395 00b7 00        		.sleb128 0
 2396 00b8 31        		.byte	0x31
 2397 00b9 1A        		.byte	0x1a
 2398 00ba 9F        		.byte	0x9f
 2399 00bb 0000 0000 		.long	.LVL9
 2400 00bf 0000 0000 		.long	.LVL12
 2401 00c3 0100      		.word	0x1
 2402 00c5 6C        		.byte	0x6c
 2403 00c6 0000 0000 		.long	0
 2404 00ca 0000 0000 		.long	0
 2405               	.LLST5:
 2406 00ce 0000 0000 		.long	.LFB5
 2407 00d2 0000 0000 		.long	.LCFI2
 2408 00d6 0300      		.word	0x3
 2409 00d8 92        		.byte	0x92
 2410 00d9 20        		.uleb128 0x20
 2411 00da 03        		.sleb128 3
 2412 00db 0000 0000 		.long	.LCFI2
 2413 00df 0000 0000 		.long	.LCFI3
 2414 00e3 0300      		.word	0x3
 2415 00e5 92        		.byte	0x92
 2416 00e6 20        		.uleb128 0x20
 2417 00e7 04        		.sleb128 4
 2418 00e8 0000 0000 		.long	.LCFI3
 2419 00ec 0000 0000 		.long	.LCFI4
 2420 00f0 0300      		.word	0x3
 2421 00f2 92        		.byte	0x92
 2422 00f3 20        		.uleb128 0x20
 2423 00f4 05        		.sleb128 5
 2424 00f5 0000 0000 		.long	.LCFI4
 2425 00f9 0000 0000 		.long	.LCFI5
 2426 00fd 0300      		.word	0x3
 2427 00ff 92        		.byte	0x92
 2428 0100 20        		.uleb128 0x20
 2429 0101 06        		.sleb128 6
 2430 0102 0000 0000 		.long	.LCFI5
 2431 0106 0000 0000 		.long	.LCFI6
 2432 010a 0300      		.word	0x3
 2433 010c 92        		.byte	0x92
 2434 010d 20        		.uleb128 0x20
 2435 010e 07        		.sleb128 7
 2436 010f 0000 0000 		.long	.LCFI6
 2437 0113 0000 0000 		.long	.LCFI7
 2438 0117 0300      		.word	0x3
 2439 0119 92        		.byte	0x92
 2440 011a 20        		.uleb128 0x20
 2441 011b 08        		.sleb128 8
 2442 011c 0000 0000 		.long	.LCFI7
 2443 0120 0000 0000 		.long	.LFE5
 2444 0124 0300      		.word	0x3
 2445 0126 92        		.byte	0x92
GAS LISTING /tmp/ccOr00ZN.s 			page 55


 2446 0127 20        		.uleb128 0x20
 2447 0128 09        		.sleb128 9
 2448 0129 0000 0000 		.long	0
 2449 012d 0000 0000 		.long	0
 2450               	.LLST6:
 2451 0131 0000 0000 		.long	.LVL13
 2452 0135 0000 0000 		.long	.LVL14-1
 2453 0139 0C00      		.word	0xc
 2454 013b 66        		.byte	0x66
 2455 013c 93        		.byte	0x93
 2456 013d 01        		.uleb128 0x1
 2457 013e 67        		.byte	0x67
 2458 013f 93        		.byte	0x93
 2459 0140 01        		.uleb128 0x1
 2460 0141 68        		.byte	0x68
 2461 0142 93        		.byte	0x93
 2462 0143 01        		.uleb128 0x1
 2463 0144 69        		.byte	0x69
 2464 0145 93        		.byte	0x93
 2465 0146 01        		.uleb128 0x1
 2466 0147 0000 0000 		.long	.LVL14-1
 2467 014b 0000 0000 		.long	.LVL20
 2468 014f 0C00      		.word	0xc
 2469 0151 5C        		.byte	0x5c
 2470 0152 93        		.byte	0x93
 2471 0153 01        		.uleb128 0x1
 2472 0154 5D        		.byte	0x5d
 2473 0155 93        		.byte	0x93
 2474 0156 01        		.uleb128 0x1
 2475 0157 5E        		.byte	0x5e
 2476 0158 93        		.byte	0x93
 2477 0159 01        		.uleb128 0x1
 2478 015a 5F        		.byte	0x5f
 2479 015b 93        		.byte	0x93
 2480 015c 01        		.uleb128 0x1
 2481 015d 0000 0000 		.long	0
 2482 0161 0000 0000 		.long	0
 2483               	.LLST7:
 2484 0165 0000 0000 		.long	.LVL15
 2485 0169 0000 0000 		.long	.LVL19
 2486 016d 0600      		.word	0x6
 2487 016f 6C        		.byte	0x6c
 2488 0170 93        		.byte	0x93
 2489 0171 01        		.uleb128 0x1
 2490 0172 6D        		.byte	0x6d
 2491 0173 93        		.byte	0x93
 2492 0174 01        		.uleb128 0x1
 2493 0175 0000 0000 		.long	0
 2494 0179 0000 0000 		.long	0
 2495               	.LLST8:
 2496 017d 0000 0000 		.long	.LFB6
 2497 0181 0000 0000 		.long	.LCFI8
 2498 0185 0300      		.word	0x3
 2499 0187 92        		.byte	0x92
 2500 0188 20        		.uleb128 0x20
 2501 0189 03        		.sleb128 3
 2502 018a 0000 0000 		.long	.LCFI8
GAS LISTING /tmp/ccOr00ZN.s 			page 56


 2503 018e 0000 0000 		.long	.LCFI9
 2504 0192 0300      		.word	0x3
 2505 0194 92        		.byte	0x92
 2506 0195 20        		.uleb128 0x20
 2507 0196 04        		.sleb128 4
 2508 0197 0000 0000 		.long	.LCFI9
 2509 019b 0000 0000 		.long	.LCFI10
 2510 019f 0300      		.word	0x3
 2511 01a1 92        		.byte	0x92
 2512 01a2 20        		.uleb128 0x20
 2513 01a3 05        		.sleb128 5
 2514 01a4 0000 0000 		.long	.LCFI10
 2515 01a8 0000 0000 		.long	.LCFI11
 2516 01ac 0300      		.word	0x3
 2517 01ae 92        		.byte	0x92
 2518 01af 20        		.uleb128 0x20
 2519 01b0 06        		.sleb128 6
 2520 01b1 0000 0000 		.long	.LCFI11
 2521 01b5 0000 0000 		.long	.LFE6
 2522 01b9 0300      		.word	0x3
 2523 01bb 92        		.byte	0x92
 2524 01bc 20        		.uleb128 0x20
 2525 01bd 07        		.sleb128 7
 2526 01be 0000 0000 		.long	0
 2527 01c2 0000 0000 		.long	0
 2528               	.LLST9:
 2529 01c6 0000 0000 		.long	.LVL21
 2530 01ca 0000 0000 		.long	.LVL22-1
 2531 01ce 0600      		.word	0x6
 2532 01d0 68        		.byte	0x68
 2533 01d1 93        		.byte	0x93
 2534 01d2 01        		.uleb128 0x1
 2535 01d3 69        		.byte	0x69
 2536 01d4 93        		.byte	0x93
 2537 01d5 01        		.uleb128 0x1
 2538 01d6 0000 0000 		.long	.LVL22-1
 2539 01da 0000 0000 		.long	.LVL27
 2540 01de 0600      		.word	0x6
 2541 01e0 6C        		.byte	0x6c
 2542 01e1 93        		.byte	0x93
 2543 01e2 01        		.uleb128 0x1
 2544 01e3 6D        		.byte	0x6d
 2545 01e4 93        		.byte	0x93
 2546 01e5 01        		.uleb128 0x1
 2547 01e6 0000 0000 		.long	0
 2548 01ea 0000 0000 		.long	0
 2549               	.LLST10:
 2550 01ee 0000 0000 		.long	.LVL23
 2551 01f2 0000 0000 		.long	.LVL28
 2552 01f6 0600      		.word	0x6
 2553 01f8 60        		.byte	0x60
 2554 01f9 93        		.byte	0x93
 2555 01fa 01        		.uleb128 0x1
 2556 01fb 61        		.byte	0x61
 2557 01fc 93        		.byte	0x93
 2558 01fd 01        		.uleb128 0x1
 2559 01fe 0000 0000 		.long	0
GAS LISTING /tmp/ccOr00ZN.s 			page 57


 2560 0202 0000 0000 		.long	0
 2561               	.LLST11:
 2562 0206 0000 0000 		.long	.LVL29
 2563 020a 0000 0000 		.long	.LVL30
 2564 020e 0100      		.word	0x1
 2565 0210 68        		.byte	0x68
 2566 0211 0000 0000 		.long	.LVL30
 2567 0215 0000 0000 		.long	.LFE9
 2568 0219 0400      		.word	0x4
 2569 021b F3        		.byte	0xf3
 2570 021c 01        		.uleb128 0x1
 2571 021d 68        		.byte	0x68
 2572 021e 9F        		.byte	0x9f
 2573 021f 0000 0000 		.long	0
 2574 0223 0000 0000 		.long	0
 2575               	.LLST12:
 2576 0227 0000 0000 		.long	.LVL31
 2577 022b 0000 0000 		.long	.LVL32
 2578 022f 0600      		.word	0x6
 2579 0231 68        		.byte	0x68
 2580 0232 93        		.byte	0x93
 2581 0233 01        		.uleb128 0x1
 2582 0234 69        		.byte	0x69
 2583 0235 93        		.byte	0x93
 2584 0236 01        		.uleb128 0x1
 2585 0237 0000 0000 		.long	.LVL32
 2586 023b 0000 0000 		.long	.LFE10
 2587 023f 0400      		.word	0x4
 2588 0241 F3        		.byte	0xf3
 2589 0242 01        		.uleb128 0x1
 2590 0243 68        		.byte	0x68
 2591 0244 9F        		.byte	0x9f
 2592 0245 0000 0000 		.long	0
 2593 0249 0000 0000 		.long	0
 2594               	.LLST13:
 2595 024d 0000 0000 		.long	.LVL33
 2596 0251 0000 0000 		.long	.LVL34
 2597 0255 0600      		.word	0x6
 2598 0257 68        		.byte	0x68
 2599 0258 93        		.byte	0x93
 2600 0259 01        		.uleb128 0x1
 2601 025a 69        		.byte	0x69
 2602 025b 93        		.byte	0x93
 2603 025c 01        		.uleb128 0x1
 2604 025d 0000 0000 		.long	.LVL34
 2605 0261 0000 0000 		.long	.LFE11
 2606 0265 0400      		.word	0x4
 2607 0267 F3        		.byte	0xf3
 2608 0268 01        		.uleb128 0x1
 2609 0269 68        		.byte	0x68
 2610 026a 9F        		.byte	0x9f
 2611 026b 0000 0000 		.long	0
 2612 026f 0000 0000 		.long	0
 2613               	.LLST14:
 2614 0273 0000 0000 		.long	.LVL38
 2615 0277 0000 0000 		.long	.LVL40
 2616 027b 0600      		.word	0x6
GAS LISTING /tmp/ccOr00ZN.s 			page 58


 2617 027d 68        		.byte	0x68
 2618 027e 93        		.byte	0x93
 2619 027f 01        		.uleb128 0x1
 2620 0280 69        		.byte	0x69
 2621 0281 93        		.byte	0x93
 2622 0282 01        		.uleb128 0x1
 2623 0283 0000 0000 		.long	.LVL40
 2624 0287 0000 0000 		.long	.LFE14
 2625 028b 0600      		.word	0x6
 2626 028d 6E        		.byte	0x6e
 2627 028e 93        		.byte	0x93
 2628 028f 01        		.uleb128 0x1
 2629 0290 6F        		.byte	0x6f
 2630 0291 93        		.byte	0x93
 2631 0292 01        		.uleb128 0x1
 2632 0293 0000 0000 		.long	0
 2633 0297 0000 0000 		.long	0
 2634               	.LLST15:
 2635 029b 0000 0000 		.long	.LVL39
 2636 029f 0000 0000 		.long	.LVL41
 2637 02a3 0100      		.word	0x1
 2638 02a5 62        		.byte	0x62
 2639 02a6 0000 0000 		.long	.LVL41
 2640 02aa 0000 0000 		.long	.LVL42
 2641 02ae 0200      		.word	0x2
 2642 02b0 8E        		.byte	0x8e
 2643 02b1 0B        		.sleb128 11
 2644 02b2 0000 0000 		.long	.LVL43
 2645 02b6 0000 0000 		.long	.LVL44
 2646 02ba 0100      		.word	0x1
 2647 02bc 62        		.byte	0x62
 2648 02bd 0000 0000 		.long	.LVL44
 2649 02c1 0000 0000 		.long	.LVL45
 2650 02c5 0200      		.word	0x2
 2651 02c7 8E        		.byte	0x8e
 2652 02c8 0B        		.sleb128 11
 2653 02c9 0000 0000 		.long	.LVL46
 2654 02cd 0000 0000 		.long	.LFE14
 2655 02d1 0100      		.word	0x1
 2656 02d3 62        		.byte	0x62
 2657 02d4 0000 0000 		.long	0
 2658 02d8 0000 0000 		.long	0
 2659               	.LLST16:
 2660 02dc 0000 0000 		.long	.LFB15
 2661 02e0 0000 0000 		.long	.LCFI12
 2662 02e4 0300      		.word	0x3
 2663 02e6 92        		.byte	0x92
 2664 02e7 20        		.uleb128 0x20
 2665 02e8 03        		.sleb128 3
 2666 02e9 0000 0000 		.long	.LCFI12
 2667 02ed 0000 0000 		.long	.LCFI13
 2668 02f1 0300      		.word	0x3
 2669 02f3 92        		.byte	0x92
 2670 02f4 20        		.uleb128 0x20
 2671 02f5 04        		.sleb128 4
 2672 02f6 0000 0000 		.long	.LCFI13
 2673 02fa 0000 0000 		.long	.LCFI14
GAS LISTING /tmp/ccOr00ZN.s 			page 59


 2674 02fe 0300      		.word	0x3
 2675 0300 92        		.byte	0x92
 2676 0301 20        		.uleb128 0x20
 2677 0302 05        		.sleb128 5
 2678 0303 0000 0000 		.long	.LCFI14
 2679 0307 0000 0000 		.long	.LCFI15
 2680 030b 0300      		.word	0x3
 2681 030d 92        		.byte	0x92
 2682 030e 20        		.uleb128 0x20
 2683 030f 06        		.sleb128 6
 2684 0310 0000 0000 		.long	.LCFI15
 2685 0314 0000 0000 		.long	.LFE15
 2686 0318 0300      		.word	0x3
 2687 031a 92        		.byte	0x92
 2688 031b 20        		.uleb128 0x20
 2689 031c 07        		.sleb128 7
 2690 031d 0000 0000 		.long	0
 2691 0321 0000 0000 		.long	0
 2692               	.LLST17:
 2693 0325 0000 0000 		.long	.LVL47
 2694 0329 0000 0000 		.long	.LVL48
 2695 032d 0600      		.word	0x6
 2696 032f 68        		.byte	0x68
 2697 0330 93        		.byte	0x93
 2698 0331 01        		.uleb128 0x1
 2699 0332 69        		.byte	0x69
 2700 0333 93        		.byte	0x93
 2701 0334 01        		.uleb128 0x1
 2702 0335 0000 0000 		.long	.LVL48
 2703 0339 0000 0000 		.long	.LVL50
 2704 033d 0600      		.word	0x6
 2705 033f 6C        		.byte	0x6c
 2706 0340 93        		.byte	0x93
 2707 0341 01        		.uleb128 0x1
 2708 0342 6D        		.byte	0x6d
 2709 0343 93        		.byte	0x93
 2710 0344 01        		.uleb128 0x1
 2711 0345 0000 0000 		.long	.LVL50
 2712 0349 0000 0000 		.long	.LVL51
 2713 034d 0400      		.word	0x4
 2714 034f F3        		.byte	0xf3
 2715 0350 01        		.uleb128 0x1
 2716 0351 68        		.byte	0x68
 2717 0352 9F        		.byte	0x9f
 2718 0353 0000 0000 		.long	.LVL51
 2719 0357 0000 0000 		.long	.LVL53
 2720 035b 0600      		.word	0x6
 2721 035d 6C        		.byte	0x6c
 2722 035e 93        		.byte	0x93
 2723 035f 01        		.uleb128 0x1
 2724 0360 6D        		.byte	0x6d
 2725 0361 93        		.byte	0x93
 2726 0362 01        		.uleb128 0x1
 2727 0363 0000 0000 		.long	.LVL53
 2728 0367 0000 0000 		.long	.LVL54-1
 2729 036b 0600      		.word	0x6
 2730 036d 68        		.byte	0x68
GAS LISTING /tmp/ccOr00ZN.s 			page 60


 2731 036e 93        		.byte	0x93
 2732 036f 01        		.uleb128 0x1
 2733 0370 69        		.byte	0x69
 2734 0371 93        		.byte	0x93
 2735 0372 01        		.uleb128 0x1
 2736 0373 0000 0000 		.long	.LVL54-1
 2737 0377 0000 0000 		.long	.LFE15
 2738 037b 0400      		.word	0x4
 2739 037d F3        		.byte	0xf3
 2740 037e 01        		.uleb128 0x1
 2741 037f 68        		.byte	0x68
 2742 0380 9F        		.byte	0x9f
 2743 0381 0000 0000 		.long	0
 2744 0385 0000 0000 		.long	0
 2745               	.LLST18:
 2746 0389 0000 0000 		.long	.LVL47
 2747 038d 0000 0000 		.long	.LVL49-1
 2748 0391 0100      		.word	0x1
 2749 0393 66        		.byte	0x66
 2750 0394 0000 0000 		.long	.LVL49-1
 2751 0398 0000 0000 		.long	.LVL51
 2752 039c 0400      		.word	0x4
 2753 039e F3        		.byte	0xf3
 2754 039f 01        		.uleb128 0x1
 2755 03a0 66        		.byte	0x66
 2756 03a1 9F        		.byte	0x9f
 2757 03a2 0000 0000 		.long	.LVL51
 2758 03a6 0000 0000 		.long	.LVL52-1
 2759 03aa 0100      		.word	0x1
 2760 03ac 66        		.byte	0x66
 2761 03ad 0000 0000 		.long	.LVL52-1
 2762 03b1 0000 0000 		.long	.LFE15
 2763 03b5 0400      		.word	0x4
 2764 03b7 F3        		.byte	0xf3
 2765 03b8 01        		.uleb128 0x1
 2766 03b9 66        		.byte	0x66
 2767 03ba 9F        		.byte	0x9f
 2768 03bb 0000 0000 		.long	0
 2769 03bf 0000 0000 		.long	0
 2770               	.LLST19:
 2771 03c3 0000 0000 		.long	.LVL55
 2772 03c7 0000 0000 		.long	.LVL59-1
 2773 03cb 0600      		.word	0x6
 2774 03cd 68        		.byte	0x68
 2775 03ce 93        		.byte	0x93
 2776 03cf 01        		.uleb128 0x1
 2777 03d0 69        		.byte	0x69
 2778 03d1 93        		.byte	0x93
 2779 03d2 01        		.uleb128 0x1
 2780 03d3 0000 0000 		.long	.LVL59-1
 2781 03d7 0000 0000 		.long	.LVL59
 2782 03db 0400      		.word	0x4
 2783 03dd F3        		.byte	0xf3
 2784 03de 01        		.uleb128 0x1
 2785 03df 68        		.byte	0x68
 2786 03e0 9F        		.byte	0x9f
 2787 03e1 0000 0000 		.long	.LVL59
GAS LISTING /tmp/ccOr00ZN.s 			page 61


 2788 03e5 0000 0000 		.long	.LFE16
 2789 03e9 0600      		.word	0x6
 2790 03eb 68        		.byte	0x68
 2791 03ec 93        		.byte	0x93
 2792 03ed 01        		.uleb128 0x1
 2793 03ee 69        		.byte	0x69
 2794 03ef 93        		.byte	0x93
 2795 03f0 01        		.uleb128 0x1
 2796 03f1 0000 0000 		.long	0
 2797 03f5 0000 0000 		.long	0
 2798               	.LLST20:
 2799 03f9 0000 0000 		.long	.LVL55
 2800 03fd 0000 0000 		.long	.LVL56
 2801 0401 0100      		.word	0x1
 2802 0403 66        		.byte	0x66
 2803 0404 0000 0000 		.long	.LVL56
 2804 0408 0000 0000 		.long	.LVL57
 2805 040c 0100      		.word	0x1
 2806 040e 62        		.byte	0x62
 2807 040f 0000 0000 		.long	.LVL57
 2808 0413 0000 0000 		.long	.LVL58
 2809 0417 0400      		.word	0x4
 2810 0419 F3        		.byte	0xf3
 2811 041a 01        		.uleb128 0x1
 2812 041b 66        		.byte	0x66
 2813 041c 9F        		.byte	0x9f
 2814 041d 0000 0000 		.long	.LVL58
 2815 0421 0000 0000 		.long	.LVL59-1
 2816 0425 0100      		.word	0x1
 2817 0427 62        		.byte	0x62
 2818 0428 0000 0000 		.long	.LVL59-1
 2819 042c 0000 0000 		.long	.LVL59
 2820 0430 0400      		.word	0x4
 2821 0432 F3        		.byte	0xf3
 2822 0433 01        		.uleb128 0x1
 2823 0434 66        		.byte	0x66
 2824 0435 9F        		.byte	0x9f
 2825 0436 0000 0000 		.long	.LVL59
 2826 043a 0000 0000 		.long	.LVL60
 2827 043e 0100      		.word	0x1
 2828 0440 62        		.byte	0x62
 2829 0441 0000 0000 		.long	.LVL60
 2830 0445 0000 0000 		.long	.LFE16
 2831 0449 0400      		.word	0x4
 2832 044b F3        		.byte	0xf3
 2833 044c 01        		.uleb128 0x1
 2834 044d 66        		.byte	0x66
 2835 044e 9F        		.byte	0x9f
 2836 044f 0000 0000 		.long	0
 2837 0453 0000 0000 		.long	0
 2838               	.LLST21:
 2839 0457 0000 0000 		.long	.LVL57
 2840 045b 0000 0000 		.long	.LVL58
 2841 045f 0100      		.word	0x1
 2842 0461 62        		.byte	0x62
 2843 0462 0000 0000 		.long	.LVL60
 2844 0466 0000 0000 		.long	.LFE16
GAS LISTING /tmp/ccOr00ZN.s 			page 62


 2845 046a 0100      		.word	0x1
 2846 046c 62        		.byte	0x62
 2847 046d 0000 0000 		.long	0
 2848 0471 0000 0000 		.long	0
 2849               		.section	.debug_aranges,"",@progbits
 2850 0000 9400 0000 		.long	0x94
 2851 0004 0200      		.word	0x2
 2852 0006 0000 0000 		.long	.Ldebug_info0
 2853 000a 04        		.byte	0x4
 2854 000b 00        		.byte	0
 2855 000c 0000      		.word	0
 2856 000e 0000      		.word	0
 2857 0010 0000 0000 		.long	.LFB1
 2858 0014 1800 0000 		.long	.LFE1-.LFB1
 2859 0018 0000 0000 		.long	.LFB2
 2860 001c 1A00 0000 		.long	.LFE2-.LFB2
 2861 0020 0000 0000 		.long	.LFB3
 2862 0024 3800 0000 		.long	.LFE3-.LFB3
 2863 0028 0000 0000 		.long	.LFB4
 2864 002c 6600 0000 		.long	.LFE4-.LFB4
 2865 0030 0000 0000 		.long	.LFB5
 2866 0034 4C00 0000 		.long	.LFE5-.LFB5
 2867 0038 0000 0000 		.long	.LFB6
 2868 003c 3400 0000 		.long	.LFE6-.LFB6
 2869 0040 0000 0000 		.long	.LFB7
 2870 0044 1A00 0000 		.long	.LFE7-.LFB7
 2871 0048 0000 0000 		.long	.LFB9
 2872 004c 5400 0000 		.long	.LFE9-.LFB9
 2873 0050 0000 0000 		.long	.LFB10
 2874 0054 0E00 0000 		.long	.LFE10-.LFB10
 2875 0058 0000 0000 		.long	.LFB11
 2876 005c 1600 0000 		.long	.LFE11-.LFB11
 2877 0060 0000 0000 		.long	.LFB12
 2878 0064 5400 0000 		.long	.LFE12-.LFB12
 2879 0068 0000 0000 		.long	.LFB13
 2880 006c 5200 0000 		.long	.LFE13-.LFB13
 2881 0070 0000 0000 		.long	.LFB8
 2882 0074 6E00 0000 		.long	.LFE8-.LFB8
 2883 0078 0000 0000 		.long	.LFB14
 2884 007c 7000 0000 		.long	.LFE14-.LFB14
 2885 0080 0000 0000 		.long	.LFB15
 2886 0084 6000 0000 		.long	.LFE15-.LFB15
 2887 0088 0000 0000 		.long	.LFB16
 2888 008c 3C00 0000 		.long	.LFE16-.LFB16
 2889 0090 0000 0000 		.long	0
 2890 0094 0000 0000 		.long	0
 2891               		.section	.debug_ranges,"",@progbits
 2892               	.Ldebug_ranges0:
 2893 0000 0000 0000 		.long	.LFB1
 2894 0004 0000 0000 		.long	.LFE1
 2895 0008 0000 0000 		.long	.LFB2
 2896 000c 0000 0000 		.long	.LFE2
 2897 0010 0000 0000 		.long	.LFB3
 2898 0014 0000 0000 		.long	.LFE3
 2899 0018 0000 0000 		.long	.LFB4
 2900 001c 0000 0000 		.long	.LFE4
 2901 0020 0000 0000 		.long	.LFB5
GAS LISTING /tmp/ccOr00ZN.s 			page 63


 2902 0024 0000 0000 		.long	.LFE5
 2903 0028 0000 0000 		.long	.LFB6
 2904 002c 0000 0000 		.long	.LFE6
 2905 0030 0000 0000 		.long	.LFB7
 2906 0034 0000 0000 		.long	.LFE7
 2907 0038 0000 0000 		.long	.LFB9
 2908 003c 0000 0000 		.long	.LFE9
 2909 0040 0000 0000 		.long	.LFB10
 2910 0044 0000 0000 		.long	.LFE10
 2911 0048 0000 0000 		.long	.LFB11
 2912 004c 0000 0000 		.long	.LFE11
 2913 0050 0000 0000 		.long	.LFB12
 2914 0054 0000 0000 		.long	.LFE12
 2915 0058 0000 0000 		.long	.LFB13
 2916 005c 0000 0000 		.long	.LFE13
 2917 0060 0000 0000 		.long	.LFB8
 2918 0064 0000 0000 		.long	.LFE8
 2919 0068 0000 0000 		.long	.LFB14
 2920 006c 0000 0000 		.long	.LFE14
 2921 0070 0000 0000 		.long	.LFB15
 2922 0074 0000 0000 		.long	.LFE15
 2923 0078 0000 0000 		.long	.LFB16
 2924 007c 0000 0000 		.long	.LFE16
 2925 0080 0000 0000 		.long	0
 2926 0084 0000 0000 		.long	0
 2927               		.section	.debug_line,"",@progbits
 2928               	.Ldebug_line0:
 2929 0000 4A02 0000 		.section	.debug_str,"MS",@progbits,1
 2929      0200 9E00 
 2929      0000 0201 
 2929      FB0E 0D00 
 2929      0101 0101 
 2930               	.LASF40:
 2931 0000 5F5F 7665 		.string	"__vector_23"
 2931      6374 6F72 
 2931      5F32 3300 
 2932               	.LASF16:
 2933 000c 5075 6C73 		.string	"Pulse"
 2933      6500 
 2934               	.LASF12:
 2935 0012 6D65 7468 		.string	"method"
 2935      6F64 00
 2936               	.LASF33:
 2937 0019 7569 4164 		.string	"uiAddress"
 2937      6472 6573 
 2937      7300 
 2938               	.LASF0:
 2939 0023 696E 7438 		.string	"int8_t"
 2939      5F74 00
 2940               	.LASF15:
 2941 002a 7374 6174 		.string	"state"
 2941      6500 
 2942               	.LASF51:
 2943 0030 7469 6D65 		.string	"timer0_hook_run"
 2943      7230 5F68 
 2943      6F6F 6B5F 
 2943      7275 6E00 
GAS LISTING /tmp/ccOr00ZN.s 			page 64


 2944               	.LASF39:
 2945 0040 706F 7041 		.string	"popAllRegs"
 2945      6C6C 5265 
 2945      6773 00
 2946               	.LASF45:
 2947 004b 7063 696E 		.string	"pcint_micros"
 2947      745F 6D69 
 2947      6372 6F73 
 2947      00
 2948               	.LASF44:
 2949 0058 7270 696E 		.string	"rpin"
 2949      00
 2950               	.LASF1:
 2951 005d 7569 6E74 		.string	"uint8_t"
 2951      385F 7400 
 2952               	.LASF50:
 2953 0065 7469 6D65 		.string	"timer0_hook"
 2953      7230 5F68 
 2953      6F6F 6B00 
 2954               	.LASF24:
 2955 0071 7469 6D65 		.string	"timer"
 2955      7200 
 2956               	.LASF41:
 2957 0077 7063 696E 		.string	"pcint_end"
 2957      745F 656E 
 2957      6400 
 2958               	.LASF42:
 2959 0081 7074 7250 		.string	"ptrPulse"
 2959      756C 7365 
 2959      00
 2960               	.LASF9:
 2961 008a 6C6F 6E67 		.string	"long long int"
 2961      206C 6F6E 
 2961      6720 696E 
 2961      7400 
 2962               	.LASF23:
 2963 0098 7469 6D65 		.string	"time_millis"
 2963      5F6D 696C 
 2963      6C69 7300 
 2964               	.LASF18:
 2965 00a4 5F73 7265 		.string	"_sreg"
 2965      6700 
 2966               	.LASF6:
 2967 00aa 6C6F 6E67 		.string	"long int"
 2967      2069 6E74 
 2967      00
 2968               	.LASF19:
 2969 00b3 5F63 6F75 		.string	"_count"
 2969      6E74 00
 2970               	.LASF52:
 2971 00ba 474E 5520 		.string	"GNU C 4.8.1 -mmcu=atmega2560 -g -Os -ffunction-sections -fdata-sections"
 2971      4320 342E 
 2971      382E 3120 
 2971      2D6D 6D63 
 2971      753D 6174 
 2972               	.LASF3:
 2973 0102 756E 7369 		.string	"unsigned char"
GAS LISTING /tmp/ccOr00ZN.s 			page 65


 2973      676E 6564 
 2973      2063 6861 
 2973      7200 
 2974               	.LASF35:
 2975 0110 7563 4461 		.string	"ucData"
 2975      7461 00
 2976               	.LASF22:
 2977 0117 5F72 6573 		.string	"_res"
 2977      00
 2978               	.LASF2:
 2979 011c 7369 676E 		.string	"signed char"
 2979      6564 2063 
 2979      6861 7200 
 2980               	.LASF26:
 2981 0128 7072 6F63 		.string	"proc"
 2981      00
 2982               	.LASF10:
 2983 012d 6C6F 6E67 		.string	"long long unsigned int"
 2983      206C 6F6E 
 2983      6720 756E 
 2983      7369 676E 
 2983      6564 2069 
 2984               	.LASF29:
 2985 0144 7469 6D65 		.string	"time_delay16"
 2985      5F64 656C 
 2985      6179 3136 
 2985      00
 2986               	.LASF7:
 2987 0151 7569 6E74 		.string	"uint32_t"
 2987      3332 5F74 
 2987      00
 2988               	.LASF32:
 2989 015a 4545 5052 		.string	"EEPROM_read"
 2989      4F4D 5F72 
 2989      6561 6400 
 2990               	.LASF30:
 2991 0166 6164 635F 		.string	"adc_read"
 2991      7265 6164 
 2991      00
 2992               	.LASF5:
 2993 016f 756E 7369 		.string	"unsigned int"
 2993      676E 6564 
 2993      2069 6E74 
 2993      00
 2994               	.LASF4:
 2995 017c 7569 6E74 		.string	"uint16_t"
 2995      3136 5F74 
 2995      00
 2996               	.LASF17:
 2997 0185 5469 6D65 		.string	"TimerHookProc"
 2997      7248 6F6F 
 2997      6B50 726F 
 2997      6300 
 2998               	.LASF38:
 2999 0193 7075 7368 		.string	"pushAllRegs"
 2999      416C 6C52 
 2999      6567 7300 
GAS LISTING /tmp/ccOr00ZN.s 			page 66


 3000               	.LASF34:
 3001 019f 4545 5052 		.string	"EEPROM_write"
 3001      4F4D 5F77 
 3001      7269 7465 
 3001      00
 3002               	.LASF14:
 3003 01ac 7374 6172 		.string	"start"
 3003      7400 
 3004               	.LASF36:
 3005 01b2 6F72 6567 		.string	"oreg"
 3005      00
 3006               	.LASF47:
 3007 01b7 7063 696E 		.string	"pcint_encoder"
 3007      745F 656E 
 3007      636F 6465 
 3007      7200 
 3008               	.LASF11:
 3009 01c5 5063 696E 		.string	"PcintMethod"
 3009      744D 6574 
 3009      686F 6400 
 3010               	.LASF37:
 3011 01d1 696E 6974 		.string	"init"
 3011      00
 3012               	.LASF46:
 3013 01d6 6F6C 6442 		.string	"oldBit"
 3013      6974 00
 3014               	.LASF8:
 3015 01dd 6C6F 6E67 		.string	"long unsigned int"
 3015      2075 6E73 
 3015      6967 6E65 
 3015      6420 696E 
 3015      7400 
 3016               	.LASF49:
 3017 01ef 7469 6D65 		.string	"timer0_overflow_count"
 3017      7230 5F6F 
 3017      7665 7266 
 3017      6C6F 775F 
 3017      636F 756E 
 3018               	.LASF31:
 3019 0205 616E 5069 		.string	"anPin"
 3019      6E00 
 3020               	.LASF27:
 3021 020b 696E 7465 		.string	"interval"
 3021      7276 616C 
 3021      00
 3022               	.LASF25:
 3023 0214 6F6C 6453 		.string	"oldSREG"
 3023      5245 4700 
 3024               	.LASF28:
 3025 021c 7469 6D65 		.string	"time_delay"
 3025      5F64 656C 
 3025      6179 00
 3026               	.LASF48:
 3027 0227 6164 6469 		.string	"addition"
 3027      7469 6F6E 
 3027      00
 3028               	.LASF43:
GAS LISTING /tmp/ccOr00ZN.s 			page 67


 3029 0230 6572 726F 		.string	"error"
 3029      7200 
 3030               	.LASF54:
 3031 0236 7469 6D65 		.string	"time_micros"
 3031      5F6D 6963 
 3031      726F 7300 
 3032               	.LASF20:
 3033 0242 6765 744F 		.string	"getOvfCount"
 3033      7666 436F 
 3033      756E 7400 
 3034               	.LASF21:
 3035 024e 7365 7454 		.string	"setTimerHook"
 3035      696D 6572 
 3035      486F 6F6B 
 3035      00
 3036               	.LASF13:
 3037 025b 7469 6D65 		.string	"timeout"
 3037      6F75 7400 
 3038               	.LASF53:
 3039 0263 2F68 6F6D 		.string	"/home/arhat109/Arduino/libraries/Arhat/arhat.c"
 3039      652F 6172 
 3039      6861 7431 
 3039      3039 2F41 
 3039      7264 7569 
 3040               		.ident	"GCC: (GNU) 4.8.1"
 3041               	.global __do_clear_bss
GAS LISTING /tmp/ccOr00ZN.s 			page 68


DEFINED SYMBOLS
                            *ABS*:0000000000000000 arhat.c
     /tmp/ccOr00ZN.s:2      *ABS*:000000000000003e __SP_H__
     /tmp/ccOr00ZN.s:3      *ABS*:000000000000003d __SP_L__
     /tmp/ccOr00ZN.s:4      *ABS*:000000000000003f __SREG__
     /tmp/ccOr00ZN.s:5      *ABS*:000000000000003b __RAMPZ__
     /tmp/ccOr00ZN.s:6      *ABS*:0000000000000000 __tmp_reg__
     /tmp/ccOr00ZN.s:7      *ABS*:0000000000000001 __zero_reg__
     /tmp/ccOr00ZN.s:14     .text.getOvfCount:0000000000000000 getOvfCount
     /tmp/ccOr00ZN.s:1012   .bss.timer0_overflow_count:0000000000000000 timer0_overflow_count
     /tmp/ccOr00ZN.s:48     .text.setTimerHook:0000000000000000 setTimerHook
     /tmp/ccOr00ZN.s:1006   .bss.timer0_hook:0000000000000000 timer0_hook
     /tmp/ccOr00ZN.s:84     .text.time_micros:0000000000000000 time_micros
     /tmp/ccOr00ZN.s:110    .text.time_micros:0000000000000024 .skip1
     /tmp/ccOr00ZN.s:113    .text.time_micros:0000000000000028 .shift1
     /tmp/ccOr00ZN.s:140    .text.time_millis:0000000000000000 time_millis
     /tmp/ccOr00ZN.s:230    .text.time_delay:0000000000000000 time_delay
     /tmp/ccOr00ZN.s:315    .text.time_delay16:0000000000000000 time_delay16
     /tmp/ccOr00ZN.s:382    .text.init:0000000000000000 init
     /tmp/ccOr00ZN.s:417    .text.adc_read:0000000000000000 adc_read
     /tmp/ccOr00ZN.s:478    .text.EEPROM_read:0000000000000000 EEPROM_read
     /tmp/ccOr00ZN.s:508    .text.EEPROM_write:0000000000000000 EEPROM_write
     /tmp/ccOr00ZN.s:549    .text.pushAllRegs:0000000000000000 pushAllRegs
     /tmp/ccOr00ZN.s:611    .text.popAllRegs:0000000000000000 popAllRegs
     /tmp/ccOr00ZN.s:672    .text.__vector_23:0000000000000000 __vector_23
     /tmp/ccOr00ZN.s:1000   .bss.timer0_hook_run:0000000000000000 timer0_hook_run
     /tmp/ccOr00ZN.s:761    .text.pcint_end:0000000000000000 pcint_end
     /tmp/ccOr00ZN.s:849    .text.pcint_micros:0000000000000000 pcint_micros
     /tmp/ccOr00ZN.s:942    .text.pcint_encoder:0000000000000000 pcint_encoder

UNDEFINED SYMBOLS
__udivmodsi4
__do_clear_bss
