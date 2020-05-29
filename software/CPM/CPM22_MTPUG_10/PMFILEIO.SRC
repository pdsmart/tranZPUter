{*-------------------------------------------*
 | Pasmat - All Direct I/O is in this Module |
 *-------------------------------------------*}
{$K0}  {$K7}  {$K12}  {$K14}  {$K15}
module pmfileio;
 {$L-}
 {$I PMDEFS.INC}
 {$L+}

  var
    finp: file of packed array [0..ibufsize] of char;
    fout: text;

  external procedure @hlt;
   {check file name for legality}
  external function cpmname(str: string): boolean;
   {pasmat entry points}
  external procedure flushsymbol;
  external procedure newline(indent: lineindex);

{$p----------------------------*
 | Terminate and Print Message |
 *-----------------------------*}


  procedure finaldata;

    var
      fstatus: integer;

    begin  {print summary data}
      if not silentmode then
	begin
	if (overflows > 0) or (comoverflows > 0) then
	  writeln;
	writeln(inputline - 1: 1, ' lines input, ', currentline: 1,
		' lines output');
	if overflows = 1 then
	  writeln('Token too wide for output at output line ',
		  firstoverflow: 1)
	else if overflows > 1 then
	  writeln('Token too wide for output in ', overflows: 1,
		  ' places, first at output line ', firstoverflow: 1);
	if comoverflows = 1 then
	  writeln('Comment too wide for output at output line ',
		  firstcomoverflow: 1)
	else if comoverflows > 1 then
	  writeln('Comment too wide for output in ', comoverflows: 1,
		  ' places, first at output line ', firstcomoverflow:
	   1);
	end;
      close(fout, fstatus);
      if fstatus = 255 then
	writeln('Unable to close output file');
    end;  {finaldata}
{$p-----------------*
 | Character output |
 *------------------*}


  procedure writea(ch: char);

    var
      i: lineindex;

    begin  {Write a character to the output buffer. If necessary (which
	    it always is after the buffer is filled), write the
	    previous contents of the buffer}
      charcount := charcount + 1;
      oldest := charcount mod bufsize;
      with unwritten[oldest] do
	begin
	if charcount > bufsize then
	  if actionis = graphic then
	    write(fout, character)
	  else if actionis = spaces then
	    begin
	    for i := 1 to spacing do
	      write(fout, ' ');
	    end
	  else  {actionis = beginline}
	    begin
	    if outputline > 1 then  {not initial begin}
	      begin
	      writeln(fout);
	      end;
	    outputline := outputline + 1;
	    for i := 1 to spacing div tabinterval do
	      write(fout, chr(tab));
	    for i := 1 to spacing mod tabinterval do
	      write(fout, ' ');
	    end;
	actionis := graphic;
	character := ch;
	writecol := writecol + 1;
	if ch = chr(tab) then
	  writecol := writecol + tabinterval - (writecol mod
		      tabinterval);
	end;  {with}
    end;  {writea}


  procedure flushbuffer;

    var
      i: 0..bufsize;

    begin  {flush any unwritten buffer}
      for i := 1 to bufsize do
	writea(' ');
      charcount := 0;
      writeln(fout);
    end;  {flushbuffer}

{$P----------------*
 | Character Input |
 *-----------------*}


  procedure getchar;

    begin  {read next character from input file}
      repeat
	if endfile then
	  ch := chr($1A)
	else
	  ch := gnb(finp);
	if (ch = chr($1A)) or (ch = chr($FF)) then
	  begin  {eof}
	  ch := ' ';
	  endfile := true;
	  exit
	  end;  {eof}
	ch := chr(ord(ch) & $7F);  {strip hi bit}
      until ch <> chr($0A);  {skip over line feeds}
      if ch = chr($0D) then
	begin  {eoln}
	if newinputline then
	  blankline := true
	else
	  newinputline := true;
	column := 0;
	inputline := inputline + 1;
	if not formatting then
	  newline(0);
	ch := ' ';
	end  {eoln}
      else
	begin  {normal}
	column := column + 1;
	if not formatting then
	  writea(ch);
	if ch = chr(tab) then
	  column := column + tabinterval - (column mod tabinterval);
	end  {normal}
    end  {getchar} ;

{$p---------------*
 | Error Handling |
 *----------------*}


  procedure lineoverflow;

    begin  {token too long for output line, note it}
      flushbuffer;
      overflows := overflows + 1;
      if overflows = 1 then
	firstoverflow := currentline - 1;
      if not silentmode then
	begin
	writeln(' ');  {put following message on separate line}
	writeln('Warning - token too wide for output: ', 'input line ',
		inputline: 1, ', output line ', currentline - 1: 1);
	end  {not silentmode} ;
    end;  {lineoverflow}


  procedure comentoverflow;

    begin  {block comment too long for output line, note it}
      comoverflows := comoverflows + 1;
      if comoverflows = 1 then
	firstcomoverflow := currentline;
      if not silentmode then
	begin
	writeln(' ');  {put following message on separate line}
	writeln('Warning - comment too wide for output: ',
		'input line ', inputline: 1, ', output line ',
		currentline: 1);
	end  {not silentmode} ;
    end;  {comentoverflow}


  procedure abort(line: integer;
		  kind: abortkind);

   {the argument 'line' is not used in CP/M version}

    begin  {abort formatting}
      flushsymbol;
      newformatting := false;
      formatting := false;
      if not silentmode then
	begin
	writeln(' ');
	if kind = syntax then
	  writeln('Syntax error: input line ', inputline: 1,
		  ', output line ', currentline - 2: 1)
	else if kind = nesting then
	  writeln('Too many levels: input line ', inputline: 1,
		  ', output line', currentline - 1: 1)
	else
	  writeln('Bad comment: input line ', inputline: 1,
		  ', output line ', currentline - 1: 1);
	end  {not silentmode} ;
      writea(ch);
      while not endfile do
	getchar;
      flushbuffer;
      finaldata;
      @hlt;
    end;  {abort}

{$p-----------------------*
 | Get input/output files |
 *------------------------*}


  procedure getfiles;

    var
      name: string;
      ch: char;


    procedure gname;

      var
	i: integer;

      begin  {gname}
	name := '';
	i := 1;
	while (i <= length(clinearg)) and (clinearg[i] = ' ') do
	  i := i + 1;  {skip leading blanks}
	while (i <= length(clinearg)) and (clinearg[i] <> ' ') do
	  begin  {copy up to next blank}
	  ch := clinearg[i];
	  i := i + 1;
	  if ch in ['a'..'z'] then
	    ch := chr(ord(ch) - $20);  {ensure upper case}
	  name := concat(name, ch);
	  end;
	if i > 1 then  {remove name}
	  delete(clinearg, 1, i - 1);
      end  {gname} ;


    procedure usage(str: string);

      begin  {print error message and abort}
	writeln(str);
	writeln('Usage:  pasmat infile outfile options');
	@hlt
      end  {usage} ;

    begin  {getfiles}
      gname;
      assign(finp, name);
      reset(finp);
      if ioresult = 255 then
	usage(concat('Unable to open ', name, ' for input'));
      gname;
      if not cpmname(name) then
	usage(concat('Illegal CP/M name: ', name));
      assign(fout, name);
      rewrite(fout);
      if ioresult = 255 then
	usage(concat('Unable to open ', name, ' for output'));
    end;  {getfiles}

modend .
