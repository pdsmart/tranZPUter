Module Acoustic_Coupler;

{		Written by Warren A. Smith		}
{	      intended for the public domain		}
{			01/30/82			}

{ This set of routines is meant to be compatible with those found in	}
{ DCMODEM (for the D.C. Hayes modem).  It is intended that with these	}
{ routines you will be able to write programs that can utilize either	}
{ the D.C. Hayes modem (or the PMMI modem when I get around to it) or	}
{ an acoustic coupler and use them interchangeably by re-linking with	}
{ the appropriate library.						}

{ Port assignments for serial port of acoustic coupler }
Const
	Status_Reg_Modem= $03;
	Modem_Rcv_Reg	= $02;
	Modem_Xmit_Reg	= $02;


Procedure Init_Modem;

  Const	Char_Length     = 3;	{ 8 data bits	}
	Stop_bits	= 0;	{ 1 stop bits	}
	Parity_Inhibit	= 1;	{ no parity	}
	Parity_Type	= 1;	{ even parity	}
	Baud		= 300;	{ 300 baud	}

  begin { Init_Modem }
	{ This routine is intended for use as an initializing routine	}
	{ if your serial port needs it.  You should set up your port	}
	{ to match the comments above. }
  end;  { Init_Modem }

Procedure Set_Modem (Modebyte : byte);

  begin { Set_Modem }
	{ This routine lets you change the various modes of the modem,	}
	{ most acoustic couplers can't do anything. }
  end;  { Set_Modem }

Procedure Go_Onhook (Var Modem_Mode : byte);

  begin { Go_Onhook }
  Clrbit (Modem_Mode, 7);
  Set_Modem (Modem_Mode)
  end;  { Go_Onhook }

Procedure Go_Offhook (Var Modem_Mode : byte);

  begin { Go_Offhook }
  SetBit (Modem_Mode, 7);
  Set_Modem (Modem_Mode)
  end;  { Go_Offhook }

Procedure Set_Ans_Mode (Var Modem_Mode : byte);

  begin { Set_Ans_Mode }
  Clrbit (Modem_Mode, 2);
  Set_Modem (Modem_Mode)
  end;  { Set_Modem_Mode }

Procedure Set_Org_Mode (Var Modem_Mode : byte);

  begin { Set_Org_Mode }
  Setbit (Modem_Mode, 2);
  Set_Modem (Modem_Mode)
  end;  { Set_Org_Mode }

Procedure Set_Baud (Baud : integer; Var Modem_Mode : byte);

  begin { Set_Baud }
  Case Baud of
    110 : Clrbit (Modem_Mode, 0);
    300 : Setbit (Modem_Mode, 0);
    else  Setbit (Modem_Mode, 0);
    end;
  Set_Modem (Modem_Mode)
  end;  { Set_Baud }

Procedure Enable_Xmit (Var Modem_Mode : byte);

  begin { Enable_Xmit }
  Setbit (Modem_Mode, 1);
  Set_Modem (Modem_mode)
  end;  { Enable_Xmit }

Procedure Disable_Xmit (Var Modem_Mode : byte);

  begin { Disable_Xmit }
  Clrbit (Modem_Mode, 1);
  Set_Modem (Modem_Mode)
  end;  { Disable_Xmit }

Function Carrier_Present : boolean;

  begin { Carrier_Present }
	{ If you have your serial port wired up to recieve a carrier	}
	{ detect signal then you should test for that bit, otherwise	}
	{ just return TRUE. }
  Carrier_Present := TRUE
{  Carrier_Present := Tstbit (Inp[Status_Reg_Modem], 6)	}
  end;  { Carrier_Present }

Function Ringing : boolean;

  begin { Ringing }
	{ Most ports can't detect ringing so just return FALSE.		}
  Ringing := FALSE
{  Ringing := not Tstbit (Inp[Status_Reg_Modem]), 7) }
  end;  { Ringing }

Function Modem_Char_Rdy : boolean;

  begin { Modem_Char_Rdy }
	{ Returns TRUE if data is available in the input port		}
	{ (does NOT read the data) }
  Modem_Char_Rdy := Tstbit (Inp[Status_Reg_Modem], 1)
  end;  { Modem_Char_Rdy }

Function Modem_In : char;

  begin { Modem_In }
	{ Reads the data port of the acoustic coupler.  May have to	}
	{ mask off bit 7 of the data if the sender is not treating it	}
	{ as part of the data byte sent. }
  Modem_In := chr(Inp[Modem_Rcv_Reg] & $7F)
  end;  { Modem_In }

Function Modem_Out (OutChar : char) : boolean;

  Function Modem_Busy : boolean;

    begin { Modem_Busy }
	{ Returns TRUE if the transmit buffer empty bit of status port	}
	{ indicates that the UART is still transmitting.		}
    Modem_Busy := not Tstbit (Inp[Status_Reg_Modem], 0)
    end;  { Modem_Busy }

  begin { Modem_Out }
  While Modem_Busy do;
  If Carrier_Present then
    begin
    Out [Modem_Xmit_Reg] := ord(OutChar);
    Modem_Out := TRUE
    end
  else
    Modem_Out := FALSE
  end;  { Modem_Out }

Procedure Delay;	{ delay's for 10 millisecond }

  Const
	Count = 477;
  Var
	I : integer;

  begin { Delay }
	{ Very machine dependent.  I am using a 5 MHz 8085, running	}
	{ Pascal MT+ 5.5 if that helps. }
  For I := 1 to Count do
  end;  { Delay }

Procedure Dial_a_Number (Var Modem_Mode : byte; Number : string);

  Var
	I, J,  Pulse_Count : integer;

  Procedure Pulse_Line;

    Var
	I : integer;
    begin { Pulse_Line }
    Go_Onhook (Modem_Mode);
    For I := 1 to 5 do
      Delay;			{ leave on for 50 ms }
    Go_Offhook (Modem_Mode);
    For I := 1 to 5 do
      Delay			{ leave off for 50 ms }
    end;  { Pulse_Line }

  begin { Dial_a_Number }
	{ Included as an example of how to do it.	}
  Go_Offhook (Modem_Mode);
  For I := 1 to 100 do
    Delay;
  For I := 1 to Length(Number) do
    If (Number[I] < '0') OR (Number[I] > '9') then
      begin
      Write (Number[I]);
      For J := 1 to 300 do	{ wait 3 seconds for non_digit }
	Delay
      end
    else
      begin
      Pulse_Count := ord(Number[I]) - $30;
      If Pulse_Count = 0 then
	Pulse_Count := 10;
      Write (Number[I]);
      For J := 1 to Pulse_Count do
	Pulse_Line;
      For J := 1 to 60 do
	Delay			{ 600 ms delay between digits }
      end;
  Writeln;
  Writeln('All right dummy, now that you''ve watched me, let''s see if');
  Writeln('you know how to dial a phone.  Make the connection, and hit');
  Writeln('RETURN when you get a carrier.');
  Readln
  end;  { Dial_a_Number }


Modend.
