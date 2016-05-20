// файл pins.h:
#include <inttypes.h>
#include <avr/pgmspace.h>

// ========================= Определения, зависящие от процессора ========================= //
// @TODO: Вынести в отдельный файл настроек, типа arduino_pins.h или arhat_pinsXXXX.h

#if !defined(_DIG_ARRAYS_)
  #define _DIG_ARRAYS_ 1

  volatile uint8_t * PROGMEM pin2ddr[] =
  {
    &DDRA, &DDRB, &DDRC, &DDRD, &DDRE, &DDRF, &DDRG, &DDRH, 0, &DDRJ, &DDRK, &DDRL
  };
  volatile uint8_t * PROGMEM pin2port[] =
  {
    &PORTA, &PORTB, &PORTC, &PORTD, &PORTE, &PORTF, &PORTG, &PORTH, 0, &PORTJ, &PORTK, &PORTL
  };
  volatile uint8_t * PROGMEM pin2pin[] =
  {
    &PINA, &PINB, &PINC, &PIND, &PINE, &PINF, &PING, &PINH, 0, &PINJ, &PINK, &PINL
  };
#endif // _DIG_ARRAYS_

#define DLed	{1,7}	/* PB 7 ** D13 + PWM13 + T0outA + T1outC + PC_INT_7 !!! INTERNAL LED! Can't be input D!!! ** */

#define D0	{4,0}	/* PE 0 ** D0 + USART0_RX + PC_INT_8 ** */
#define D1	{4,1}	/* PE 1 ** D1 + USART0_TX ** */
#define D2	{4,4}	/* PE 4 ** D2 + PWM2 + T3outB + INT_4 ** */
#define D3	{4,5}	/* PE 5 ** D3 + PWM3 + T3outC + INT_5 ** */
#define D4	{6,5}	/* PG 5 ** D4 + PWM4 + T0outB ** */
#define D5	{4,3}	/* PE 3 ** D5 + PWM5 + T3outA + AIN1 ** */
#define D6	{7,3}	/* PH 3 ** D6 + PWM6 + T4outA ** */
#define D7	{7,4}	/* PH 4 ** D7 + PWM7 + T4outB ** */
#define D8	{7,5}	/* PH 5 ** D8 + PWM8 + T4outC ** */
#define D9	{7,6}	/* PH 6 ** D9 + PWM9 + T2outB ** */
#define D10	{1,4}	/* PB 4 ** D10 + PWM10 + T2outA + PC_INT_4 ** */
#define D11	{1,5}	/* PB 5 ** D11 + PWM11 + T1outA + PC_INT_5 ** */
#define D12	{1,6}	/* PB 6 ** D12 + PWM12 + T1outB + PC_INT_6 ** */
#define D13	{1,7}	/* PB 7 ** D13 + PWM13 + T0outA + T1outC + PC_INT_7 !!! INTERNAL LED! Can't be input D!!! ** */
#define D14	{9,0}	/* PJ 1 ** D14 + USART3_TX + PC_INT_10 ** */
#define D15	{9,0}	/* PJ 0 ** D15 + USART3_RX + PC_INT_9 ** */
#define D16	{7,0}	/* PH 1 ** D16 + USART2_TX ** */
#define D17	{7,0}	/* PH 0 ** D17 + USART2_RX ** */
#define D18	{3,0}	/* PD 3 ** D18 + USART1_TX + INT_3 ** */
#define D19	{3,0}	/* PD 2 ** D19 + USART1_RX + INT_2 ** */
#define D20	{3,0}	/* PD 1 ** D20 + I2C_SDA + INT_1 ** */
#define D21	{3,0}	/* PD 0 ** D21 + I2C_SCL + INT_0 ** */
#define D22	{0,0}	/* PA 0 ** D22 (D22) + BUS_AD0 ** */
#define D23	{0,0}	/* PA 1 ** D23 (D23) + BUS_AD1 ** */
#define D24	{0,0}	/* PA 2 ** D24 (D24) + BUS_AD2 ** */
#define D25	{0,0}	/* PA 3 ** D25 (D25) + BUS_AD3 ** */
#define D26	{0,0}	/* PA 4 ** D26 (D26) + BUS_AD4 ** */
#define D27	{0,0}	/* PA 5 ** D27 (D27) + BUS_AD5 ** */
#define D28	{0,0}	/* PA 6 ** D28 (D28) + BUS_AD6 ** */
#define D29	{0,0}	/* PA 7 ** D29 (D29) + BUS_AD7 ** */
#define D30	{2,0}	/* PC 7 ** D30 (D30) + BUS_A15 ** */
#define D31	{2,0}	/* PC 6 ** D31 (D31) + BUS_A14 ** */
#define D32	{2,0}	/* PC 5 ** D32 (D32) + BUS_A13 ** */
#define D33	{2,0}	/* PC 4 ** D33 (D33) + BUS_A12 ** */
#define D34	{2,0}	/* PC 3 ** D34 (D34) + BUS_A11 ** */
#define D35	{2,0}	/* PC 2 ** D35 (D35) + BUS_A10 ** */
#define D36	{2,0}	/* PC 1 ** D36 (D36) + BUS_A9 ** */
#define D37	{2,0}	/* PC 0 ** D37 (D37) + BUS_A8 ** */
#define D38	{3,0}	/* PD 7 ** D38 (D38) + T0_IN ** */
#define D39	{6,0}	/* PG 2 ** D39 (D39) + BUS_ALE ** */
#define D40	{6,0}	/* PG 1 ** D40 (D40) + BUS_RD ** */
#define D41	{6,0}	/* PG 0 ** D41 (D41) + BUS_WR ** */
#define D42	{11,0}	/* PL 7 ** D42 (D42) not other use ** */
#define D43	{11,0}	/* PL 6 ** D43 (D43) not other use ** */
#define D44	{11,0}	/* PL 5 ** D44 (D44) + PWM44 + T5outC ** */
#define D45	{11,0}	/* PL 4 ** D45 (D45) + PWM45 + T5outB ** */
#define D46	{11,0}	/* PL 3 ** D46 (D46) + PWM46 + T5outA ** */
#define D47	{11,0}	/* PL 2 ** D47 (D47) + T5_IN ** */
#define D48	{11,0}	/* PL 1 ** D48 (D48) + T5_ICP ** */
#define D49	{11,0}	/* PL 0 ** D49 (D49) + T4_ICP ** */
#define D50	{1,0}	/* PB 3 ** D50 (D50) + SPI_MISO + PC_INT_3 ** */
#define D51	{1,0}	/* PB 2 ** D51 (D51) + SPI_MOSI + PC_INT_2 ** */
#define D52	{1,0}	/* PB 1 ** D52 (D52) + SPI_SCK + PC_INT_1 ** */
#define D53	{1,0}	/* PB 0 ** D53 (D53) + SPI_SS + PC_INT_0 ** */
#define D54	{5,0}	/* PF 0 ** Analog0 ** */
#define D55	{5,0}	/* PF 1 ** Analog1 ** */
#define D56	{5,0}	/* PF 2 ** Analog2 ** */
#define D57	{5,0}	/* PF 3 ** Analog3 ** */
#define D58	{5,0}	/* PF 4 ** Analog4 + JTAG_TCK ** */
#define D59	{5,0}	/* PF 5 ** Analog5 + JTAG_TMS ** */
#define D60	{5,0}	/* PF 6 ** Analog6 + JTAG_TDO ** */
#define D61	{5,0}	/* PF 7 ** Analog7 + JTAG_TDI ** */
#define D62	{10,0}	/* PK 0 ** Analog8 + PC_INT_16 ** */
#define D63	{10,0}	/* PK 1 ** Analog9 + PC_INT_17 ** */
#define D64	{10,0}	/* PK 2 ** Analog10 + PC_INT_18 ** */
#define D65	{10,0}	/* PK 3 ** Analog11 + PC_INT_19 ** */
#define D66	{10,0}	/* PK 4 ** Analog12 + PC_INT_20 ** */
#define D67	{10,0}	/* PK 5 ** Analog13 + PC_INT_21 ** */
#define D68	{10,0}	/* PK 6 ** Analog14 + PC_INT_22 ** */
#define D69	{10,0}	/* PK 7 ** Analog15 + PC_INT_23 ** */

// ========================= Конец зависимых определений тут ========================= //
// ========================= "C"-онистам: внутренние определения ========================= //

#ifdef __cplusplus
  extern "C" {
#endif

// for speed use. Demand 3 byte for each pin variable
typedef struct {
  volatile uint8_t * port;
  uint8_t            mask;
} _Dig_pin;

/**
 * Will be compiled into Asm:
 *      in   reg_data, port | lds reg_data, port(Z)
 *      tst  val_reg
 *      breq .ELSE
 *        or   reg_data, reg_mask
 *        jmp  .ENDIF
 * .ELSE:
 *        com reg_mask
 *        and reg_data,reg_mask
 * .ENDIF:
 *      out port,reg_data | sts port(Z), reg_data
 */
#define __dig_out(port, mask, val) \
{                                  \
  uint8_t    data = *(port);       \
                                   \
  if(val) (data) |= (mask);        \
  else    (data) &= ~(mask);       \
  *(port) = (data);                \
}

// @param _Dig_pin p -- const|vars, not for Dxx macro! or classes
#define _dig_out(p, val)                \
{                                       \
  DigitalPin  tmp = p;                  \
  __dig_out(tmp.port, tmp.mask, (val)); \
}

#define __dig_set_bits(port, mask) \
{                                  \
  uint8_t    data = *(port);       \
  (data) |= (mask);                \
  *(port) = (data);                \
}

#define __dig_clr_bits(port, mask) \
{                                  \
  uint8_t    data = *(port);       \
  (data) &= ~(mask);               \
  *(port) = (data);                \
}

// Converting port number [0..7,9..11] into port ram address:
#define __dignum_2_ddr(p)  (pgm_read_word( pin2ddr[(p)] ))
#define __dignum_2_port(p) (pgm_read_word( pin2port[(p)] ))
#define __dignum_2_pin(p)  (pgm_read_word( pin2pin[(p)] ))

#ifdef __cplusplus
  } // extern "C"
#endif
// ========================= Конец внутренних определений ========================= //
// ========================= "Классным любителям" ========================= //

/* сделай это, и не придется писать каждый раз квалификатор класса перед константой..
#define INPUT    0
#define OUTPUT   1
#define INPULLUP 2
#define LOW      0
#define HIGH     1
*/
class PinAbstract
{
  const uint8_t INPUT    = 0;
  const uint8_t OUTPUT   = 1;
  const uint8_t INPULLUP = 2;

  const uint8_t LOW   = 0;
  const uint8_t HIGH  = 1;

  uint8_t Mode (const uint8_t _mode) = 0;
  uint8_t Out  (const uint8_t _val)  = 0;
  uint8_t In   (void) = 0;

};

class DigitalPin :: public PinAbstract {
private:
  uint8_t portnum; // номер портов пина [0..7,9..11]
  uint8_t mask;    // маска номера бита пина в порту ИЛИ групповая маска пинов одного порта
public:
  inline DigitalPin::DigitalPin (const DigitalPin _pin);
  DigitalPin::DigitalPin (const DigitalPin _pin, uint8_t _mode = PinAbstract::INPUT, uint8_t _val = PinAbstract::LOW);

         uint8_t Mode (uint8_t _mode);
         uint8_t Out  (uint8_t _val);
  inline uint8_t In   (void);
}

// ========================= Реализация С++ ========================= //

DigitalPin::DigitalPin(const DigitalPin _pin)
: portnum(_pin.portnum), mask(_pin.mask)
{}

DigitalPin::DigitalPin(const DigitalPin _pin, uint8_t _mode, uint8_t _val)
: portnum(_pin.portnum), mask(_pin.mask)
{
  this.Mode(_mode);
  this.Out(_val);
}

DigitalPin::Mode(const uint8_t _mode)
{
  uint8_t * mem = __dignum_2_ddr(this->portnum);

  if( _mode == PinAbstract::OUTPUT )    __dig_set_bits(mem, this->mask);
  else {
    __dig_clr_bits(mem, this->mask);
    if( _mode == PinAbstract::INPULLUP  ){
      mem = __dignum_2_port(this->portnum);
      __dig_set_bits(mem, this->mask);
    }
  }
  return _mode;
}

DigitalPin::Out(const uint8_t _val)
{
  _dig_out(this, _val);
  return _val;
}

uint8_t DigitalPin::In(void)
{
  uint8_t * mem = __dignum_2_pin(this.portnum);
  return *mem;
}
