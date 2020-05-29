{##########################################################################
####                                                                   ####
####  Full module name: TYPE_TABLE MODULE OF THE TYPE_CHECKER PROGRAM. ####
####  File name:  TYPE1TAB.PAS.(First of 3 files reqd for this module.)####
####  Support modules reqd:  PASLIB.ERL, SCANNER.                      ####
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
       6-MAR-82 Vers 2.1.  Add conformant array stuff.
      19-APR-82 Vers 2.2.  No changes made.
####                                                                   ####
##########################################################################}


MODULE TYPE_TABLE_HANDLER;

{$I B:TYPECHK.DEC }

VAR
  last_tt_entry: integer;  { index to last filled entry of type table }
  token: EXTERNAL tokentype;
  tokenbuf: EXTERNAL string132;
  exit_keywords: SET OF token_type;
  outfile: EXTERNAL text;
  record_parsing_status : t_record_parsing_status;
  last_entry_point_name: EXTERNAL string132;
  ttentry_types_where_base_types_wont_compare,
  rectype_expansion: SET OF tt_types;
  debug: EXTERNAL boolean;

EXTERNAL PROCEDURE get_next_token;
EXTERNAL PROCEDURE error (pascal_error_no: integer);
EXTERNAL PROCEDURE @hlt;
EXTERNAL PROCEDURE cmstore_scalar_type_values (VAR n_of_values: integer;
   VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec);
EXTERNAL PROCEDURE cmfinish_parsing_constant_value (VAR actual_value: integer;
   VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec);





















{#############################################################################}
{--- Initialize all of the variables private to this module }
{#############################################################################}
PROCEDURE tminit_type_table_module
  (VAR type_table:  ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);

  VAR i: integer;
  BEGIN 
    FOR i:= 1 TO 9
    DO WITH type_table[i]
       DO BEGIN
          entry_purpose:= predef_type;
          base_type_index := 0;
          lower_bound := 0; upper_bound := 0
          END;
    WITH type_table[0] DO type_id := '0UNDEFIN';
    WITH type_table[1] 
    DO BEGIN type_id := 'CHAR';     upper_bound := 255   END;
    WITH type_table[2]
    DO BEGIN type_id := 'BYTE';     upper_bound := 255   END;
    WITH type_table[3]
    DO BEGIN type_id := 'INTEGER';  lower_bound := -32768; upper_bound := 32767
       END;
    WITH type_table[4]
    DO BEGIN type_id := 'BOOLEAN';  upper_bound := 1     END;
    WITH type_table[5]
    DO BEGIN type_id := 'WORD';     lower_bound := -32768; upper_bound := 32767
       END;
    WITH type_table[6] DO type_id := 'REAL';
    WITH type_table[7] 
    DO BEGIN type_id := 'STRING';   upper_bound := 255   END;
    WITH type_table[8] DO type_id := 'TEXT';
    WITH type_table[9] DO type_id := 'FILE';

    last_tt_entry := 9;
    rectype_expansion :=
      [recfields, recfldnestedrecord, recvariant, recvarvalues];
    ttentry_types_where_base_types_wont_compare :=
      [array_type, file_type, record_type]
    END;




{#############################################################################}
(*-- Assuming that a Pascal keyword has been read in, we will parse the
---- folllowing Pascal/MT+ BNF productions:
---- <type_definition_part> ::= <empty> |
----          TYPE <type_definition> {; <type_definition>} ;
----          <type_definition_part>
---- <type_definition> ::= <type_identifier> = <type>
---- <type_identifier> ::= <identifier>
---- <type> ::= <SEE TM0PARSE_REST_OF_TYPE_DEFINITION>
----                                                                   *)
{#############################################################################}
PROCEDURE tmadd_new_types_to_type_table
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);
  
  CONST action = 'Handling Types...';
  BEGIN
  writeln;  writeln (action); writeln (outfile); writeln (outfile, action);
  exit_keywords := [toktype, tokvar, tokproc, tokfunc, tokbegin, tokexternal];
  record_parsing_status.got_rec_type := 0;
  WHILE token = toktype
  DO BEGIN
     get_next_token;    { should be type identifier being defined }
     REPEAT
       last_entry_point_name := tokenbuf;
       tm1add_type_identifier_to_type_table (tokenbuf, type_table);
       get_next_token;  { should be equal_sign }
       REPEAT  tm0parse_rest_of_type_definition (const_table, type_table)
       UNTIL (record_parsing_status.got_rec_type= 0) AND (token= toksemicolon);
       get_next_token;  { should be type_id or keyword }
     UNTIL (token IN exit_keywords)
     END
  END;











{#############################################################################}
{--- Place a type_id into a new slot of the type table. }
{#############################################################################}
PROCEDURE tm1add_type_identifier_to_type_table
  (new_id: alfa;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);

  BEGIN
  tminc_last_tt_entry_index (tthibound);
  WITH type_table [last_tt_entry]
  DO BEGIN
     entry_purpose := undef_type; 
     IF record_parsing_status. got_rec_type = 0 THEN type_id := new_id;
     lower_bound := 0; upper_bound := 0; base_type_index := 0
     END;
  tmchange_any_refs_to_identical_type_id_with_undef_type (type_table)
  END;





{#############################################################################}
{--- Bump the index into the type table by 1, and error if overflow }
{#############################################################################}
PROCEDURE tminc_last_tt_entry_index (max_type_elements: natural);

  VAR i: integer;
  BEGIN
  IF last_tt_entry >= max_type_elements
  THEN BEGIN
       writeln;
       writeln ('Type Table overflow, last id: ', last_entry_point_name);
       close (outfile, i);
       @hlt
       END;
  last_tt_entry := last_tt_entry + 1
  END;






{#############################################################################}
(*-- Parse the following Pascal/MT+ BNF productions: 
---- <type> ::= <simple_type> | <structured_type> | <pointer_type>
---- <structured_type> ::= <unpacked_structured_type> |
----          PACKED <unpacked_structured_type>
---- <unpacked_structured_type> ::= <array_type> | <record_type> | 
----          <set_type> | <file_type>
---- <array_type> ::= <normal_array> | <string_array>
---- <simple_type> ::= <SEE TM9PARSE_SIMPLE_TYPE>
---- <pointer_type> ::= <SEE TM4PARSE_POINTER>
---- <normal_array> ::= <SEE TM5PARSE_ARRAY>
---- <string_array> ::= <SEE TM3PARSE_STRING>
---- <record_type> ::= <SEE TM6PARSE_RECORD>
---- <set_type> ::= <SEE TM1PARSE_SET>
---- <file_type> ::= FILE <tokof_and_beyond>
---- <tokof_and_beyond> ::= <SEE TM2PARSE_TOKOF_AND_BEYOND>
----                                                              *)
{#############################################################################}
PROCEDURE tm0parse_rest_of_type_definition 
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);
 
  BEGIN
  get_next_token;    { should be some type definition stuff }
  IF (token = tokidentifier) AND (tokenbuf = 'ABSOLUTE')
  THEN BEGIN  { ignore [ <constant> ] syntax representing the address } 
       get_next_token; get_next_token; get_next_token; get_next_token END
  ELSE IF token = tokexternal THEN get_next_token;
  IF token = tokpacked THEN get_next_token;
  { for sure now, we are at the type_id being defined }
  tm1init_new_type_table_entry (token, type_table);
  CASE token OF
    tokset    : tm1parse_set (const_table, type_table);
    tokfile   : tm2parse_tokof_and_beyond (const_table, type_table);
    tokstring : tm3parse_string (const_table, type_table);
    tokpointer: tm4parse_pointer (type_table);
    tokarray  : tm5parse_array (const_table, type_table);
    tokrecord : tm6parse_record (const_table, type_table);
    ELSE tm9finish_parsing_simple_type (const_table, type_table)
    END;
  IF debug THEN error (0);
  tmremove_duplicate_type_declaration (type_table)
  END;

{#############################################################################}
{--- Assuming index has already been bumped and type_identifier entered,
---- initialize some of the other fields for that entry                }
{#############################################################################}
PROCEDURE tm1init_new_type_table_entry
  (token: tokentype;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);

  BEGIN
  WITH type_table [last_tt_entry]
  DO IF record_parsing_status.got_rec_type = 0
     THEN entry_purpose := tok_class (token)
     ELSE BEGIN
          entry_purpose := tokrec_class (token);
          n_of_stacked_fields:= record_parsing_status.last_n_of_stacked_fields;
          record_nesting := record_parsing_status.got_rec_type;
          local_fieldlist_continues := true;
          field_entry_purpose := tok_class (token)
          END
  END;


FUNCTION tokrec_class (token: tokentype): tt_types;

  BEGIN
  IF token = tokrecord
  THEN tokrec_class := recfldnestedrecord
  ELSE tokrec_class := recfields
  END;

FUNCTION tok_class (token: tokentype): tt_types;
  
  BEGIN
  CASE token OF
    tokset     : tok_class := set_type;
    tokfile    : tok_class := file_type;
    tokstring  : tok_class := string_type;
    tokpointer : tok_class := ptr_type;
    tokarray   : tok_class := array_type;
    tokrecord  : tok_class := record_type;
    notoken    : tok_class := undef_type;
    ELSE  tok_class := simple_type
    END
  END;

{$I B:TYPE2TAB.PAS }
{$I B:TYPE3TAB.PAS }

MODEND.
















