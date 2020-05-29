{++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+							+}
{+  PROGRAM TITLE:	Copy With Prefixed Char Count	+}
{+							+}
{+  WRITTEN BY: 	George W. Cherry [1]		+}
{+							+}
{+  Modified by Raymond E. Penley, 7 Oct 1980		+}
{+	The program reads in whole lines instead	+}
{+  of single characters then prints the whole		+}
{+  linked list of "lines".				+}
{+							+}
{+  [1] "Pascal Programming Structures", pgs 232-237	+}
{+    Reston Publishing Company, Inc.			+}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
PROGRAM CopyWithPrefixedCharCount;

CONST
  default = 80;
  input = 0;	{Pascal/Z needs this crutch}

TYPE
  items 	= string default;
  P_pointer	= ^queuecell;
  queuecell	= record
		    line : items;
		    next : P_pointer
		  end;
  S$0	= string 0;
  S$255	= string 255;

VAR
  charcount	: integer;
  currentline	: items;	{the current line}
  FrntPtr,
  RearPtr	: P_pointer;
  ch		: char;
  linecount	: integer;
  EndOfLine,
  EndOfFile,
  done		: boolean;
  ix		: integer;

Function  length(x: S$255): integer; external;

Procedure setlength(var x: S$0; y: integer); external;

Procedure KEYIN(VAR cix: char); EXTERNAL;

Procedure InitializeQueue;
begin
  FrntPtr := NIL;
  RearPtr := NIL;
end {of InitializeQueue};

Procedure Queue( currentline : items );
VAR
  new_ptr : P_pointer;
begin
  NEW(new_ptr);			{reserve a new queuecell }
  new_ptr^.line := currentline;
  new_ptr^.next := NIL;
  If FrntPtr = NIL then
    FrntPtr := new_ptr
  Else
    RearPtr^.next := new_ptr;
  RearPtr := new_ptr;		{complete the circular queue}
end {of Queue};

Function QueueIsEmpty : BOOLEAN;
begin
  QueueIsEmpty := (FrntPtr = NIL);
end {of queueIsEmpty};

Procedure Serve(var current: items);
VAR
  curitem : P_pointer;
begin
  If QueueIsEmpty then
    {nothing to do the queue is empty}
  Else
    begin
      curitem := FrntPtr;
      current := curitem^.line;
      FrntPtr := FrntPtr^.next;
      If FrntPtr = NIL then
	RearPtr := NIL;
    end;
end {of serve};

Procedure Read_a_chunck;
VAR
  done_reading_lines : BOOLEAN;

   Procedure GetC(VAR ch: char);
   { Recognizes "control-E" as End of File on the console. }
   begin
     KEYIN(ch);write(ch);
     endofline := ( ord(ch)=13 );
     endoffile := ( ord(ch)=5 );
     If ( endofline ) OR ( endoffile ) then ch := ' ';
   end;

   Procedure GetL(var LINE: items);
   begin
     setlength(LINE,0);
     GetC(ch);
     while not( EndOfLine OR EndOfFile ) DO
       begin
         charcount := charcount + 1;
         append(line,ch);
         GetC(ch);
       end;
   end; {GetLine}

begin {of Read_a_chunck}
  done_reading_lines := FALSE;
  while not done_reading_lines do
    begin
      write('?');
      GetL(currentline);Writeln;
      If (length(currentline)=0) OR ( EndOfFile ) then
         done_reading_lines := TRUE
      Else
        Queue(currentline)
    end;
end;{of Read_a_chunck}

Procedure Process_chunck;
begin
  linecount := 0;
  while not QueueIsEmpty do
    begin
      linecount := linecount + 1;
      write(linecount:3, ': ');
      Serve(currentline);
      Writeln(currentline);
    end;{while not queueisempty}
  Writeln;
end;{of Process_chunck}

BEGIN {Main Program}
  for ix:=1 to 25 Do writeln;	{ clear the crt }
  InitializeQueue;
  EndOfFile := FALSE;
  while not EndOfFile do
    begin
      { INITIALIZE }
      charcount := 0;
      MARK(chunck);
      Read_a_chunck;
      Process_chunck;
      RELEASE(chunck);
    end;{while not EndOfFile}
END.
