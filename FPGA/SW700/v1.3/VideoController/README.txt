If the Character Generator ROM is changed you need to regenerate the ChrGENRAM definition file using the command (alterered suitably):
${ROOT_DIR}/zSoft/tools/zpugen BA 32 ../../../../software/roms/MZ700_cgrom.rom ChrGenRAM_DP_3208.vhd.tmpl 0 > ChrGenRAM_DP_3208.vhd
