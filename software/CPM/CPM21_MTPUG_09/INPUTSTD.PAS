{##########################################################################
####                                                                   ####
####  Full module name: STANDARD READLN INPUT OF SOURCE MODULE.        ####
####  File name:  INPUTSTD.PAS.                                        ####
####  Support modules reqd:  PASLIB.ERL.                               ####
####  Run time environment: <any>.                                     ####
####  Compile time environment: MT MicroSYSTEMS Pascal/MT+v5.25.       ####
####  Link time environment: MT MicroSYSTEMS Linkmt v5.1.              ####
####  Copyright (C) 1982 by Haldo Products, Inc. All rights reserved.  ####
####                        56 Camille Ln, E. Patchogue, NY 11772      ####
####  Programmer: Lawrence Adkins.                                     ####
####  Module Development/Maintenance History:                          ####
      19-APR-82 Vers 2.2.  File just created, and completed.
  
####                                                                   ####
##########################################################################}






MODULE STNDRD_INPUT;

{$I B:TYPECHK.DEC }    { list of all our type declarations }

VAR 
  endfile: boolean;           { Here, equivalent to eof function }
  infile, infile1: EXTERNAL text;










{$E+}
FUNCTION maineof: boolean;
  BEGIN  maineof :=  eof (infile)  END;


PROCEDURE init_include_file_block;
  BEGIN  endfile := false  END;


PROCEDURE init_main_file_block;
  BEGIN  endfile := false  END;


PROCEDURE readln_main_program_text (VAR input_line: string132);
  BEGIN  grab_some_text (infile, input_line)  END;


PROCEDURE readln_include_file_text (VAR input_line: string132);
  BEGIN  grab_some_text (infile1, input_line)  END;

{$E-}
PROCEDURE grab_some_text (VAR infile: text; VAR input_line: string132);
  BEGIN
  IF eof (infile) THEN input_line := '' ELSE readln (infile, input_line);
  endfile := eof (infile)
  END;


MODEND.



















