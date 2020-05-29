{*---------------------------------*
 | Pasmat Recursive Descent Parser |
 *---------------------------------*}
{$K0}  {$K2}  {$K7}  {$K12}  {$K13}  {$K14}  {$K15}
(* {$S+}  {$Q2} *)
module pmparse;
 {$L-}
 {$I PMDEFS.INC}
 {$L+}

  external procedure abort(line: integer;
			   kind: abortkind);
  external procedure bunch(start: collog;
			   var success: boolean);
  external procedure bunchstatement(start: collog);
  external procedure checksym(desired: symbols;
			      line: integer);
  external procedure getsym;
  external procedure indentplus(delta: integer;
				line: integer);
  external procedure logsymbolstart(var log: collog);
  external procedure nextonnewline(spacing, delta: integer);
  external procedure nextsym;
  external procedure printline(indent: integer);
  external procedure putsym;
  external procedure setsymbolbreak;
  external procedure space(n: integer);
  external procedure undent;

{$p----------------*
 | Identifier list |
 *-----------------*}


  procedure identlist;

    begin  {scan a list of identifiers separated by commas}
      while sym = identifier do
	begin
	nextsym;
	if sym = comma then
	  begin
	  nextsym;
	  setsymbolbreak;
	  end;
	end;
    end;  {identlist}
{$p---------*
 | Constant |
 *----------*}


  procedure cnstnt;

    begin  {scan a constant}
      if (sym = plus) or (sym = minus) then
	nextsym;
      if not (sym in (cnstnts - [plus, minus])) then
	abort(linenumber, syntax);
      nextsym;
    end;  {cnstnt}
{$p---------*
 | Variable |
 *----------*}


  procedure variable;

    begin  {scan off a variable, doesn't check much}
      while sym in [identifier, period, pointer, openbrack] do
	begin
	if sym = openbrack then
	  begin
	  nextsym;
	  exprlist;
	  checksym(closebrack, linenumber);
	  end
	else
	  nextsym;
	end;
    end;  {variable}
{$p--------------*
 | Constant list |
 *---------------*}


  procedure constlist;

    begin  {scan a list of constants, as for case labels}
      while sym in cnstnts do
	begin
	cnstnt;
	if sym = comma then
	  begin
	  nextsym;
	  setsymbolbreak;
	  end;
	end;
    end;  {constlist}
{$p-------*
 | Factor |
 *--------*}


  procedure factor;

    begin  {scan a factor in an expression, ignores precedence}
      if sym = openparen then
	begin
	setsymbolbreak;
	nextsym;
	expression;
	checksym(closeparen, linenumber);
	end
      else if sym = openbrack then
	begin  {set expression}
	setsymbolbreak;
	nextsym;
	while sym in exprbegsys do
	  begin
	  exprlist;
	  if sym = subrange then
	    nextsym;
	  end;
	checksym(closebrack, linenumber);
	end
      else if sym = identifier then
	begin
	variable;
	if sym = openparen then
	  begin
	  if writecol <= threefourthline then
	    indentplus(writecol - indent, linenumber)
	  else
	    indentplus(0, linenumber);
	  nextsym;
	  exprlist;
	  checksym(closeparen, linenumber);
	  undent;
	  end
	end
      else
	cnstnt;
    end;  {factor}
{$p-----------*
 | Expression |
 *------------*}


  procedure expression;

    var
      exprbroken: boolean;  {break point already found}

    begin  {scan an expression}
      exprbroken := false;
      while sym in exprbegsys do
	begin
	if sym in [plus, minus, notsy] then
	  nextsym;
	if (sym = plus) or (sym = minus) or (sym = notsy) then
	  nextsym;
	factor;
	if (sym = andsy) or (sym = orsy) then
	  begin
	  nextsym;
	  setsymbolbreak;
	  exprbroken := true;
	  end
	else if sym in relops then
	  begin
	  nextsym;
	  if not exprbroken and (writecol > fiveeighthline) then
	    begin
	    setsymbolbreak;
	    exprbroken := true;
	    end;
	  end
	else if sym in arithops then
	  begin
	  nextsym;
	  if not exprbroken and (writecol > threefourthline) then
	    begin
	    setsymbolbreak;
	    exprbroken := true;
	    end;
	  end;
	end;  {while}
    end;  {expression}
{$p----------------*
 | Expression list |
 *-----------------*}


  procedure exprlist;

    begin  {scan a list of expressions}
      while sym in exprbegsys do
	begin
	expression;
	if (sym = comma) or (sym = colon) then
	  begin
	  nextsym;
	  setsymbolbreak;
	  end;
	end;
    end;  {exprlist}
{$p--------------------------*
 | Statement List (statlist) |
 *---------------------------*}


  procedure statlist;

    var
      statterms: setofsyms;
      statstart: collog;
      firststat: boolean;

    begin  {process a list of statements}
      statterms := statset + [semicolon];
      firststat := true;
      repeat
	logsymbolstart(statstart);
	statement;
	{note: may or may not have semicolon}
	if (sym = semicolon) and not symwritten then
	  putsym;
	if (statsperline > 1) and not firststat then
	  bunchstatement(statstart);
	{split like this so following comments don't screw up}
	if sym = semicolon then
	  getsym;
	firststat := false;
      until not (sym in statterms);
    end;  {statelist}
{$p---------------------------*
 | Compound statement (begin) |
 *----------------------------*}


  procedure dobegin(procblock: boolean);

    var
      trim: integer;  {amount to indent}

    begin  {handle a begin - end block, indenting if requested by
	    setting procblock true}
      if procblock then
	trim := tabspaces
      else
	trim := 0;
      nextonnewline(0, trim);
      statlist;
      undent;
      printline(indent);
      checksym(endsy, linenumber);
    end;  {dobegin}
{$p------------------------------*
 | Assignment and Procedure Call |
 *-------------------------------*}


  procedure doassigncall;

    begin  {either assignment or call}
      printline(indent);
      indentplus(continuespaces, linenumber);
      variable;
      if sym = becomes then
	begin
	nextsym;
	if writecol < threefourthline then
	  indentplus(writecol - indent + 1, linenumber)
	else
	  indentplus(0, linenumber);
	expression;
	undent;
	end
      else if sym = openparen then
	begin
	nextsym;
	if writecol <= threefourthline then
	  indentplus(writecol - indent, linenumber)
	else
	  indentplus(0, linenumber);
	exprlist;
	undent;
	checksym(closeparen, linenumber);
	end;
      if sym = semicolon then
	putsym;
      undent;
    end;  {doassigncall}
{$p---------------*
 | Goto statement |
 *----------------*}


  procedure dogoto;

    begin  {goto statement}
      printline(indent);
      nextsym;
      checksym(number, linenumber);
      if sym = semicolon then
	putsym;
    end;  {dogoto}
{$p----------------*
 | While statement |
 *-----------------*}


  procedure dowhile;

    begin  {while statement}
      printline(indent);
      nextsym;
      if writecol < threefourthline then
	indentplus(writecol - indent + 1, linenumber)
      else
	indentplus(continuespaces, linenumber);
      expression;
      checksym(dosy, linenumber);
      undent;
      indentplus(tabspaces, linenumber);
      statindent := indent;
      statement;
      undent;
    end;  {dowhile}
{$p---------------*
 | With statement |
 *----------------*}


  procedure dowith;

    begin  {withstatement}
      printline(indent);
      nextsym;
      if writecol < threefourthline then
	indentplus(writecol - indent + 1, linenumber)
      else
	indentplus(continuespaces, linenumber);
      exprlist;
      checksym(dosy, linenumber);
      undent;
      indentplus(tabspaces, linenumber);
      statindent := indent;
      statement;
      undent;
    end;  {dowith}
{$p-------------*
 | If statement |
 *--------------*}


  procedure doif(prevelse: boolean  {set if previous sym was else} );

    var
      ifstart: collog;  {start of if statement}
      startline, endline: integer;  {statement lines}
      successful: boolean;  {bunching went}

    begin  {if statement}
      if not prevelse then
	printline(indent);
      nextsym;
      if writecol < threefourthline then
	indentplus(writecol - indent + 1, linenumber)
      else
	indentplus(continuespaces, linenumber);
      startline := currentline;
      expression;
      checksym(thensy, linenumber);
      undent;
      indentplus(tabspaces, linenumber);
      endline := currentline;
      logsymbolstart(ifstart);
      statement;
      if bunching and (startline = endline) then
	bunch(ifstart, successful);
      undent;
      statindent := indent;
      if sym = elsesy then
	begin
	printline(indent);
	nextsym;
	if sym = ifsy then
	  doif(true)
	else
	  begin
	  indentplus(tabspaces, linenumber);
	  logsymbolstart(ifstart);
	  statement;
	  if bunching then
	    bunch(ifstart, successful);
	  undent;
	  end;
	end;
    end;  {doif}
{$p---------------*
 | Case statement |
 *----------------*}


  procedure docase;

    var
      casestart: collog;  {start of case}
      successful: boolean;  {bunching successful}
      labstart, labend: integer;  {label list lines}

    begin  {casestatement}
      printline(indent);
      nextsym;
      if writecol < threefourthline then
	indentplus(writecol - indent + 1, linenumber)
      else
	indentplus(continuespaces, linenumber);
      expression;
      checksym(ofsy, linenumber);
      undent;
      indentplus(tabspaces, linenumber);
      statindent := indent;
      while not (sym in [endsy, elsesy, othwisesy]) do
	begin
	if sym in cnstnts then
	  begin
	  printline(indent);
	  labstart := currentline;
	  constlist;
	  checksym(colon, linenumber);
	  labend := currentline;
	  indentplus(tabspaces, linenumber);
	  logsymbolstart(casestart);
	  statement;
	  if bunching and (labstart = labend) then
	    bunch(casestart, successful);
	  undent;
	  statindent := indent;
	  end;  {if sym in constants}
	if sym = semicolon then
	  nextsym;
	if not (sym in (cnstnts + [endsy, semicolon, elsesy,
	   othwisesy])) then
	  abort(linenumber, syntax);
	end;  {while}
      if (sym = othwisesy) or (sym = elsesy) then
	begin
	nextonnewline(0, tabspaces);
	statlist;
	undent;
	end;
      printline(indent);
      checksym(endsy, linenumber);
      undent;
    end;  {docase}
{$p-----------------*
 | Repeat statement |
 *------------------*}


  procedure dorepeat;

    begin  {repeat statement}
      nextonnewline(0, tabspaces);
      statlist;
      undent;
      statindent := indent;
      printline(indent);
      checksym(untilsy, linenumber);
      if writecol < threefourthline then
	indentplus(writecol - indent + 1, linenumber)
      else
	indentplus(continuespaces, linenumber);
      expression;
      if sym = semicolon then
	putsym;
      undent;
    end;  {dorepeat}
{$p--------------*
 | For statement |
 *---------------*}


  procedure dofor;

    begin  {for statement}
      nextonnewline(0, continuespaces);
      checksym(identifier, linenumber);
      checksym(becomes, linenumber);
      expression;
      if (sym <> tosy) and (sym <> downtosy) then
	abort(linenumber, syntax);
      nextsym;
      expression;
      checksym(dosy, linenumber);
      undent;
      indentplus(tabspaces, linenumber);
      statement;
      undent;
    end;  {dofor}
{$p----------*
 | Statement |
 *-----------*}


  procedure statement;

    begin  {handle a (possibly empty) statement}
      statindent := indent;
      if sym = number then
	begin
	indentplus( - tabspaces, linenumber);
	printline(indent);
	nextsym;
	checksym(colon, linenumber);
	undent;
	end;
      if sym in (statset - [number]) then
	case sym of
	  beginsy:
	    dobegin(false);
	  casesy:
	    docase;
	  forsy:
	    dofor;
	  gotosy:
	    dogoto;
	  identifier:
	    doassigncall;
	  ifsy:
	    doif(false);
	  repeatsy:
	    dorepeat;
	  whilesy:
	    dowhile;
	  withsy:
	    dowith;
	  end;  {case}
      statindent := indent;
    end;  {statement}
{$p----------------------*
 | Formal Parameter List |
 *-----------------------*}


  procedure parameters;

    begin  {format a formal parameter list: if they start less than
	    halfway across the page, they are all lined up with the
	    first parameter, on successive lines. If they start more
	    than halfway across the page, they begin on the next line,
	    indented double the usual (arbitrary)}
      if writecol > onehalfline then
	printline(indent + 2 * tabspaces);
      nextsym;
      indentplus(writecol - indent, linenumber);
      while sym in [identifier, funcsy, procsy, varsy] do
	begin
	if sym <> identifier then
	  nextsym;
	if sym <> identifier then
	  abort(linenumber, syntax);
	indentplus(continuespaces, linenumber);
	identlist;
	undent;
	if sym = colon then
	  begin  {not proc or func}
	  nextsym;
	  if sym = stringsy then
	    stringtype  {overly permissive}
	  else if sym = arraysy then
	    arraytype  {overly permissive}
	  else
	    checksym(identifier, linenumber)
	  end;
	if sym = semicolon then
	  begin
	  nextsym;
	  printline(indent);
	  end;
	end;
      checksym(closeparen, linenumber);
      undent;
    end;  {parameters}
{$p-----------*
 | Field list |
 *------------*}


  procedure fieldlist;

    var
      invarpart: boolean;  {true if there was an invarient part}

    begin  {scan field list of type specification }
      invarpart := false;
      while sym = identifier do
	begin
	invarpart := true;
	indentplus(continuespaces, linenumber);
	identlist;
	checksym(colon, linenumber);
	undent;
	scantype;
	if sym = semicolon then
	  nextsym;
	if sym = identifier then
	  printline(indent);
	end;
      if sym = casesy then
	begin  {case}
	if invarpart then
	  printline(indent);
	nextsym;
	indentplus(continuespaces, linenumber);
	checksym(identifier, linenumber);
	if sym = colon then
	  begin
	  nextsym;
	  checksym(identifier, linenumber);
	  end;
	checksym(ofsy, linenumber);
	undent;
	indentplus(tabspaces, linenumber);
	statindent := indent;
	printline(indent);
	repeat  {variant part}
	  constlist;
	  checksym(colon, linenumber);
	  indentplus(tabspaces, linenumber);
	  statindent := indent;
	  printline(indent);
	  checksym(openparen, linenumber);
	  indentplus(1, linenumber);  {compensate for paren}
	  fieldlist;
	  undent;
	  checksym(closeparen, linenumber);
	  undent;
	  statindent := indent;
	  if sym = semicolon then
	    nextsym;
	  if (sym <> endsy) and (sym <> closeparen) then
	    printline(indent);
	until not (sym in cnstnts);
	undent;
	statindent := indent;
	end  {case}
    end;  {fieldlist}
{$p------------*
 | Record type |
 *-------------*}


  procedure recordtype(packedstart: collog);

    begin  {handle a record type, includes a kluge to move "packed" down
	    to the next line}
      indentplus(tabspaces, linenumber);
      with packedstart do
	if formatting and (logchar <> 0) and (charcount -
	   logchar < bufsize) then
	  with unwritten[logchar mod bufsize] do
	    begin  {note that this kluge assumes the logged point has
		    become a space so it can be changed to a newline}
	    actionis := beginline;
	    spacing := indent;
	    writecol := indent + writecol - logcol;
	    currentline := currentline + 1;
	    end
	else
	  printline(indent);
      nextsym;
      indentplus(tabspaces, linenumber);
      statindent := indent;
      printline(indent);
      fieldlist;
      undent;
      printline(indent);
      checksym(endsy, linenumber);
      undent;
    end;  {recordtype}
{$p-----------*
 | Array type |
 *------------*}


  procedure arraytype;

    begin  {format an array type}
      indentplus(tabspaces, linenumber);
      nextsym;
      setsymbolbreak;
      checksym(openbrack, linenumber);
      while sym in cnstnts do
	begin
	cnstnt;
	if sym = subrange then
	  begin
	  nextsym;
	  cnstnt;
	  end;
	if sym = colon then
	  begin  {for conformant arrays}
	  nextsym;
	  checksym(identifier, linenumber)
	  end;
	if sym = comma then
	  begin
	  nextsym;
	  setsymbolbreak;
	  end;
	end;  {while}
      checksym(closebrack, linenumber);
      checksym(ofsy, linenumber);
      scantype;
      undent;
    end;  {arraytype}
{$P------------*
 | String type |
 *-------------*}


  procedure stringtype;

    begin  {format a string type}
      nextsym;
      if sym = openbrack then
	begin  {optional size '[n]'}
	nextsym;
	cnstnt;
	checksym(closebrack, linenumber)
	end
    end;
{$p-----------------*
 | Enumeration type |
 *------------------*}


  procedure enumtype;

    begin  {handle an enumeration type, align to the right of the
	    opening parenthesis if there is room, otherwise use normal
	    continuation}
      nextsym;
      if writecol <= threefourthline then
	indentplus(writecol - indent, linenumber)
      else
	indentplus(continuespaces, linenumber);
      identlist;
      checksym(closeparen, linenumber);
      undent;
    end;  {enumtype}
{$p----------*
 | Scan type |
 *-----------*}


  procedure scantype;

    var
      packedstart: collog;

    begin  {scan a type, formatting differs for each one}
      indentplus(continuespaces, linenumber);
      if sym = externsy then
	nextsym
      else if sym = abslutesy then
	begin {absolute [ nnn ] or absolute [ nnn : mmm ]}
	nextsym;
	checksym(openbrack, linenumber);
	cnstnt;
	if sym = colon then
	  begin
	  nextsym;
	  cnstnt
	  end;
	checksym(closebrack, linenumber);
	space(1);
	end;
      if sym = packedsy then
	begin  {mark start of 'packed' - must actually be a space}
	logsymbolstart(packedstart);
	nextsym
	end
      else
	packedstart.logchar := 0;
      undent;
      if not (sym in typebegsys) then
	abort(linenumber, syntax);
      case sym of
	openparen:
	  enumtype;
	arraysy:
	  arraytype;
	stringsy:
	  stringtype;
	filesy:
	  begin
	  nextsym;  {untyped file is ok}
	  if sym = ofsy then
	    begin
	    nextsym;
	    scantype
	    end
	  end;
	setsy:
	  begin
	  nextsym;
	  checksym(ofsy, linenumber);
	  scantype
	  end;
	identifier, number, plus, minus, stringcon:
	  begin  {simple or subrange}
	  cnstnt;
	  if sym = subrange then
	    begin
	    nextsym;
	    cnstnt;
	    end;
	  end;
	pointer:
	  begin
	  nextsym;
	  scantype;
	  end;
	recordsy:
	  recordtype(packedstart);
	end;  {case}
      statindent := indent;
    end;  {scantype}
{$p------------------*
 | Label Declaration |
 *-------------------*}


  procedure dolabel;

    begin  {label declaration}
      nextonnewline(1, tabspaces);
      printline(indent);
      while sym = number do
	begin
	nextsym;
	if sym = comma then
	  nextsym;
	end;  {while}
      checksym(semicolon, linenumber);
      undent;
      statindent := indent;
    end;  {dolabel}
{$p---------------------*
 | Constant Declaration |
 *----------------------*}


  procedure doconst;

    var
      conststart: collog;  {start of particular declaration}
      firstconst: boolean;  {first constant in decl}

    begin  {constant declaration}
      nextonnewline(1, tabspaces);
      firstconst := true;
      while sym = identifier do
	begin
	logsymbolstart(conststart);
	printline(indent);
	nextsym;
	checksym(equal, linenumber);
	cnstnt;
	if sym = semicolon then
	  putsym
	else
	  abort(linenumber, syntax);
	if (statsperline > 1) and not firstconst then
	  bunchstatement(conststart);
	nextsym;  {split so comments format right}
	firstconst := false;
	end;  {while}
      undent;
      statindent := indent;
    end;  {doconst}
{$p-----------------*
 | Type Declaration |
 *------------------*}


  procedure dotype;

    begin  {typedeclaration}
      nextonnewline(1, tabspaces);
      while sym = identifier do
	begin
	printline(indent);
	nextsym;
	checksym(equal, linenumber);
	scantype;
	checksym(semicolon, linenumber);
	end;  {while}
      undent;
      statindent := indent;
    end;  {dotype}
{$p----------------*
 | Var Declaration |
 *-----------------*}


  procedure dovar;

    begin  {var declaration}
      nextonnewline(1, tabspaces);
      while (sym = identifier) do
	begin
	printline(indent);
	indentplus(continuespaces, linenumber);
	if sym <> identifier then
	  abort(linenumber, syntax);
	identlist;
	checksym(colon, linenumber);
	undent;
	scantype;
	checksym(semicolon, linenumber);
	end;  {while}
      undent;
      statindent := indent;
    end;  {dovar}
{$P---------------------------*
 | Procedure/Function Heading |
 *----------------------------*}


  procedure doprochead;

    var
      startsym: symbols;

    begin  {process procedure or function heading}
      if sym = externsy then
	begin  {optional 'external'}
	nextonnewline(0, continuespaces);
	if sym = openbrack then  {optional '[n]'}
	  begin
	  nextsym;
	  cnstnt;
	  checksym(closebrack, linenumber)
	  end;
	startsym := sym;
	nextsym
	end
      else
	begin
	startsym := sym;
	nextonnewline(2, continuespaces)
	end;
      if sym = intruptsy then
	begin  {optional 'interrupt [n]'}
	nextsym;
	checksym(openbrack, linenumber);
	cnstnt;
	checksym(closebrack, linenumber);
	space(1)
	end;
      checksym(identifier, linenumber);
      if sym = openparen then
	parameters;
      if startsym = funcsy then
	begin
	checksym(colon, linenumber);
	checksym(identifier, linenumber)
	end;
      checksym(semicolon, linenumber);
      undent;
    end;

{$p----------------------*
 | Procedure Declaration |
 *-----------------------*}


  procedure doprocedure;

    begin  {procedure}
      doprochead;
      indentplus(tabspaces, linenumber);
      if sym = forwardsy then
	begin
	printline(indent);
	nextsym;
	end
      else if sym in blockbegsys then
	doblock
      else
	abort(linenumber, syntax);
      if sym = semicolon then
	begin
	putsym;
	undent;
	statindent := indent;
	nextsym;
	end
      else
	abort(linenumber, syntax);
    end;  {doprocedure}
{$p--------*
 | Program |
 *---------*}


  procedure doprogram;

    var
      doingmodule: boolean;  {this is a module}

    begin  {program or module}
      doingmodule := (sym = modulesy);
      nextonnewline(0, continuespaces);
      checksym(identifier, linenumber);
      if sym = openparen then
	begin
	nextsym;
	while sym = identifier do
	  begin
	  nextsym;
	  if sym = comma then
	    begin
	    nextsym;
	    setsymbolbreak;
	    end;
	  end;
	checksym(closeparen, linenumber);
	end;
      checksym(semicolon, linenumber);
      undent;
      indentplus(tabspaces, linenumber);
      doblock;
      undent;
      if doingmodule then
	begin
	if sym = semicolon then
	  nextsym;
	if sym = modendsy then
	  nextonnewline(1, indent)
	else
	  abort(linenumber, syntax);
	end  {final end for module} ;
      checksym(period, linenumber);
    end;  {doprogram}
{$p------*
 | Block |
 *-------*}


  procedure doblock;

    begin  {scan a block, including types, etc}
      statindent := indent;
      while sym in headingbegsys do
	begin  {declarations}
	case sym of
	  labelsy:
	    dolabel;
	  constsy:
	    doconst;
	  typesy:
	    dotype;
	  varsy:
	    dovar;
	  procsy, funcsy:
	    doprocedure;
	  externsy:
	    doprochead;
	  end;  {case}
	statindent := indent;
	end;  {while}
      if sym = beginsy then
	begin
	blankline := true;
	dobegin(true);
	end;
    end;  {doblock}

modend .
