Module DC_Hayes_Modem;

{		Written by Warren A. Smith		}
{	    Intended for use in the Public Domain	}
{			01/30/82			}

{ This set of routines will give you complete access to the functions	}
{ of a D.C. Hayes Modem.						}

{ Port assignments for D.C. Hayes S-100 Modem board }
Const
	Base_Register	= $10;
	Modem_Rcv_Reg	= $10;	{ Base_register		}
	Modem_Xmit_Reg	= $10;	{ Base_register		}
	Status_Reg_Modem= $11;	{ Base_register + 1	}
	Reg1Modem	= $11;	{ Base_register + 1	}
	Reg2Modem	= $12;	{ Base_register + 2	}

{ These routines require that you declare a global variable in your	}
{ main program that will hold the current status of the modem.  It	}
{ should be a BYTE type and will be passed into the various routines	}
{ that set the modems modes.	}

Procedure Init_Modem;

  Const	Char_Length     = 3;	{ 8 data bits	}
	Stop_bits	= 0;	{ 1 stop bits	}
	Parity_Inhibit	= 1;	{ no parity	}
	Parity_Type	= 1;	{ even parity	}

  begin { Init_Modem }
	{ Initializes the serial port on the modem to the above values.	}
	{ This is the only routine that outputs to Reg1Modem.	}
  Out [Reg1Modem] := SHL(Parity_Inhibit,4) ! SHL(Stop_bits,3) !
		     SHL(Char_Length,1) ! Parity_Type
  end;  { Init_Modem }

Procedure Set_Modem (Modebyte : byte);

  begin { Set_Modem }
	{ Used to set various modes of the modem, (this is the only	}
	{ routine that outputs to Reg2Modem).	}
  Out [Reg2Modem] := Modebyte
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

Procedure Set_Baud (Baud_Rate : integer; Var Modem_Mode : byte);

  begin { Set_Baud }
	{ The D.C. Hayes modem only allows 110 or 300 bps communication	}
	{ so those are the only values allowed.  Any other value results}
	{ in 300 baud.	}
  Case Baud_Rate of
    110 : Clrbit (Modem_Mode, 0);
    300 : Setbit (Modem_Mode, 0);
    else  Setbit (Modem_Mode, 0)
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
  Carrier_Present := Tstbit (Inp[Status_Reg_Modem], 6)
  end;  { Carrier_Present }

Function Ringing : boolean;

  begin { Ringing }
  Ringing := not Tstbit (Inp[Status_Reg_Modem], 7)
  end;  { Ringing }

Function Modem_Char_Rdy : boolean;

  begin { Modem_Char_Rdy }
  Modem_Char_Rdy := Tstbit (Inp[Status_Reg_Modem], 0)
  end;  { Modem_Char_Rdy }

Function Modem_In : char;

  begin { Modem_In }
	{ Some systems require that bit 7 of incoming data be masked	}
	{ off.  That is because the sender may be forcing bit 7 high.	}
	{ If the system you are talking to lets bit 7 be a real data	}
	{ bit then you will not want to mask it off as it is here.  This}
	{ setup will work for just about any time share service.	}
  Modem_In := chr(Inp[Modem_Rcv_Reg] & $7F)
  end;  { Modem_In }

Function Modem_Out (OutChar : char) : boolean;

	{ Modem_Out is a boolean function so that it can return the	}
	{ status of the line.  If carrier is lost you don't want to get	}
	{ hung up in a status loop, and it would be nice to know when	}
	{ carrier was actually lost.	}
  Function Modem_Busy : boolean;

    begin { Modem_Busy }
    Modem_Busy := not Tstbit (Inp[Status_Reg_Modem], 1)
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
	{ This loop was determined empirically.  I put it in a tight	}
	{ loop toggling an output port and attached a frequency counter	}
	{ to that port.  You may have to change the value of the	}
	{ constant for your machine.  I am using a 5 MHz 8085 on a	}
	{ Godbout dual processor board and Pascal MT+ ver. 5.5		}
  For I := 1 to Count do
  end;  { Delay }

Procedure Dial_a_Number (Var Modem_Mode : byte; Number : string);

  Var
	I, J, Pulse_Count : integer;

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
	{ If this routine doesn't seem to be able to actually dial, the	}
	{ problem is probably in the DELAY procedure.  If it is not	}
	{ delaying enough, the pulses will be too fast and the local	}
	{ phone exchange may not respond to them.  Try increasing the	}
	{ constant in DELAY (doubling it will not hurt).		}
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
  Writeln
  end;  { Dial_a_Number }

Modend.
