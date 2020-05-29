MODULE KCOL;
{*********************************************************************
 *                             LOCK                                  *
 *     Date                                         Author           *
 *   13-October-82                                 Sue Arnold        *
 *                                                                   *
 * This routine will lock out other programs from using your record. *
 * To use it, you must pass the file descriptor and the File_ID that *
 * was returned by "SHARE" when you opened the file in unlock mode.  *
 *                                                                   *
 * An assembly routine (alock) will be called to actually lock out   *
 * the record after this routine moves the file_ID to the sector     *
 * buffer and sets the current DMA.                                  *
 *                                                                   *
 * This program requires that the rec# of the record to be locked be *
 * in the FCB. To get it there, please access the record before      *
 * calling this routine via a "SEEKREAD". (or something similiar).   *
 *********************************************************************}


  {****************************************************************
   * follows is the format for the Pascal MT+ file information    *
   * block (FIB).  It was modified for Ver 5.5 to include file    *
   * option type "fauxio".                                        *
   ****************************************************************}
TYPE
  opttype = (notopen,fwrite,frdwr,frandom,fconio,ftrmio,flstout,fauxio);
  buftype = PACKED ARRAY [0..127] OF CHAR;

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
	fsector: buftype;	{ 1 sector buffer for CP/M }
	fbuffer: PACKED ARRAY [0..0  ] OF CHAR;
      END;


  {****************************************************************
   * Here are bunches of external procedure declarations.         *
   ****************************************************************}
EXTERNAL PROCEDURE setDMA (VAR sector_buffer: buftype);

EXTERNAL PROCEDURE alock (VAR ufile: FIB;
                          VAR lck_err: INTEGER);

{****************************************************************
 *   Procedure LOCK starts here:                                *
 ****************************************************************}

PROCEDURE lock (VAR ufile   : FIB; 
                    file_ID : WORD;
                VAR lck_err : INTEGER);

BEGIN
  {****************************************************************
   * First, put the file_ID number in the file sector buffer:     *
   * Then, call "alock" to lock the record.                       *
   ****************************************************************}
  MOVE (file_ID, ufile.fsector[0], 2);
  setDMA( ufile.fsector );
  alock ( ufile, lck_err);
 END; {procedure LOCK}

MODEND.
