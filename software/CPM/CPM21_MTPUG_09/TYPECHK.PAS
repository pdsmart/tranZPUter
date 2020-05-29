{##########################################################################
####                                                                   ####
####  Full program name: MULTI_MODULE_PARAMETER_AND_VAR_TYPE_CHECKER.  ####
####  File name:  TYPECHK.PAS.                                         ####
####  Support modules reqd:  PASLIB.ERL, SCANNER.                      ####
####  Run time environment: <any>.                                     ####
####  Compile time environment: MT MicroSYSTEMS Pascal/MT+v5.25.       ####
####  Link time environment: MT MicroSYSTEMS Linkmt v5.1.              ####
####  Copyright (C) 1982 by Haldo Products Inc. All rights reserved.   ####
####                        56 Camille Ln, E. Patchogue, NY 11772      ####
####  Programmer: Lawrence Adkins.                                     ####
####  Module Development/Maintenance History:                          ####
       6-NOV-81 Vers 1.0.  File just created.
      12-NOV-81            Development of this version completed.
       9-JAN-82 Vers 2.0.  development begins.
       1-MAR-82            Development of this version completed.
       6-MAR-82 Vers 2.1.  Conformant array stuff added.
      19-APR-82 Vers 2.2.  Add blockread compatibility stuff.
####                                                                   ####
##########################################################################}


{#######################################################################
####                                                                ####
####      C R O S S   M O D U L E   T Y P E   C H E C K E R         ####
####                                                                ####
####  This program, along with the scanner module located in the    ####
####  'scanner.pas' file, scans a series of Pascal/MT source files  ####
####  to make sure that the routines defined in one module and      ####
####  referenced from within separate modules have the same number  ####
####  of parameters and that the types of the corresponding parms   ####
####  match.  A listing of all errors is output to a diskfile named ####
####  'output.prn'.  The list of file names to scan is expected to  ####
####  be in the file whose name is specified in the command line.   ####
####  To use,                                                       ####
####  1) Compile the modules using MTPLUS to remove all errors that ####
####     can be trapped by that program.  This program will bomb if ####
####     syntactic errors normally trapped by MTPLUS exist in the   ####
####     files being scanned.                                       ####
####  2) Edit the file 'FILES.CMD' to enter the names of the files  ####
####     to be scanned by this program, one file per line, with a   ####
####     carriage return after even the last file name.             ####
####     Sample 'files.cmd' contents:  '<CR>' means carriage return ####
####       ; typechk 1.0 source files.<CR>                          ####
####       ; (This is a CPM-type comment)<CR>                       ####
####       ; There are 3 switches permitted: $D, $Pd and $@         ####
####       b:mprog.pas $D $PB<CR>                                   ####
####       b:mymodule.pas $D<CR>                                    ####
####  3) Run the program TYEPECHK FILES.CMD                         ####
####  The program expects the list of file name file to be specified####
####  on the command line.                                          ####
#######################################################################}














PROGRAM mult_module_type_checker;

{$I B:TYPECHK.DEC}

VAR
  memory: ABSOLUTE [$0000] ARRAY [0..0] OF byte;
  sysmem: EXTERNAL integer;

  infile: text;   { infile is pascal source file with no errors after }
  outfile: text;  { file where listing of errors is sent }
  filenamefile: text;  { file containing list of files to be scanned }

  input_line: string132;       { holds line currently being scanned }
  curr_input_line: string132;  { hold lines of input for printing upon error }
  prev_input_line: string132; 
  prev1_input_line: string132;
  token: tokentype;            { hold last token scanned }
  tokenbuf,ident_buf: string132; { hold last identifier/number/string scanned }
  charbuf: char;               { hold last character scanned }
  
  debug: boolean;              { determines if tables are dumped often or not }
  file_entered: boolean;       { has same effect as eof(filenamefile)}
  symbols_avail_for_external_reference: boolean; {false if $E-, else true }
  at_is_alternative_pointer_symbol: boolean;{true if $@ switch seen else false}
  last_entry_point_name: string132; { store last $E+ symbol scanned }
  include_file_level: byte;    { 0 if in main file, 1 if in include file }
  includ_file_name: string15;  { holds name of the source file being included }
  i: integer;                  { no special purpose }
  fname: string132;            { name of the file currently being compiled }
  cpmcmdbuf: ABSOLUTE [$80] PACKED ARRAY [0..cpmlinesz] OF char;
  cpmstr: STRING [cpmlinesz];
  list_of_files: string15;

  const_table:   ARRAY [1..max_constants] OF t_const_tab_rec;
  type_table :   ARRAY [0..max_type_elements] OF t_type_tab_rec;
  var_table  :   ARRAY [1..max_var_elements] OF t_var_tab_rec;
  routine_table: ARRAY [1..max_routines] OF t_rout_tab_rec;

EXTERNAL PROCEDURE @hlt;   { Stop program execution }
EXTERNAL FUNCTION  @bdos (func: integer; parm: word): integer;
EXTERNAL PROCEDURE get_next_token;
EXTERNAL PROCEDURE init_scan;
EXTERNAL PROCEDURE mark ({VAR} p: integer);
EXTERNAL PROCEDURE release (p: integer);
EXTERNAL PROCEDURE cminit_constant_table_module 
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec);
EXTERNAL PROCEDURE tminit_type_table_module 
  (VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);
EXTERNAL PROCEDURE vminit_var_table_module;
EXTERNAL PROCEDURE rminit_routine_table_module;
EXTERNAL PROCEDURE cmadd_new_constants_to_const_table
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec);
EXTERNAL PROCEDURE tmadd_new_types_to_type_table
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec; 
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);
EXTERNAL PROCEDURE vmadd_new_vars_to_var_table
  (VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec; 
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec; 
   VAR var_table  : ARRAY [vtlobound..vthibound: natural] OF t_var_tab_rec);
EXTERNAL PROCEDURE rmadd_new_routines_to_routine_table 
  (VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec; 
   VAR routine_table: ARRAY [rtlobound..rthibound: natural] OF t_rout_tab_rec);
EXTERNAL PROCEDURE cmdump_constant_table
  (VAR outfile: text; 
   VAR const_table: ARRAY [ctlobound..cthibound: natural] OF t_const_tab_rec);
EXTERNAL PROCEDURE tmdump_type_table
  (VAR outfile: text;
   VAR type_table : ARRAY [ttlobound..tthibound: natural] OF t_type_tab_rec);
EXTERNAL PROCEDURE vmdump_variable_table
  (VAR outfile: text; 
   VAR var_table  : ARRAY [vtlobound..vthibound: natural] OF t_var_tab_rec);
EXTERNAL PROCEDURE rmdump_routine_table
  (VAR outfile: text; 
   VAR routine_table: ARRAY [rtlobound..rthibound: natural] OF t_rout_tab_rec);
EXTERNAL PROCEDURE init_main_file_buffer;













{##########################################################################
####  Print out an error message.
##########################################################################}
PROCEDURE error (pascal_error_no: integer);

  CONST 
    bar    = '-------------------------------------------------------';
    fmsg   = 'File being Scanned: ';
    epmsg  = 'Entry Point is: ';
    ltsmsg = 'Last Identifier Scanned: ';
    errmsg = 'Error # ';
  VAR ch: char;
  BEGIN
  writeln;  writeln(outfile);
  IF pascal_error_no > 0
  THEN BEGIN
       writeln (bar); writeln (outfile, bar);
       writeln (prev1_input_line);writeln (outfile,' ':10, prev1_input_line);
       writeln (prev_input_line); writeln (outfile, ' ':10, prev_input_line);
       writeln (curr_input_line); writeln (outfile, ' ':10, curr_input_line);
       writeln (bar); writeln (outfile, bar);
       writeln (fmsg, fname); writeln (outfile, fmsg, fname);
       writeln (epmsg, last_entry_point_name);
       writeln (outfile, epmsg, last_entry_point_name);
       writeln (ltsmsg, ident_buf); writeln (outfile, ltsmsg, ident_buf);
       writeln (errmsg, pascal_error_no);
       writeln (outfile, errmsg, pascal_error_no);
       writeln ('Hit any key to continue...');
       WHILE @bdos (11,wrd(-1)) <> 0 DO read (ch); { remove queued up chars }
       read (ch)  { wait so that the user can recognize the error occurance }
       END;
  IF NOT debug
  THEN ch := 'Y'
  ELSE BEGIN write ('???? Want Tables (Y/N)? '); read (ch); writeln END;
  IF uppercase (ch) = 'Y'
  THEN BEGIN
       cmdump_constant_table (output, const_table);
       cmdump_constant_table (outfile, const_table);
       tmdump_type_table (output, type_table);
       tmdump_type_table (outfile, type_table);
       vmdump_variable_table (output, var_table);
       vmdump_variable_table (outfile, var_table);
       rmdump_routine_table (output, routine_table);
       rmdump_routine_table (outfile, routine_table);
       END 
  END;




















{######################################################################
####  Repeatedly try to open files (containing pascal source) whose names
####  were specified in filenamefiles until a file is successfully opened
####  for parsing.  File_entered is set false if eof is met here.
####  Limitations: Each filename must start on the first column of
####  a separate line.  Comments must also start on the first column of 
####  a new line, and must begin with a ':' or ';' character.
####  MTPLUS compiler-like switches $Pd and $@ are now also supported.
####  The P switch puts the output file onto the specified device, and
####  the default is not to have an output file listing.  The @ switch,
####  if present, permits use of the '@' character instead of the '^'
####  character.  The default is that '@' is an identifier character.
####  An enabled @ switch will be disabled when the end of the specified
####  module is reached.
######################################################################}
PROCEDURE obtain_and_open_an_input_file;

  CONST
    openerrmsg = '*** Unable to Open Input file: ';
    openmsg = 'Processing file: ';
  VAR 
    openerrnum: integer;
    openok : boolean;
  BEGIN
  close (infile, openerrnum);
  REPEAT
    debug := false;                            {by default, switch $D is off}
    at_is_alternative_pointer_symbol := false; {by default, switch $@ is off}
    openok := NOT eof (filenamefile);
    IF openok
    THEN BEGIN
         REPEAT readln (filenamefile, fname)
         UNTIL ((fname[1] <> ':') AND (fname[1] <> ';')) OR eof (filenamefile);
         { permit comments the way CP/M permits them in ".SUB" files. }
         writeln;  writeln (outfile);
         handle_directive_switches (fname);
         open (infile, fname, openerrnum); openok := openerrnum <> 255;
         IF NOT openok
         THEN BEGIN
              writeln (openerrmsg, fname); writeln (outfile, openerrmsg, fname)
              END
         ELSE BEGIN
              init_main_file_buffer;
              writeln (openmsg, fname); writeln (outfile, openmsg, fname)
              END
         END
  UNTIL openok OR eof (filenamefile);
  symbols_avail_for_external_reference := true;  {by default, toggle is $E+}
  file_entered := openok
  END;
















{###########################################################################
####  Handle compiler directive switches.
####  Only $Pd and $@ switches presently implemented,
####  The acceptable format is
####  filename.pas $PB $@ $D
###########################################################################}
PROCEDURE handle_directive_switches (VAR fname: string132);

  VAR position: byte;
  FUNCTION switch_char_posn (VAR fname: string132): byte;
    VAR n: integer;
    BEGIN
    n := pos ('$', fname);
    IF n = 0 THEN n := pos ('#', fname);
    switch_char_posn := n
    END;
  BEGIN
  FOR position := 1 TO length (fname)
  DO fname [position] := uppercase (fname [position]);
  WHILE fname[1] = ' ' DO delete (fname, 1, 1);
  { search for multiple '$' switches, and act on them }
  position := switch_char_posn (fname);
  WHILE position > 0
  DO BEGIN
     fname [position] := '&';
     CASE fname [position + 1] OF
       'P': open_output_file (fname [position + 2]);
       '@': at_is_alternative_pointer_symbol := true;
       'D': debug := true
       END;
     position := switch_char_posn (fname)
     END;
  { remove the switch settings from the file name }
  position := pos (' ', fname);
  IF position > 0 THEN fname := copy (fname, 1, position-1)
  END;








{###########################################################################
#### Open the file output.prn, where the listing is sent to.
###########################################################################}
PROCEDURE open_output_file (drive_spec: char);

  VAR
    s: STRING [15];
    i: integer;
  BEGIN
  close (outfile, i);
  IF drive_spec = 'P'
  THEN s := 'LST:';
  assign (outfile, s);
  rewrite (outfile);
  writeln (outfile); writeln (outfile, header1);
  writeln (outfile, header2); writeln (outfile);
  END;





{########################################################################
#### read a file name from the command_line buffer, and return in outstr.
########################################################################}
PROCEDURE getname (VAR outstr: string15);

  BEGIN
  outstr := '';
  { strip off the leading blanks }
  WHILE (length (cpmstr) > 0) AND (cpmstr [1] = ' ')
  DO delete (cpmstr, 1, 1);
  { obtain the file name characters }
  WHILE (length (cpmstr) > 0) AND (cpmstr [1] <> ' ')
  DO BEGIN outstr := concat (outstr, cpmstr[1]); delete (cpmstr, 1, 1) END
  END;








{####################################################################
####  Initialize everything other than the four identifier tables.
####################################################################}
PROCEDURE initialize;

  VAR i: integer;
  BEGIN
  { copy command tail to a private pascal string } 
  move ({from} cpmcmdbuf, {to} cpmstr, cpmlinesz + 1 {bytes});
  getname (list_of_files);
  writeln; writeln (header1); writeln (header2); writeln;
  open (filenamefile, list_of_files, i);
  IF i = 255
  THEN BEGIN
       writeln ('Failure to Open Input file: ',list_of_files,
                ' containing the list of file names. ');
       @hlt    { halt program execution }
       END;
  file_entered := false;
  include_file_level := 0;    { by default, not in include file }
  includ_file_name := '';
  input_line := ''; charbuf := ' ';
  last_entry_point_name := '';
  token := notoken;
  END;




{##################################################################
####  Convert a lower case alpha char to an upper case one.
##################################################################}
FUNCTION uppercase (charbuf: char): char;
  
  BEGIN
  IF (charbuf >= 'a') AND (charbuf <= 'z')
  THEN charbuf := chr (charbuf & $DF);
  uppercase := charbuf
  END;





{###################################################################
####  The main program....
###################################################################}

BEGIN
fillchar (memory [datastart], dataextent, chr (0)); {zero out the data area}
{ We had to use the linker's "/D" option and also do local file I/O }
initialize;
init_scan;
cminit_constant_table_module (const_table);
tminit_type_table_module (type_table);
vminit_var_table_module;
rminit_routine_table_module;
obtain_and_open_an_input_file;
WHILE file_entered
DO BEGIN
   cmadd_new_constants_to_const_table (const_table);         { add constants }
   tmadd_new_types_to_type_table (const_table, type_table);      { add types }
   vmadd_new_vars_to_var_table (const_table, type_table, var_table);{ " vars }
   rmadd_new_routines_to_routine_table (type_table, routine_table);
                                                       { check routine parms }
   tokenbuf := 'Normal EOF Reached on Source file. ';
   writeln; writeln (outfile); writeln (tokenbuf); writeln (outfile,tokenbuf);
   error (0);                       { get a dump of the tables at this point }
   obtain_and_open_an_input_file
   END;
tokenbuf := 'End of Normal Program Execution. ';
writeln;  writeln (outfile);
writeln (tokenbuf);  writeln (outfile, tokenbuf);
close (outfile, i);
IF i = 255
THEN writeln ('Unable to Close file: ', output_file)
ELSE writeln ('Examine file: ',output_file)
END.






    


