/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            nasconv.c
// Created:         June 2020
// Author(s):       Philip Smart
// Description:     Tool to extract a linear image from a NASCOM cassette format image. The NASCOM
//                  is formatted with tape sequencing data which is not needed.
//
// Credits:         
// Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
//
// History:         March 2020   - Initial program written.
//
// Notes:           
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// This source file is free software: you can redistribute it and#or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This source file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
/////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <getopt.h>

#define VERSION              "1.0"


// Simple help screen to remmber how this utility works!!
//
void usage(void)
{
    printf("NASCONV v%s\n", VERSION);
    printf("\nRequired:-\n");
    printf("  -i | --image <file>      Image file to be converted.\n");
    printf("  -o | --output <file>     Target destination file for converted data.\n");
    printf("\nOptions:-\n");

    printf("  -l | --loadaddr <addr>   MZ80A basic start address. NASCOM address is used to set correct MZ80A address.\n");
    printf("  -n | --nasaddr <addr>    Original NASCOM basic start address.\n");
    printf("  -h | --help              This help test.\n");
    printf("  -v | --verbose           Output more messages.\n");

    printf("\nExamples:\n");
    printf("  nasconv --image 3dnc.cas --output 3dnc.bas --nasaddr 0x10fa --loadaddr 0x4341    Convert the file 3dnc.cas from NASCOM cassette format.\n");
}

// Method to convert a little endian <-> big endian 32bit unsigned.
//
uint32_t swap_endian(uint32_t value)
{
    uint32_t b[4];
    b[0] = ((value & 0x000000ff) << 24u);
    b[1] = ((value & 0x0000ff00) <<  8u);
    b[2] = ((value & 0x00ff0000) >>  8u);
    b[3] = ((value & 0xff000000) >> 24u);

    return(b[0] | b[1] | b[2] | b[3]);
}


// Main program, to be split up into methods at a later date!! Just quick write.
//
int main(int argc, char *argv[])
{

    int        opt; 
    int        option_index      = 0; 
    int        help_flag         = 0;
    int        verbose_flag      = 0;
    uint8_t    zeroCount         = 0;
    uint8_t    ffCount           = 0;
    uint8_t    readCount         = 0;
    uint8_t    hdrCount          = 0;
    uint8_t    hdr[5];
    uint8_t    cassette[65536];
    uint16_t   loadAddr          = 0x4341;
    uint16_t   nasAddr           = 0x10fa;
    uint32_t   casPos            = 0;
    uint32_t   casIdx            = 0; 
    char       imageFile[1024];
    char       outputFile[1024];
    FILE       *fpImage;
    FILE       *fpOutput;

    // Initialise other variables.
    //
    imageFile[0] = 0x00;
    outputFile[0] = 0x00;

    // Modes of operation.
    static struct option long_options[] =
    {
        {"help",        no_argument,       0,   'h'},
        {"image",       required_argument, 0,   'i'},
        {"output",      required_argument, 0,   'o'},
        {"loadaddr",    required_argument, 0,   'l'},
        {"nasaddr",     required_argument, 0,   'n'},
        {"verbose",     no_argument,       0,   'v'},
        {0,             0,                 0,   0}
    };

    // Parse the command line options.
    //
    while((opt = getopt_long(argc, argv, ":hvi:o:l:n:", long_options, &option_index)) != -1)  
    {  
        switch(opt)  
        {  
            case 'h':
                help_flag = 1;
                break;

            case 'i':
                strcpy(imageFile, optarg);
                break;
                
            case 'o':
                strcpy(outputFile, optarg);
                break;

            case '1':
                loadAddr = atoi(optarg);
                break;

            case 'n':
                nasAddr = atoi(optarg);
                break;

            case 'v':
                verbose_flag = 1;
                break;

            case ':':  
                printf("Option %s needs a value\n", argv[optind-1]);  
                break;  
            case '?':  
                printf("Unknown option: %s, ignoring!\n", argv[optind-1]); 
                break;  
        }  
    } 

    // Validate the input.
    if(help_flag == 1)
    {
        usage();
        exit(0);
    }
    if(strlen(imageFile) == 0 )
    {
        printf("Image file not specified.\n");
        exit(10);     
    }
    if(strlen(outputFile) == 0 )
    {
        printf("Output file not specified.\n");
        exit(10);     
    }

    // Open the NASCOM CASSETTE image file.
    fpImage  = fopen(imageFile,  "r");
    if(fpImage == NULL)
    {
        printf("Couldnt open the image file:%s.\n", imageFile);
        exit(30);     
    }
    
    // Create a new file to output the extracted data.
    fpOutput  = fopen(outputFile,  "w");
    if(fpOutput == NULL)
    {
        printf("Couldnt create the output file:%s.\n", outputFile);
        exit(31);     
    }
    
    // First get the image into memory removing the outer tape block wrappers.
    //
    fseek(fpImage, 0, 0);
    uint32_t addr = 0;
    do {
        int c = fgetc(fpImage);

        // If we are in a data block, just store into memory for later manipulation.
        if(ffCount >= 4 && hdrCount >= 5)
        {
            if(verbose_flag)
                printf("%02x ", c);
            cassette[casPos++] = c;
            readCount++;

            // Header[2] contains the block size, normally 256 bytes but can be less on the last block.
            if(readCount == hdr[2])
            {
                zeroCount = 0;
                ffCount = 0;
                hdrCount = 0;
            }
        } else
        {
            // A block header starts with one or more zeros followed by 4x0xFF then a 5 byte description block.
            if(c == 0x00 && ffCount == 0)
            {
                zeroCount++;
            } else
            if(zeroCount > 0 && ffCount < 4 && c == 0xff)
            {
                ffCount++;
            } else
            if(ffCount >= 4 && hdrCount < 5)
            {
                hdr[hdrCount] = c;
                hdrCount++;
                if(hdrCount == 5)
                {
                    readCount = 0;
                }
                if(verbose_flag)
                    printf("ADDR:%04x, HDR[0..4]=%02x,%02x,%02x,%02x,%02x\n", addr, hdr[0], hdr[1], hdr[2], hdr[3], hdr[4]);
            } else
            {
                zeroCount = 0;
                ffCount = 0;
                hdrCount = 0;
            }
        }
        addr++;
    } while(!feof(fpImage));

    // Find the start of the basic program, a block starting 0x80 0x00 0x00 0x00
    //
    //for(casIdx = 0; casIdx < casPos; casIdx++)
    // {
    //     if(cassette[casIdx] == 0x80 && cassette[casIdx+1] == 0x00 && cassette[casIdx+2] == 0x00 && cassette[casIdx+3] == 0x000)
    //         break;
    // }
    // The above code only worked on some files, others are not really decipherable given I dont have the NASCOM tape details, but further analysis shows
    // all the files start at the common vector 0x132 or 0x24 after removal of tape run in header, so will run with this!
    casIdx = 0x24 - 4; // Adjust so the below code works as intended.

    if(verbose_flag)
    {
        printf("\n"); for(uint16_t idx=0; idx < casPos; idx++) { printf("%02x ", cassette[idx]); }; printf("\n");
    }

    // If the start block couldnt be found then we cant process this file.
    if(casIdx < casPos)
    {
        // Update the pointers to the correct load address in the MZ80A basic.
        // The cassette image contains the load addresses of each line, these addresses are NASCOM addresses so need updating.
        //
        uint16_t lastAddr = nasAddr;
        for(uint16_t idx = casIdx+4; idx< casPos;)
        {
            uint16_t origAddr = *(uint16_t *)&cassette[idx];

            // End of program the next address will be zero so exit.
            if(idx > casIdx+4 &&  origAddr == 0x0000)
                break;

            // Update the address to the new value for the MZ80A version of Microsoft Basic.
            *(uint16_t *)&cassette[idx] = (origAddr - nasAddr) + loadAddr;
            //printf("OrigAddr = %04x, lastAddr = %04x, next = %04x\n", origAddr, lastAddr, (origAddr - nasAddr) + loadAddr);
            
            // Scan for tokens in the program code and update.
            // Skip the line number and just work within the actual tokenised data.
            //
            for(uint16_t idx2 = idx+4; idx2 < idx + (origAddr - lastAddr); idx2++)
            {
                if(cassette[idx2] > 0xA4 && cassette[idx2] < 0xcf)
                {
                    //printf("Updating:%04x,%02x\n", idx, cassette[idx2]);
                    if(cassette[idx2] > 0xe4)
                        printf("EXCEED:%04x,%02x\n", idx2, cassette[idx2]);
                    cassette[idx2] = cassette[idx2] + (0xC0 - 0xA5);
                }
            }
            idx += origAddr - lastAddr;
            lastAddr = origAddr;
        }

        // Write out the data to finish.
        for(uint32_t idx=casIdx+4; idx < casPos; idx++)
        {
            fputc(cassette[idx], fpOutput);
        }
    }
    else
    {
        printf("Tape data not valid:%s, update logic to cater for this file or use a correct data file.\n", outputFile);
    }

    // Close files to finish.
    fclose(fpImage);
    fclose(fpOutput);
    if(verbose_flag)
        printf("Image file updated.\n");
}
