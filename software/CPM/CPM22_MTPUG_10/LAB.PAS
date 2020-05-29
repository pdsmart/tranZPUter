


MODULE LAB;
{$M AD1_CONVERT }
{$M AD2_CONVERT }
{$M DA_CONVERT  }
{$M TIMER       }
{$M TIME_OUT    }
{$M READ_CLOCK  }
{$M PRINT_TIME  }
{$M CONTROL     }
{$M HYDROGEN    }
{$M OXYGEN      }
{$M AIR         }
{$M STRIP_CHART }       
{$M LOGIN_DISK  }

{$M *}

TYPE         AD1_CHAN = 0..7;
             AD2_CHAN = 0..15;
              DA_CHAN = 0..3;
               NIBBLE = 0..15;
          DEVICE_CODE = RECORD
                          HOUSE : 'A'..'P';
                           UNIT : 0..15;
                        END;
       CONTROL_ACTION = (ON,OFF,ALL_ON,ALL_OFF,BRIGHTEN,DIM,CLR_STOP);

          TIME_OF_DAY = RECORD
                            YEAR : 1982..2000;
                           MONTH : 1..12;
                             DAY : 1..31;
                            HOUR : 0..23;
                          MINUTE : 0..59;
                          SECOND : 0..59;
                         END;

            FILE_NAME = STRING;



EXTERNAL FUNCTION @BDOS(FUNC,PARM : INTEGER) : INTEGER;
 
FUNCTION AD1_CONVERT(CHANNEL : AD1_CHAN; N : NIBBLE) : INTEGER;
   {Access the CDC 12-bit A/D converter board set at +/-5 volts}
   CONST  AD1_PORT = $A0;
              MASK = $20;
   BEGIN
   {GAIN = 2**N.  However we must adjust N so that the proper gain}
   {switching is inputted to the programmable gain amplifier.  See}
   {p. 7 of the 3606 IC manual.   }
   CASE N OF
      0,  1,  2 : N:=N;
          3,  4 : N:=N+2;
      5,  6,  7 : N:=N+3;
      8,  9, 10 : N:=N+4;
      ELSE BEGIN
         WRITELN('Gain of 1024 (2**10) is a maximum bound.');
         N:=14
         END
   END;

   OUT[ AD1_PORT   ]:=N;             {input gain switch}
   OUT[(AD1_PORT+1)]:=CHANNEL;
   OUT[(AD1_PORT+2)]:=0;             {start A/D conversion}

   WAIT(AD1_PORT,MASK,TRUE);         {wait until the 5th bit goes low}

   AD1_CONVERT:=SWAP(INP[(AD1_PORT+3)]) ! INP[(AD1_PORT+2)]
   END;



FUNCTION AD2_CONVERT(CHANNEL : AD2_CHAN) : INTEGER;
   {Access the Techmar 12-bit A/D converter board set at +/-10 volts}
   CONST  AD2_PORT = $B0;
              MASK = $01;
   BEGIN

   OUT[ AD2_PORT   ]:=CHANNEL;
   OUT[(AD2_PORT+1)]:=0;             {start A/D conversion}

   WAIT(AD2_PORT+1,MASK,FALSE);      {wait until the LSB bit goes high}

   AD2_CONVERT:=SWAP(INP[(AD2_PORT+3)]) ! INP[(AD2_PORT+2)]
   END;



PROCEDURE DA_CONVERT(CHANNEL : DA_CHAN; DA_OUTPUT : INTEGER);
   {Access the CDC 12-bit D/A converter board set at +/-10 volts}
   CONST   DA_PORT = $C0;

   VAR   DAC_PORT : BYTE;

   BEGIN
   IF ( CHANNEL>3 ) OR ( CHANNEL<0 ) THEN
      WRITELN('D/A CHANNEL',CHANNEL,' does not exist.');
   DAC_PORT:=DA_PORT + 2*CHANNEL;
   OUT[(DAC_PORT    )]:=HI(DA_OUTPUT);
   OUT[(DAC_PORT + 1)]:=LO(DA_OUTPUT)
   END;



PROCEDURE TIMER(SECONDS : INTEGER);
   {Access the SciTronics RTC-100 Real Time Clock board}
   {and wait a specified number of seconds.            }

   VAR         I : INTEGER;
             NOW : TIME_OF_DAY;
         OLD_SEC : INTEGER;

   BEGIN
   READ_CLOCK(NOW);
   FOR I:=SECONDS DOWNTO 1 DO
      BEGIN
      OLD_SEC:=NOW.SECOND;
      REPEAT
         READ_CLOCK(NOW)
      UNTIL NOW.SECOND<>OLD_SEC
      END
   END;


PROCEDURE TIME_OUT(HOURS,MINUTES,SECONDS : INTEGER);
   {Access the RTC-100 Real Time Clock board and wait a specified}
   {block of time (accurate only to the nearest second).         }

   CONST    RTC0 = $18;
            RTC1 = $19;
            RTC2 = $1A;
            RTC3 = $1B;

   VAR            I : INTEGER;
                NOW : TIME_OF_DAY;
             TARGET : TIME_OF_DAY;
        SUM_SECONDS : INTEGER;
        SUM_MINUTES : INTEGER;
          SUM_HOURS : INTEGER;
       MINUTE_CARRY : INTEGER;
         HOUR_CARRY : INTEGER;
              READY : BOOLEAN;

   BEGIN
   READ_CLOCK(NOW);
   READY:=FALSE;

   SUM_SECONDS  := NOW.SECOND + SECONDS;

   MINUTE_CARRY := SUM_SECONDS DIV 60;
   SUM_MINUTES  := NOW.MINUTE + MINUTES + MINUTE_CARRY;

   HOUR_CARRY   := SUM_MINUTES DIV 60;
   SUM_HOURS    := NOW.HOUR + HOURS + HOUR_CARRY;

   TARGET.SECOND:= SUM_SECONDS MOD 60;
   TARGET.MINUTE:= SUM_MINUTES MOD 60;
   TARGET.HOUR  := SUM_HOURS   MOD 24;

   REPEAT
      READ_CLOCK(NOW);
      IF NOW.HOUR=TARGET.HOUR THEN
         IF NOW.MINUTE=TARGET.MINUTE THEN
            READY:=TARGET.SECOND=NOW.SECOND
   UNTIL READY
   END;



PROCEDURE READ_CLOCK(VAR NOW : TIME_OF_DAY);
   {Read the RTC-100 Real Time Clock}
   VAR  TIME : ARRAY[0..12] OF BYTE;

   PROCEDURE RTC_READ;
      CONST    RTC0 = $18;
               RTC1 = $19;
               RTC2 = $1A;
               RTC3 = $1B;

      VAR    I : INTEGER;

      BEGIN
      OUT[RTC1]:=$F0;
      OUT[RTC0]:=$0F;
      OUT[RTC3]:=$FC;
      OUT[RTC1]:=$F4;

      FOR I:=0 TO 12 DO
         BEGIN
         OUT[RTC0]:=I;
         TIME[I]:=SHR( INP[RTC0], 4)
         END;

      OUT[RTC1]:=$F8;
      OUT[RTC0]:=$0F;
      OUT[RTC3]:=$F8;
      OUT[RTC1]:=$FC;
      OUT[RTC0]:=$0F
      END;

   BEGIN
   RTC_READ;
   WITH NOW DO
      BEGIN
      YEAR:=TIME[12]*10 + TIME[11] + 1900;
      MONTH:=(TIME[10] & 3)*10 + TIME[9];
      DAY:=TIME[8]*10 + TIME[7];
      HOUR:=(TIME[5] & 3)*10 + TIME[4];
      MINUTE:=TIME[3]*10 + TIME[2];
      SECOND:=TIME[1]*10 + TIME[0]
      END
   END;




PROCEDURE PRINT_TIME(F_NAME : FILE_NAME);
   VAR   TIME : TIME_OF_DAY;

   BEGIN
   READ_CLOCK(TIME);
   WITH TIME DO
      IF F_NAME='SCREEN' THEN
         WRITE('Time is:  ',HOUR:2,':',MINUTE:2,':',SECOND:2)
      ELSE WRITE(F_NAME, HOUR:2,':',MINUTE:2,':',SECOND:2)
   END;




PROCEDURE CONTROL(TRIAC : DEVICE_CODE; COMMAND : CONTROL_ACTION);
   {Works in conjunction with the SciTronics Remote Controller  }
   {board.  This procedure accesses and performs the appropriate}
   {command for a BSR control module.  It takes approximately   }
   {3 seconds to execute.                                       }

   CONST     RC_PORT = $40;
                MASK = $80;

   VAR     STR : STRING;
             I : INTEGER;

   BEGIN
   WITH TRIAC DO
      BEGIN
      STR:='JBHPLDFNIAGOKCEM';
      {output the device code --> see p.8 of RC-100 manual}
      OUT[RC_PORT]:=SHL(UNIT,4)!( POS(HOUSE,STR) - 1 );
      CASE COMMAND OF

                ON : OUT[(RC_PORT + 1)]:=$93;

               OFF : OUT[(RC_PORT + 1)]:=$9B;

            ALL_ON : OUT[(RC_PORT + 1)]:=$95;

           ALL_OFF : OUT[(RC_PORT + 1)]:=$9D;

          BRIGHTEN : OUT[(RC_PORT + 1)]:=$C7;

               DIM : OUT[(RC_PORT + 1)]:=$CF;

          CLR_STOP : OUT[(RC_PORT + 1)]:=$A1

          END;

 
      FOR I:=1 TO 100 DO;  {a short delay before reading status}
 
      {wait until controller has stopped transmitting}
      WAIT(RC_PORT,MASK,TRUE)
      END
   END;



FUNCTION KEYPRESSED : BOOLEAN;
   BEGIN
   KEYPRESSED:=( @BDOS(11,0) <> 0 )
   END;



PROCEDURE HYDROGEN(FLOWRATE : INTEGER);
   {This procedure activates the appropriate solenoid valve to   }
   {the gas regulator and inputs a voltage to the flow controller}
   {which will correspond to the given flowrate requested.       }

   CONST    H2_FLOW_CONTROLLER = 3;     {D/A channel 3}
                      MAX_FLOW = 300;   {cm**3/minute}
                      MIN_FLOW =  13;

   VAR     H2_VALVE : DEVICE_CODE;
             FLOW_I : INTEGER;
   BEGIN
   H2_VALVE.HOUSE:='P';      {If using BSR appliance}
   H2_VALVE.UNIT:=2;         {modules, dial in "P3" }

   IF FLOWRATE<=0 THEN
      CONTROL(H2_VALVE,OFF)
   ELSE IF FLOWRATE<=MAX_FLOW THEN
      BEGIN
      CONTROL(H2_VALVE,ON);
      {Generate a positve DAC voltage <= 5.0 volts for proper flowrate}
      FLOW_I:=ROUND(1024.0*FLOWRATE/MAX_FLOW);
      DA_CONVERT(H2_FLOW_CONTROLLER,FLOW_I)
      END
   ELSE WRITELN('Error  *** Hydrogen flowrate exceeds controller max.')

   END;



PROCEDURE OXYGEN(FLOWRATE : INTEGER);
   {This procedure activates the appropriate solenoid valve to   }
   {the gas regulator and inputs a voltage to the flow controller}
   {which will correspond to the given flowrate requested.       }

   CONST    O2_FLOW_CONTROLLER = 2;     {D/A channel 2}
                      MAX_FLOW = 2000;  {cm**3/minute}
                      MIN_FLOW =    0;

   VAR     O2_VALVE : DEVICE_CODE;
             FLOW_I : INTEGER;
   BEGIN
   O2_VALVE.HOUSE:='P';      {If using BSR appliance}
   O2_VALVE.UNIT:=3;         {modules, dial in "P4" }

   IF FLOWRATE<=0 THEN
      CONTROL(O2_VALVE,OFF)
   ELSE IF FLOWRATE<=MAX_FLOW THEN
      BEGIN
      CONTROL(O2_VALVE,ON);
      {Generate a positve DAC voltage <= 5.0 volts for proper flowrate}
      FLOW_I:=ROUND(1024.0*FLOWRATE/MAX_FLOW);
      DA_CONVERT(O2_FLOW_CONTROLLER,FLOW_I)
      END
   ELSE WRITELN('Error  *** Oxygen flowrate exceeds controller max.')

   END;


PROCEDURE AIR(FLOWRATE : INTEGER);
   {This is used when a 21% oxygen/79% nitrogen mixture flows}
   {through the flow controller calibrated for pure oxygen.  }
   BEGIN
   OXYGEN( ROUND(1.00*FLOWRATE) )    {Correction factor given}
   END;                              {in Tylan manual, p. 19 }



PROCEDURE STRIP_CHART(ACTION : CONTROL_ACTION);
   {This procedure turns the Houston Instrument strip chart recorder}
   {on or off.  No pen control is needed since it automatically goes}
   {up when power is curtailed.                                     }

   VAR    CHART : DEVICE_CODE;
   BEGIN
   CHART.HOUSE:='P';         {If using BSR appliance}
   CHART.UNIT:=4;            {modules, dial in "P5" }

   CASE ACTION OF
      ON,OFF : CONTROL(CHART,ACTION);
      ELSE BEGIN
         WRITELN('***> Control action requested is not available');
         WRITELN('      for the strip chart recorder.')
         END
      END
   END;


PROCEDURE LOGIN_DISK(DISK : CHAR);
   {logs in the given floppy disk drive (A,B,C,...)}
   CONST  DISK_DRIVE_LOGIN = 14;
   
   VAR   DUMMY : INTEGER;
   BEGIN
   DUMMY:=@BDOS( DISK_DRIVE_LOGIN, ORD(DISK)-ORD('A') )
   END;
   


MODEND.
