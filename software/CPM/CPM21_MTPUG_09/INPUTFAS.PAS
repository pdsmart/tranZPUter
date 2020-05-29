{##########################################################################
####                                                                   ####
####  Full module name: FAST BLOCKREAD INPUT OF SOURCE MODULE.         ####
####  File name:  INPUTFST.PAS.                                        ####
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






MODULE STD_INPUT;

{$I B:TYPECHK.DEC }    { list of all our type declarations }

VAR 
  endfile: boolean;           { Here, true only if eofmark char was read }
  infile, infile1: EXTERNAL text;
  {$E-}
  saved_main_program_text: string132; {Store line till after include file done}
  ior_for_main_file, ior_for_include_file: integer;
  maintextbuffer,includfiletextbuffer: p_array_of_char;
  main1_file_index, includ1_file_index: integer;
  include_file_level: EXTERNAL integer;

{$E+}
FUNCTION maineof: boolean;

  BEGIN
  maineof :=  endfile AND (include_file_level = 0)
  END;


PROCEDURE init_include_file_block;

  BEGIN 
  blockread (infile1, includfiletextbuffer, ior_for_include_file, blkiosize,
       {record} 0);
  includ1_file_index := 1;
  saved_main_program_text := '';
  endfile := false 
  END;


PROCEDURE init_main_file_block;

  BEGIN
  blockread (infile, maintextbuffer, ior_for_main_file, blkiosize, {record} 0);
  main1_file_index := 1;
  saved_main_program_text := '';
  endfile := false
  END;




PROCEDURE readln_main_program_text (VAR input_line: string132);

  BEGIN
  IF length (saved_main_program_text) > 0
  THEN BEGIN
       input_line := saved_main_program_text;
       saved_main_program_text := ''
       END
  ELSE grab_some_text (input_line, maintextbuffer, main1_file_index, infile,
         ior_for_main_file)
  END;

PROCEDURE readln_include_file_text (VAR input_line: string132);
  BEGIN
  IF length (saved_main_program_text) = 0
  THEN BEGIN
       saved_main_program_text := input_line;
       IF length (saved_main_program_text) = 0
       THEN saved_main_program_text := ' '
       END;
  grab_some_text (input_line, includfiletextbuffer, includ1_file_index,
        infile1, ior_for_include_file)
  END;

{$E-}
PROCEDURE grab_some_text (VAR input_line: string132;
                          VAR textbuffer: p_array_of_char;
                          VAR buf_index: integer;
                          VAR infile: text;
                          VAR ior: integer);

  FUNCTION at_eof: boolean;
    BEGIN  at_eof := (textbuffer [buf_index] = chr (eofmark))
                 OR ((buf_index > blkiosize) AND (ior > 0))
    END;
  BEGIN
  input_line := '';
  WHILE ((textbuffer [buf_index] =  chr (cr))
     OR  (textbuffer [buf_index] =  chr (lf)))
    AND NOT at_eof
  DO BEGIN
     buf_index := buf_index + 1;
     IF (buf_index > blkiosize) AND (ior = 0)
     THEN BEGIN
          blockread (infile, textbuffer, ior, blkiosize, -1 {seq access});
          buf_index := 1
          END;
     END;

  WHILE (textbuffer [buf_index] <> chr (cr))
    AND NOT at_eof
  DO BEGIN
     IF (buf_index <= blkiosize)
     THEN BEGIN
          input_line := concat (input_line, textbuffer [buf_index]);
          buf_index := buf_index + 1
          END;
     IF (buf_index > blkiosize) AND (ior = 0) 
     THEN BEGIN
          blockread (infile, textbuffer, ior, blkiosize, -1 {seq access});
          buf_index := 1
          END
     END;
  endfile := at_eof
  END;

MODEND.





















