Module Circular_Queue ;

{		Written by Warren A. Smith		}
{	   Intended for use in the public domain	}
{			01/30/82			}

{ These routines are meant to give you a way to handle circular queues.	}
{ Or FIFO buffers, whatever you want to call them.  They are very handy	}
{ for buffering between asynchronous events and I got tired of having	}
{ to rewrite them so I put them into this library.  I hope you find	}
{ them useful (or instructive, whatever).				}

Type
	Q_range	      = Min_Q..Max_Q ;
	Q_Type	      = byte ;		{ Could be any type }
	Queue	      = record
			Q_not_empty,
			Q_not_full	: boolean ;
			Q_head,
			Q_tail		: Q_Range ;
			Q		: array [Q_Range] of Q_Type ;
		    end ;

Function Put_Q (Var Cur_Q : Queue ; Var Cur_Entry : Q_Type) : boolean ;

  begin { Put_Q }
  With Cur_Q do
    If Q_not_full then
      begin
      Q[Q_head] := Cur_Entry ;
      If Q_head = Max_Q then
        Q_head := Min_Q
      else
        Q_head := Q_head + 1 ;
      Q_not_full := Q_head <> Q_tail ;
      Q_not_empty := TRUE ;
      Put_Q := TRUE
      end
    else
      Put_Q := FALSE
  end ; { Put_Q }

Function Get_Q (Var Cur_Q : Queue ; Var Cur_Entry : Q_Type) : boolean ;

  begin { Get_Q }
  With Cur_Q do
    If Q_not_empty then
      begin
      Cur_Entry := Q[Q_tail] ;
      If Q_tail = Max_Q then
        Q_tail := Min_Q
      else
        Q_tail := Q_tail + 1 ;
      Q_not_full := TRUE ;
      Q_not_empty := Q_head <> Q_tail ;
      Get_Q := TRUE
      end
    else
      Get_Q := FALSE
  end ; { Get_Q }

Procedure Init_Q (Var Cur_Q : Queue);

  begin { Init_Q }
  Q_not_Empty := FALSE;
  Q_not_Full  := TRUE;
  Q_head      := Min_Q;
  Q_tail      := Q_head
  end;  { Init_Q }

ModEnd.
