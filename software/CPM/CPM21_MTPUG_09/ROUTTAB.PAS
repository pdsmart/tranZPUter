{##########################################################################
####                                                                   ####
####  Full program name: ROUTINE_TABLE_MODULE_FOR_TYPE_CHECKER_PROGRAM.####
####  File name:  ROUTTAB.PAS.                                         ####
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


MODULE ROUTINE_TABLE_HANDLER;

{$I B:TYPECHK.DEC }

VAR
  last_rt_entry: integer; { index to last filled element of routine table }
  token: EXTERNAL token_type;
  tokenbuf: EXTERNAL string132;
  infile: EXTERNAL text;
  outfile: EXTERNAL text;
  last_entry_point_name: EXTERNAL string132;
  symbols_avail_for_external_reference: EXTERNAL boolean;
  last_tt_entry: EXTERNAL integer;
  extern_declaration: boolean;
  exit_keywords: EXTERNAL SET OF token_type;
  debug: EXTERNAL boolean;

EXTERNAL PROCEDURE get_next_token;
EXTERNAL PROCEDURE error (pascal_error_no: integer);
EXTERNAL PROCEDURE @hlt;
EXTERNAL PROCEDURE mark ({VAR} p: integer);
EXTERNAL PROCEDURE release (p: integer);
EXTERNAL FUNCTION  tm1find_prev_occurance_of_type_id
  (VAR name_to_find: string132;
       last_index: integer;
   VAR ret_index: integer;
   VAR type_table: ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec):
                  boolean;


{#############################################################################}
{ Initialize this module's private variables. }
{#############################################################################}
PROCEDURE rminit_routine_table_module;

  BEGIN
  last_rt_entry := 0;
  END;






{#############################################################################}
(*-- Assuming the first symbol has already been scanned,
---- parse the following Pascal/MT+ productions:
---- <procfunc_declaration_part> ::= {<proc_or_func> ;}
---- <proc_or_func> ::= <procedure_declaration> | <function_declaration>
---- <procedure_declaration> ::= EXTERNAL <procedure_heading> |
----          <procedure_heading> <block>
---- <function_declaration> ::= EXTERNAL <function_heading> |
----          <function_heading> <block>
---- <procedure_heading> ::= <SEE RTHANDLE_ROUTINE_HEADING_GUTS>
---- <function_heading> ::= <SEE RTHANDLE_ROUTINE_HEADING_GUTS>
---- <block> ::= <SEE RTSKIP_ROUTINE_BODY>
----                                                    *)
{#############################################################################}
PROCEDURE rmadd_new_routines_to_routine_table
  (VAR type_table   : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec;
   VAR routine_table: ARRAY [rtlobound..rthibound: natural] OF t_rout_tab_rec);

  CONST action = 'Handling Routines...';
  VAR saw_a_begin_token: boolean;
  BEGIN
  writeln; writeln (action); writeln (outfile); writeln (outfile, action);
  exit_keywords := [tokexternal, tokproc, tokfunc];
  WHILE NOT eof (infile)  { outer file }
  DO BEGIN
     IF (token IN exit_keywords)
     THEN BEGIN
          extern_declaration := token = tokexternal;
          IF token = tokexternal THEN get_next_token;
          rthandle_routine_heading_guts
             (symbols_avail_for_external_reference, type_table, routine_table);
          IF debug THEN error (0);
          rtremove_duplicate_routine_entry (routine_table);
          IF NOT extern_declaration 
          THEN rtskip_routine_body (type_table, routine_table)
          ELSE get_next_token
          END
     ELSE get_next_token
     END
  END;




{#############################################################################}
(*-- Parse the <block> BNF production.  See the Pascal manuals. *)
{#############################################################################}
PROCEDURE rtskip_routine_body
  (VAR type_table   : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec;
   VAR routine_table: ARRAY [rtlobound..rthibound: natural] OF t_rout_tab_rec);

  BEGIN
  REPEAT
    get_next_token
  UNTIL (token IN exit_keywords) OR (token = tokbegin);
  WHILE (token IN exit_keywords)  { some local routine declarations }
  DO BEGIN   
     rthandle_routine_heading_guts (false, type_table, routine_table);
     rtrecurse_skip_routine_body (type_table, routine_table)
     END;
  { Assume that we are now at the outer begin of this block }
  REPEAT
    get_next_token;
    WHILE (token = tokend) AND (NOT eof (infile))
    DO BEGIN
       get_next_token;
       IF token = toksemicolon
       THEN BEGIN
            get_next_token; 
            IF (token IN exit_keywords) OR (token = tokbegin)
            THEN  exit
            END
       END
  UNTIL eof (infile)
  END;




PROCEDURE rtrecurse_skip_routine_body
  (VAR type_table   : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec;
   VAR routine_table: ARRAY [rtlobound..rthibound: natural] OF t_rout_tab_rec);

  BEGIN  rtskip_routine_body (type_table, routine_table)  END;




{#############################################################################}
{--- Insert the specified info into a record linked onto the routine table--
---- The routine being parsed has parameters.                              }
{#############################################################################}
PROCEDURE rtupdate_parmlist
  (VAR type_id: string132;
       n_of_stacked_parms: integer;
       param_class: tparm_class;
   VAR type_table   : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec;
   VAR routine_table: ARRAY [rtlobound..rthibound: natural] OF t_rout_tab_rec);

  VAR ptr, last_ptr, top_of_addl_parm_list: t_ptr_to_next_parm;
      i, type_index: integer;
      b: boolean;
  BEGIN
  { Assume that at least one additional parm is to to added to parmlist }
  new (ptr);  last_ptr := ptr; top_of_addl_parm_list := ptr;
  b := tm1find_prev_occurance_of_type_id
            (type_id, last_tt_entry, type_index, type_table);
  WITH ptr^
  DO BEGIN 
     parm_indx_to_type_table := type_index;
     parm_class := param_class;
     rest_of_parm_list := nil
     END;
  IF n_of_stacked_parms > 1
  THEN FOR i := 2 TO n_of_stacked_parms
       DO BEGIN
          new (ptr);
          WITH ptr^
          DO BEGIN
             parm_indx_to_type_table := type_index;
             parm_class := param_class;
             rest_of_parm_list := nil
             END;
          last_ptr^.rest_of_parm_list := ptr;
          last_ptr := ptr
          END;
    { Add the additional parm list to the existing parmlist }
  ptr := routine_table [last_rt_entry]. parm_list;
  IF ptr = nil
  THEN routine_table [last_rt_entry]. parm_list := top_of_addl_parm_list
  ELSE BEGIN
       WHILE ptr^.rest_of_parm_list <> nil
       DO ptr := ptr^. rest_of_parm_list;
       ptr^.rest_of_parm_list := top_of_addl_parm_list
       END
  END;


















{#############################################################################}
(*-- Assuming that the first symbol has already been scanned,
---- parse the following Pascal/MT+ productions:
---- <procedure_heading> ::= PROCEDURE INTERRUPT [ <constant> ] ; |
----          PROCEDURE [ <constant> ] <common_routine_heading> ; |
----          PROCEDURE <common_routine_heading> ;
---- <function_heading> ::= FUNCTION <common_routine_heading> : 
----          <result_type> ;
---- <common_routine_heading> ::= <identifier> <overlay_num> |
----          <identifier> <overlay_num> <parmlist>
---- <overlay_num> ::= [ <unsigned_integer> ] | <empty>
----                                                    *)
{#############################################################################}
PROCEDURE rthandle_routine_heading_guts
  (    rtinsert_flag: boolean;
   VAR type_table   : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec;
   VAR routine_table: ARRAY [rtlobound..rthibound: natural] OF t_rout_tab_rec);

  BEGIN
  get_next_token;          { should be routine identifier }
  IF (token = toklbracket)
    OR ((token = tokidentifier) AND (tokenbuf = 'INTERRUPT'))
  THEN BEGIN               { get past overlay/interrupt syntax stuff }
       REPEAT  get_next_token  UNTIL token = tokrbracket;
       get_next_token
       END;
  IF rtinsert_flag
  THEN BEGIN
       last_entry_point_name := tokenbuf;
       rtplace_id_into_routine_table (tokenbuf, routine_table)
       END;
  get_next_token;          { should be lparen, scolon, or colon tokens }
  IF token = toklparen
  THEN BEGIN 
       rt1handle_formal_parmlist (rtinsert_flag, type_table, routine_table);
       get_next_token;     { should be func's colon or proc's scolon }
       END;
  IF token = tokcolon
  THEN BEGIN
       get_next_token;     { should be result_type_id }
       IF rtinsert_flag
       THEN rtupdate_parmlist (tokenbuf, 1, func_value, type_table, 
                 routine_table);
       get_next_token      { should be scolon token }
       END
  END;




















{#############################################################################}
(*-- Assuming the first symbol has already been scanned,
---- parse the following Pascal/MT+ productions:
---- <parmlist> ::= ( <formal_parm> {, <formal_parm>} )
---- <formal_parm> ::= <procedure_heading> | <function_heading> |
----          VAR <parm_group> | <parm_group>
---- <parm_group> ::= <identifier> {, <identifier>} : <type_identifier> |
----          <identifier> {, <identifier>} : <conformant_array>
---- <conformant_array> ::= ARRAY [ <indxtyp> {; <indxtyp>} ] OF
----          <conarray2>
---- <conarray2> ::= <type_identifier> | <conformant_array>
---- <indxtyp> ::= <identifier> .. <identifier> : <ordtypid>
---- <ordtypeid> ::= <scalar_type_identifier> | <subrange_type_identifier>
----                                                     *)
{#############################################################################}
PROCEDURE rt1handle_formal_parm_list
  (    rtinsert_flag: boolean;
   VAR type_table   : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec;
   VAR routine_table: ARRAY [rtlobound..rthibound: natural] OF t_rout_tab_rec);

  VAR n_of_stacked_parms: integer;
      param_class: t_parm_class;
      was_a_procfunc_parm: boolean;
  BEGIN
  REPEAT
    param_class := value_parm;
    n_of_stacked_parms := 0;
    was_a_procfunc_parm := false;
    REPEAT
      get_next_token; { should be VAR,  parm_id, FUNCTION or PROCEDURE tokens }
      IF (token = tokfunc) OR (token = tokproc)
      THEN BEGIN
           was_a_procfunc_parm := true;
           param_class := proc_func;
           rthandle_routine_heading_guts (false, type_table, routine_table);
           tokenbuf := '0undefin'
           END
      ELSE BEGIN
           IF token = tokvar
           THEN BEGIN param_class := var_parm; get_next_token END;
           get_next_token   { should be comma or colon tokens }
           END;
      n_of_stacked_parms := n_of_stacked_parms + 1;
    UNTIL (token = tokcolon) OR was_a_procfunc_parm;
    IF NOT was_a_procfunc_parm
    THEN BEGIN
      get_next_token;    { should be type_id token, or ARRAY }
      IF token = tokarray
      THEN BEGIN
           param_class := conform_array;
           rm2handle_conformant_array (type_table, routine_table)
           END
      END;
    IF rtinsert_flag
    THEN rtupdate_parmlist (tokenbuf, n_of_stacked_parms,
             param_class, type_table, routine_table);
    IF NOT was_a_procfunc_parm
    THEN get_next_token { should be scolon or rparen tokens }
  UNTIL token = tokrparen;
  END;






{#############################################################################}
{---- For now, skip by the conformant array syntax. }
{#############################################################################}
PROCEDURE rm2handle_conformant_array
  (VAR type_table   : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec;
   VAR routine_table: ARRAY [rtlobound..rthibound: natural] OF t_rout_tab_rec);
  
  BEGIN
  REPEAT
    REPEAT
      get_next_token; get_next_token;  { should be lbracket, then identifier }
      get_next_token; get_next_token;  { should be dotdot, then identifier }
      get_next_token; get_next_token;  { should be colon, then ordtypeid }
      get_next_token; get_next_token   { should be rbracket, then scolon or OF}
    UNTIL token = tokof;
    get_next_token           { should be ARRAY or base_type_id }
  UNTIL token <> tokarray
  END;




{#############################################################################}
{--- Insert a routine identifier into the routine tablem, after first
---- bumping up the routine table index and checking for its overflow. }
{#############################################################################}
PROCEDURE rtplace_id_into_routine_table
  (VAR proc_id: alfa;
   VAR routine_table: ARRAY [rtlobound..rthibound: natural] OF t_rout_tab_rec);

  VAR i: integer;
  BEGIN
  IF (last_rt_entry >= max_routines)
  THEN BEGIN
       writeln; 
       writeln ('Routine Table overflow, Last id: ',last_entry_point_name);
       close (outfile, i);
       @hlt
       END;
  last_rt_entry := last_rt_entry + 1;
  WITH routine_table [last_rt_entry]
  DO BEGIN  parm_list := nil;  routine_name := proc_id  END
  END;

{#############################################################################}
{--- Find a preexisting occurance of the last routine in the routine table
---- and compare the pair, before deleting the latter one.               }
{#############################################################################}
PROCEDURE rtremove_duplicate_routine_entry
  (VAR routine_table: ARRAY [rtlobound..rthibound: natural] OF t_rout_tab_rec);

  VAR i: integer;
      ptr, temp_ptr: t_ptr_to_next_parm;
  BEGIN
  FOR i := 1 TO (last_rt_entry - 1)
  DO IF routine_table [i]. routine_name = 
        routine_table [last_rt_entry]. routine_name
     THEN BEGIN
          temp_ptr := routine_table [last_rt_entry]. parm_list;
          ptr := routine_table [i]. parm_list;
          WHILE (ptr <> nil) AND (temp_ptr <> nil)
          DO BEGIN
             IF   (temp_ptr^. parm_indx_to_type_table <>
                        ptr^. parm_indx_to_type_table)
               OR (temp_ptr^.parm_class <> ptr^.parm_class)
             THEN error (127);   { illegal parameter substitution }
             temp_ptr := temp_ptr^. rest_of_parm_list;
             ptr := ptr^.rest_of_parm_list
             END;
          IF temp_ptr <> ptr
          THEN error (126);  { # of parms do not agree with prev declaration }
          mark (addr (routine_table [last_rt_entry]. parm_list));
          release (routine_table [last_rt_entry]. parm_list);
          last_rt_entry := last_rt_entry - 1;
          exit                    { stop comparing }
          END
  END;











{#############################################################################}
{--- Display the current contents of the routine table. }
{#############################################################################}
PROCEDURE rmdump_routine_table
  (VAR outfile: text;
   VAR routine_table: ARRAY [rtlobound..rthibound: natural] OF t_rout_tab_rec);

  VAR i: integer;
      ptr: t_ptr_to_next_parm;
  BEGIN
  writeln (outfile);  writeln (outfile, '--- Routine Table Dump --- ');
  writeln (outfile, 'name':20, 'parms':10);
  FOR i := 1 TO last_rt_entry
  DO BEGIN
     write (outfile, i:10, routine_table[i]. routine_name:10);
     ptr := routine_table [i]. parm_list;
     WHILE ptr <> nil
     DO BEGIN
        CASE ptr^.parm_class OF
          var_parm  :    write (outfile, ' ( var_parm ');
          value_parm:    write (outfile, ' ( val_parm ');
          func_value:    write (outfile, ' ( func_val ');
          conform_array: write (outfile, ' ( conf_arr ');
          proc_func:     write (outfile, ' ( procfunc ')
          END;
        write (outfile, ptr^. parm_indx_to_type_table:5, ' ) ');
        ptr := ptr^. rest_of_parm_list
        END;
     writeln (outfile)
     END;
  writeln (outfile)
  END;




MODEND.






