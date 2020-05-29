{$p----------*
 | Constants |
 *-----------*}

  const
    maxlinelen = 132; {max output line length}
    bufsize = 134; {output buffer size, > maxlinelen}
    maxwordlen = 9; {reserved words char size}
    noreswords = 53; {number of reserved words}
    defaultoutline = 72; {default output line length}
    defaulttabspaces = 2; {logical indentation increments}
    defaultcomentspaces = 1; {spacing before and after comments}
    tab = 9; {ord of tab character}
    tabinterval = 8; {standard tab interval for CP/M}
    ibufsize = 2047; {size of input file buffer}

{$p------*
 | Types |
 *-------*}

  type
    symbols = (abslutesy, andsy, arraysy, beginsy, casesy, constsy,
	       divsy, dosy, downtosy, elsesy, endsy, externsy, filesy,
	       forsy, forwardsy, funcsy, gotosy, ifsy, insy, intruptsy,
	       labelsy, modsy, modendsy, modulesy, nilsy, notsy, ofsy,
	       orsy, othwisesy, packedsy, procsy, programsy, recordsy,
	       repeatsy, setsy, stringsy, thensy, tosy, typesy, untilsy,
	       varsy, whilesy, withsy, plus, minus, mult, divide,
	       becomes, period, comma, semicolon, colon, equal,
	       notequal, lessthan, lessequal, greatequal, greatthan,
	       pointer, subrange, apostrophy, openparen, closeparen,
	       openbrack, closebrack, identifier, number, stringcon,
	       coment, textend, dummysy);

    {basic symbol enumeration}
    setofsyms = set of symbols; {set ops on basic symbols}
    wordtype = packed array [1..maxwordlen] of char;

    {reserved}
    lentabletype = {index into reserved word table by length}
      record
	lowindex, hiindex: 1..noreswords;
      end;

    lineindex = 0..maxlinelen;
    actions = (graphic, spaces, beginline);
    bufferindex = 0..bufsize; {output buffer index}
    charbuffer = array [bufferindex] of
	record
	  case actionis: actions of
	    spaces, beginline:
	      (spacing: lineindex);
	    graphic:
	      (character: char)
	end;
    collog =
      record
	logchar: integer; {charcount at time of log}
	logcol: lineindex; {writecol at time of log}
	logline: integer; {currentline at time of log}
      end;
    abortkind = (syntax, nesting, comformat); {error types}
    stringp = ^string;

{$p----------*
 | Variables |
 *-----------*}

  var
    {CP/M interface variables}
    clinearg: external string[127];

    {Structured Constants}
    stdsyms: external setofsyms; {symbols valid in standard pascal}
    validdirectives: external set of char; {valid formatter directives}
    spacebefore, spaceafter: external setofsyms; {individual symbol spacing}
    alphanumerics: external setofsyms; {alpha symbols}
    resvwrd: external array [1..noreswords] of wordtype; {reserved word table}
    ressymbol: external array [1..noreswords] of symbols; {symbols for resvwrd}
    reslen: external array [2..maxwordlen] of lentabletype; { length index}
    digits, letters: external set of char;
    uppercase: external array [char] of char;
    lowercase: external array [char] of char; {case conversion tables}
    progset, blockbegsys, statset: external setofsyms; {syntactic symbol types}
    cnstnts: external setofsyms; {symbols which can be constants}
    headingbegsys: external setofsyms; {symbols which begin a block heading}
    typebegsys: external setofsyms; {type beginning symbols}
    exprbegsys: external setofsyms; {expression beginning symbols}
    relops: external setofsyms; {relational operators}
    arithops: external setofsyms; {arithmetic operators}

    {Formatting variables}
    indent: external integer; {current number of indentation spaces}
    statindent: external integer; {indentation for major statement}
    writecol: external integer; {current output column}
    symbolbreak: external integer; {break symbol for putsym}
    breakcol: external integer; {output column for putsym}
    lastsym: external symbols; {last symbol processed}
    symwritten: external boolean; {last symbol was written}
    indentstate: external array [lineindex] of lineindex;
    indentlevel: external lineindex; {these make a stack of indent levels}

    {comment formatting}
    statbreak: external integer; {character where line can be broken}
    statblanks: external boolean; {set if blank was last char}
    firstinputline: external boolean; {set if first input line}

    {miscellaneous}
    outputline: external integer; {line numbers for output}
    currentline: external integer; {line number being written}
    inputline: external integer; {input line number}
    linenumber: external integer;

    {Formatting Control Values}
    outlinelen: external integer; {current output line length}
    onehalfline: external integer; {significant point upon line}
    fiveeighthline: external integer; { "}
    threefourthline: external integer; {"}
    tabspaces: external integer; {spaces to indent for each level}
    continuespaces: external integer; {spaces to indent continuation line}
    comentspaces: external integer; {spaces before statement comment}
    statsperline: external integer; {statements per line}

    {Flags to direct formatting}
    ucreswords: external boolean; {convert reserved words to UC}
    ucidents: external boolean; {convert identifiers to UC}
    litcopy: external boolean; {copy identifiers and reserved words literally}
    portabilitymode: external boolean; {eliminate underscores}
    formatting: external boolean; {do formatting (otherwise, copy)}
    newformatting: external boolean; {start formatting at end of comment}
    bunching: external boolean; {bunch statements on one line}
    silentmode: external boolean; {don't even generate error messages}

    {lexical scanner variables}
    symbolfound: external boolean; {success from lexical analysis}
    newinputline: external boolean; {true when no chars as yet on new line}
    endfile: external boolean; {eof read}
    blankline: external boolean; {true when blank line is ok to output}
    ch: external char; {current character for lexical analysis}
    doubleperiod: external boolean; {set if double period found}
    column: external integer; {input column for last char input}
    sym: external symbols; {current basic symbol from lex}
    symbol: external array [lineindex] of char; {workspace for lex analysis}
    symlen: external 0..maxlinelen; {index into WINDOW array}
    {output character buffering}
    unwritten: external charbuffer; {unwritten characters}
    charcount: external integer; {characters written so far}
    oldest: external bufferindex; {oldest char in buffer}

    {error handling variables}
    overflows: external 0..maxint; {number of line overflows}
    firstoverflow: external 0..maxint; {line where first overflow occured}
    comoverflows: external 0..maxint; {number of comment overflows}
    firstcomoverflow: external 0..maxint; {line of first comment overflow}
