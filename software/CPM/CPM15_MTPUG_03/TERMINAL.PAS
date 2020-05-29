Program Terminal;

{		Written by Warren A. Smith		}
{	    Intended for use in the Public Domain	}
{			01/30/82			}

{ This program is intended to give you the capability to use your	}
{ computer as a dumb terminal connected to another computer.  It can	}
{ operate in full or half duplex and can be in a test mode where it	}
{ will display all the characters coming in in hex form (unless they	}
{ are printable.  This latter is handy if you are trying to talk to an	}
{ unknown device and you want to find out what it is sending to cause	}
{ your screen to behave so funny.					}
{ The program can also convert carriage returns to CNTL-S (or DC3)	}
{ which is useful in a TWX network or when talking to some IBM systems	}
{ which only accept teletypes that are configured for TWX (my case, and	}
{ the reason the feature is in here.					}

Var
	Modem_Mode : byte;	{ must be used to hold modem's mode }
	I	: integer;
	Number	: string;
	Quit,
	Half_Duplex,
	Test_Line,
	Xoff	: boolean;
	ESC_Chr,
	Control_Code,
	In_Char,
	Answer	: char;

{  ***********   Found in CRT.ERL   ************  }
External Procedure ScreenClr;

External Procedure GotoXY (X, Y : integer);

External Procedure ConOut (OutChar : char);

External Function KeyPressed (Var In_Char : char) : boolean;

External Function Get_Console : char;

{  ************   Found in UTILITY.ERL   ************  }
External Function Upper (In_Char : char) : char;

{  ************   Found in DCMODEM.ERL   ************  }
External Procedure Init_Modem;

External Procedure Set_Modem (Modebyte : byte);

External Procedure Go_Onhook (Var Modem_Mode : byte);

External Procedure Go_Offhook (Var Modem_Mode : byte);

External Procedure Set_Ans_Mode (Var Modem_Mode : byte);

External Procedure Set_Org_Mode (Var Modem_Mode : byte);

External Procedure Set_Baud (Baud : integer; Var Modem_Mode : byte);

External Procedure Enable_Xmit (Var Modem_Mode : byte);

External Procedure Disable_Xmit (Var Modem_Mode : byte);

External Function Carrier_Present : boolean;

External Function Ringing : boolean;

External Function Modem_Char_Rdy : boolean;

External Function Modem_In : char;

External Function Modem_Out (OutChar : char) : boolean;

External Procedure Delay;	{ delay's for 10 millisecond }

External Procedure Dial_a_Number (Var Modem_Mode : byte; Number : string);



Function Perform_Function (Control_Char : char) : boolean;

  Var
	Dummy_Boolean : boolean;

  begin { Perform_Function }
  Case Control_Char of
  '@' : begin
	Half_Duplex := not Half_Duplex;
	If Half_Duplex then
	  Writeln ('Half_Duplex')
	else
	  Writeln ('Full Duplex');
	Perform_Function := TRUE
	end;
  'A' : Perform_Function := FALSE;
  'B' : begin
	Test_Line := not Test_Line;
	Perform_Function := TRUE
	end;
  else
  end
  end;  { Perform_Function }

Procedure Dumb;

  Var
	Terminator, In_Char, In_Mod,
	Control_Char, Dummy_Char	: char;
	Quit				: boolean;

  begin { Dumb }
  In_Char := chr(0);
  Terminator := chr(26);	{ CNTL-Z }
  Quit := FALSE;

  While (In_Char <> Terminator) AND not Quit do
    begin
    If KeyPressed (In_Char) then
      begin
      If In_Char = chr(13) then	{ carriage return }
	In_Char := chr(19);	{ control-S	  }
      If In_Char = ESC_Chr then
	begin
	Control_Char := Get_Console;
	Dummy_Char := Get_Console;	{ should be a carriage return	}
	Quit := not Perform_Function (Control_Char)
	end
      else
	If Modem_Out (In_Char) then
	  begin
	  If Half_Duplex then
	    ConOut (In_Char)
	  end
	else
	  begin
	  Writeln ('Carrier Lost');
	  Quit := TRUE
	  end
      end;

    If Modem_Char_Rdy then
      begin
      In_Mod := Modem_In;
      If Test_Line then
	If (In_Mod >= ' ') AND (In_Mod <= '~') then
	  ConOut (In_Mod)
	else
	  begin
	  WriteHex (Output, In_Mod, 1);
	  Writeln
	  end
      else
	ConOut (In_Mod)
      end;

    If not Carrier_Present then
      begin
      Writeln ('Carrier Lost');
      Quit := TRUE
      end
    end
  end;  { Dumb }

Procedure Title_Page;

  begin { Title_Page }
  Writeln;
  Writeln('	*****************************************');
  Writeln('	*					*');
  Writeln('	*      Written by Warren A. Smith	*');
  Writeln('	*					*');
  Writeln('	*	 For the Public Domain		*');
  Writeln('	*					*');
  Writeln('	*****************************************');
  Writeln;
  Writeln('The function keys of the Televideo 920 are used as follows:');
  Writeln('	F1	- Toggle between Half and Full Duplex');
  Writeln('	F2	- Terminate connection and hang up');
  Writeln('	F3	- Toggle test mode');
  Writeln;
  Writeln(' If you do not have a Televideo 912/920 you may duplicate the');
  Writeln(' function keys by hitting a CNTL-A followed by');
  Writeln('	   @      (for F1)');
  Writeln('	   A	  (for F2)');
  Writeln('	   B	  (for F3)');
  Writeln(' followed by a carriage return.');
  Writeln;
  Write  ('Hit any key to continue. ');
  While not KeyPressed (In_Char) do;
  ScreenClr;
  end;  { Title_Page }

begin { Main }

ESC_Chr := chr(01);

Half_Duplex := TRUE;
Test_Line := FALSE;

ScreenClr;

Title_Page;

Writeln('Answer N to the following question if you don''t understand it.');
Writeln('It is giving you the option to convert carriage returns to CNTL-S.');
Writeln('This is useful for TWX networks and some IBM systems.  Use N if');
Writeln('you are unsure.');
Write('Will you be using X-Off (carriage return = cntl-S) (Y or N)? ');
Read (Answer);
Writeln;
Xoff := Upper(Answer)='Y';

Modem_Mode := 0;

Init_Modem;

Write ('Number Please - ');
Readln (Number);

Writeln ('Dialing');

Dial_a_Number (Modem_Mode, Number);

Set_Baud (300, Modem_Mode);

Set_Org_Mode (Modem_Mode);

Enable_Xmit (Modem_Mode);

I := 0;		{ Set up for 20 second timeout }
While (I < 2000) AND (not Carrier_Present) do
  begin
  If KeyPressed (In_Char) then
    If In_Char = ESC_Chr then
      begin
      Control_Code := Get_Console;
      In_Char	   := Get_Console;	{ supposed to be CR }
      Quit := not Perform_Function (Control_Code)
      end;
  Delay;
  I := I + 1
  end;

If Carrier_Present then
  begin
  Writeln ('Connection made');
  If not Quit then
    Dumb
  end
else
  Writeln ('No carrier found, check number - ', Number);

Go_Onhook (Modem_Mode);

Writeln ('Hanging Up');

Writeln ('Program terminated')

end.
