Program Ring_Test;

{		Written by Warren A. Smith		}
{	    Intended for use in the Public Domain	}
{			01/30/82			}

{ This program utilizes the D.C. Hayes (or PMMI) modem to tell	}
{ you if your phone is ringing.  I only have one phone line in	}
{ my house and if my computer is on it I normally can't tell if	}
{ someone is calling.  This program will make your terminal tell}
{ you.								}

Var
	In_Char		: char;
	I		: integer;
	Just_Rang	: boolean;

{  ************   Found in CRT.ERL   ************  }
External Procedure ScreenClr;

External Procedure LineClr;

External Procedure GotoXY (X, Y : integer);

External Function KeyPressed (In_Char : char) : boolean;

{  ************   Found in DCMODEM.ERL (or PMMI.ERL)   ***********  }
External Function Ringing : boolean;

begin { Main }
Just_Rang := TRUE;
ScreenClr;
Repeat
  If Ringing then
    begin
    If not Just_Rang then
      begin
      GotoXY (1,1);
      LineClr;
      GotoXY (25, 11);
      Write('PHONE RINGING', chr(7));
      Just_Rang := TRUE
      end
    end
  else
    If Just_Rang then
      begin
      GotoXY (1,1);
      Write('Waiting for phone to ring');
      GotoXY (25, 11);
      LineClr;
      Just_Rang := FALSE
      end
Until KeyPressed (In_Char)
end.  { Main }
