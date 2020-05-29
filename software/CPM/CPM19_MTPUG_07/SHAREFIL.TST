



PROGRAM SHAREFIL;

TYPE 
     PERSON    = RECORD
                   NAME : STRING;
                   ADDRESS : STRING;
                 END;
     FYLE = FILE OF PERSON;
        
VAR 
    BF : FYLE;
    S,NAME  : STRING;
    BUFFSIZE,ID,RN,ERR_CD  : INTEGER;
    CREATE,REED : BOOLEAN;
    CH  : CHAR;
    FID : WORD;


    EXTERNAL PROCEDURE SHARE(VAR UFILE : FYLE; UNAME : STRING;
                             VAR FILE_ID : INTEGER);  
    EXTERNAL PROCEDURE @HLT;
    EXTERNAL PROCEDURE USET (VAR UFILE : FYLE; BUFFSIZE : INTEGER;
                             VAR FILE_ID : INTEGER);
    EXTERNAL PROCEDURE LOCK (VAR UFILE : FYLE; FILE_ID : WORD;
                             VAR LCK_ERR : INTEGER);
    EXTERNAL PROCEDURE UNLOCK (VAR UFILE : FYLE; FILE_ID : WORD;
                               VAR ERR_CD : INTEGER);
                               

PROCEDURE HALT;
BEGIN 
  CLOSE(BF,FID); 
  @HLT 
END; 


PROCEDURE ERR_CHK (VAR ERR_CD : INTEGER);
VAR IORSLT : INTEGER;
BEGIN
  IORSLT := IORESULT;
  IF ERR_CD <> 0
     THEN
       BEGIN
         WRITELN ('UNSUCCESSFUL LOCK/UNLOCK, ERROR CODE = ',ERR_CD);
         ERR_CD := 0;
         ACCESS_RECS;
         EXIT
       END;
  IF IORSLT <> 0
     THEN
       BEGIN
         WRITELN ('UNSUCCESSFUL FILE I/O, IORESULT = ',IORSLT);
         O_C_FILE;
         EXIT
       END;
END;


PROCEDURE READ_RECS;
BEGIN
  WRITE('RECORD NUMBER ? ');
  READLN(RN);
  SEEKREAD(BF,RN);
  IF REED
     THEN BEGIN
            ERR_CHK (ERR_CD);
            WRITELN (BF^.NAME,'/',BF^.ADDRESS)
          END;
END;


PROCEDURE WRITE_RECS;
BEGIN
  READ_RECS;
  FID := WRD(ID);
  IF CREATE = FALSE
     THEN BEGIN
            LOCK (BF,FID,ERR_CD);
            ERR_CHK (ERR_CD)
          END;
  WRITE('NAME?');
  READLN(S);
  BF^.NAME := S;
  WRITE('ADDRESS?');
  READLN(S);
  BF^.ADDRESS := S;
  SEEKWRITE(BF,RN);
  UNLOCK (BF,FID,ERR_CD);
  ERR_CHK (ERR_CD)
END;


PROCEDURE ACCESS_RECS;
BEGIN
  REPEAT
    WRITE ('R)EAD,W)RITE OR Q)UIT? ');
    READ(CH);
    WRITELN;
    CASE CH OF
      'R','r' :   BEGIN
                    REED := TRUE;
                    READ_RECS
                  END;
      'W','w' :   BEGIN
                    REED := FALSE;
                    WRITE_RECS
                  END;
      'Q','q' :   HALT 

       ELSE  WRITELN('ENTER R, W OR Q ONLY')
    END;
  UNTIL FALSE;
END;


PROCEDURE OPEN_FILE;
BEGIN
  WRITE ('FILE NAME? ');
  READLN (NAME);
  SHARE (BF,NAME,ID);
  ERR_CHK (ERR_CD);
END;


PROCEDURE CREATE_FILE;
BEGIN
  WRITE ('FILE NAME? ');
  READLN (NAME);
  ASSIGN (BF,NAME);
  REWRITE (BF);
  CLOSE (BF,FID);
  SHARE (BF,NAME,ID);
  ERR_CHK (ERR_CD);
  CREATE := TRUE
END;

PROCEDURE O_C_FILE;
BEGIN
  CREATE := FALSE;
  REPEAT
  WRITE ('C)REATE OR O)PEN? ');
  READLN (CH);
  WRITELN;
    IF CH = 'O'
       THEN OPEN_FILE
       ELSE IF CH = 'C'
               THEN CREATE_FILE
               ELSE WRITELN ('TYPE "C" OR "O" ONLY')
  UNTIL (CH = 'O') OR (CH = 'C');
  ACCESS_RECS
END;


BEGIN  (* MAINLINE *)
  ERR_CD := 0;
  O_C_FILE
END.

