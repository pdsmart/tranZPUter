PROGRAM display_pascal_error_text;

VAR errfile: text;
   error_num, users_error_num, ioreturn_value: integer;
   error_text: STRING;
BEGIN
write ('What is the Pascal/MT+ error number that you want the text of? '); 
readln (users_error_num);
error_text := 'MTERRS.TXT';
open (errfile, error_text, ioreturn_value);
IF ioreturn_value > 4
THEN BEGIN writeln ('File ', error_text, ' not found.'); exit END;
read (errfile, error_num);
WHILE (error_num <> users_error_num) AND NOT eof (err_file)
DO BEGIN readln (err_file); read (err_file, error_num) END;
IF NOT EOF (err_file)
THEN BEGIN
     readln (errfile, error_text);
     writeln ('Error ', error_num, ' is: ', error_text)
     END
ELSE writeln ('Unexplainable error. ')
END.