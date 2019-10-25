#########################################################################################################
##
## Name:            Makefile
## Created:         June 2019
## Author(s):       Philip Smart
## Description:     tranZPUter Makefile
##                  This script builds the tranZPUter fpga test images.
##
## Credits:         
## Copyright:       (c) 2019 Philip Smart <philip.smart@net2net.org>
##
## History:         September 2019   - Initial script written.
##
#########################################################################################################
## This source file is free software: you can redistribute it and#or modify
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

ROOT        = ../
ZPUROOT     = ../../zpu/

# Build utilites
QUARTUS_SH  = quartus_sh
QUARTUS_CPF = quartus_cpf
TEE         = tee
ECHO        = echo
MV          = mv
GREP        = grep
RM          = rm
CC			= CC $(CINCLUDES)
AR			= ar
LD			= ld

# Build flags
SH_FLAGS    = --flow compile
CPF_FLAGS   = -c -o bitstream_compression=on
MSG_FILTER  = "Error\|success"
# MSG_FILTER  = "Info\|Warning\|Error\|success"
# MSG_FILTER  = "Info\|Warning\|Error\|success"
# MSG_FILTER  = "Info\|Warning\|Error\|success"

SOC         = $(ZPUROOT)/zpu_soc.vhd $(ROOT)/zpu_soc_pkg.vhd
ZPU_EVO     = $(ZPUROOT)/cpu/zpu_core_evo.vhd $(ZPUROOT)/cpu/zpu_pkg.vhd

.PHONY:	all
all: tranZPUter_SMALL tranZPUter_MEDIUM tranZPUter_FLEX tranZPUter_EVO tranZPUter_EVO_MINIMAL
tranZPUter: tranZPUter_SMALL tranZPUter_MEDIUM tranZPUter_FLEX tranZPUter_EVO tranZPUter_EVO_MINIMAL
SMALL: tranZPUter_SMALL
MEDIUM: tranZPUter_MEDIUM
FLEX: tranZPUter_FLEX
EVO: tranZPUter_EVO
EVO_MINIMAL: tranZPUter_EVO_MINIMAL

tranZPUter_SMALL:
	@cat $(ROOT)/zpu_soc_pkg.tmpl.vhd | sed 's/ZPU_SMALL                :     integer    := [01]/ZPU_SMALL                :     integer    := 1/g' |\
	                                    sed 's/ZPU_MEDIUM               :     integer    := [01]/ZPU_MEDIUM               :     integer    := 0/g' |\
	                                    sed 's/ZPU_FLEX                 :     integer    := [01]/ZPU_FLEX                 :     integer    := 0/g' |\
	                                    sed 's/ZPU_EVO                  :     integer    := [01]/ZPU_EVO                  :     integer    := 0/g' |\
	                                    sed 's/ZPU_EVO_MINIMAL          :     integer    := [01]/ZPU_EVO_MINIMAL          :     integer    := 0/g' \
	  > $(ROOT)/zpu_soc_pkg.vhd
	@$(ECHO) "Compiling $@..."
	$(QUARTUS_SH) $(SH_FLAGS) tranZPUter.qpf 2> /dev/null | $(TEE) $@.log | $(GREP) -i $(MSG_FILTER)
	$(MV) output_files/tranZPUter.sof $@.sof
	@$(QUARTUS_CPF) $(CPF_FLAGS) $@.sof $@.rbf 2> /dev/null | $(TEE) -a $@.log | $(GREP) -i $(MSG_FILTER)
	@$(ECHO) "$@.sof and $@.rbf generated..."

tranZPUter_MEDIUM:
	@cat $(ROOT)/zpu_soc_pkg.tmpl.vhd | sed 's/ZPU_SMALL                :     integer    := [01]/ZPU_SMALL                :     integer    := 0/g' |\
	                                    sed 's/ZPU_MEDIUM               :     integer    := [01]/ZPU_MEDIUM               :     integer    := 1/g' |\
	                                    sed 's/ZPU_FLEX                 :     integer    := [01]/ZPU_FLEX                 :     integer    := 0/g' |\
	                                    sed 's/ZPU_EVO                  :     integer    := [01]/ZPU_EVO                  :     integer    := 0/g' |\
	                                    sed 's/ZPU_EVO_MINIMAL          :     integer    := [01]/ZPU_EVO_MINIMAL          :     integer    := 0/g' \
	  > $(ROOT)/zpu_soc_pkg.vhd
	@$(ECHO) "Compiling $@..."
	@$(QUARTUS_SH) $(SH_FLAGS) tranZPUter.qpf 2> /dev/null | $(TEE) $@.log | $(GREP) -i $(MSG_FILTER)
	@$(MV) output_files/tranZPUter.sof $@.sof
	@$(QUARTUS_CPF) $(CPF_FLAGS) $@.sof $@.rbf 2> /dev/null | $(TEE) -a $@.log | $(GREP) -i $(MSG_FILTER)
	@$(ECHO) "$@.sof and $@.rbf generated..."

tranZPUter_FLEX:
	@cat $(ROOT)/zpu_soc_pkg.tmpl.vhd | sed 's/ZPU_SMALL                :     integer    := [01]/ZPU_SMALL                :     integer    := 0/g' |\
	                                    sed 's/ZPU_MEDIUM               :     integer    := [01]/ZPU_MEDIUM               :     integer    := 0/g' |\
	                                    sed 's/ZPU_FLEX                 :     integer    := [01]/ZPU_FLEX                 :     integer    := 1/g' |\
	                                    sed 's/ZPU_EVO                  :     integer    := [01]/ZPU_EVO                  :     integer    := 0/g' |\
	                                    sed 's/ZPU_EVO_MINIMAL          :     integer    := [01]/ZPU_EVO_MINIMAL          :     integer    := 0/g' \
	  > $(ROOT)/zpu_soc_pkg.vhd
	@$(ECHO) "Compiling $@..."
	@$(QUARTUS_SH) $(SH_FLAGS) tranZPUter.qpf 2> /dev/null | $(TEE) $@.log | $(GREP) -i $(MSG_FILTER)
	@$(MV) output_files/tranZPUter.sof $@.sof
	@$(QUARTUS_CPF) $(CPF_FLAGS) $@.sof $@.rbf 2> /dev/null | $(TEE) -a $@.log | $(GREP) -i $(MSG_FILTER)
	@$(ECHO) "$@.sof and $@.rbf generated..."

tranZPUter_EVO:
	@cat $(ROOT)/zpu_soc_pkg.tmpl.vhd | sed 's/ZPU_SMALL                :     integer    := [01]/ZPU_SMALL                :     integer    := 0/g' |\
	                                    sed 's/ZPU_MEDIUM               :     integer    := [01]/ZPU_MEDIUM               :     integer    := 0/g' |\
	                                    sed 's/ZPU_FLEX                 :     integer    := [01]/ZPU_FLEX                 :     integer    := 0/g' |\
	                                    sed 's/ZPU_EVO                  :     integer    := [01]/ZPU_EVO                  :     integer    := 1/g' |\
	                                    sed 's/ZPU_EVO_MINIMAL          :     integer    := [01]/ZPU_EVO_MINIMAL          :     integer    := 0/g' \
	  > $(ROOT)/zpu_soc_pkg.vhd
	@$(ECHO) "Compiling $@..."
	@$(QUARTUS_SH) $(SH_FLAGS) tranZPUter.qpf 2> /dev/null | $(TEE) $@.log | $(GREP) -i $(MSG_FILTER)
	@$(MV) output_files/tranZPUter.sof $@.sof
	@$(QUARTUS_CPF) $(CPF_FLAGS) $@.sof $@.rbf 2> /dev/null | $(TEE) -a $@.log | $(GREP) -i $(MSG_FILTER)
	@$(ECHO) "$@.sof and $@.rbf generated..."

tranZPUter_EVO_MINIMAL:
	@cat $(ROOT)/zpu_soc_pkg.tmpl.vhd | sed 's/ZPU_SMALL                :     integer    := [01]/ZPU_SMALL                :     integer    := 0/g' |\
	                                    sed 's/ZPU_MEDIUM               :     integer    := [01]/ZPU_MEDIUM               :     integer    := 0/g' |\
	                                    sed 's/ZPU_FLEX                 :     integer    := [01]/ZPU_FLEX                 :     integer    := 0/g' |\
	                                    sed 's/ZPU_EVO                  :     integer    := [01]/ZPU_EVO                  :     integer    := 0/g' |\
	                                    sed 's/ZPU_EVO_MINIMAL          :     integer    := [01]/ZPU_EVO_MINIMAL          :     integer    := 1/g' \
	  > $(ROOT)/zpu_soc_pkg.vhd
	@$(ECHO) "Compiling $@..."
	@$(QUARTUS_SH) $(SH_FLAGS) tranZPUter.qpf 2> /dev/null | $(TEE) $@.log | $(GREP) -i $(MSG_FILTER)
	@$(MV) output_files/tranZPUter.sof $@.sof
	@$(QUARTUS_CPF) $(CPF_FLAGS) $@.sof $@.rbf 2> /dev/null | $(TEE) -a $@.log | $(GREP) -i $(MSG_FILTER)
	@$(ECHO) "$@.sof and $@.rbf generated..."

clean:
	@$(ECHO) "Removing all temporary files..."
	@$(RM) -fr c5_pin_model_dump.txt ./db tranZPUter.asm.rpt tranZPUter.done tranZPUter.fit.rpt tranZPUter.fit.smsg tranZPUter.fit.summary tranZPUter.flow.rpt tranZPUter.jdi tranZPUter.map.rpt tranZPUter.map.smsg tranZPUter.map.summary tranZPUter.pin tranZPUter.rbf tranZPUter.sld tranZPUter.sof tranZPUter.sta.rpt tranZPUter.sta.summary ./incremental_db qmegawiz_errors_log.txt tranZPUter.pof tranZPUter*.log tranZPUter*.rbf tranZPUter*.sof tranZPUter*.sta.smsg
	@$(RM) -fr output_files
