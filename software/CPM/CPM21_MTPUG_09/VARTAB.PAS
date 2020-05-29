{##########################################################################
####                                                                   ####
####  Full module name: VARIABLE_TABLE_MODULE_FOR_TYPE_CHECKER_PROGRAM.####
####  File name:  VARTAB.PAS.                                          ####
####  Support modules reqd:  TYPETAB.PAS, PASLIB.ERL.                  ####
####  Run time environment: <any>.                                     ####
####  Compile time environment: MT MicroSYSTEMS Pascal/MT+v5.25.       ####
####  Link time environment: MT MicroSYSTEMS Linkmt v5.1.              ####
####  Copyright (C) 1982 by Haldo Products, Inc. All rights reserved.  ####
####                        56 Camille Ln, E. Patchogue, NY 11772      ####
####  Programmer: Lawrence Adkins.                                     ####
####  Module Development/Maintenance History:                          ####
       1-MAR-82 Vers 2.0.  File just created, and completed.
       6-MAR-82 Vers 2.1.  Conformant array stuff added.
      19-APR-82 Vers 2.2.  No changes made.
####                                                                   ####
##########################################################################}





MODULE VARIABLE_TABLE_HANDLER;

{$I B:TYPECHK.DEC }    { list of all our type declarations }

VAR 
  last_vt_entry: integer;   { last filled element of var table }
  token: EXTERNAL tokentype;
  tokenbuf: EXTERNAL string132;
  exit_keywords: EXTERNAL SET OF tokentype;
  last_entry_point_name: EXTERNAL string132;
  outfile: EXTERNAL text;
  record_parsing_status: EXTERNAL t_record_parsing_status;
  last_tt_entry: EXTERNAL integer;
  symbols_avail_for_external_reference: EXTERNAL boolean;
  debug: EXTERNAL boolean;

EXTERNAL PROCEDURE get_next_token;
EXTERNAL PROCEDURE error (pascal_error_no: integer);
EXTERNAL PROCEDURE @hlt;
EXTERNAL PROCEDURE tm1add_type_identifier_to_type_table
  (    new_id: alfa;
   VAR type_table: ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);
EXTERNAL PROCEDURE tm0parse_rest_of_type_definition
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);
EXTERNAL FUNCTION  tm1find_prev_occurance_of_type_id 
  (VAR type_id: string132;
       last_index: integer;
   VAR ret_index: integer;
   VAR type_table: ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec):
                  boolean;


{#############################################################################}
{--- Initialize the variables in this module }
{#############################################################################}
PROCEDURE vminit_var_table_module;

  BEGIN
  last_vt_entry := 0
  END;



{#############################################################################}
(*-- Then we will parse the following Pascal/MT+ BNF productions:
---- <variable_declaration_part> ::= <empty> |
----          VAR <variable_declaration> {; <variable_declaration>} ;
---- <variable_declaration> ::= <identifier> {, <identifier>} :
----          <attribute> <type>
---- <attribute> ::= EXTERNAL | ABSOLUTE [ <constant> ] | <empty>
---- <type> ::= <SEE TM0PARSE_REST_OF_TYPE_DEFINITION>
----                                                                   *)
{#############################################################################}
PROCEDURE vmadd_new_vars_to_var_table
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec;
   VAR var_table  : ARRAY [vtlobound..vthibound: natural] OF t_var_tab_rec);

  CONST action =  'Handling Variables...';
  VAR type_id: alfa;
      b: boolean;
      i, j, typ_index, first_var_index: integer;
  BEGIN
  writeln; writeln (action); writeln (outfile); writeln (outfile, action);
  exit_keywords := 
     [tokvar, tokproc, tokfunc, tokbegin, tokexternal];
  record_parsing_status.got_rec_type := 0;

  WHILE token = tokvar
  DO BEGIN
     get_next_token;         { should be var identifier }
     REPEAT
       type_id := concat ('9', tokenbuf);
       tm1add_type_identifier_to_type_table (type_id, type_table);
       first_var_index := last_vt_entry + 1;
       REPEAT { for the list of vars being declared of the same type }
         last_entry_point_name := tokenbuf;
         vmplace_var_id_into_var_table (var_table);
         get_next_token;       { should be tokcolon }
         IF token = tokcomma THEN get_next_token   { should be var_id }
       UNTIL token = tokcolon;

       REPEAT
         { let that routine strip off the <attribute> }
         tm0parse_rest_of_type_definition (const_table, type_table)
       UNTIL (record_parsing_status.got_rec_type= 0) AND (token= toksemicolon);

       b := tm1find_prev_occurance_of_type_id
                (type_id, last_tt_entry, i, type_table);
       WITH type_table [i]
       DO IF entry_purpose = simple_type
          THEN BEGIN 
               typ_index := base_type_index; last_tt_entry := last_tt_entry - 1
               END
          ELSE typ_index := i;
       FOR j := first_var_index TO last_vt_entry
       DO var_table [j]. var_ptr_to_type_table := typ_index;
       IF NOT symbols_avail_for_external_reference
       THEN BEGIN last_tt_entry := i-1; last_vt_entry := first_var_index-1 END
       ELSE vmremove_duplicate_var_entry (var_table);
       IF debug THEN error (0);
       get_next_token;        { should be var_id or exit keyword }
     UNTIL (token IN exit_keywords);
     END
  END;




{#############################################################################}
{---- Check for identical identifier earlier in the table, if match,
----- compare entries, and erase latter entry.                      }
{#############################################################################}
PROCEDURE vmremove_duplicate_var_entry
  (VAR var_table  : ARRAY [vtlobound..vthibound: natural] OF t_var_tab_rec);

  VAR  i: integer;
  BEGIN
  FOR i := 1 TO (last_vt_entry - 1)
  DO WITH var_table [i]
    DO IF var_id = var_table [last_vt_entry]. var_id
      THEN BEGIN
           IF var_ptr_to_type_table <>
             var_table [last_vt_entry].var_ptr_to_type_table
           THEN error (101);  { id declared elsewhere with different value }
           last_vt_entry := last_vt_entry - 1;
           exit
           END
  END;


{#############################################################################}
{--- Bump the index into the variable table by one. Error if overflow.
---- Then insert the variable identifier presently in tokenbuf.       }
{#############################################################################}
PROCEDURE vmplace_var_id_into_var_table
  (VAR var_table  : ARRAY [vtlobound..vthibound: natural] OF t_var_tab_rec);

  VAR i: integer;
  BEGIN
  IF last_vt_entry >= vthibound
  THEN BEGIN
       writeln; 
       writeln ('Variable table overflow. Last id: ', last_entry_point_name); 
       close (outfile, i);
       @hlt
       END;
  last_vt_entry := last_vt_entry + 1;
  var_table [last_vt_entry]. var_id := tokenbuf
  END;



{#############################################################################}
{--- Display the current contents of the variable table  }
{#############################################################################}
PROCEDURE vmdump_variable_table
  (VAR outfile: text;
   VAR var_table  : ARRAY [vtlobound..vthibound: natural] OF t_var_tab_rec);

  VAR i: integer;
  BEGIN
  writeln (outfile);  writeln (outfile, '--- Variable Table Dump --- ');
  writeln (outfile, 'name':30, 'type index':15);
  FOR i := 1 TO last_vt_entry
  DO WITH var_table[i]
     DO writeln (outfile, i:10, var_id:20, var_ptr_to_type_table:15);
  writeln (outfile)
  END;



MODEND.

