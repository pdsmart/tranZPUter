{*-----------------------*
 | Pasmat Initialization |
 *-----------------------*}
{$K0} {$K2} {$K7} {$K12} {$K13} {$K14} {$K15}
module pminit;
 {$L-}
 {$I PMDEFS.INC}
 {$L+}
{$p-------------------------*
 | Initialize Set Constants |
 *--------------------------*}


  procedure init1sets;

    begin {initialize set constants, part 1}
      stdsyms := [abslutesy, andsy, arraysy, beginsy, casesy, constsy,
		 divsy, dosy, downtosy, elsesy, endsy, externsy, filesy,
		 forsy, forwardsy, funcsy, gotosy, ifsy, insy,
		 intruptsy, labelsy, modsy, modendsy, modulesy, nilsy,
		 notsy, ofsy, orsy, othwisesy, packedsy, procsy,
		 programsy, recordsy, repeatsy, setsy, stringsy, thensy,
		 tosy, typesy, untilsy, varsy, whilesy, withsy, plus,
		 minus, mult, divide, becomes, period, comma, semicolon,
		 colon, equal, notequal, lessthan, lessequal,
		 greatequal, greatthan, pointer, subrange, apostrophy,
		 openparen, closeparen, openbrack, closebrack,
		 identifier, number, stringcon, coment, textend,
		 dummysy];
      {constants used by putsym}
      spacebefore := [abslutesy, andsy, divsy, dosy, downtosy, insy,
		     intruptsy, modsy, ofsy, orsy, thensy, tosy, plus,
		     minus, mult, divide, becomes, equal, notequal,
		     lessthan, lessequal, greatequal, greatthan];
      spaceafter := [abslutesy, andsy, arraysy, casesy, divsy, downtosy,
		    externsy, filesy, forsy, funcsy, gotosy, ifsy, insy,
		    intruptsy, modsy, modendsy, modulesy, notsy, ofsy,
		    orsy, othwisesy, packedsy, procsy, programsy, tosy,
		    untilsy, whilesy, withsy, plus, minus, mult, divide,
		    becomes, comma, semicolon, colon, equal, notequal,
		    lessthan, lessequal, greatequal, greatthan, coment];
      alphanumerics := [abslutesy..withsy, identifier, number];
      digits := ['0'..'9'];
      letters := ['a'..'z', 'A'..'Z', '_', '@'];
      progset := [programsy, modulesy];
    end {init1sets} ;


  procedure init2sets;

    begin {initialize set constants, part 2}
      headingbegsys := [labelsy, constsy, typesy, varsy, procsy, funcsy,
		       externsy];
      blockbegsys := headingbegsys + [beginsy];
      statset := [beginsy, ifsy, casesy, whilesy, repeatsy, forsy,
		 withsy, gotosy, number, identifier];
      cnstnts := [number, identifier, stringcon, plus, minus, nilsy];
      exprbegsys := cnstnts + [notsy, nilsy, openbrack, openparen];
      relops := [equal, notequal, lessthan, lessequal, greatthan,
		greatequal, insy];
      arithops := [plus, minus, mult, divide, divsy, modsy];
      typebegsys := cnstnts + [pointer, setsy, recordsy, filesy,
		    arraysy, openparen, stringsy];
      validdirectives := ['b', 'B', 'c', 'C', 'f', 'F', 'l', 'L', 'o',
			 'O', 'p', 'P', 'q', 'Q', 'r', 'R', 's', 'S',
			 't', 'T', 'u', 'U'];
    end {init2sets} ;
{$p--------------------------*
 | initialize reserved words |
 *---------------------------*}


  procedure init1resvwrd;

    begin {[s=2] initialize reserved word length indices into reserved
	   word array for length keyed search}
      reslen[2].lowindex := 1;         reslen[2].hiindex := 6;
      reslen[3].lowindex := 7;         reslen[3].hiindex := 15;
      reslen[4].lowindex := 17;        reslen[4].hiindex := 23;
      reslen[5].lowindex := 31;        reslen[5].hiindex := 36;
      reslen[6].lowindex := 37;        reslen[6].hiindex := 43;
      reslen[7].lowindex := 45;        reslen[7].hiindex := 46;
      reslen[8].lowindex := 47;        reslen[8].hiindex := 49;
      reslen[9].lowindex := 51;        reslen[9].hiindex := 53;
    end {[s=1] init1resvwrd} ;


  procedure init2resvwrd;

    begin {[s=2] initialize reserved word array}
      resvwrd[1] := 'do       ';       ressymbol[1] := dosy;
      resvwrd[2] := 'if       ';       ressymbol[2] := ifsy;
      resvwrd[3] := 'in       ';       ressymbol[3] := insy;
      resvwrd[4] := 'of       ';       ressymbol[4] := ofsy;
      resvwrd[5] := 'or       ';       ressymbol[5] := orsy;
      resvwrd[6] := 'to       ';       ressymbol[6] := tosy;
      resvwrd[7] := 'and      ';       ressymbol[7] := andsy;
      resvwrd[8] := 'div      ';       ressymbol[8] := divsy;
      resvwrd[9] := 'end      ';       ressymbol[9] := endsy;
      resvwrd[10] := 'for      ';      ressymbol[10] := forsy;
      resvwrd[11] := 'mod      ';      ressymbol[11] := modsy;
      resvwrd[12] := 'nil      ';      ressymbol[12] := nilsy;
      resvwrd[13] := 'not      ';      ressymbol[13] := notsy;
      resvwrd[14] := 'set      ';      ressymbol[14] := setsy;
      resvwrd[15] := 'var      ';      ressymbol[15] := varsy;
      {resvwrd[16] := '*********';      ressymbol[16] := dummysy; }
      resvwrd[17] := 'case     ';      ressymbol[17] := casesy;
      resvwrd[18] := 'else     ';      ressymbol[18] := elsesy;
      resvwrd[19] := 'file     ';      ressymbol[19] := filesy;
      resvwrd[20] := 'goto     ';      ressymbol[20] := gotosy;
      resvwrd[21] := 'then     ';      ressymbol[21] := thensy;
      resvwrd[22] := 'type     ';      ressymbol[22] := typesy;
      resvwrd[23] := 'with     ';      ressymbol[23] := withsy;
      {resvwrd[24] := '*********';      ressymbol[24] := dummysy; }
      {resvwrd[25] := '*********';      ressymbol[25] := dummysy; }
      {resvwrd[26] := '*********';      ressymbol[26] := dummysy; }
      {resvwrd[27] := '*********';      ressymbol[27] := dummysy; }
    end {[s=1] init2resvwrd} ;


  procedure init3resvwrd;

    begin {[s=2] initialize reserved word array}
      {resvwrd[28] := '*********';      ressymbol[28] := dummysy; }
      {resvwrd[29] := '*********';      ressymbol[29] := dummysy; }
      {resvwrd[30] := '*********';      ressymbol[30] := dummysy; }
      resvwrd[31] := 'array    ';      ressymbol[31] := arraysy;
      resvwrd[32] := 'begin    ';      ressymbol[32] := beginsy;
      resvwrd[33] := 'const    ';      ressymbol[33] := constsy;
      resvwrd[34] := 'label    ';      ressymbol[34] := labelsy;
      resvwrd[35] := 'until    ';      ressymbol[35] := untilsy;
      resvwrd[36] := 'while    ';      ressymbol[36] := whilesy;
      resvwrd[37] := 'downto   ';      ressymbol[37] := downtosy;
      resvwrd[38] := 'modend   ';      ressymbol[38] := modendsy;
      resvwrd[39] := 'module   ';      ressymbol[39] := modulesy;
      resvwrd[40] := 'packed   ';      ressymbol[40] := packedsy;
      resvwrd[41] := 'record   ';      ressymbol[41] := recordsy;
      resvwrd[42] := 'repeat   ';      ressymbol[42] := repeatsy;
      resvwrd[43] := 'string   ';      ressymbol[43] := stringsy;
      {resvwrd[44] := '*********';      ressymbol[44] := dummysy; }
      resvwrd[45] := 'forward  ';      ressymbol[45] := forwardsy;
      resvwrd[46] := 'program  ';      ressymbol[46] := programsy;
      resvwrd[47] := 'absolute ';      ressymbol[47] := abslutesy;
      resvwrd[48] := 'external ';      ressymbol[48] := externsy;
      resvwrd[49] := 'function ';      ressymbol[49] := funcsy;
      {resvwrd[50] := '*********';      ressymbol[50] := dummysy; }
      resvwrd[51] := 'interrupt';      ressymbol[51] := intruptsy;
      resvwrd[52] := 'otherwise';      ressymbol[52] := othwisesy;
      resvwrd[53] := 'procedure';      ressymbol[53] := procsy;
    end {[s=1] init3resvwrd} ;
{$p-----------*
 | initialize |
 *------------*}


  procedure initialize;

    var
      p: integer;
      c: char; {induction var}

    begin {initialize all global variables}
      linenumber := - 1; {not used in this version}
      init1sets;
      init2sets;
      for c := chr(0) to chr(127) do
	begin
	lowercase[c] := c;
	uppercase[c] := c;
	end;
      for c := 'A' to 'Z' do
	begin
	lowercase[c] := chr(ord(c) + ord('a') - ord('A'));
	uppercase[chr(ord(c) + ord('a') - ord('A'))] := c;
	end;
      outlinelen := defaultoutline;
      tabspaces := defaulttabspaces;
      continuespaces := (tabspaces + 1) div 2;
      comentspaces := defaultcomentspaces;
      indentlevel := 0;
      onehalfline := outlinelen div 2;
      fiveeighthline := (5 * outlinelen) div 8;
      threefourthline := (3 * outlinelen) div 4;
      statsperline := 1;
      for p := 1 to outlinelen do
	symbol[p] := ' ';
      symlen := 0;
      indent := 0;
      statindent := 0;
      writecol := 0;
      column := 0;
      outputline := 1;
      currentline := 0;
      inputline := 1;
      newinputline := true;
      blankline := false;
      charcount := 0;
      sym := period;
      symbolbreak := 0;
      lastsym := period;
      symwritten := false;
      ch := ' ';
      doubleperiod := false;
      ucreswords := false {'R' in options} ;
      ucidents := false {'U' in options} ;
      litcopy := false {'L' in options} ;
      portabilitymode := false {'P' in options} ;
      bunching := false {'B' in options} ;
      silentmode := false; {'Q' in options} ;
      formatting := true;
      newformatting := true;
      overflows := 0;
      comoverflows := 0;
      init1resvwrd;
      init2resvwrd;
      init3resvwrd;
    end {initialize} ;

modend .
