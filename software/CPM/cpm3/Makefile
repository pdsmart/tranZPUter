#
# Unix Makefile for CP/M 3.1
#
OBJS=mcd80a.obj mcd80f.obj parse.obj
#
HEXS=copysys.hex ccp3.hex ccpdate.hex date.hex device.hex dir.hex \
	dump.hex ed.hex erase.hex get.hex gencom.hex gencpm.hex help.hex \
	hexcom.hex patch.hex pip.hex put.hex rename.hex set.hex setdef.hex \
	show.hex submit.hex type.hex minhlp.hex

OBJS=copysys.obj ccp3.obj ccpdate.obj date.obj device.obj dir.obj \
	dump.obj ed.obj erase.obj get.obj gencom.obj gencpm.obj help.obj \
	objcom.obj patch.obj pip.obj put.obj rename.obj set.obj setdef.obj \
	show.obj submit.obj type.obj minhlp.obj

BLKS=date device dir disp dpb80 ed erase gencom gencpm get hexcom hexpat \
	help main80 minhlp pip put rename scan search set setdef show sort \
	submit timest type util

MCOMS = copysys.com ccp.com date.com device.com dir.com dump.com ed.com \
       erase.com get.com gencom.com gencpm.com help.com hexcom.com patch.com \
       pip.com put.com rename.com set.com setdef.com show.com \
       submit.com type.com sid.com #save.com

BDOS = resbdos3.spr bdos3.spr bnkbdos3.spr

ZXCC = zxcc
THAMES = ./runthames

MAC=mac.com
RMAC=rmac.com
LINK=drlink.com

BINARIES= bdos3.spr     date.com	  erase.com   help.hlp	  README \
	setdef.com bnkbdos3.spr  device.com  gencom.com  hexcom.com  \
	rename.com	show.com ccp.com       dir.com	  gencpm.com  \
	patch.com   resbdos3.spr	submit.com copysys.com   dump.com \
	get.com     pip.com	 save.com	type.com cpmldr.rel    \
	ed.com	  help.com    put.com	  set.com sid.com

SOURCES= assemble.txt  disp.plm	    hexcom.asm	  parse.asm	search.plm \
	bdos30.asm    dpb80.plm     hexcom.c	  patch.asm	setbuf.plm \
	bios.bin      dpb.lit	    hexpat.c	  pip.plm	setdef.plm \
	bioskrnl.asm  drvtbl.asm    inpout.asm	  plibios3.asm	set.plm \
	boot.asm      dump.asm	    ldrlwr.asm	  plibios.asm	show.plm \
	callvers.asm  echovers.asm  _libios3.asm  plidio.asm	sopt.dcl \
	ccp3.asm      ed.plm	    _lidio.asm	  prs0mov.asm	sopt.inc \
	ccp3org.asm   		    drlink.com	  prs1asm.asm	sort.plm \
	ccpdate.asm   erase.plm     loader3.asm   prs2mon.asm	submit.plm \
	chario.asm    fcb.lit	    mac.com	  putf.asm	subrsx.asm \
	comlit.lit    fd1797sd.asm  main80.plm	  put.plm	timest.plm \
	conbdos.asm   finfo.lit     main.plm	  putrsx.asm	type.plm \
	copyrt.lit    format.lit    makedate.lib  random.asm	_ump.asm \
	copysys.asm   gencom.plm    Makefile	  README	util.plm \
	cpmbdos1.asm  gencpm.plm    making.txt	  rename.plm	utl0mov.asm \
	cpmbdos2.asm  getdef.plm    mcd80a.asm	  resbdos.asm	utl1hst.asm \
	cpmldr.asm    getf.asm	    mcd80f.asm	  rmac.com	utl2trc.asm \
	crdef.plm     get.plm	    minhlp.plm	  save.asm	vers.lit \
	date.plm      getrsx.asm    mon.plm	  scan.lit	xfcb.lit \
	datmod.asm    getrsx.lib    move.asm	  scan.plm \
	device.plm    help.dat	    newpip.plm	  scb.asm \
	dirlbl.asm    help.plm	    _opysys.asm   search.lit  runthames


all:	$(MCOMS) $(BDOS) cpmldr.rel help.hlp

zip:	cpm3src_unix.zip cpm3bin_unix.zip

cpm3src_unix.zip:	$(SOURCES)
	zip $@ $(SOURCES)

cpm3bin_unix.zip:	$(BINARIES)
	zip $@ $(BINARIES)

############################################################################
#
# Build tools
#
hexcom:		hexcom.c
	${CC} -o hexcom hexcom.c

hexpat:		hexpat.c
	${CC} -o hexpat hexpat.c

##############################################################################
#
# Help
#
help.hlp:	help.dat minhlp.com
	$(ZXCC) minhlp.com -[CREATE]
#


##############################################################################
#
# Specific build rules
#
# The redirection to CCPPHASE.* produces two lists of addresses (one in 
# CCP3.COM and one in LOADER3.PRL) which should match.
#

loader3.rel:	loader3.asm
	$(ZXCC) $(RMAC) loader3 >ccpphase.lst

ccp3.hex:	ccp3.asm
	$(ZXCC) $(MAC) ccp3 >> ccpphase.lst

ccp.com:	loader3d.tmp hexpat ccpdate.hex
	./hexpat $< $@ < ccpdate.hex

loader3d.tmp:	loader3c.tmp hexpat ccp3.hex
	./hexpat $< $@ < ccp3.hex

loader3c.tmp:	loader3a.tmp loader3b.tmp
	cat loader3a.tmp loader3b.tmp > $@

# Shave the header off loader3.prl to get the loader image
loader3a.tmp:	loader3.prl
	dd if=loader3.prl of=loader3a.tmp bs=128 skip=2

# This empty space will be overwritten by ccp3.hex
loader3b.tmp:
	dd if=/dev/zero of=loader3b.tmp bs=128 count=19
	
dir.tra:	dir.mod
	$(THAMES) :F3:locate $< code\(0100h\) stacksize\(50\) map print\($@\)

dir.mod:	main80 scan search sort disp dpb80 util timest mcd80a.obj
	$(THAMES) :F3:link mcd80a.obj,main80,scan,search,sort,disp,util,dpb80,timest,:F1:plm80.lib to dir.mod

erase.mod:	erase.obj parse.obj mcd80a.obj
	$(THAMES) :F3:link mcd80a.obj,parse.obj,$<,:F1:plm80.lib to $@

gencom.mod:	gencom.obj parse.obj mcd80a.obj
	$(THAMES) :F3:link mcd80a.obj,parse.obj,$<,:F1:plm80.lib to $@

gencpm.mod:	gencpm.obj setbuf.obj getdef.obj crdef.obj ldrlwr.obj \
		mcd80f.obj datmod.obj
	$(THAMES) :F3:link mcd80f.obj,$<,setbuf.obj,getdef.obj,crdef.obj,ldrlwr.obj,datmod.obj,:F1:plm80.lib to $@

get.mod:	get.obj mcd80a.obj parse.obj getf.obj
	$(THAMES) :F3:link mcd80a.obj,$<,parse.obj,getf.obj,:F1:plm80.lib to $@

get.com:	get.hex getrsx.rsx gencom.com hexcom
	./hexcom $@ <$<
	cp getrsx.rsx get.rsx
	$(ZXCC) gencom.com $@ get.rsx

get.rsx:	getrsx.rel
	$(ZXCC) $(LINK) getrsx +-[OP]
	mv -f getrsx.prl $@

pip.mod:	pip.obj mcd80f.obj inpout.obj
	$(THAMES) :F3:link mcd80f.obj,inpout.obj,$<,:F1:plm80.lib to $@

put.mod:	put.obj mcd80a.obj parse.obj putf.obj
	$(THAMES) :F3:link mcd80a.obj,$<,parse.obj,putf.obj,:F1:plm80.lib to $@

put.com:	put.hex put.rsx gencom.com hexcom
	./hexcom $@ <$<
	$(ZXCC) gencom.com $@ put.rsx

put.rsx:	putrsx.rel
	$(ZXCC) $(LINK) putrsx +-[OP]
	mv -f putrsx.prl $@

save.com:	save.rsx gencom.com
	rm -f $@
	$(ZXCC) gencom save +-[NULL]

set.com:	set.hex dirlbl.rsx gencom.com hexcom
	./hexcom $@ <$<
	$(ZXCC) gencom.com $@ dirlbl.rsx

sid.com:	hexpat sid.spr prs0mov.hex
	./hexpat sid.spr $@ <prs0mov.hex

submit.com:	submit.hex subrsx.rsx gencom.com hexcom
	./hexcom $@ <$<
	cp subrsx.rsx sub.rsx
	$(ZXCC) gencom.com $@ sub.rsx

rename.mod:	rename.obj parse.obj mcd80a.obj
	$(THAMES) :F3:link mcd80a.obj,$<,parse.obj,:F1:plm80.lib to $@

set.mod:	set.obj parse.obj mcd80a.obj
	$(THAMES) :F3:link mcd80a.obj,parse.obj,$<,:F1:plm80.lib to $@

submit.mod: 	submit.obj parse.obj getf.obj mcd80a.obj
	$(THAMES) :F3:link mcd80a.obj,$<,parse.obj,getf.obj,:F1:plm80.lib to $@

type.mod:	type.obj parse.obj mcd80a.obj
	$(THAMES) :F3:link mcd80a.obj,$<,parse.obj,:F1:plm80.lib to $@


mcd80f.obj:	mcd80f.asm
	$(THAMES) :F2:asm80 $<


resbdos3.spr:	resbdos.rel
	$(ZXCC) $(LINK) resbdos3 +-= +resbdos +-[os]

bdos3.spr:	cpmbdosx.rel
	$(ZXCC) $(LINK) bdos3 +-= cpmbdosx +-[os]

bnkbdos3.spr:	cpmbdos.rel
	$(ZXCC) $(LINK) bnkbdos3 +-= cpmbdos +-[os]

cpmbdosx.asm:	cpmbdos1.asm conbdos.asm bdos30.asm makedate.lib
	cat cpmbdos1.asm conbdos.asm bdos30.asm > $@

cpmbdos.asm:	cpmbdos2.asm conbdos.asm bdos30.asm makedate.lib
	cat cpmbdos2.asm conbdos.asm bdos30.asm > $@

# Bits of DIR
main80:	main80.plm
	$(THAMES) :F1:plm80 $< debug pagewidth\(130\) optimize object\($@\) 

scan:	scan.plm
	$(THAMES) :F1:plm80 $< debug pagewidth\(130\) optimize object\($@\) 

search:	search.plm
	$(THAMES) :F1:plm80 $< debug pagewidth\(130\) optimize object\($@\) 

sort:	sort.plm
	$(THAMES) :F1:plm80 $< debug pagewidth\(130\) optimize object\($@\) 

disp:	disp.plm
	$(THAMES) :F1:plm80 $< debug pagewidth\(130\) optimize object\($@\) 

dpb80:	dpb80.plm
	$(THAMES) :F1:plm80 $< debug pagewidth\(130\) optimize object\($@\) 

util:	util.plm
	$(THAMES) :F1:plm80 $< debug pagewidth\(130\) optimize object\($@\) 

timest:	timest.plm
	$(THAMES) :F1:plm80 $< debug pagewidth\(130\) optimize object\($@\) 

##############################
#
# SID
#
sid.spr:        prs1asm.rel prs2mon.rel
	$(ZXCC) $(LINK) sid.spr +-= +prs1asm +-, +prs2mon +-[OS]
 
prs0mov.hex:    prs0mov.asm makedate.lib
	$(ZXCC) $(MAC) prs0mov
 
prs1asm.rel:    prs1asm.asm
	$(ZXCC) $(RMAC) prs1asm
 
prs2mon.rel:    prs2mon.asm
	$(ZXCC) $(RMAC) prs2mon                             

##############################################################################
#
# Generic build rules
#

%.obj:	%.asm
	$(THAMES) :F2:asm80 $< debug


###########################################################################
#
# COM files from hex files
#
%.com:	%.hex hexcom
	./hexcom $@ < $<

###########################################################################
#
# HEX files from asm source
#
%.hex: %.asm makedate.lib
	$(ZXCC) $(MAC) `basename $< .asm`

###########################################################################
#
# HEX files from PL/M source
#
%.hex: %.tra
	$(THAMES) :F3:objhex `basename $< .tra` to $@

# The "%.tra" rule also builds "%", which is what objhex actually uses, but
# I couldn't get a bare % rule to work.
%.tra:	%.mod
	$(THAMES) :F3:locate $< code\(0100h\) stacksize\(100\) map print\($@\)

%.mod:	%.obj mcd80a.obj
	$(THAMES) :F3:link mcd80a.obj,$<,:F1:plm80.lib to $@

%.obj:	%.plm
	$(THAMES) :F1:plm80 $< optimize debug	


###########################################################################
#
# PRL and RSX files from .REL files 
#
%.prl:	%.rel
	$(ZXCC) $(LINK) `basename $< .rel` +-[OP]

%.spr:	%.rel loader*.tmp
	$(ZXCC) $(LINK) `basename $< .rel` +-[OS]

%.rsx:	%.rel
	$(ZXCC) $(LINK) `basename $< .rel` +-[OP]
	mv -f `basename $< .rel`.prl `basename $< .rel`.rsx

%.rel:	%.asm
	$(ZXCC) $(RMAC) `basename $< .asm`

#
# 
#
clean:
	rm -f $(MCOMS) $(HEXS) $(BLKS) *.lst *.rel *.sym *.tra *.rsx *.spr *.hex \
	*.mod *.obj loader*.tmp help.hlp
