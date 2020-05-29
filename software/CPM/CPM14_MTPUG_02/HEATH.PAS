MODULE HEATHLIB;

(* This module is a library for the special functions available to the
   H-19 terminal *)

const
   cpm = 5;

procedure reverse;

(* this procedure sets the H-19 for reverse video *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1b /
	   "CALL / cpm /
	   "MVI C / 6 /
	   "MVI E / 'p' /
	   "CALL / cpm )
end;

procedure normal;

(* this procedure sets the H-19 for normal viedo *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1b /
	   "CALL / cpm /
	   "MVI C / 6 /
	   "MVI E / 'q' /
	   "CALL / cpm )
end;

procedure save_cursor;

(* this procedure saves the location of the cursor.  It is
   used before attempting to write to the 25th line  *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1b /
	   "CALL / cpm /
	   "MVI C / 6 /
	   "MVI E / 'j' /
	   "CALL / cpm )
end;

procedure restore_cursor;

(* this procedure restores the cursor to the position which
   was previously saved  *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1b /
	   "CALL / cpm /
	   "MVI C / 6 /
	   "MVI E / 'k' /
	   "CALL / cpm )
end;

procedure put_cursor (x,y:integer);

(* this procedure positions the cursor to the location x,y where
   allowable values of x are 1 to 25, and y are 1 to 80 inclusive *)

begin
   x := x+31;
   y := y+31;
   inline ("MVI C / 6 /
	   "MVI E / $1b /
	   "CALL / cpm /
	   "MVI C / 6 /
	   "MVI E / 'Y' /
	   "CALL / cpm /
	   "MVI C / 6 /
	   "LXI H / x /
	   "MOV E,M /
	   "CALL / cpm /
	   "MVI C / 6 /
	   "LXI H / y /
	   "MOV E,M /
	   "CALL / cpm )
end;

procedure get_cursor (var x,y: integer);

(* this procedure fetches the location of the cursor *)
var
   str: array [1..4] of char;
   i: integer;

begin
   inline ("MVI C / 6 /
	   "MVI E / $1b /
	   "CALL / CPM /
	   "MVI C / 6 /
	   "MVI E / 'n' /
	   "CALL / CPM );
   for i := 1 to 4 do read (str[i]);
   x := ord (str[3])-31;
   y := ord (str[4])-31
end;


	procedure put25;

(* this procedure enables the 25th line and positions the cursor.
   there *)

begin
   save_cursor;
   inline ("MVI C / 6 /
	   "MVI E / $1b /
	   "CALL / cpm /
	   "MVI C / 6 /
	   "MVI E / 'x' /
	   "CALL / cpm /
	   "MVI C / 6 /
	   "MVI E / '1' /
	   "CALL / cpm );
   put_cursor (25,1)
end;

procedure clear_line;

(* This procedure is used to clear a line.  Usually, it will be used
   before the twenty-fifth line is rewritten. *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1b /
	   "CALL / cpm /
	   "MVI C / 6 /
	   "MVI E / 'l' /
	   "CALL / cpm )
end;

procedure clear_screen;

(* this procedure clears the screen of the H-19 and
   homes the cursor to the upper left position *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1b /
	   "CALL / cpm /
	   "MVI C / 6 /
	   "MVI E / 'E' /
	   "CALL / cpm )
end;

procedure clear_bottom;

(* this procedure clears the bottom part of the H-19 screen
   including the cursor position *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1B /
	   "CALL  / CPM /
	   "MVI C / 6 /
	   "MVI E / 'J' /
           "CALL  / CPM )
end;

procedure clear_top;

(* this procedure clears the upper part of the H-19 screen
   including the cursor position *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1B /
	   "CALL  / CPM /
	   "MVI C / 6 /
	   "MVI E / 'b' /
	   "CALL  / CPM )
end;

procedure eol;

(* this procedure erases to the end of line *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1B /
	   "CALL  / CPM /
	   "MVI C / 6 /
	   "MVI E / 'K' /
	   "CALL  / CPM )
end;

procedure ebl;

(* this procedure erases to the start of the line *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1B /
	   "CALL  / CPM /
	   "MVI C / 6 /
	   "MVI E / 'o' /
	   "CALL  / CPM )
end;

function funct_key: char;

(* this function tests the input stream until it finds
   the start of an escape sequence.  it then returns
   the second character in the sequence *)

var
   ch: char;

begin
   inline ("MVI E / $FF /
	   "MVI C / 6 /
	   "CALL  / CPM /
	   "CPI   / $1B /
	   "JNZ   / *-9 ); (* THIS FETCHES THE ESCAPE KEY *)
   inline ("MVI E / $FF /
	   "MVI C / 6 /
	   "CALL  / CPM /
	   "ORA A /
	   "JZ    / *-8 /
	   "STA   / CH  ); (* THIS GETS THE ESCAPE CHARACTER *)
   funct_key := ch
end;

procedure cursor_up;

(* this procedure moves the cursor up one line *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1B /
	   "CALL / CPM /
	   "MVI C / 6 /
	   "MVI E / 'A' /
	   "CALL / CPM )
end;

procedure cursor_down;

(* this procedure moves the cursor down one line *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1B /
	   "CALL / CPM /
	   "MVI C / 6 /
	   "MVI E / 'B' /
	   "CALL / CPM )
end;

procedure cursor_left;

(* this procedure moves the cursor to the left one character *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1B /
	   "CALL / CPM /
	   "MVI C / 6 /
	   "MVI E / 'D' /
	   "CALL / CPM )
end;

procedure cursor_right;

(* this procedure moves the cursor to the right one character *)

begin
   inline ("MVI C / 6 /
	   "MVI E / $1B /
	   "CALL / CPM /
	   "MVI C / 6 /
	   "MVI E / 'C' /
	   "CALL / CPM )
end;

modend.

