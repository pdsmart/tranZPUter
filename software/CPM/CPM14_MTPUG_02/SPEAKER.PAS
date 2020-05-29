Program speaker;

(* this program is a software driver for the votrax
   SC-01 voice synthesis chip.  Using this software
   package, one can enter a word, say the word, modify
   the word, or disassemble the word into its phonemes.
   The system will be expanded to write a vocabulary
   file onto a disk and to read a file from a disk. *)

const
   (* these values are particular to the hardware
      configuration of the SC-01 chip.  Port assignments,
      control words, and masks will have to be changed
      to adapt this software to a different system.
      This can be done by changing the equates in this
      constant block.  *)

   voice = $8c;  (* i/o port for voice data *)
   status = $8e; (* sc-01 status port *)
   parctl = $8f; (* 8255 control port *)
   strobe = $0f; (* sets sc-01 strobe hi *)
   nostrb = $0e; (* sets sc-01 strobe low *)
   ready =  $01; (* mask bit for ready bit *)
   ctrpar = $83; (* control word for 8255 *)

type
   word_def = record
                 spelling: string[14];
                 phonemes: string[20];
                 filled: boolean
              end;

   nmen = array [0..63] of string[4];

var
   token: byte; (* built by parsing routines *)
   i,j,k: integer;  (* general purpose *)
   command: char; (* the command interpreter *)
   ch:char;
   data_valid: boolean; (* to eliminate extraneous spaces *)
   utterance: word_def;
   dictionary: array [1..100] of word_def;
   accept: boolean;
   entry: integer; (* number of entries in dictionary *)
   in_file: file of word_def; (* name of file from which dict comes *)
   out_file: file of word_def; (* name of file written by this program *)
   word_spelling: string [14]; (* used to locate one word in dictionary *)
   sentenct: string;
   nmptr : ^nmen;

   external PROCEDURE reverse;
   external PROCEDURE normal;
   external PROCEDURE save_cursor;
   external PROCEDURE restore_cursor;
   external PROCEDURE put_cursor (x,y: integer);
   external PROCEDURE get_cursor (var x,y: integer);
   external PROCEDURE put25;
   external PROCEDURE clear_line;
   external PROCEDURE clear_screen;
   external PROCEDURE cursor_up;
   external PROCEDURE cursor_down;
   external PROCEDURE cursor_left;
   external PROCEDURE cursor_right;
   external PROCEDURE clear_bottom;
   external PROCEDURE clear_top;
   external PROCEDURE eol;
   external PROCEDURE ebl;
   external FUNCTION funct_key: char;

   PROCEDURE say (what: char);
   (* this PROCEDURE waits until the status bit
      returns ready.  It then writes a phoneme code
      passed to it to the SC-01 *)

BEGIN
      while (inp[status] & ready) = 0 do;
      out[voice] := what;
      out[parctl] := strobe;
      out[parctl] := nostrb
   end;

   PROCEDURE sayit (var str: string);
   (* this PROCEDURE enunciates an utterance whose
      address is passed to it *)

   var
      i: integer;

   BEGIN
      for i := 1 to length (str) do
         say (str[i])
   end;

   PROCEDURE nmentable;

   BEGIN
      INLINE (	3	/	'EH3 '	/
		3	/	'EH2 '	/
		3	/	'EH1 '	/
		3	/	'PA0 '	/
		2	/	'DT  '	/
		2	/	'A2  '	/
		2	/	'A1  '	/
		2	/	'ZH  '	/
		3	/	'AH2 '	/
		2	/	'I3  '	/
		2	/	'I2  '	/
		2	/	'I1  '	/
		1	/	'M   '	/
		1	/	'N   '	/
		1	/	'B   '	/
		1	/	'V   '	/
		2	/	'CH  '	/
		2	/	'SH  '	/
		1	/	'Z   '	/
		3	/	'AW1 '	/
		2	/	'NG  '	/
		3	/	'AH1 '	/
		3	/	'OO1 '	/
		2	/	'OO  '	/
		1	/	'L   '	/
		1	/	'K   '	/
		1	/	'J   '	/
		1	/	'H   '	/
		1	/	'G   '	/
		1	/	'F   '	/
		1	/	'D   '	/
		1	/	'S   '	/
		1	/	'A   '	/
		2	/	'AY  '	/
		2	/	'Y1  '	/
		3	/	'UH3 '	/
		2	/	'AH  '	/
		1	/	'P   '	/
		1	/	'O   '	/
		1	/	'I   '	/
		1	/	'U   '	/
		1	/	'Y   '	/
		1	/	'T   '	/
		1	/	'R   '	/
		1	/	'E   '  /
		1	/	'W   '	/
		2	/	'AE  '	/
		3	/	'AE1 '	/
		3	/	'AW2 '	/
		3	/	'UH2 '	/
		3	/	'UH1 '	/
		2	/	'UH  '	/
		2	/	'O2  '	/
		2	/	'O1  '	/
		2	/	'IU  '	/
		2	/	'U1  '	/
		3	/	'THV '	/
		2	/	'TH  '	/
		2	/	'ER  '	/
		2	/	'EH  '	/
		2	/	'E1  '	/
		2	/	'AW  '	/
		3	/	'PA1 '	/
		4	/	'STOP'	)
   END;

   PROCEDURE disasm (ch: char; var str: string);
   (* this PROCEDURE disassembles a phoneme code into its
      nmemonic *)

   BEGIN
      nmptr := addr (nmentable);
      str := nmptr^[ord(ch)]
   END;

   PROCEDURE parse_a;
   (* this PROCEDURE is used to encode the phonemes which
      BEGIN with the letter A *)

   BEGIN
      read (ch);
      case ch of
         ' ': token := $20;
         '1': token := $6;
         '2': token := $5;
         'Y': token := $21;
         'E': BEGIN
              read (ch);
              case ch of
                 ' ': token := $2e;
                 '1': BEGIN
                      read(ch);
                      if ch = ' ' then token := $2f
                      end
                 end (* case *)
              end; (* AE sequence *)
         'H': BEGIN
              read (ch);
              case ch of
                 ' ': token := $24;
                 '1': token := $15;
                 '2': token := $8
                 end (* case *)
              end; (* AH sequence *)
         'W': BEGIN
              read (ch);
              case ch of
                 ' ': token := $3d;
                 '1': token := $13;
                 '2': token := $30
                 end (* case *)
              end (* AW sequence *)
          end (* A-something sequence *)
      end; (* Case A *)

   PROCEDURE parse_e;
   (* this PROCEDURE is used to parse out the phonemes
      which start with the letter E *)

   BEGIN
      read (ch);
      case ch of
         ' ': token := $2c;
         '1': token := $3c;
         'H': BEGIN
              read (ch);
              case ch of
                 ' ': token := $3b;
                 '1': token := $2;
                 '2': token := $1;
                 '3': token := 0
                 end (* case *)
              end; (* EH phoneme sequence *)
         'R': token := $3a
         end (* case *)
      end; (* E phoneme sequence *)

   PROCEDURE parse_i;
   (* this PROCEDURE parses the phonemes which start with
      the letter I *)

   BEGIN
      read (ch);
      case ch of
         ' ': token := $27;
         '1': token := $b;
         '2': token := $a;
         '3': token := $9;
         'U': token := $36
         end (* case *)
      end; (* I phoneme sequence *)

   PROCEDURE parse_o;
   (* this PROCEDURE parses the phonemes which start with
      the letter O *)

   BEGIN
      read (ch);
      case ch of
         ' ': token := $26;
         '1': token := $35;
         '2': token := $34;
         'O': BEGIN
              read (ch);
              case ch of
                 ' ': token := $17;
                 '1': token := $16;
                 end (* case OO *)
              end (* OO phoneme sequence *)
         end (* case *)
      end; (* O sequence *)

   PROCEDURE parse_u;
   (* this PROCEDURE parses the phonemes that start with
      the letter U *)

   BEGIN
      read (ch);
      case ch of
         ' ': token := $28;
         '1': token := $37;
         'H': BEGIN
              read (ch);
              case ch of
                 ' ': token := $33;
                 '1': token := $32;
                 '2': token := $31;
                 '3': token := $23
                 end
              end (* UH Sequence *)
         end (* case *)
      end; (* U phoneme sequence *)

   PROCEDURE parse_p;
   (* this PROCEDURE parses the phoneme codes which
      BEGIN with the letter P *)

   BEGIN
      read (ch);
      case ch of
         ' ': token := $25;
         'A': BEGIN
              read (ch);
              case ch of
                 '0': token := $3;
                 '1': token := $3e
                 end (* case *)
              end
          end (* case *)
      end; (* P phoneme sequence *)

   PROCEDURE parse_t;
   (* this PROCEDURE parses the phonemes which start
      with the letter T *)

   BEGIN
      read (ch);
      case ch of
         ' ': token := $2a;
         'H': BEGIN
              read (ch);
              case ch of
                 ' ': token := $39;
                 'V': token := $38
                 end (* case *)
              end (* TH sequence *)
          end (* case *)
      end; (* T phoneme sequence *)

   FUNCTION getphoneme: char;
   (* this PROCEDURE fetches characters from the keyboard input
      and returns a phoneme code which corresponds to the
      input character string *)

      BEGIN
         data_valid := true;
         read (ch); (* get a character *)
         case ch of
            'A': parse_a;
            'B': token := $0e;
            'C': BEGIN
                 read (ch);
                 if ch = 'H' then token := $10
                 end; (* CH phoneme *)
            'D': BEGIN
                 read (ch);
                 case ch of
                    ' ': token := $1e;
                    'T': token := $4
                    end (* case *)
                 end; (* D sequence *)
            'E': parse_e;
            'F': token := $1d;
            'G': token := $1c;
            'H': token := $1b;
            'I': parse_i;
            'J': token := $1a;
            'K': token := $19;
            'L': token := $18;
            'M': token := $c;
            'N': BEGIN
                 read (ch);
                 case ch of
                    ' ': token := $d;
                    'G': token := $14
                    end (* case *)
                 end; (* N phoneme sequence *)
            'O': parse_o;
            'P': parse_p;
            'R': token := $2b;
            'S': BEGIN
                 read (ch);
                 case ch of
                    ' ': token := $1f;
                    'H': token := $11;
                    'T': token := $3f
                    end (* case *)
                 end; (* S phoneme sequence *)
            'T': parse_t;
            'U': parse_u;
            'V': token := $f;
            'W': token := $2d;
            'Y': BEGIN
                 read (ch);
                 case ch of
                    ' ': token := $29;
                    '1': token := $22
                    end
                 end; (* Y phoneme sequence *)
            'Z': BEGIN
                 read (ch);
                 case ch of
                    ' ': token := $12;
                    'H': token := $7
                    end
                 end (* Z phoneme sequence *)
            else data_valid := false
            end;
            getphoneme := token
      end; (* phoneme fetching & decoding *)

   PROCEDURE get_entry;
   (* this PROCEDURE fetches an entry from the user and stores
      in a temporary location called utterance *)

   var
      phoneme: char;

   BEGIN
      clear_screen;
      list_phonemes;
      put_cursor (16,1);
      write ('Enter the ENGLISH spelling of a word:  ');
      readln (utterance.spelling);
      put_cursor (17,1);
      writeln ('And its PHONETIC spelling');
      writeln ('(Insert a space between each phoneme)');
      utterance.phonemes := ''; (* reset utterance *)

      repeat
         phoneme := getphoneme;
         if data_valid then
         utterance.phonemes := concat (utterance.phonemes,phoneme)
      until eoln
   end;

   PROCEDURE put_in_dictionary;
   (* this PROCEDURE loads the utterance into the next available
      dictionary position *)
   VAR
      I: integer;

   BEGIN
      put_cursor (15,20);
      write ('Save Word Information in Dictionary');
      i := 0;
      repeat
         i := i + 1
      until (i>100) or not dictionary[i].filled;
      if entry < i then entry := i;
      if entry >100
         then
            BEGIN
            writeln;
            write ('Dictionary FULL, Save it on Disk and try again')
            end
         else
            BEGIN
            dictionary[i] := utterance;
            dictionary[i].filled := true;
            put_cursor (17,20);
            write (utterance.spelling,' saved as entry ',i)
            end;
      for i := 1 to 30000 do
   end;

   PROCEDURE save_on_disk;
   (* this PROCEDURE writes a dictionary disk file *)

   var
      file_name: string[17];
      i,j: integer;

   BEGIN
      put_cursor (15,20);
      write ('Save Dictionary on Disk FUNCTION');
      put_cursor (17,1);
      write ('Enter Dictionary Name:  ');
      readln (file_name);
      assign (out_file,filename);
      rewrite (out_file);
      if ioresult = 255
         then
            BEGIN
            put_cursor (18,1);
            write ('Disk directory full');
            for i := 1 to 30000 do
            end
         else
            BEGIN
            j := 0;
            for i := 1 to entry do
               BEGIN
               if dictionary[i].filled then
                  BEGIN
                  j := j + 1;
                  out_file^ := dictionary[i];
                  put (out_file)
                  end
               end; (* for *)
            close (outfile,i)
         end; (* if *)
      put_cursor (17,1);
      clear_line;
      write (j,' Words written to File ',file_name);
      for i := 1 to 30000 do
   end;

   PROCEDURE get_from_disk;
   (* this PROCEDURE loads a dictionary disk file into
      the workspace dictionary *)

   var
      file_name: string[17];
      i,j: integer;

   BEGIN
      put_cursor (15,20);
      write ('Get Dictionary From Disk File');
      put_cursor (17,1);
      write ('Enter File Name:  ');
      readln (file_name);
      assign (in_file,file_name);
      reset (in_file);
      if ioresult = 255
         then writeln ('file does not exist')
         else
            BEGIN
            for i := 1 to 100 do dictionary[1].filled := false;
            i := 0;
            repeat
               i := i+1;
               dictionary[i] := in_file^;
               get (infile)
            until eof(in_file);
            entry := i;
            put_cursor (19,1);
            write (entry,' Words Written into Workspace')
         end; (* if *)
      for i := 1 to 30000 do
   end;

   PROCEDURE rpt_word;
   (* this PROCEDURE repeats the utterance *)

   BEGIN
      sayit (utterance.phonemes);
      say (chr($3f))
   end;


   PROCEDURE LIST_PHONEMES;

   (* This procedure lists the phonemes which are available *)

   BEGIN
      put_cursor (4,30);
      write ('Phonemes available:');
      put_cursor (6,1);
      writeln ('E    EH   AE   UH   OO1  Z    B    T    S    M    PA0'); 
      writeln ('E1   EH1  AE1  UH1  R    ZH   D    DT   SH   N    PA1');
      writeln ('Y    EH2  AH   UH2  ER   J    G    K    CH   NG   ST');
      writeln ('Y1   EH3  AH1  UH3  L    V         P    TH');
      writeln ('I    A    AH2  O    IU   THV            F');
      writeln ('I1   A1   AW   O1   U                   H');
      writeln ('I2   A2   AW1  O2   U1');
      writeln ('I3   AY   AW2  OO   W')
   END;


   PROCEDURE encode;
   (* this PROCEDURE encodes a word into the string
      passed to it *)

   var
      i: integer;
      phoneme: char;
      nmemonic: string [4];
      continue: boolean;

   PROCEDURE help;
   (* this PROCEDURE writes the meaning of the FUNCTION keys
      onto the screen.  By convention, the grey (white) FUNCTION
      key toggles in and out of this mode *)

   var
      i: integer;

   BEGIN
      put_cursor (15,20);
      write ('Command Summary');
      for i := 1 to 9 do
         BEGIN
         put_cursor (i+15,5);
         case i of
            1: write ('GET (f1): Encode a user utterance');
            2: write ('WRT (f2): Write current utterance into dictionary');
            3: write ('SOD (f3): Save current dictionary on disk file');
            4: write ('GFD (f4): Load disk file into dictionary');
            5: write ('XIT (f5): Exit to main menu');
            6: write ('DLE (ERASE) : Delete selected dictionary entry');
            7: write ('RPT (blue): repeat current utterance');
            8: write ('MOD (red): Modify a word');
            9: write ('HLP (white): display help messages')
         end (* case *)
      end; (* for *)
      while funct_key <> 'R' do
   end;

   PROCEDURE KILL_WORD;
   (* This procedure is used to delete a word from the dictionary *)

   var
      i: integer;

   BEGIN
      clear_screen;
      list_words;
      put_cursor (24,1);
      write ('Delete Which?  ');
      read (word_spelling);
      i := 0;
      repeat
      i := i+1
      until (i>100) or (word_spelling = dictionary[i].spelling);
      if i > 100 then write ('Word not in dictionary')
      else 
      BEGIN
         dictionary[i].spelling := '';
         dictionary[i].filled := false
      end;
      clear_screen
   END;

   PROCEDURE MODIFY_PHONEMES;
   (* This prodecure is used to modify the phonemes in a word *)
   (* which has already been encoded.                         *)

   var
      i,j,k: integer;
      test_phoneme: string[20];

   PROCEDURE INS_PHONEME;

   var
      index: integer;
      phoneme: char;

   BEGIN
      put_cursor (15,1);
      clear_bottom;
      write (dictionary[i].spelling,' = ');
      display (test_phoneme);
      put_cursor (23,1);
      write ('Insert where?  ');
      readln (index);
      put_cursor (23,30);
      write ('Insert what?  ');
      phoneme := get_phoneme;
      insert (phoneme,test_phoneme,index);
      put_cursor (15,1);
      clear_line;
      write (dictionary[i].spelling,' = ');
      display (test_phoneme);
      sayit (test_phoneme);
      say (chr($3f))
   END;

   PROCEDURE KILL_PHONEME;

   var
      index: integer;

   BEGIN
      put_cursor (15,1);
      clear_bottom;
      write (dictionary[i].spelling,' = ');
      display (test_phoneme);
      put_cursor (23,1);
      write ('Delete where?  ');
      readln (index);
      delete (test_phoneme,index,1);
      put_cursor (15,1);
      eol;
      write(dictionary[i].spelling,' = ');
      display (test_phoneme);
      sayit (test_phoneme);
      say (chr($3f))
   END;


   BEGIN
      clear_screen;
      list_words;
      put_cursor (24,1);
      write ('Modify which word?  ');
      read (word_spelling); 
      i := 0;
      repeat
         i := i + 1
      until (i>100) or (word_spelling = dictionary[i].spelling);
      if i > 100 then
      begin
         put_cursor (24,1);
         clear_line;
         write ('cannot find ',word_spelling,' in the dictionary');
         for i := 1 to 30000 do;
         clear_screen;
         exit
      end;
      clear_screen;
      list_phonemes;
      put_cursor (15,1);
      write (dictionary[i].spelling,' = ');
      display (dictionary[i].phonemes);
      put_25;
      clear_line;
      write ('        INS   DLE   SAY   ACC   XIT   NEW');
      restore_cursor;
      test_phoneme := dictionary[i].phonemes;
      repeat
         put_cursor (16,1);
         clear_bottom;
         case funct_key of
         'S': ins_phoneme;
         'T': kill_phoneme;
         'U': begin
              sayit (test_phoneme);
              say (chr($3f))
              end;
         'V': dictionary[i].phonemes := test_phoneme;
         'W': exit;
         'J': test_phoneme := dictionary[i].phonemes
      end
      until false
   end;

   BEGIN
      clear_screen;
      put_cursor (3,30);
      write ('Encode Word FUNCTION');
      continue := true;
      while continue do
      BEGIN
      put_25;
      clear_line;
      write ('         GET   WRT   SOD   GFD   XIT   DLE   RPT   MOD   HLP');
      restore_cursor;
      put_cursor (15,1); 
      clear_bottom;
      case funct_key of
         'S': get_entry;
         'T': put_in_dictionary;
         'U': save_on_disk;
         'V': get_from_disk;
         'W': continue := false;
         'P': rpt_word;
         'J': kill_word;
         'R': help;
         'Q': modify_phonemes
      end (* case *)
      end; (* while *)
      put_25;
      clear_line;
      restore_cursor
   end;

   Procedure help;

   (* this PROCEDURE displays the summary of the commands
      allowed in the main menu *)

   var
      i: integer;

   BEGIN
      clear_screen;
      put_cursor (3,30);
      write ('Summary of Commands');
      for i := 1 to 8 do
         BEGIN
         put_cursor (i+4,20);
         case i of
            1: write ('ENC (f1): Encode a word');
            2: write ('DIS (f2): Disassemble a word into its phonemes');
            3: write ('CHA (f3): Modify the phonemes within a word');
            4: write ('SAY (f4): Say a word');
            5: write ('CPM (f5): Return to CP/M operating system');
            6: write ('LST (blue): List the current dictionary');
            7: write ('SEN (red): Enunciate a sentence');
            8: write ('HLP (grey): Display summary of commands')
         end (* case *)
      end; (* for *)
      for i := 1 to 30000 do
   end;

   PROCEDURE display (var str: string);
   (* this PROCEDURE displays the phoneme codes for
      an utterance passed to it *)

   var
      i: integer;
      nmemonic: string[4];

   BEGIN
      for i := 1 to length(str) do
         BEGIN
         disasm (str[i],nmemonic);
         write (nmemonic,' ')
         end
   end;

   PROCEDURE LIST_WORDS;

   var
      i,j,k: integer;

   BEGIN
      clear_screen;
      put_cursor (1,20);
      write ('Dictionary Contents (',entry,' entries)');
      k := 1;
      for i := 0 to (entry div 20) do
         BEGIN
         for j := 1 to 20 do
            BEGIN
            put_cursor(j+1,1+15*i);
            if dictionary[k].filled then
               write (k:3,' ',dictionary[k].spelling);
            k := k + 1;
            if (k > entry) or (k > 100) then exit
            end (* for j *)
         end (* for i *)
   end;

procedure say_sentence;
(* this procedure implements the function which will enunciate
   a sentence entered on the console keyboard *)

var
   sentence: string;
   phon_string: string [40];
   word_list: array [1..40] of integer;
   test_spell: string [14];
   dummy_spell: string [14];
   dummy_ch: char;
   i,j,k: integer;

BEGIN
   list_words;
   put_cursor (22,1);
   write ('Enter a SENTENCE in all CAPITAL letters');
   put_cursor (23,1);
   clear_line;
   read (sentence);
   i := 1;
   j := 1;
   repeat
      test_spell := ''; (* clear out the test string *)
      repeat
         test_spell := concat(test_spell,sentence[j]);
         j := j + 1
      until (sentence[j] = ' ') or (j = length(sentence));
      j := j + 1; (* skip over the space *)
      k := 0;
      repeat
         k := k + 1
      until (test_spell = dictionary[k].spelling) or (k > entry);
        if k <= entry then
         sayit (dictionary[k].phonemes);
      i := i + 1
   until (i > 40) or (j >= length(sentence));
   say (chr ($3f))

(*   put_cursor (23,1);
   clear_line;
   for i := 1 to 20 do
      begin
      k := word_list[i];
      write (dictionary[k].spelling,' ');
      phon_string := dictionary[k].phonemes;
      sayit (phon_string);
      say (chr($3f))
      end *)
end;

BEGIN (* MAIN PROGRAM STARTS HERE *)

   out [parctl] := ctrpar;
   say (chr($3f)); (* turn off SC-01 chip *)
   for i := 1 to 100 do dictionary[1].spelling := '';
   repeat
      clear_screen;
      put_cursor (3,10);
      write ('Voice Synthesis Development Software Package 10-25-81');
   
      put_25;
      clear_line;
      write (
'         ENC   DIS         SAY   CPM             LST   SEN   HLP');
      restore_cursor;

      put_cursor (23,10);
      write ('Select a FUNCTION:');

         case funct_key of
            'S': encode;
            'T': BEGIN
                 put_cursor (11,5);
                 clear_bottom;
                 write ('Which word? ');
                 read (word_spelling);
                 i := 0;
                 repeat
                    i := i + 1;
                 until (i>100) or (word_spelling = dictionary[i].spelling);
                 if i > 100 then
                    begin
                    put_cursor (13,5);
                    write (word_spelling,' not found');
                    exit
                 end;
                 put_cursor (13,5);
                 write (dictionary[i].spelling,' = ');
                 display (dictionary[i].phonemes);
                 while funct_key <> 'T' do
                 end;
            'V': BEGIN
                 put_cursor (11,5);
                 clear_bottom;
                 write ('Which word? ');
                 word_spelling := '';
                 read (word_spelling);
                 i := 0;
                 repeat
                    i := i+1;
                 until (word_spelling = dictionary[i].spelling) or
                    (i > entry);
                 if i <= entry then
                    begin
                    sayit (dictionary[i].phonemes);
                    say (chr($3f))
                    end
                 else
                    begin
                    put_cursor (11,5);
	            clear_bottom;
                    write (word_spelling,' is not in this dictionary');
                    while funct_key <> 'V' do
                    end
                 end;
            'W': BEGIN
                 put_25;
                 clear_line;
                 restore_cursor;
                 clear_screen;
                 exit
                 end;
            'P': begin
                 list_words;
                 while funct_key <> 'P' do
                 end;
            'Q': say_sentence;
            'R': help
         end (* case *)
   until false
end.

end.
se
end.
e *