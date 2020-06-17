#########################################################################################################
##
## Name:            Makefile
## Created:         May 2020
## Author(s):       Philip Smart
## Description:     Helper tools for the MZ80A tranZPUter / tranZPUterSW upgrades.
##                  This makefile builds tools written in C which help with building/setting up the
##                  tranZPUter/tranZPUterSW and configuration images.
##
## Credits:         
## Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
##
## History:         May 2020   - Initial Makefile creation
##
## Notes:           
##
#########################################################################################################
## This source file is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published
## by the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This source file is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
#########################################################################################################
BASE	        = 
CC              = $(BASE)gcc
LD              = $(BASE)gcc
AS              = $(BASE)as
CP              = $(BASE)objcopy
DUMP            = $(BASE)objdump

BASEDIR         = ../../..
SWDIR           = $(BASEDIR)/software/src
INSTALLDIR      = $(BASEDIR)/software/tools

# we use printf from here
COMMON_DIR      = $(SWDIR)/common
INCLUDE_DIR     = $(SWDIR)/include

# Working directory to build object files.
BUILD_DIR       = tools_obj

COMMON_SRC      = 
COMMON_OBJ      = $(patsubst $(COMMON_DIR)/%.c,$(BUILD_DIR)/%.o,$(COMMON_SRC))

FLASHMMCFG_PRJ  = flashmmcfg
FLASHMMCFG_SRC  = flashmmcfg.c
FLASHMMCFG_OBJ  = $(COMMON_OBJ) $(patsubst %.c,$(BUILD_DIR)/%.o,$(FLASHMMCFG_SRC))
NASCONV_PRJ     = nasconv
NASCONV_SRC     = nasconv.c
NASCONV_OBJ     = $(COMMON_OBJ) $(patsubst %.c,$(BUILD_DIR)/%.o,$(NASCONV_SRC))

# Commandline options for each tool.
OPTS            = 

CFLAGS          = -I. -I$(COMMON_DIR) -I$(INCLUDE_DIR) -O3 
# Enable debug output.
OFLAGS         += -DDEBUG
LFLAGS          = -Wl,--gc-sections -Wl,--relax -Os
#
# Assembler flags.
ASFLAGS         = -I. -I$(COMMON_DIR) -I$(INCLUDE_DIR) -I$(STARTUP_DIR) 
#

# Our target.
all: clean $(BUILD_DIR) $(FLASHMMCFG_PRJ) $(NASCONV_PRJ)

install: all
	cp $(FLASHMMCFG_PRJ) $(INSTALLDIR)
	cp $(NASCONV_PRJ) $(INSTALLDIR)

clean:
	rm -f $(BUILD_DIR)/*.o *.hex *.lss *.elf *.map *.lst *.srec *~ */*.o *.bin *.srec *.dmp *.vhd *.rpt $(FLASHMMCFG_PRJ) $(NASCONV_PRJ)

$(FLASHMMCFG_PRJ): $(FLASHMMCFG_PRJ).elf $(FLASHMMCFG_PRJ).dmp $(FLASHMMCFG_PRJ).lss
$(NASCONV_PRJ): $(NASCONV_PRJ).elf $(NASCONV_PRJ).dmp $(NASCONV_PRJ).lss

# Convert ELF binary to bin file.
%.bin: %.elf
	@$(CP) -O binary $< $@

# Convert ELF to srec format for serial upload.
%.srec: %.elf
	@$(CP) -O srec $< $@

%.dmp: %.elf
	@$(DUMP) -x $< >>$@

# Create extended listing file from ELF output file.
# testing: option -C
%.lss: %.elf
	@echo
	@$(DUMP) -h -S -C $< > $@

$(FLASHMMCFG_PRJ): $(FLASHMMCFG_OBJ)
	$(CC) $(LFLAGS) $(FLASHMMCFG_OBJ) -o $@ $(LIBS)
	chmod +x $@

$(NASCONV_PRJ): $(NASCONV_OBJ)
	$(CC) $(LFLAGS) $(NASCONV_OBJ) -o $@ $(LIBS)
	chmod +x $@

# Link - this produces an ELF binary.
$(FLASHMMCFG_PRJ).elf: $(FLASHMMCFG_OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

# Link - this produces an ELF binary.
$(NASCONV_PRJ).elf: $(NASCONV_OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

$(BUILD_DIR)/%.o: %.c Makefile
	$(CC) $(CFLAGS) $(OFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.o: %.cpp Makefile
	$(CC) $(CFLAGS) $(OFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.o: $(COMMON_DIR)/%.c Makefile
	$(CC) $(CFLAGS) $(OFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: $(STARTUP_DIR)/%.s
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

