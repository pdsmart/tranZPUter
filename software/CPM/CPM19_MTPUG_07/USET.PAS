MODULE SUERESET;
{*********************************************************************
 *                             USET                                  *
 *     Date                                         Author           *
 *   04-October-82                                 Sue Arnold        *
 *                                                                   *
 * This is a modified version of Digital Research's Pascal MT+       *
 * "RESET" procedure.  It sets the "open in unlocked mode" attribute *
 * bit (f5') in the FCB before calling "UOPEN" - an assembly         *
 * routine that replaces the @BDOS call that is normally used.       *
 *                                                                   *
 * Please note that after the OPEN the attribute bit will be reset   *
 * by the operating system.                                          *
 *********************************************************************}


  {****************************************************************
   * follows is the format for the Pascal MT+ file information    *
   * block (FIB).  It was modified for Ver 5.5 to include file    *
   * option type "fauxio".                                        *
   ****************************************************************}
TYPE
  opttype = (notopen,fwrite,frdwr,frandom,fconio,ftrmio,flstout,fauxio);

  FIB=
     RECORD
	fname  : STRING[16];	{ d:filename.ext }
	FCB    : PACKED ARRAY [0..34] OF CHAR;	{ CP/M FILE CONTROL BLOCK }
	buflen : INTEGER;	{ size of fbuffer }
	bufidx : INTEGER;	{ current index into fbuffer }
	option : opttype;
	IOsize : INTEGER;	{ size of next transfer }
	feoln  : BOOLEAN;	{ TRUE if text file at end-of-line }
	feof   : BOOLEAN;	{ TRUE if at end-of-file }
	fbufadr: WORD;		{ pointer to fbuffer }
	fsecinx: 0..128;	{ index into fsector <+1 for overflow> }
	ftext  : BOOLEAN;	{ TRUE if this is a text file! }
	nosectrs:BOOLEAN;	{ TRUE if no more disk room available }
	fsector: PACKED ARRAY [0..127] OF CHAR;	{ 1 sector buffer for CP/M }
	fbuffer: PACKED ARRAY [0..0  ] OF CHAR;
      END;

VAR
  resultio : 	EXTERNAL INTEGER;
  @LFB : 	EXTERNAL ^FIB;

  {****************************************************************
   * Here are bunches of external procedure declarations.         *
   ****************************************************************}
EXTERNAL PROCEDURE @DFLT;		{ to set Default DMA addr}
EXTERNAL FUNCTION  @SPN(VAR ufile:FIB):BOOLEAN;
EXTERNAL FUNCTION  @NOK(S :STRING):BOOLEAN;  {parses file name}
EXTERNAL PROCEDURE @RNB;
EXTERNAL PROCEDURE CLOSE(VAR ufile:FIB; SZ:INTEGER;VAR result:INTEGER);
EXTERNAL PROCEDURE @HLT;                     {to abort task}
EXTERNAL PROCEDURE GET(VAR ufile:FIB; SZ:INTEGER);
EXTERNAL PROCEDURE uopen (VAR ufile: FIB; VAR result: INTEGER);

{****************************************************************
 *   Procedure USET starts here:                                *
 ****************************************************************}

PROCEDURE uset (VAR ufile   : FIB; 
                    bufsize : INTEGER;
                VAR file_ID : INTEGER);

VAR
  result : INTEGER;

BEGIN
  @DFLT;	{ Set DMA Address }
  {****************************************************************
   * Set the f5' attribute bit before we do anything else:        *
   ****************************************************************}
  SETBIT (ufile.FCB[5], 7);        {that's all there is to it}
  {****************************************************************
   * If file write option set, then close the file first:         *
   ****************************************************************}
  IF ufile.option = fwrite THEN
    BEGIN { file write option }
      CLOSE(ufile,bufsize,result);
      IF result = 255 THEN
        {*************************************************
         * Do error handling required for bad file close:*
         *************************************************}
        BEGIN { can't close the file}
	  WRITELN;
	  WRITELN('UNABLE TO AUTOMATICALLY CLOSE: ',ufile.fname,' IN RESET');
	  WRITELN;
	  WRITELN('PROGRAM ABORTED');
	  @HLT                        {abort via @HLT}
        END; { can' close the file}
    END; { file write option }

  {****************************************************************
   * Put zeros in FCB entries 12-34 and set BUFLEN to zero:       *
   ****************************************************************}
  FILLCHAR(ufile.FCB[12],25,CHR(0));	{ PREPARE FOR OPEN }
  {****************************************************************
   * Set the file option to indicate that it's not open:          *
   ****************************************************************}
  ufile.option := NOTOPEN;

  {****************************************************************
   * If TEXT file, then indicate this in the FIB:                 *
   ****************************************************************}
  IF bufsize = -1 THEN { text file }
    BEGIN { text file }
      bufsize := -bufsize;
      ufile.ftext := TRUE
    END { TEXT FILE }
  {****************************************************************
   * If not a text file, just set the text file boolean to FALSE  *
   ****************************************************************}
  ELSE
    ufile.ftext := FALSE;

  {****************************************************************
   * The following section of code sets up the default values for *
   * the data in the file information block as follows:           *
   *                                                              *
   *  end-of-file = FALSE        end-of-line = FALSE              *
   *  FCB record count = 0       fsector index = 128              *
   *  there is room on disk      file option = read/write         *
   *  IOsize = bufsize (1?)      buffer length = bufsize (1?)     *
   *  fbufadr points to fbuffer                                   *
   *                                                              *
   ****************************************************************}
  ufile.feof := FALSE;
  ufile.feoln := FALSE;		{ default these to FALSE }
  ufile.FCB[32] := CHR(0);		{ set up next record field in FCB }
  @LFB := ADDR(ufile);
  ufile.fsecinx:= 128;		{ To force initial reads }
  ufile.nosectrs := FALSE;		{ Initially sectors available }
  ufile.option := FRDWR;		{ READ / WRITE }
  ufile.IOsize := bufsize;
  ufile.buflen := bufsize;
  ufile.fbufadr := WRD(ADDR(ufile.fbuffer));

  {****************************************************************
   * Now check the file name.. to see if there is one and if it   *
   * has the correct format:                                      *
   ****************************************************************}
  IF (LENGTH(ufile.fname) = 0) OR NOT(@NOK(ufile.fname)) THEN
    BEGIN { bad file name }
       resultio := 255;
    END { bad file name }
  {****************************************************************
   * If the file name is OK then call XDOS to open the file IF it *
   * is on a disk device after setting f5'                        *
   ****************************************************************}
  ELSE
    BEGIN { see where the file is }
      IF @SPN(ufile) THEN	{=TRUE if  CON:, LST:, KBD:, TRM: }
        BEGIN { not on disk }
          EXIT;                 {so we're done already}
        END { not on disk }
    ELSE
        BEGIN { on disk }
           SETBIT(ufile.FCB[5], 7);     {mark the attribute bit}
           uopen (ufile, resultio);
           MOVE (ufile.FCB[33], file_ID, 2);  {get file ID}
        END { on disk }
    END; { see where the file is }

  {****************************************************************
   * Add finishing touches to the FIB if we survived this far.    *
   ****************************************************************}
  IF resultio <> 255 THEN { continue processing }
    BEGIN
      resultio := 0;
      ufile.feof := FALSE;
      ufile.feoln := FALSE;
      ufile.buflen := bufsize;
     {*****************************************
      * Do an "initial GET" of who knows what:*
      *****************************************}
      IF bufsize <> 0 THEN { do an initial get }
        BEGIN { buffer size not zero }
	  ufile.bufidx  := 0;
          IF ufile.ftext THEN
            BEGIN { text file }
               GET(@LFB^,@LFB^.buflen);
            END { text file }
          ELSE 
            BEGIN { not text file }
               @RNB;
            END; { not text file }
        END { buffer size not zero }
    END
  {****************************************************************
   * We didn't make it... mark end-of-file in the FIB.            *
   * <We get here if unable to open the file or if name bad>      *
   ****************************************************************}
  ELSE
    BEGIN {bad file name or unable to open}
      ufile.feof := TRUE;
      ufile.feoln := TRUE
    END {bad file name or unable to open}
END; { newset }

MODEND.
