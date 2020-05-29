{##########################################################################
####                                                                   ####
####  Full module name: TYPE_TABLE MODULE OF THE TYPE_CHECKER PROGRAM. ####
####  File name:  TYPE3TAB.PAS.(3'rd of 3 files reqd for this module.) ####
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
       1-MAR-82            Development of this version completed.
####                                                                   ####
##########################################################################}




{#############################################################################}
(*-- Assuming that the first_symbol has already been scanned,
---- parse the following Pascal/MT+ productions:
---- <simple_type> ::= <scalar_type> | <subrange_type> |
----          <type_identifier>
---- <scalar_type> ::= ( <identifier> {, <identifier>} )
---- <subrange_type> ::= <constant> .. <constant>
---- <type_identifier> ::= <identifier>
---- <constant> ::= <SEE CMFINISH_PARSING_CONSTANT_VALUE>
----                                                         *)
{#############################################################################}
PROCEDURE tm9finish_parsing_simple_type 
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);
  
  VAR base, n_of_values, actual_value: integer;
  BEGIN
  IF token = toklparen
  THEN BEGIN
       cmstore_scalar_type_values (n_of_values, const_table); 
       WITH type_table [last_tt_entry]
       DO BEGIN lower_bound := 0;  upper_bound := n_of_values - 1 END
       END
  ELSE IF tm1find_prev_occurance_of_type_id
               (tokenbuf, last_tt_entry, base, type_table)
       THEN type_table [last_tt_entry]. base_type_index := base
       ELSE BEGIN
            cmfinish_parsing_constant_value (actual_value, const_table);
            type_table [last_tt_entry]. lower_bound := actual_value;
            get_next_token;  { should be dot_dot token }
            get_next_token;  { should be constant_value or identifier }
            cmfinish_parsing_constant_value (actual_value, const_table);
            type_table [last_tt_entry]. upper_bound := actual_value
            END;
  get_next_token          { should be scolon, END, or rparen tokens }
  END;                    { or even rbracket or comma tokens (as with arrays) }








{#############################################################################}
{--- Find 2 occurances of the same type declaration, compare the two, and 
---- remove the latter one.  Error if two dont compare. }
{#############################################################################}
PROCEDURE tmremove_duplicate_type_declaration
  (VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);

  VAR j, base, len, last_type_dec_index: integer;
      rec: t_type_tab_rec;
  BEGIN
  IF (record_parsing_status. got_rec_type = 0)
    AND tm2find_prev_occurance_of_last_type_entry (base, len, type_table)
  THEN BEGIN
         {compare all related pairs of records for identity }
       last_type_dec_index := last_tt_entry - len;
       FOR j := 0 TO len
       DO BEGIN
          rec := type_table [last_type_dec_index + j];
          WITH type_table [base + j]
          DO IF   (lower_bound <> rec.lower_bound)
               OR (upper_bound <> rec.upper_bound)
               OR (NOT exception (entry_purpose) AND
                   (base_type_index <> rec.base_type_index))
               OR (entry_purpose <> rec.entry_purpose)
               OR ((entry_purpose IN rectype_expansion)
                 AND ((n_of_stacked_fields <> rec.n_of_stacked_fields)
                   OR (NOT exception (field_entry_purpose) AND
                       (field_entry_purpose <> rec.field_entry_purpose))
                   OR(local_fieldlist_continues<>rec.local_fieldlist_continues)
                   OR (record_nesting <> rec.record_nesting) ) )
             THEN BEGIN
                  error (101);  { type declared differently from first time }
                  last_tt_entry := last_type_dec_index - 1;
                  exit
                  END;
          END;  { for }
       last_tt_entry := last_type_dec_index - 1
       END  { if }
  END;





{#############################################################################}
{--- Resolve previously unresolved type declarations. }
{--- It is assumed that any references to undefined types occur only
---- in the form  TYPE ptr_type_name = ^ defined_or_undefined_type }
{#############################################################################}
PROCEDURE tmchange_any_refs_to_identical_type_id_with_undef_type
  (VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);

  VAR base, len: integer;
  BEGIN
  WHILE tm2find_prev_occurance_of_last_type_entry (base, len, type_table)
  DO IF type_table [base]. entry_purpose = undef_type
     THEN BEGIN
          type_table [base-1]. base_type_index := last_tt_entry;
          WITH type_table [base] DO type_id := concat ('0', type_id)
          END
     ELSE exit
  END;




{#############################################################################}
{--- Determine the number of entries consumed by the last type declaration,
---- as well as the index to the last previous occurance of the same type
---- identifier.                                                          }
{#############################################################################}
FUNCTION tm2find_prev_occurance_of_last_type_entry
  (VAR ret_index: integer;
   VAR entries_consumed: integer;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec):
          boolean;

  VAR last_type_dec_index: integer;
  BEGIN
  last_type_dec_index := last_tt_entry;
  WHILE (type_table [last_type_dec_index]. entry_purpose IN rectype_expansion)
     OR (type_table [last_type_dec_index]. type_id [1] = '0')
  DO last_type_dec_index := last_type_dec_index - 1;
  entries_consumed := last_tt_entry - last_type_dec_index;
  tm2find_prev_occurance_of_last_type_entry :=
    tm1find_prev_occurance_of_type_id (type_table[last_type_dec_index].type_id,
       (last_type_dec_index - 1), ret_index, type_table)
  END;
{#############################################################################}
{--- Looking back from last_index, return the index where the last declar-
---- ation of the specified type identifier may be found.                }
{#############################################################################}
FUNCTION tm1find_prev_occurance_of_type_id
  (VAR name_string: string132;
       last_index: integer;
   VAR ret_index: integer;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec):
            boolean;

  VAR i: integer;
      name_to_find: alfa;
  BEGIN
  ret_index := 0;
  name_to_find := name_string;  { reduce length to alfalen characters }
  tm1find_prev_occurance_of_type_id := false;
  FOR i :=last_index DOWNTO 1
  DO IF (NOT (type_table [i]. entry_purpose IN rectype_expansion))
         AND (type_table [i]. type_id = name_to_find)
     THEN BEGIN
          tm1find_prev_occurance_of_type_id := true;
          ret_index := i;  exit
          END
  END;





{#############################################################################}
{--- Return true if we dont want to compare the base type entry field }
{#############################################################################}
FUNCTION exception (entry_purpose: tt_types): boolean;
  
  BEGIN
  exception := entry_purpose IN ttentry_types_where_base_types_wont_compare
  END;






{#############################################################################}
{--- Display the current contents of the type table  }
{#############################################################################}
PROCEDURE tmdump_type_table
  (VAR outfile: text;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);

  VAR i: integer;
  BEGIN
  writeln (outfile); writeln (outfile, '--- TYPE TABLE DUMP --- ');
  write (outfile, '      rec# #fld nest  recpurpose   cont lbound ubound ');
  writeln (outfile, 'mainpurpose   base');
  FOR i := 0 TO last_tt_entry
  DO WITH type_table [i]
     DO BEGIN
        write (outfile, i:10);
        IF NOT (entry_purpose IN rectype_expansion)
        THEN write (outfile, type_id: 20, ' ':8)
        ELSE BEGIN
             write (outfile, n_of_stacked_fields:5, record_nesting:5);
             write_tt_type_value (outfile, field_entry_purpose);
             write (outfile, local_fieldlist_continues:5)
             END;
        write (outfile, lower_bound:7, upper_bound:7);
        write_tt_type_value (outfile, entry_purpose);
        writeln (outfile, base_type_index:5)
        END;
  writeln (outfile)
  END;















{#############################################################################}
{#############################################################################}
PROCEDURE write_tt_type_value (VAR outfile: text; tt_type_value: tt_types);
  
  BEGIN
  CASE tt_type_value OF
    undef_type        : write (outfile, ' undef_type   ');
    predef_type       : write (outfile, ' predef_type  ');
    simple_type       : write (outfile, ' simple_type  ');
    ptr_type          : write (outfile, ' ptr_type     ');
    string_type       : write (outfile, ' string_type  ');
    array_type        : write (outfile, ' array_type   ');
    file_type         : write (outfile, ' file_type    ');
    set_type          : write (outfile, ' set_type     ');
    record_type       : write (outfile, ' record_type  ');
    recfields         : write (outfile, ' recfields    ');
    recfldnestedrecord: write (outfile, ' recfldnested ');
    recvariant        : write (outfile, ' recvariant   ');
    recvarvalues      : write (outfile, ' recvarvalues ')
    END
  END;






















