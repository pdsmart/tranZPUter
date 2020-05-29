MODULE erahs;       
{*********************************************************************
 *                             SHARE                                 *
 *     Date                                         Author           *
 *   04-October-82                                 Sue Arnold        *
 *                                                                   *
 * This is a super-duper procedure that will open the file of your   *
 * choice in UNLOCKED mode!  Just send it the file descriptor, the   *
 * file name, and it will open the file and return the file ID       *
 * number that you need to have in order to lock and unlock          *
 * records.                                                          *
 *********************************************************************}


  {****************************************************************
   * follows is the format for the Pascal MT+ file information    *
   * block (FIB).  It was modified for Ver 5.5 to include file    *
   * option type "fauxio".                                        *
   ****************************************************************}
TYPE
  string15 = STRING[15];

  dum_rec =
     RECORD
	dumb   : BYTE;
      END;
 dum_type = FILE OF dum_rec;

VAR
  bufsize :  INTEGER;         {default value = 1}
 
EXTERNAL PROCEDURE uset  (VAR ufile: dum_type;
                              bufsize: INTEGER;
                          VAR file_ID: INTEGER);

{****************************************************************
 *   Procedure SHARE starts here:                               *
 ****************************************************************}

PROCEDURE share (VAR ufile    : dum_type;
                 VAR filename : string15;
                 VAR file_ID  : INTEGER);

BEGIN
  ASSIGN(ufile, filename);
  uset (ufile, bufsize, file_ID);
END; { procedure share }

MODEND.
