{##########################################################################
####                                                                   ####
####  Full module name: SCANNER.    File name:  SCANNER.PAS.           ####
####  Support modules reqd:  PASLIB.ERL.                               ####
####  Run time environment: <any>.                                     ####
####  Compile time environment: MT MicroSYSTEMS Pascal/MT+v5.25.       ####
####  Link time environment: MT MicroSYSTEMS Linkmt v5.1.              ####
####  Copyright (C) 1982 by Haldo Products Inc. All rights reserved.   ####
####                        56 Camille Ln, E. Patchogue, NY 11772      ####
####  Programmer: Lawrence Adkins.                                     ####
####  Module Development/Maintenance History:                          ####
       6-NOV-81 vers 1.0. File just created.
      12-NOV-81           development of this version complete.
       9-JAN-82 vers 2.0. Minor mods for use with other updated modules. 
       1-MAR-82           deveopment of this version complete.
      19-APR-82 Vers 2.2. Add blockread compatibility stuff.
####                                                                   ####
##########################################################################}




{############################################################################
####                                                                     ####
####            S  C  A  N  N  E  R      M  O  D  U  L  E                ####
####                                                                     ####
####  This is a collection of procedures of the cross-module type checking###
####  program which are involved with the sending back to the parser the ####
####  next token in the source text.  There are two entry points:        ####
####  GET_NEXT_TOKEN which drives almost everything else within this     ####
####  module, and SCAN_INIT which initializes this module's variables.   ####
####  NOTE: We do not tokenize every single symbol in the Pascal         ####
####  language, but rather only those symbols that make up all constant, ####
####  type, and var declarations, as well as procedure and function      ####
####  headings.                                                          ####
####  Vers 2 changes: add ',','^','@' to the alphabet, permit '@' to be  ####
####  used as either a pointer or an identifier character. Move uppercase####
####  function to another module. Improved SKIP_COMMENT logic.           ####
############################################################################}

MODULE pascal_type_var_and_routine_header_scanner;

{$I B:TYPECHK.DEC}

VAR
  infile: EXTERNAL text;
  infile1: text;
  outfile: EXTERNAL text;
  input_line: EXTERNAL string132;
  curr_input_line: EXTERNAL string132;
  prev_input_line: EXTERNAL string132;
  prev1_input_line: EXTERNAL string132;
  token: EXTERNAL tokentype;
  tokenbuf, ident_buf: EXTERNAL string132;
  charbuf: EXTERNAL char;
  at_is_alternative_pointer_symbol: EXTERNAL boolean;  
  symbols_avail_for_external_reference: EXTERNAL boolean;
  include_file_level: EXTERNAL byte;
  includ_file_name: EXTERNAL string15;
  token_table: ARRAY [token_type] OF alfa;
  debug: EXTERNAL boolean;
  endfile: EXTERNAL boolean;




EXTERNAL PROCEDURE @hlt;
EXTERNAL FUNCTION uppercase (ch: char): char;
EXTERNAL PROCEDURE init_include_file_buffer;
EXTERNAL FUNCTION maineof: boolean;
EXTERNAL PROCEDURE readln_main_program_text (VAR input_line: string132);
EXTERNAL PROCEDURE readln_include_file_text (VAR input_line: string132);
















{############################################################################
####  Initialize charbuf and the token table.
############################################################################}
PROCEDURE init_scanner;
  BEGIN
  charbuf := ' ';
  token_table [notoken]      := 'NOTOKEN';
  token_table [tokliteral]   := 'LITERAL';
  token_table [toklparen]    := 'LPAREN';
  token_table [tokrparen]    := 'RPAREN';
  token_table [tokcomma]     := 'COMMA';
  token_table [tokperiod]    := 'PERIOD';
  token_table [tokcolon]     := 'COLON';
  token_table [toksemicolon] := 'SCOLON';
  token_table [tokequal]     := 'EQUAL';
  token_table [toklbracket]  := 'LBRACKET';
  token_table [tokrbracket]  := 'RBRACKET';
  token_table [tokdotdot]    := 'DOTDOT';
  token_table [tokpointer]   := 'UPARROW';
  token_table [tokplus]      := 'PLUS';
  token_table [tokminus]     := 'MINUS';
  token_table [tokintnum]    := 'INTNUM';
  token_table [tokbytenum]   := 'BYTENUM';
  token_table [tokrealnum]   := 'REALNUM';
  token_table [toklitstring] := 'LITVALUE';
  token_table [tokidentifier]:= 'IDENT';
  token_table [tokbegin]     := 'BEGIN';
  token_table [tokend]       := 'END';
  token_table [tokconst]     := 'CONST';
  token_table [toktype]      := 'TYPE';
  token_table [tokvar]       := 'VAR';
  token_table [tokproc]      := 'PROCEDUR';
  token_table [tokfunc]      := 'FUNCTION';
  token_table [tokpacked]    := 'PACKED';
  token_table [tokstring]    := 'STRING';
  token_table [tokarray]     := 'ARRAY';
  token_table [tokof]        := 'OF';
  token_table [tokfile]      := 'FILE';
  token_table [tokset]       := 'SET';
  token_table [tokrecord]    := 'RECORD';
  token_table [tokcase]      := 'CASE';
  token_table [tokexternal]  := 'EXTERNAL';
  token_table [toklabel]     := 'LABEL';
  END;




{$E- #######################################################################
####  Return the character that would have appeared in charbuf had we called
####  get-next-char instead.  Dont disturb contents of charbuf or input-line.
###########################################################################}
FUNCTION lookahead_char: char;
  BEGIN
  IF length (input_line) = 0
  THEN lookahead_char := ' '
  ELSE lookahead_char := input_line[1]
  END;








{##########################################################################
####  If input-line string is empty then fill it up by reading the next
####  source line and insert a blank into charbuf.  Otherwise, remove the
####  next character from input-line and deposit it into charbuf.
####  If we were already at eof of an include file then start reading from
####  the main text and subtract one from include-file-level to let every-
####  one else know about this change in input files.
##########################################################################}
PROCEDURE get_next_char;
  CONST 
    eoifmsg = 'EOF reached on Include file. ';
  BEGIN
  IF (length (input_line) = 0) AND NOT endfile
  THEN BEGIN
       IF include_file_level = 0
       THEN readln_main_program_text (input_line)
       ELSE readln_include_file_text (input_line);
       IF debug
       THEN BEGIN writeln (input_line); writeln (outfile, input_line) END
       ELSE BEGIN write ('+'); write (outfile, '+') END; 
       { update the three line buffer used when printing out errors }
       prev1_input_line := prev_input_line;
       prev_input_line := curr_input_line;
       curr_input_line := input_line
       END;
  IF length (input_line) = 0
  THEN charbuf := ' '         { return blank as a separator }
  ELSE BEGIN
       charbuf := input_line[1]; { return character }
       delete (input_line,1,1)   { easier then maintaining column index }
       END;
  IF endfile AND (include_file_level > 0)
  THEN BEGIN    { jump out of include file }
       endfile := false;
       include_file_level := include_file_level - 1;
       writeln; writeln (outfile);
       writeln (eoifmsg);  writeln (outfile, eoifmsg)
       END
  END;





{###########################################################################
####  return true if char is permissable in type, var, routine declaration.
###########################################################################}
FUNCTION in_alphabet (character: char): boolean;
  BEGIN in_alphabet := character IN
    ['A'..'Z', 'a'..'z', '0'..'9', ':', ';', '*', '{', '}', '''', '+',
     '-', '=', '(', ')', '.', ',', '$', '_', '[', ']', '^', '@', ' ']
  END;

FUNCTION in_alpha (character: char): boolean;
  BEGIN in_alpha := character IN ['A'..'Z', 'a'..'z', '_'] END;

FUNCTION in_numeric (character: char): boolean;
  BEGIN in_numeric := character IN ['0'..'9'] END;

FUNCTION in_hex_numeric (character: char): boolean;
  BEGIN in_hex_numeric := character IN ['0'..'9', 'A'..'F', 'a'..'f'] END;





{#################################################################
####  Procedures that call this will do so if after they call 
####  get-next-char all they find in charbuf is either a blank or
####  is not in the alphabet as we define it for type, var, and
####  routine heading declarations. We correct the state of charbuf by
####  repeatedly calling get-next-char until either a legal nonblank
####  character is found or eof of the main text is found.
##################################################################} 
PROCEDURE handle_blank_or_illegal_chars;
  BEGIN
  WHILE ((NOT in_alphabet(charbuf)) OR (charbuf = ' ')) AND 
          NOT maineof
  DO get_next_char
  END;








{#######################################################################
####  Check whether or not the sequence of characters is a reserved word.
#######################################################################}
PROCEDURE check_if_reserved_word;
  VAR 
    temp_str: alfa;
    i: token_type;
  BEGIN
  temp_str := tokenbuf;
  FOR i := tokbegin TO toklabel
  DO IF temp_str = token_table [i]
     THEN BEGIN  token:= i; exit  END
  END;









{######################################################################
####  Assuming that the character in charbuf was determined to be
####  an alpha, scan all following alphanumeric characters.  After
####  then checking if the id is a reserved word, leave in charbuf
####  the last alphanumeric character scanned.
######################################################################}
PROCEDURE handle_identifier;
  BEGIN
  token := tokidentifier;
  tokenbuf := '';
  charbuf := uppercase (charbuf);
  tokenbuf := concat (tokenbuf, charbuf);
  WHILE in_alpha (lookahead_char) OR in_numeric (lookahead_char)
  DO BEGIN
     REPEAT get_next_char UNTIL (charbuf <> '_');
     charbuf := uppercase (charbuf);
     tokenbuf := concat (tokenbuf, charbuf);
     END;
  check_if_reserved_word
  END;


{########################################################################
####  If two periods found in a row (one in charbuf, the other still in
####  input-line, then transfer the second one from input-line to charbuf.
########################################################################}
PROCEDURE handle_dot_dot;
  BEGIN
  token := tokperiod;
  IF lookahead_char = '.'
  THEN BEGIN   get_next_char; token := tokdotdot END
  END;












{########################################################################
####  Assuming the character in charbuf is a '$', scan the following chars
####  in input-line as hex digits.  Stop before reading in a non-hex digit.
#########################################################################}
PROCEDURE handle_hex_num;
  BEGIN
  token := tokintnum; tokenbuf := charbuf;
  WHILE in_hex_numeric (lookahead_char)
  DO BEGIN  get_next_char; tokenbuf := concat (tokenbuf, charbuf) END;
  END;












{########################################################################
####  Assuming that the character in charbuf is a literal mark, get 
####  any other characters on that line into tokenbuf until either a second
####  literal mark or eoln occurs.  Stop before loading into charbuf any
####  character that is not a part of the literal string.
########################################################################}
PROCEDURE handle_literal_constant;
  CONST lit_mark = '''';
  BEGIN
  token := toklitstring; tokenbuf := '';
  WHILE (length (input_line) > 0) AND (lookahead_char <> lit_mark)
  DO BEGIN
     get_next_char;
     tokenbuf := concat (tokenbuf, charbuf)
     END;
  get_next_char;   { put second literal mark into charbuf }
  IF (lookahead_char = lit_mark) 
  THEN BEGIN get_next_char; get_next_char; tokenbuf := charbuf END
  END;



{#########################################################################
####  Process a single digit for handle_integer_or_real_number
#########################################################################}
  PROCEDURE handle_a_digit (VAR bytenum: integer);
      BEGIN
      IF bytenum < 256 THEN bytenum := (bytenum * 10) + (ord(charbuf) - 48);
      tokenbuf := concat (tokenbuf, charbuf);  { next digit }
      IF lookahead_char IN ['E','e','.']
      THEN BEGIN               { treat number as a real number instead }
           IF (lookahead_char = '.') AND (input_line[1] = '.')
           THEN exit;             { a dotdot is the next token }
           byte_num := 256;
           token := tokrealnum;
           get_next_char;         { to get the 'E' or '.' }
           tokenbuf := concat (tokenbuf, charbuf);
           IF lookahead_char IN ['+','-']
           THEN BEGIN get_next_char; tokenbuf := concat (tokenbuf, charbuf) END
           END;
      END;



{########################################################################
####  Assuming that the digit in charbuf is a digit or sign, bring in the
####  following digits into tokenbuf.  The encountering of a period or 'e'
####  character will make the number a real one.  The encountering of
####  other alpha chars (as might follow a sign) will force the interpreting
####  of an identifier instead. As with the other routines in this module, 
####  one must do a get_next_char to get the char following the last digit.
########################################################################}
PROCEDURE handle_integer_or_real_num;
  VAR
    bytenum: integer; {used to find out if integer can be squeezed into byte}
  BEGIN
  bytenum := 0;
  token := tokintnum; tokenbuf := '';
  handle_a_digit (bytenum);  { charbuf should now contain the first digit }
  WHILE in_numeric (lookahead_char)
  DO BEGIN get_next_char; handle_a_digit (bytenum) END;
  IF (bytenum <= 255) AND (bytenum >= 0)
  THEN token := tokbytenum;     { integer can be crammed into a byte }
  END;


{##########################################################################
####  Go open the include file specified following the the $I option
####  within the comment last scanned.  Bump up include_file_level by one
####  to notify the rest of the program that we are now in an include file.
##########################################################################}
PROCEDURE open_include_file;
  CONST
    eifmsg = 'Including Text from file: ';
    comsg =  'Cannot open Include file: ';
  VAR
    i: integer;
  BEGIN
  open (infile1, includ_file_name, i);
  writeln;  writeln (outfile);
  IF i = 255
  THEN BEGIN
       writeln (comsg, includ_file_name); 
       writeln (outfile, comsg, includ_file_name);
       close (outfile,i);
       @hlt
       END
  ELSE BEGIN
       init_include_file_buffer;
       include_file_level := include_file_level + 1;
       writeln (eifmsg, includ_file_name);
       writeln (outfile, eifmsg, includ_file_name)
       END;
  includ_file_name := ''
  END;















{#########################################################################
####  Pull off characters of the specified include file name and insert
####  into the variable includ_file_name. Leave in charbuf the last letter
####  of the file name obtained. 
#########################################################################}
PROCEDURE get_include_file_name;
  BEGIN
  get_next_char;     {get first char following the I letter }
  handle_blank_or_illegal_chars; {charbuf now has 1st letter of fname }
  includ_file_name := concat (includ_file_name, uppercase (charbuf));
  WHILE NOT (lookahead_char IN [' ','*','}'])
  DO BEGIN
     get_next_char;
     includ_file_name := concat (includ_file_name, uppercase (charbuf))
     END
  END;






{#############################################################################
####  Assuming that either a left brace or left paren is in charbuf, keep on 
####  scanning until the matching right brace or right paren is in charbuf, 
####  then return.  If a dollar sign follows the chars that signal the 
####  beginning of a comment, then parse the relevant compiler toggles.
####  Permissable ones are Entry-point symbol ($E+/-) and Include-file 
####  ($I fname.ext) as documented in the MT MicroSYSTEMS Pascal manual.
#############################################################################} 
PROCEDURE handle_comment;
  VAR
    brace_comment: boolean; 
    prev_char: char;
  BEGIN
  brace_comment := charbuf = '{';
  IF (charbuf = '(') 
  THEN IF (lookahead_char = '*') 
       THEN get_next_char
       ELSE BEGIN token := toklparen; exit END;
  token := notoken;
  IF lookahead_char = '$'
  THEN BEGIN
       get_next_char;
       CASE uppercase (lookahead_char) OF
         'E': BEGIN  get_next_char;
              symbols_avail_for_external_reference := lookahead_char <> '-'
              END;
         'I': BEGIN get_next_char; get_include_file_name END
         END
       END;
       
  { Continue to read characters until the end of the comment is found. }
  charbuf := ' ';
  REPEAT  prev_char := charbuf;  get_next_char
  UNTIL ((prevchar = '*') AND (charbuf = ')') AND (NOT brace_comment))
     OR ((charbuf  = '}') AND brace_comment)
     OR   maineof
  END;







{$E+ ##################################################################
####  This entry procedure is the driver of all of the other routines in
####  this module.  Its function, when called by the parser in the main
####  program are to get the next character in the linebuffer into 
####  charbuf, determine the token value, and then perhaps to call another
####  routine to determine if the consecutively following characters in
####  the linebuffer might cause a change in the token value.  The repeat
####  loop is intended to handle the occurence of a comment.
######################################################################}
PROCEDURE get_next_token;
  BEGIN
  IF tokenbuf <>'' THEN ident_buf := tokenbuf; { store id for use in error }
  tokenbuf := '';
  REPEAT
    IF includ_file_name <> '' THEN open_include_file;
    get_next_char;            { advance past character from last token }
    handle_blank_or_illegal_chars; { skip any separators }
    IF in_alpha (charbuf)   THEN handle_identifier ELSE
    IF in_numeric (charbuf) THEN handle_integer_or_real_num ELSE
    CASE charbuf OF
        '$': handle_hex_num;
       '''': handle_literal_constant; 
    '(','{': handle_comment;
        ')': token := tokrparen;
        ',': token := tokcomma;
        '.': handle_dot_dot;
        ':': token := tokcolon;
        ';': token := toksemicolon;
        '=': token := tokequal;
        '[': token := toklbracket;
        ']': token := tokrbracket;
        '^': token := tokpointer;
        '@': IF at_is_alternative_pointer_symbol
             THEN token := tokpointer
             ELSE handle_identifier;
        '-': token := tokminus;
        '+': token := tokplus;
        ELSE token := notoken
        END 
  UNTIL (token <> notoken) OR maineof;
  IF debug
  THEN BEGIN
       write (' ':20, '<token, tokenbuf>   ');
       writeln (token_table [token]:10, ' ':5, tokenbuf:10)
       END
  END;


MODEND.
















