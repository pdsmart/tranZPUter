{##########################################################################
####                                                                   ####
####  Full module name: TYPE_TABLE MODULE OF THE TYPE_CHECKER PROGRAM. ####
####  File name:  TYPE2TAB.PAS.(2'nd of 3 files reqd for this module.) ####
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
       6-MAR-82 Vers 2.1.  Conformant array stuff added.
      19-APR-82 Vers 2.2.  No changes made.
####                                                                   ####
##########################################################################}


{#############################################################################}
{ Call to this could have been a call to tm2parse_tokof_and_beyond,
  except that here we avoid filling another type_table entry   }
(*-- Assuming that the first symbol has already been scanned, 
---- parse the following Pascal/MT+ BNF productions:
---- <set_type> ::= SET OF <base_type>
---- <base_type> ::= <simple_type>
---- <simple_type> ::= <SEE TM9FINISH_PARSING_SIMPLETYPE>
----                                                         *)
{#############################################################################}
PROCEDURE tm1parse_set
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec); 

  BEGIN
  get_next_token;  { should be OF token }
  get_next_token;  { should be lparen, constant, or type_id }
  tm9finish_parsing_simple_type (const_table, type_table);
  END;



{#############################################################################}
(*-- parse the following Pascal/MT+ BNF production:
---- <tokof_and_beyond> ::= {OF <type>}
---- <type> ::= <SEE TM0PARSE_REST_OF_TYPE_DEFINITION>
----                                                         *)
{#############################################################################}
PROCEDURE tm2parse_tokof_and_beyond
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec); 
  
  VAR orig_token: token_type;
  BEGIN
  orig_token:= token;
  get_next_token;  { should be OF, scolon, END, or rparen tokens }
  IF token = tokof
  THEN BEGIN
       tm1add_type_identifier_to_type_table ('0BASETYP', type_table);
       type_table [last_tt_entry - 1]. base_type_index := last_tt_entry;
       tm0parse_rest_of_type_definition (const_table, type_table)
       END
  ELSE IF orig_token = tokfile
       THEN tmmake_it_reference_a_simple_type (token, type_table)
  END;





















{#############################################################################}
(*-- Assuming that the first symbol has already been scanned,
---- parse the following Pascal/MT+ BNF productions:
---- <string_array> ::= STRING <max_length>
---- <max_length> ::= [ <intconst> ] | <empty>
---- <intconst> ::= <unsigned_integer> | <int_const_id>
---- <int_const_id> ::= <identifier>
----                                                         *)
{#############################################################################}
PROCEDURE tm3parse_string
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec); 

 BEGIN
  get_next_token;      { should be lbracket, scolon, END, or rparen tokens }
  IF token = toklbracket
  THEN BEGIN
       get_next_token; { should be constant_id or constant_value }
       cmfinish_parsing_constant_value (type_table[last_tt_entry].upper_bound,
          const_table);
       get_next_token; { should be rbracket }
       get_next_token  { should be scolon, END, or rparen tokens }
       END
  ELSE tmmake_it_reference_a_simple_type (tokstring, type_table)
  END;



















{#############################################################################}
{---- Make a type entry have as it's base type a simple type, not the following
----- type table entry, so that we may save some type table space.}
{#############################################################################}
PROCEDURE tmmake_it_reference_a_simple_type
  (    token: token_type;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec); 

  BEGIN
  WITH type_table [last_tt_entry]
  DO BEGIN
     IF (entry_purpose IN rectype_expansion)
     THEN field_entry_purpose := simple_type
     ELSE entry_purpose := simple_type;
     CASE token OF
       tokfile:   base_type_index := 9;
       tokstring: base_type_index := 7
       END
     END
  END;


{#############################################################################}
(*-- Assuming that the first symbol has already been scanned,
---- parse the following Pascal/MT+ BNF production:
---- <pointer_type> ::= ^ <type_identifier> |
----          @ <type_identifier>
----                                                         *)
{#############################################################################}
PROCEDURE tm4parse_pointer
  (VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec); 

  VAR base, len: integer;
  BEGIN
  get_next_token;      { should be (possibly undefined) type_id }
  IF tm1find_prev_occurance_of_type_id
         (tokenbuf, last_tt_entry, base, type_table)
  THEN type_table [last_tt_entry]. base_type_index := base
  ELSE BEGIN
       tm1add_type_identifier_to_type_table (tokenbuf, type_table);
       tm1init_new_type_table_entry (notoken, type_table);
       type_table [last_tt_entry - 1]. base_type_index := last_tt_entry
       END;
  get_next_token       { should be scolon, END, or rparen tokens }
  END;





















{#############################################################################}
(*-- Assuming that the first symbol has already been scanned,
---- parse the following Pascal/MT+ BNF productions:
---- <normal_array> ::= ARRAY [ <index_type> {, <index_type>} ]
----          <tokof_and_beyond>
---- <index_type> ::= <simple_type>
---- <simple_type> ::= <SEE TM9FINISH_PARSING_SIMPLETYPE>
---- <tokof_and_beyond> ::= <SEE T2PARSE_TOKOF_AND_BEYOND>
----                                                         *)
{#############################################################################}
PROCEDURE tm5parse_array
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec); 

  BEGIN
  get_next_token;      { should be lbracket }
  REPEAT
    get_next_token;    { should be lparen, constant, or type_id }
    tm9finish_parsing_simple_type (const_table, type_table);
      { present token should be a comma or rbracket }
    IF token = tokcomma
    THEN BEGIN
         tm1add_type_identifier_to_type_table ('0ARRAY', type_table);
         tm1init_new_type_table_entry (tokarray, type_table);
         type_table [last_tt_entry - 1]. base_type_index := last_tt_entry
         END
  UNTIL token = tokrbracket;
  tm2parse_tokof_and_beyond (const_table, type_table)
  END;















{#############################################################################}
(*-- Assuming that the first symbol has already been scanned,
---- parse the following Pascal/MT+ BNF productions:
---- <record_type> ::= RECORD <fieldlist> END
---- <fieldlist> ::= <SEE TM7PARSE_FIELDLIST>
----                                                         *)
{#############################################################################}
PROCEDURE tm6parse_record
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec); 

  BEGIN
  IF last_tt_entry < max_type_elements
  THEN type_table [last_tt_entry]. base_type_index := last_tt_entry + 1;
  WITH record_parsing_status DO got_rec_type := got_rec_type + 1;
  tm7parse_fieldlist (const_table, type_table);
    { should now be at the END token for this record }
  WITH record_parsing_status DO got_rec_type := got_rec_type - 1;
  type_table [last_tt_entry]. local_fieldlist_continues := false;
  get_next_token       { should be scolon, END, or rparen tokens }
  END;

{#############################################################################}
(*-- Assuming that the first symbol has already been scanned,
---- parse the following Pascal/MT+ BNF productions:
---- <field_list> ::= <fixed_part> | <fixed_part> ; <variant_part> |
----          <variant_part>
---- <fixed_part> ::= <record_section> {; <record_section>}
---- <record_section> ::= <field_identifier> {, <field_identifier>} :
----          <type>  |  <empty>
---- <field_identifier> ::= <identifier>
---- <variant_part> ::= CASE <tag_field_part> OF <variant> {; <variant>}
---- <tag_field_part> ::= <SEE TM71PARSE_VARIANT_DECLARATION>
---- <variant> ::= <case_label_list> : ( <field_list> ) | <empty>
---- <case_label_list> ::= <SEE TM72PARSE_LIST_OF_VARIANT_VALUES>
----                                                         *)
{#############################################################################}
PROCEDURE tm7parse_fieldlist
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec); 

  BEGIN
  REPEAT
    record_parsing_status.last_n_of_stacked_fields := 0;
    get_next_token;      { should be identifier, CASE, END, or rparen tokens }
    CASE token OF
      tokidentifier:
        BEGIN
        REPEAT
          IF token = tokidentifier   { as opposed to being tokcomma }
          THEN WITH record_parsing_status
               DO last_n_of_stacked_fields := last_n_of_stacked_fields + 1;
          get_next_token { should be comma or colon tokens }
        UNTIL token = tokcolon;
        tm1add_type_identifier_to_type_table ('0noname', type_table);
        tm0parse_rest_of_type_definition (const_table, type_table)
        END;
      tokcase: 
        BEGIN
        tm71parse_variant_declaration (type_table);
        get_next_token;  { should be OF token }
        REPEAT
          tm72parse_list_of_variant_values (type_table);
          REPEAT
            get_next_token;{ should be lparen }
            tm7recurse_parse_fieldlist (const_table, type_table);
            IF token = toksemicolon { instead of tokrparen }
            THEN tm72parse_list_of_variant_values (type_table)
          UNTIL token = tokrparen;
          type_table [last_tt_entry]. local_fieldlist_continues := false;
          get_next_token   { should be scolon or END token }
        UNTIL token = tokend
        END;
      tokrparen, tokend:
        { do no action }
      END  { case }
  UNTIL (token = tokend) OR (token = tokrparen)
  END;


PROCEDURE tm7recurse_parse_fieldlist
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec); 

  BEGIN  tm7parse_fieldlist (const_table, type_table)  END; 



{#############################################################################}
(*-- parse the following Pascal/MT+ BNF productions:
---- <tag_field_part> ::= <tag_field> <type_identifier>
---- <tag_field> ::= <field_identifier> : | <empty>
----                                                         *)
{#############################################################################}
PROCEDURE tm71parse_variant_declaration
  (VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec); 

  VAR base: integer;
  BEGIN
  get_next_token;      { should be identifier (variant_var_id or type_id) }
  IF tm1find_prev_occurance_of_type_id
          (tokenbuf, last_tt_entry, base, type_table)
  THEN record_parsing_status.last_n_of_stacked_fields := 0
  ELSE BEGIN
       record_parsing_status.last_n_of_stacked_fields := 1;
       get_next_token; { should be colon token }
       get_next_token  { should be type_id  }
       END;
  tminc_last_tt_entry_index (tthibound);
  record_parsing_status.last_base_type_index := base;
  WITH type_table [last_tt_entry]
  DO BEGIN
     entry_purpose := recvariant;
     base_type_index := base;
     upper_bound := type_table [base]. upper_bound;
     lower_bound := type_table [base]. lower_bound;
     n_of_stacked_fields := record_parsing_status.last_n_of_stacked_fields;
     field_entry_purpose := simpletype;
     local_fieldlist_continues := true;
     record_nesting := record_parsing_status.got_rec_type
     END
  END;










{#############################################################################}
(*-- parse the following Pascal/MT+ BNF productions:
---- <case_label_list> ::= <case_label> {, <case_label>}
---- <case_label> ::= <constant>
----                                                         *)
{#############################################################################}
PROCEDURE tm72parse_list_of_variant_values
  (VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec); 

  VAR n_of_values: integer;
  BEGIN
  n_of_values := 0;
  REPEAT
    get_next_token;  { should be constant_value }
    n_of_values := n_of_values + 1;
    get_next_token   { should be comma or colon tokens }
  UNTIL token = tokcolon;
  tminc_last_tt_entry_index (tthibound);
  WITH type_table [last_tt_entry]
  DO BEGIN
     entry_purpose := recvarvalues;
     base_type_index := record_parsing_status. last_base_type_index;
     upper_bound := n_of_values;
     lower_bound := 0;
     local_fieldlist_continues := true;
     field_entry_purpose := simple_type;
     record_nesting := record_parsing_status. got_rec_type;
     n_of_stacked_fields := 1
     END
  END;













