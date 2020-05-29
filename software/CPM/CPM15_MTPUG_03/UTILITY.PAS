Module Utility ;

{		Written by Warren A. Smith		}
{	   Intended for use in the Public Domain	}
{			01/30/82			}

{ This only has one routine so far but what the heck.	}

Function Upper (In_Char : char) : char ;

{ I don't like having to redo this in all my interactive programs,	}
{ I thought you may not like to either.					}

  Begin { Upper }
  If (In_Char >= 'a') and (In_Char <= 'z') then
    Upper := chr( ord(In_Char) - 32)
  else
    Upper := In_Char
  end ; { Upper }

ModEnd.
