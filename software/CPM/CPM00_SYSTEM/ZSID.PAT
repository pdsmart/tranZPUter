========
Newsgroups: comp.os.cpm
Subject: Re: CP/M web page has new stuff
From: hp@kbbs.org (Holger Petersen)
Date: Mon, 25 Aug 1997 07:19:08 GMT

timolmst@cyberramp.net writes:

> Also, ZSID binary is now available.

Could you please mention the patch from "Dr. Dobbs Journal #62, Dec 1981 
page 519: ZSID Bug and (Risky?) Patch" ? 
It changed the byte at 02AE from C2 to C3.

Befor, some adresses of FF80 to FFFF would be handled bad in (A)ssemble,
(F)ill, (M)ove and (D)ump - commands:

A>ZSID
ZSID VERS 1.4
#A100
0100 LD HL,0FF7F
0103 LD HL,0FF80
0106 LD HL,0FFFF
0109
#L100,108
  0100 LD HL,FF7F
  0103 LD HL,0080
  0106 LD HL,00FF
  0109

===========================

Some months later, I got a letter from Digital Research which 'begged' 
for the allowence to use this patch, which I did...

Greetings, Holger
 
