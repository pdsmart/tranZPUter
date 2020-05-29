Module CRT_Televideo;

{		Written by Warren A. Smith		}
{	    Intended for use in the Public Domain	}
{			01/30/82			}

{ This set of routines is designed to support a Televideo 912/920 type	}
{ of terminal using direct I/O in CP/M (mainly for full screen type	}
{ applications).								}

{$E-}	{ These constants are not to be used by external routines.	}
Const
	Direct_IO = 6 ;	{ CP/M direct I/O function }

{ Constants used by GOTOXY routine, may have to be changed for your	}
{ terminal.  It is assumed the upper left corner is 0,0.		}
{ The following constants are set up for a Televideo 912/920.		}
	Load_Cursor_Char = '=';
	X_PLAC = 4 ;	{ Byte position of the X coordinate of escape seq. }
	Y_PLAC = 3 ;	{ Byte position of the Y coordinate of escape seq. }
	MAX_X  = 79 ;	{ how many characters wide your screen is -1 }
	MAX_Y  = 23 ;	{ how many rows your screen has - 1 }
	X_OFF  = 32 ;	{ offset added to X coordinate before sending to crt }
	Y_OFF  = 32 ;	{ offset added to Y coordinate before sending to crt }
{$E+}

External Function @BDOS(Func,Parm:integer):integer;

Function Con_In : char ;	{ non-echoed input from the console	}

  Const
	Parm = 255;

  Begin { Con_In }
  Con_In := chr(@BDOS(Direct_IO, Parm))
  end ; { Con_In }

Procedure Con_Out (Out_Char : char) ;

  Var
	Dummy : integer ;

  Begin { Con_Out }
  Dummy := @BDOS(Direct_IO, ord(Out_Char))
  end ; { Con_Out }

Function KeyPressed (Var In_Char : char) : Boolean ;

  Begin { KeyPressed }
  In_Char := chr (@BDOS(Direct_IO, -1));
  KeyPressed := In_Char <> chr(0)
  end ; { KeyPressed }

Function Get_Console : char ;	{ waits for a single character from the	}
				{ console.  Does not echo it.	}

  Var
	In_Char : char;

  Begin { Get_Console }
  While not KeyPressed (In_Char) do;
  Get_Console := In_Char
  end ; { Get_Console }

Procedure GoToXY (X, Y : integer) ;

  Var
	BUFFER : array [1..4] of char ;

  Begin { GoToXY }
  BUFFER [1] := chr(27);	{ Escape character }
  BUFFER [2] := Load_Cursor_Char;
  If X < 0 Then
    BUFFER [X_PLAC] := chr(X_OFF)
  else
    If X > MAX_X then
      BUFFER [X_PLAC] := chr(MAX_X + X_OFF)
    else
      BUFFER [X_PLAC] := chr(X + X_OFF) ;

  If Y < 0 then
    BUFFER [Y_PLAC] := chr(Y_OFF)
  else
    If Y > MAX_Y then
      BUFFER [Y_PLAC] := chr(MAX_Y + Y_OFF)
    else
      BUFFER [Y_PLAC] := chr(Y + Y_OFF) ;

  Con_Out(Buffer[1]) ;
  Con_Out(Buffer[2]) ;
  Con_Out(Buffer[3]) ;
  Con_Out(Buffer[4])

  end ; { GoToXY }

Procedure Home ;

  Begin { Home }
  Con_Out (chr($1E))
  end ; { Home }

Procedure ScreenClr ;

  Begin { ScreenClr }
  Con_Out (chr(26))
  end ; { ScreenClr }

Procedure LineClr;

  Begin { LineClr }
  Con_Out (chr(27));
  Con_Out ('t')
  end;  { LineClr }

Procedure Read_Cursor (Var X, Y : integer);

    Var
	In_Char : char;

    begin { Read_Cursor }
	{ Request cursor coordinates from TeleVideo 912 or 920.  A 2 MHz}
	{ 8080 may have trouble getting this from a 9600 baud line.	}
	{ If this routine doesn't work, try slowing your terminals baud	}
	{ rate down to 4800 or 2400.	}
    ConOut (chr(27));
    ConOut ('?');
    While not KeyPressed (In_Char) do;
    Y := ord(In_Char) - Y_OFF;
    While not KeyPressed (In_Char) do;
    X := ord(In_Char) - X_OFF;
    While not KeyPressed (In_Char) do;
    { this last character is supposed to be a CR, it can be ignored.	}
    end;  { Read_Cursor }

ModEnd.
