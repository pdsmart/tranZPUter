{##########################################################################
####                                                                   ####
####  Full module name: CONSTANT_TABLE_MODULE_FOR_TYPE_CHECKER_PROGRAM.####
####  File name:  CONSTTAB.PAS.                                        ####
####  Support modules reqd:  PASLIB.ERL.                               ####
####  Run time environment: <any>.                                     ####
####  Compile time environment: MT MicroSYSTEMS Pascal/MT+v5.25.       ####
####  Link time environment: MT MicroSYSTEMS Linkmt v5.1.              ####
####  Copyright (C) 1982 by Haldo Products, Inc. All rights reserved.  ####
####                        56 Camille Ln, E. Patchogue, NY 11772      ####
####  Programmer: Lawrence Adkins.                                     ####
####  Module Development/Maintenance History:                          ####
       6-NOV-81 Vers 1.0.  File just created.
      12-NOV-81            Development of this version completed.
       9-JAN-82 Vers 2.0.  development begins.
       1-MAR-82            Development of this version complete.
      19-APR-82 Vers 2.2.  No changes made.
####                                                                   ####
##########################################################################}



MODULE CONSTANT_TABLE_HANDLER;

{$I B:TYPECHK.DEC }    { list of all our type declarations }

VAR 
  last_ct_entry: natural;   { last filled element of const table }
  token: EXTERNAL tokentype;
  tokenbuf: EXTERNAL string132;
  exit_keywords: EXTERNAL SET OF tokentype;
  last_entry_point_name: EXTERNAL string132;
  outfile: EXTERNAL text;
  debug: EXTERNAL boolean;

EXTERNAL PROCEDURE get_next_token;
EXTERNAL PROCEDURE error (pascal_error_no: integer);
EXTERNAL PROCEDURE @hlt;






{###########################################################################}
{--- Initialize the variables in this module }
{###########################################################################}
PROCEDURE cminit_constant_table_module
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec);

  BEGIN
  WITH const_table [1] DO BEGIN
    const_id := 'MAXINT';  actual_value := 32767  END;
  WITH const_table [2] DO BEGIN
    const_id := 'FALSE';   actual_value := 0      END;
  WITH const_table [3] DO BEGIN
    const_id := 'TRUE';    actual_value := 1      END;
  WITH const_table [4] DO BEGIN
    const_id := 'NIL';     actual_value := 0      END;

  last_ct_entry := 4
  END;




{#############################################################################}
(*-- First we will skip past the <program_heading> and <label_declaration_part>
 --- syntax until we hit a token defined in the exit_keyword set.      *)
(*-- Then we will parse the following Pascal/MT+ BNF productions:
 --- <constant_definition_part> ::= <empty> |
 ---          CONST <constant_definition> {; <constant_definition>} ;
 ---          <constant_definition_part>
 --- <constant_definition> ::= <identifier> = <constant>
 --- <constant> ::= <SEE CMFINISH_PARSING_CONSTANT_VALUE>
 ---                                                                   *)
{#############################################################################}
PROCEDURE cmadd_new_constants_to_const_table 
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec);

  CONST action_message = 'Handling Constants...';
  BEGIN
  writeln (action_message); writeln (outfile, action_message);
  exit_keywords := 
     [tokconst, toktype, tokvar, tokproc, tokfunc, tokbegin, tokexternal];

  REPEAT get_next_token  { skip prog heading and label declarations }
  UNTIL  (token IN exit_keywords);

  WHILE token = tokconst
  DO BEGIN
     get_next_token;            { should be constant identifier }
     REPEAT
       last_entry_point_name := tokenbuf;
       cminc_last_ct_entry_index (cthibound);
       WITH const_table [last_ct_entry]
       DO BEGIN
          const_id := tokenbuf;
          get_next_token;       { should be tokequal }
          get_next_token;       { should be const_id, number, sign, or string }
          cmfinish_parsing_constant_value (actual_value, const_table);
          cmremove_duplicate_const_entry (const_table)
          END;
       get_next_token;           { should be semicolon }
       IF debug THEN error (0);
       get_next_token            { should be const_id or new keyword }
     UNTIL (token IN exit_keywords);
     END
  END;

{#############################################################################}
(*-- Assuming that the first symbol has already been scanned,
 --- Here we will finish parsing the following Pascal/MT+ BNF productions:
 --- <constant> ::= <unsigned_number> | <sign> <unsigned_number> |
 ---          <constant_identifier> | <sign> <constant_identifier> |
 ---          <string>
 --- <unsigned_number> ::= <unsigned_integer> | <unsigned_real>
 --- <unsigned_real> ::= <unsigned_integer> . <digit_sequence> |
 ---          <unsigned_integer> . <digit_sequence> E <scale_factor> |
 ---          <unsigned_integer> E <scale_factor>
 --- <digit_sequence> ::= <digit> {<digit>}
 --- <scale_factor> ::= <unsigned_integer> | <sign> <unsigned_integer>
 --- <sign> ::= + | -
 --- <constant_identifier> ::= <identifier>
 --- <string> ::= ' <character> {<character>} ' | ''
 ---                                                                   *)  
{#############################################################################}
PROCEDURE cmfinish_parsing_constant_value
  (VAR actual_value: integer;
   VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec);

  VAR sign: integer;
  BEGIN
  sign := +1;
  IF (token = tokplus) OR (token = tokminus)
  THEN BEGIN
       IF TOKEN = tokminus THEN sign := -1;
       get_next_token;       { should be const_id or unsigned number }
       END;

  CASE token OF
    tokidentifier:  
      BEGIN  { look up it's integer value in the table }
      IF cmfind_const_id (actual_value, const_table)
      THEN actual_value := actual_value * sign
      ELSE actual_value := 0
      END;
    tokintnum, tokbytenum, tokrealnum:
      BEGIN  { make the characters into an integer }
      cmxlate_const_value (actual_value, const_table);
      actual_value := actual_value * sign
      END;
    toklitstring: 
      BEGIN   { take the ordinal value of just the first character }
      IF length (tokenbuf) > 0
      THEN actual_value := ord (tokenbuf[1])
      ELSE actual_value := 0
      END
    END
  END;
















{############################################################################}
{---- Check for identical identifier earlier in the table, if match,
----- compare entries, and erase latter entry.                      }
{############################################################################}
PROCEDURE cmremove_duplicate_const_entry
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec);

  VAR  i: integer;
  BEGIN
  FOR i := 1 TO (last_ct_entry - 1)
  DO WITH const_table [i]
     DO IF const_id = const_table [last_ct_entry].const_id
        THEN BEGIN
             IF actual_value <> const_table [last_ct_entry].actual_value
             THEN error (101);  { id declared elsewhere with different value }
             last_ct_entry := last_ct_entry - 1;
             exit
             END
  END;



{#############################################################################}
{--- Search out specified identifier in constant table.  If found,
---- return the index, and true, meaning found.                  }
{#############################################################################}
FUNCTION cmfind_const_id
  (VAR ret_val: integer;
   VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec):
       boolean;

  VAR i : integer;
      name_to_find: alfa;
  BEGIN
  ret_val := 0;  cm_find_const_id := false;
  name_to_find := tokenbuf;  {shorten length down to alfalen chars}
  FOR i := 1 TO last_ct_entry
  DO WITH const_table[i]
     DO IF const_id = name_to_find
        THEN BEGIN ret_val := actual_value; cmfind_const_id := true; exit END
  END;



{############################################################################}
(*-- Assuming we have already scanned the first symbol,
 --- Here we will finish parsing the following Pascal/MT+ BNF productions:
 --- <unsigned_integer> ::= $ <digit_sequence> | <digit_sequence>
 --- <digit_sequence> ::= <digit> {<digit>}
 ---                                                                    *)
{############################################################################}
PROCEDURE cmxlate_const_value
  (VAR ret_val: integer;
   VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec);

  VAR i, offset, first, last, base: byte;
  BEGIN
  last := length(tokenbuf); ret_val := 0;
  IF tokenbuf[1] = '$' 
  THEN BEGIN first := 2; base := 16 END
  ELSE BEGIN first := 1; base := 10 END;
  FOR i := first TO last
  DO BEGIN
     IF tokenbuf[i] <= '9' THEN offset := 48 ELSE offset := 65;
     ret_val := (ret_val * base) + (ord(tokenbuf[i]) - offset)
     END
  END;


{############################################################################}
{--- Bump the index into the constant table by one. Error if overflow. }
{############################################################################}
PROCEDURE cminc_last_ct_entry_index (max_const_elements: natural);

  VAR i: integer;
  BEGIN
  IF last_ct_entry >= max_const_elements
  THEN BEGIN
       writeln; 
       writeln ('Const table overflow. Last id: ', last_entry_point_name); 
       close (outfile, i);
       @hlt
       END;
  last_ct_entry := last_ct_entry + 1
  END;



{#############################################################################}
{--- Display the current contents of the constant table  }
{#############################################################################}
PROCEDURE cmdump_constant_table
  (VAR outfile: text;
   VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec);

  VAR i: integer;
  BEGIN
  writeln (outfile);  writeln (outfile, '--- Constant Table Dump --- ');
  writeln (outfile, 'name':30, 'value':10);
  FOR i := 1 TO last_ct_entry
  DO WITH const_table[i]
     DO writeln (outfile, i:10, const_id:20, actual_value:10);
  writeln (outfile)
  END;






{#############################################################################}
(*-- Assuming that the first symbol has already been scanned,
 --- here we will finish parsing the following Pascal/MT+ BNF production :
 --- <scalar_type> ::= ( <identifier>  {, <identifier>} )
 ---                                                                    *)
{#############################################################################}
PROCEDURE cmstore_scalar_type_values
  (VAR n_of_values: integer;
   VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec);

  BEGIN
  n_of_values := 0;
  REPEAT
    get_next_token;   { should be scalar value identifier }
    cminc_last_ct_entry_index (cthibound);
    WITH const_table [last_ct_entry]
    DO BEGIN const_id := tokenbuf; actual_value := n_of_values END; 
    n_of_values := n_of_values + 1;
    cmremove_duplicate_const_entry (const_table);
    get_next_token    { should be comma or right paren }
  UNTIL token = tokrparen
  END;


MODEND.


















