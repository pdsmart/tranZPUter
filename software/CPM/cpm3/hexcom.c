/*
 * load - convert a hex file to a com file
 *
 * Expanded to HEXCOM by John Elliott, 25-5-1998
 *
 * Compiles with gcc or Pacific C
 *
 */

#include <stdio.h>
#include <stdlib.h>
 
unsigned char   checksum;
int L;

FILE *fpout;

unsigned char   getbyte () {
    register int    c;
    unsigned char   x;

    c = getchar ();
    if ('0' <= c && c <= '9')
	x = c - '0';
    else
	if ('A' <= c && c <= 'F')
	    x = c - 'A' + 10;
	else
	    goto funny;

    x <<= 4;
    c = getchar ();
    if ('0' <= c && c <= '9')
	x |= c - '0';
    else
	if ('A' <= c && c <= 'F')
	    x |= c - 'A' + 10;
	else {
    funny:
	    fprintf (stderr, "Funny hex letter %c\n", c);
	    exit (2);
	}
    checksum += x;
    return x;
}

main (int argc, char **argv) {
    register unsigned   i, n;
    char    c, buf[64];
    unsigned    type;
    unsigned int al, ah, addr = 0, naddr;

	L = 0;
	if (argc < 2) fpout = stdout;
	else fpout = fopen(argv[1],"wb");
    
    do {
	do {
	    c = getchar ();
	    if (c == EOF) {
		fprintf (stderr, "Premature EOF colon missing\n");
		exit (1);
	    }
	} while (c != ':');

	++L;
	checksum = 0;
	n = getbyte ();		/* bytes / line */
	ah = getbyte ();
	al = getbyte ();

	
	switch (type = getbyte ()) 
	{
	    case 0:
		if (!n)	/* MAC uses a line with no bytes as EOF */
		{
			type = 1;
			break;
		}
		naddr = (ah << 8) | al;
		if (!addr) addr = naddr;
		else while (addr < naddr)  
		{
			fwrite("", 1, 1, fpout);
			++addr;
		}
		if (addr > naddr) 
		{
			fprintf(stderr,"Line %d: Records out of sequence at %x > %x\n", L, naddr, addr);
			exit(1);
		}

		for (i = 0; i < n; i++)
		    buf[i] = getbyte ();
		fwrite (buf, 1, n, fpout);
		break;

		case 1:
		break;
		
	    default:
		fprintf (stderr, "Line %d: Funny record type %d\n", L, type);
		exit (1);
	}

	(void) getbyte ();
	if (checksum != 0) 
	{
	    fprintf (stderr, "Line %d: Checksum error", L);
	    exit (2);
	}

	addr += n;
	
    } while (type != 1);
    exit(0);
}
