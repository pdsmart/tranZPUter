{*--------------------------------------*
 | Pasmat Comment Formatting Procedures |
 *--------------------------------------*}
{$K0}  {$K7}  {$K12}  {$K13}  {$K14}  {$K15}
module comment;
 {$L-}
 {$I PMDEFS.INC}
 {$L+}

  external procedure abort(line: integer;
			   kind: abortkind);
  external procedure comentoverflow;
  external procedure getchar;
  external procedure getfiles;
  external procedure indentplus(delta, line: integer);
  external procedure printline(indent: integer);
  external procedure space(n: integer);
  external procedure symbolput(thischar: char);
  external procedure undent;
  external procedure writea(ch: char);

{$p------------------------*
 | Block Comment Character |
 *-------------------------*}


  procedure blkcomchar(character: char);

    begin  {Write a character for a block comment. The comment
	    formatting must be terminated with a call to
	    adjustblkcoment. The comment is copied exactly, and if it
	    will not fit within the outlinelen a message will be
	    printed.}
      if endfile then
	abort(linenumber, syntax);
      if formatting then
	if newinputline then
	  begin
	  if writecol > outlinelen then
	    comentoverflow;
	  printline(column);
	  firstinputline := false;
	  newinputline := false;
	  end
	else
	  writea(character);
    end;  {blkcomchar}
{$p----------------------------*
 | Statement Comment Character |
 *-----------------------------*}


  procedure breakstatcoment;

    var
      extralen: integer;  {length from last break}
      comindent: integer;  {amount to indent the extra}

    begin  {Break a statement comment at the last break. Assumes
	    (statbreak <> 0) and (charcount - statbreak < bufsize)}
      extralen := charcount - statbreak + 1;
      if writecol - extralen > maxlinelen then
	abort(linenumber, comformat)
      else
	begin  {we can at least write it}
	if writecol - extralen > outlinelen then
	  comentoverflow;
	comindent := outlinelen - extralen;
	if comindent < 0 then
	  comindent := 0
	else if comindent > indent then
	  comindent := indent;
	with unwritten[statbreak mod bufsize] do
	  begin
	  actionis := beginline;
	  spacing := comindent;
	  end;
	currentline := currentline + 1;
	writecol := comindent + extralen;
	end;
    end;  {breakstatcoment}


  procedure statcomchar(character: char);

    begin  {Take a statement character and format it. assumes that
	    statbreak and statblank are initialized before the first
	    character and are unchanged thereafter. The procedure
	    adjuststatcoment must be called after the comment is done}
      if endfile then
	abort(linenumber, syntax);
      if formatting then
	if (character = ' ') or (character = chr(tab)) then
	  begin
	  if not statblanks then
	    begin
	    if (writecol > outlinelen) and (statbreak <> 0) then
	      breakstatcoment;
	    writea(' ');
	    statbreak := charcount;
	    statblanks := true;
	    end;
	  end
	else
	  begin
	  writea(character);
	  statblanks := false;
	  end;
    end;  {statcomchar}
{$p-----------------------*
 | Do compiler directives |
 *------------------------*}


  procedure docompilerdirectives(block: boolean);

    begin  {scan off compiler directives}
      while (ch <> '[') and (ch <> '*') and (ch <> '}') do
	begin
	if block then
	  blkcomchar(ch)
	else
	  statcomchar(ch);
	getchar;
	end;
    end;  {docompilerdirectives}
{$p----------------------*
 | doformatterdirectives |
 *-----------------------*}


  procedure doformatterdirectives(block: boolean  {block comment} ;
				  cline: boolean  {control line} );

    var
      optchar: char;  {which option specified}


    procedure copyachar;

      begin  {copy a character and get a new one}
	if cline then
	  begin
	  if length(clinearg) = 0 then
	    ch := '}'
	  else
	    begin
	    ch := clinearg[1];
	    delete(clinearg, 1, 1)
	    end
	  end
	else
	  begin
	  if block then
	    blkcomchar(ch)
	  else
	    statcomchar(ch);
	  getchar;
	  end;
      end;  {copyachar}


    procedure switchdir(var switch: boolean);

      begin  {read and set a switch directive, if char is not + or -,
	      the value is unchanged}
	if ch = '+' then
	  begin
	  switch := true;
	  copyachar
	  end
	else if ch = '-' then
	  begin
	  switch := false;
	  copyachar
	  end;
      end;  {switchdir}


    procedure numdir(var value: integer;
		     min, max: integer  {limits} );

      var
	tempval: integer;  {value being accumulated}

      begin  {Read a numeric directive and set value. If the value is
	      out of bounds it is set to the limit value}
	if ch = '=' then
	  copyachar;
	if (ch >= '0') and (ch <= '9') then
	  begin
	  tempval := 0;
	  repeat
	    if tempval <= (maxint - 9) div 10 then
	      tempval := tempval * 10 + (ord(ch) - ord('0'));
	    copyachar;
	  until (ch < '0') or (ch > '9');
	  if tempval < min then
	    tempval := min;
	  if tempval > max then
	    tempval := max;
	  value := tempval;
	  end;
      end;  {numdir}

    begin  {doformatterdirectives: read a formatter directive and set
	    flags and value appropriately}
      copyachar;
      repeat
	if ch in validdirectives then
	  begin
	  optchar := ch;
	  copyachar;
	  case optchar of
	    'b', 'B':
	      switchdir(bunching);
	    'c', 'C':
	      numdir(comentspaces, 0, maxlinelen);
	    'f', 'F':
	      switchdir(newformatting);
	    'l', 'L':
	      switchdir(litcopy);
	    'o', 'O':
	      begin
	      numdir(outlinelen, 1, maxlinelen);
	      onehalfline := outlinelen div 2;
	      fiveeighthline := (5 * outlinelen) div 8;
	      threefourthline := (3 * outlinelen) div 4;
	      end;
	    'p', 'P':
	      switchdir(portabilitymode);
	    'q', 'Q':
	      switchdir(silentmode);
	    'r', 'R':
	      switchdir(ucreswords);
	    's', 'S':
	      numdir(statsperline, 1, maxlinelen);
	    't', 'T':
	      begin
	      numdir(tabspaces, 0, maxlinelen);
	      continuespaces := (tabspaces + 1) div 2;
	      end;
	    'u', 'U':
	      switchdir(ucidents);
	    end;  {case}
	  end
	else if not (ch in [']', '*', '}']) then
	  copyachar;
      until ch in [']', '*', '}'];
      if ch = ']' then
	copyachar;
    end;  {doformatterdirectives}

{$P------------------------*
 | Command Line Directives |
 *-------------------------*}


  procedure commanddirectives;

    begin  {read a command line and process directives}
      getfiles;
      if length(clinearg) > 0 then
	doformatterdirectives(false, true);
    end;  {commanddirectives}

{$P-----------------*
 | Comment Handling |
 *------------------*}


  procedure docoment(block: boolean;  {true if block comment}
		     initcol: lineindex;  {starting column}
		     initchar: char  {starting char} );
 {Handles all comments.
  Comments are split into two classes which are handled separately.
  Comments which begin a line are treated as "block comments" and
  are not formatted.  At most, it will be folded to fit on the
  output line.
  Comments which follow other statements on a line are formatted
  like any other statement.}

{$p---------------------*
 | Adjust Block Comment |
 *----------------------*}


    procedure adjustblkcoment(startcol, startchar: integer);

      var
	comlength: integer;  {length of comment if on one line}
	comindent: integer;  {amount to indent comment}

      begin  {if the comment is all on one line, adjust it to line up
	      with the indentation if possible, otherwise just try to
	      fit it somehow. In any case, if the comment extends
	      beyond the allowable length, bitch about it.}
	if formatting then
	  begin
	  if firstinputline then
	    begin
	    comlength := writecol - startcol;
	    comindent := outlinelen - comlength;
	    if comindent < 0 then
	      comindent := 0
	    else if comindent > statindent then
	      comindent := statindent;
	    unwritten[startchar mod bufsize].spacing := comindent;
	    writecol := comindent + comlength;
	    end;
	  if writecol > outlinelen then
	    comentoverflow;
	  end;  {if formatting}
      end;  {adjustblkcoment}

{$p------------------------*
 | Adjust Statment Comment |
 *-------------------------*}


    procedure adjuststatcoment;

      begin  {called after the last character of a statment comment has
	      been written to ensure that it all fits on a line}
	if formatting then
	  if writecol > outlinelen then
	    if statbreak = 0 then
	      if writecol <= maxlinelen then
		comentoverflow
	      else
		abort(linenumber, comformat)
	    else
	      breakstatcoment;
      end;  {adjuststatcoment}

{$p--------------*
 | Block Comment |
 *---------------*}


    procedure blkcoment;

      var
	comcolstart: integer;  {start of comment}
	comcharstart: integer;  {start of comment in buffer}

      begin  {format a block comment: If the comment is all on one input
	      line it will be indented to the current statement level
	      unless it won't fit, in which case it is shifted left
	      until it will fit. If any part of a block comment will
	      not fit in the output line, the output line will be
	      extended and a message printed.}
	printline(initcol - 1);
	comcolstart := writecol;
	comcharstart := charcount;
	firstinputline := true;
	blkcomchar('{');
	getchar;
	if ch = '$' then
	  docompilerdirectives(true);
	if ch = '[' then
	  doformatterdirectives(true, false);
	if initchar = '{' then
	  while ch <> '}' do
	    begin
	    blkcomchar(ch);
	    getchar
	    end
	else
	  repeat
	    while ch <> '*' do
	      begin
	      blkcomchar(ch);
	      getchar
	      end;
	    getchar;
	    if ch <> ')' then
	      blkcomchar('*');
	  until ch = ')';
	blkcomchar('}');
	adjustblkcoment(comcolstart, comcharstart);
      end;  {blkcoment}

{$p-----------*
 | Statcoment |
 *------------*}


    procedure statcoment;

      begin  {Format a statement comment: These are inserted in the line
	      at the place found, and subsequent lines are indented to
	      the start of the comment. If the start of the comment is
	      too far to the right, it will be indented on the next
	      line. Text will be moved as necessary to fill lines. All
	      breaks will be at blanks, and if it is not possible to
	      break a comment properly the output line will be extended
	      and a message printed}
	{initialize statcomchar}
	statbreak := 0;
	statblanks := false;
	indentplus(writecol + comentspaces + 1 - indent, linenumber);
	if (indent > threefourthline) and (tabspaces <
	   comentspaces) then
	  begin
	  undent;
	  indentplus(tabspaces, linenumber);
	  end;
	if writecol < (outlinelen - comentspaces - 1) then
	  space(comentspaces);
	statcomchar('{');
	getchar;
	if ch = '$' then
	  docompilerdirectives(false);
	if ch = '[' then
	  doformatterdirectives(false, false);
	if initchar = '{' then
	  while ch <> '}' do
	    begin
	    statcomchar(ch);
	    getchar
	    end
	else
	  repeat
	    while ch <> '*' do
	      begin
	      statcomchar(ch);
	      getchar
	      end;
	    getchar;
	    if ch <> ')' then
	      statcomchar('*');
	  until ch = ')';
	statcomchar('}');
	adjuststatcoment;
	undent;
	blankline := false;
      end;  {statcoment}

{$p----------------------*
 | Main Body of Docoment |
 *-----------------------*}

    begin  {docoment}
      newinputline := false;
      if block then
	blkcoment
      else
	statcoment;
      formatting := newformatting;
      newinputline := false;
      getchar;
      while ((ch = ' ') or (ch = chr(tab))) and not newinputline do
	getchar;
      if newinputline then  {start new line if comment is last on line}
	if formatting then
	  begin
	  space(0);
	  writecol := outlinelen;
	  symbolbreak := 0;
	  end  {comment at end of line} ;
      symbolfound := false;
      lastsym := coment;
    end;  {docoment}

{$p-----------------*
 | Start of Comment |
 *------------------*}


  procedure comentchar;

    begin  {possible start of comment}
      if ch = '(' then
	begin  {see if comment or just open paren}
	symbolput('(');
	if ch = '*' then
	  begin
	  symlen := 0;
	  docoment(newinputline, column - 1, ch)
	  end
	else
	  begin
	  newinputline := false;
	  sym := openparen;
	  symbolfound := true
	  end;
	end
      else
	docoment(newinputline, column, ch);
    end;  {comentchar}

modend .
