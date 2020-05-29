(*****************************************************
*
*		LONGLINE PROGRAM
*
*	This program was taken out of the Pascal/Z
*  manual, page 56. It is a demo on using Pascal/Z
*  STRING functions.
*
*  Typed/edited by Charlie Foster, Oct 1980
*  for the Pascal/Z Users Group
*****************************************************)

PROGRAM longline;

CONST
	linesize = 80;
TYPE
	  $string0 = string 0;
	$string255 = string 255;
VAR
	line : STRING linesize;
	word : STRING 80;

FUNCTION length (X : $string255) : INTEGER; EXTERNAL;
FUNCTION index (X, Y : $string255) : INTEGER; EXTERNAL;
PROCEDURE setlength ( VAR   X :  $string0; Y : INTEGER); EXTERNAL;

BEGIN
	WRITELN ('			      STRING DEMO');
	WRITELN;
	WRITELN ('Type one word at a time and this program',
		 ' will assemble the words into lines of  ',
		   linesize:1,' words each.');
	WRITELN;
	WRITELN ('Type, !"#$ ,to STOP');
	setlength (word, 0);	(* initialize word to 0 *)
	REPEAT
	  setlength (line, 0);	(* initialize line to 0 *)
	  WHILE
	       ( length (line) + length (word) < linesize ) and
	       ( index (word, '!"#$') = 0 ) DO
		BEGIN
		  APPEND (line, word);
		  IF length (line) < linesize THEN
		    APPEND (line, ' ');  (* word space word *)
		  WRITE ('The word is: ');
		  READLN (word);
		END;
		WRITELN ('The line is: ');
		WRITE (line);
	  UNTIL index (word, '!"#$') <> 0;
	  WRITELN;
	  WRITELN ('I am tired of this, I quit!');
END.
