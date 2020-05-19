-- ZPU (flex variant)
--
-- Copyright 2004-2008 oharboe - �yvind Harboe - oyvind.harboe@zylin.com
-- 
-- Changes by Alastair M. Robinson, 2013
-- to allow the core to run from external RAM, and to balance performance and area.
-- The goal is to make the ZPU a useful support CPU for such tasks as loading
-- ROMs from SD Card, while keeping the area under 1,000 logic cells.
-- To this end, there are a number of generics which can be used to adjust the
-- speed / area balance.
--
-- The FreeBSD license
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above
--    copyright notice, this list of conditions and the following
--    disclaimer in the documentation and/or other materials
--    provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE ZPU PROJECT ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
-- PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
-- ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
-- INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation
-- are those of the authors and should not be interpreted as representing
-- official policies, either expressed or implied, of the ZPU Project.


-- WARNING - the stack bit has changed from bit 26 to bit 30.
-- RTL code which relies upon this will need updating.
-- Provided the linkscripts and CPU are kept in sync,
-- this change should be essentially invisible to the user.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.zpu_pkg.all;

entity zpu_core_flex is
    generic (
        IMPL_MULTIPLY             : boolean;                -- Self explanatory
        IMPL_COMPARISON_SUB       : boolean;                -- Include sub and (U)lessthan(orequal)
        IMPL_EQBRANCH             : boolean;                -- Include eqbranch and neqbranch
        IMPL_STOREBH              : boolean;                -- Include halfword and byte writes
        IMPL_LOADBH               : boolean;                -- Include halfword and byte reads
        IMPL_CALL                 : boolean;                -- Include call
        IMPL_SHIFT                : boolean;                -- Include lshiftright, ashiftright and ashiftleft
        IMPL_XOR                  : boolean;                -- include xor instruction
 --     REMAP_STACK               : boolean;                -- Map the stack / Boot ROM to an address specific by "stackbit" - default 0x40000000
        CACHE                     : boolean;                -- Cache - only 32-bits but reduces re-fetching and speeds up consecutive IMs in particular.
--      stackbit                  : integer                 -- Specify base address of stack - defaults to 0x40000000
        CLK_FREQ                  : integer := 100000000;   -- Frequency of the input clock.  
        STACK_ADDR                : integer := 0            -- Initial stack address on CPU start.
    );
    port ( 
        clk                       : in  std_logic;
        -- asynchronous reset signal
        reset                     : in  std_logic;
        -- this particular implementation of the ZPU does not
        -- have a clocked enable signal
        enable                    : in  std_logic;
        in_mem_busy               : in  std_logic;
        mem_read                  : in  std_logic_vector(WORD_32BIT_RANGE);
        mem_write                 : out std_logic_vector(WORD_32BIT_RANGE);
        out_mem_addr              : out std_logic_vector(ADDR_BIT_RANGE);
        out_mem_writeEnable       : out std_logic;
        out_mem_bEnable           : out std_logic;  -- Enable byte write
        out_mem_hEnable           : out std_logic;  -- Enable halfword write
        out_mem_readEnable        : out std_logic;
        -- Set to one to jump to interrupt vector
        -- The ZPU will communicate with the hardware that caused the
        -- interrupt via memory mapped IO or the interrupt flag can
        -- be cleared automatically
        interrupt_request         : in  std_logic;
        interrupt_ack             : out std_logic; -- Interrupt acknowledge, ZPU has entered Interrupt Service Routine.
        interrupt_done            : out std_logic; -- Interrupt service routine completed/done.
        -- Signal that the break instruction is executed, normally only used
        -- in simulation to stop simulation
        break                     : out std_logic;
        debug_txd                 : out std_logic; -- Debug serial output.        
        --
        MEM_A_WRITE_ENABLE        : out std_logic;
        MEM_A_ADDR                : out std_logic_vector(ADDR_32BIT_RANGE);
        MEM_A_WRITE               : out std_logic_vector(WORD_32BIT_RANGE);
        MEM_B_WRITE_ENABLE        : out std_logic;
        MEM_B_ADDR                : out std_logic_vector(ADDR_32BIT_RANGE);
        MEM_B_WRITE               : out std_logic_vector(WORD_32BIT_RANGE);
        MEM_A_READ                : in  std_logic_vector(WORD_32BIT_RANGE);
        MEM_B_READ                : in  std_logic_vector(WORD_32BIT_RANGE)
     );
 end zpu_core_flex;
 
 architecture behave of zpu_core_flex is

    -- state machine.
    type State_Type is (
        State_Fetch,
        State_WriteIODone,
        State_Execute,
        State_StoreToStack,
        State_Add,
        State_Or,
        State_And,
        State_Xor,
        State_Store,
        State_ReadIO,
        State_ReadIOBH,
        State_WriteIO,
        State_WriteIOBH,
        State_Load,
        State_FetchNext,
        State_AddSP,
        State_AddSP2,
        State_ReadIODone,
        State_StoreAndDecode,
        State_Decode,
        State_Resync,
        State_Interrupt,
        State_Mult,
        State_Comparison,
        State_EqNeq,
        State_Sub,
        State_IncSP,
        State_Shift,
        State_Debug
    );
  
    type DecodedOpcodeType is (
        Decoded_Nop,
        Decoded_Im,
        Decoded_ImShift,
        Decoded_LoadSP,
        Decoded_StoreSP ,
        Decoded_AddSP,
        Decoded_Emulate,
        Decoded_Break,
        Decoded_PushSP,
        Decoded_PopPC,
        Decoded_Add,
        Decoded_Or,
        Decoded_And,
        Decoded_Load,
        Decoded_LoadBH,
        Decoded_Not,
        Decoded_Xor,
        Decoded_Flip,
        Decoded_Store,
        Decoded_StoreBH,
        Decoded_PopSP,
        Decoded_Interrupt,
        Decoded_Mult,
        Decoded_Sub,
        Decoded_Comparison,
        Decoded_EqNeq,
        Decoded_EqBranch,
        Decoded_Call,
        Decoded_Shift
    );

    --
    type DebugType is 
    (
        Debug_Start,
        Debug_DumpFifo,
        Debug_DumpFifo_1,
        Debug_End
    );
 
    -- start byte address of stack. 
    -- point to top of RAM - 2*words
    --constant spStart              : unsigned(spStart(ADDR_32BIT_RANGE));
    --std_logic_vector(ADDR_BIT_RANGE) := std_logic_vector(to_unsigned((2**(maxAddrBitBRAM+1))-8, maxAddrBit));
  
    signal memAWriteEnable                 : std_logic;
    signal memAAddr                        : unsigned(ADDR_32BIT_RANGE);
    signal memAWrite                       : unsigned(WORD_32BIT_RANGE);
    signal memARead                        : unsigned(WORD_32BIT_RANGE);
    signal memBWriteEnable                 : std_logic;
    signal memBAddr                        : unsigned(ADDR_32BIT_RANGE);
    signal memBWrite                       : unsigned(WORD_32BIT_RANGE);
    signal memBRead                        : unsigned(WORD_32BIT_RANGE);
   
    signal pc                              : unsigned(ADDR_BIT_RANGE);           -- Synthesis tools should reduce this automatically
    signal sp                              : unsigned(ADDR_32BIT_RANGE);
    signal interrupt_suspended_addr        : unsigned(ADDR_BIT_RANGE);           -- Save address which got interrupted.
  
  
    -- this signal is set upon executing an IM instruction
    -- the subsequence IM instruction will then behave differently.
    -- all other instructions will clear the idim_flag.
    -- this yields highly compact immediate instructions.
    signal idim_flag                       : std_logic;
    --
    signal busy                            : std_logic;
    --
    signal begin_inst                      : std_logic;
    signal fetchneeded                     : std_logic;
  
    signal trace_opcode                    : std_logic_vector(7 downto 0);
    signal trace_pc                        : std_logic_vector(ADDR_BIT_RANGE);
    signal trace_sp                        : std_logic_vector(ADDR_32BIT_RANGE);
    signal trace_topOfStack                : std_logic_vector(WORD_32BIT_RANGE);
    signal trace_topOfStackB               : std_logic_vector(WORD_32BIT_RANGE);
    signal debugState                      : DebugType;
    signal debugCnt                        : integer;
    signal debugRec                        : zpu_dbg_t;
    signal debugLoad                       : std_logic;
    signal debugReady                      : std_logic;
  
    signal programword                     : std_logic_vector(WORD_32BIT_RANGE);
    signal cachedprogramword               : std_logic_vector(WORD_32BIT_RANGE);
    signal inrom                           : std_logic;
    signal sampledOpcode                   : std_logic_vector(OpCode_Size-1 downto 0);
    signal opcode                          : std_logic_vector(OpCode_Size-1 downto 0);
    signal opcode_saved                    : std_logic_vector(OpCode_Size-1 downto 0);
    --
    signal decodedOpcode                   : DecodedOpcodeType;
    signal sampledDecodedOpcode            : DecodedOpcodeType;
  
    signal state                           : State_Type;
    --
    subtype index is std_logic_vector(2 downto 0);
    --
    signal tOpcode_sel                     : index;
    --
    signal inInterrupt                     : std_logic;
  
    signal comparison_sub_result           : unsigned(wordSize downto 0); -- Extra bit needed for signed comparisons
    signal comparison_sign_mod             : std_logic;
    signal comparison_eq                   : std_logic;
   
    signal eqbranch_zero                   : std_logic;
    
    signal shift_done                      : std_logic;
    signal shift_sign                      : std_logic;
    signal shift_count                     : unsigned(5 downto 0);
    signal shift_reg                       : unsigned(31 downto 0);
    signal shift_direction                 : std_logic;
  
    signal add_low                         : unsigned(17 downto 0);
  
 begin
 
    -- Wire up the BRAM (RAM/ROM)
    MEM_A_ADDR                                        <= std_logic_vector(memAAddr(ADDR_32BIT_RANGE));
    MEM_A_WRITE                                       <= std_logic_vector(memAWrite);
    MEM_B_ADDR                                        <= std_logic_vector(memBAddr(ADDR_32BIT_RANGE));
    MEM_B_WRITE                                       <= std_logic_vector(memBWrite);
    memARead                                          <= unsigned(MEM_A_READ);
    memBRead                                          <= unsigned(MEM_B_READ);
    MEM_A_WRITE_ENABLE                                <= memAWriteEnable;
    MEM_B_WRITE_ENABLE                                <= memBWriteEnable;
 
    tOpcode_sel(2)                                    <= '1' when CACHE=true and fetchneeded='0' else '0';
    tOpcode_sel(1 downto 0)                           <= std_logic_vector(pc(minAddrBit-1 downto 0));
  
    programword                                       <= MEM_B_READ;
    inrom                                             <='1';
 
    -- move out calculation of the opcode to a separate process
    -- to make things a bit easier to read
    decodeControl : process(programword, cachedprogramword, comparison_sub_result, pc, tOpcode_sel)
        variable tOpcode : std_logic_vector(OpCode_Size-1 downto 0);
    begin
 
        -- simplify opcode selection a bit so it passes more synthesizers
        case (tOpcode_sel) is
            when "000"  => tOpcode                    := std_logic_vector(programword(31 downto 24));
    
            when "001"  => tOpcode                    := std_logic_vector(programword(23 downto 16));
    
            when "010"  => tOpcode                    := std_logic_vector(programword(15 downto 8));
    
            when "011"  => tOpcode                    := std_logic_vector(programword(7 downto 0));
    
            when "100"  => tOpcode                    := std_logic_vector(cachedprogramword(31 downto 24));
    
            when "101"  => tOpcode                    := std_logic_vector(cachedprogramword(23 downto 16));
    
            when "110"  => tOpcode                    := std_logic_vector(cachedprogramword(15 downto 8));
     
            when "111"  => tOpcode                    := std_logic_vector(cachedprogramword(7 downto 0));
    
            when others => tOpcode                    := std_logic_vector(programword(7 downto 0));
        end case;
    
        sampledOpcode <= tOpcode;
    
        if (tOpcode(7 downto 7) = OpCode_Im) then
            sampledDecodedOpcode                      <= Decoded_Im;
        elsif (tOpcode(7 downto 5) = OpCode_StoreSP) then
            sampledDecodedOpcode                      <= Decoded_StoreSP;
        elsif (tOpcode(7 downto 5) = OpCode_LoadSP) then
            sampledDecodedOpcode                      <= Decoded_LoadSP;
        elsif (tOpcode(7 downto 5) = OpCode_Emulate) then
            sampledDecodedOpcode                      <= Decoded_Emulate;
            if IMPL_CALL=true and tOpcode(5 downto 0) = OpCode_Call then
                sampledDecodedOpcode                  <= Decoded_Call;
            end if;
            if IMPL_MULTIPLY=true and tOpcode(5 downto 0) = OpCode_Mult then
                sampledDecodedOpcode                  <= Decoded_Mult;
            end if;
            if IMPL_XOR=true and tOpcode(5 downto 0) = OpCode_Xor then
                sampledDecodedOpcode                  <= Decoded_Xor;
            end if;
            if IMPL_COMPARISON_SUB=true then
                if tOpcode(5 downto 0) = OpCode_Eq or tOpcode(5 downto 0) = OpCode_Neq then
                    sampledDecodedOpcode              <= Decoded_EqNeq;
                elsif tOpcode(5 downto 0)= OpCode_Sub then
                    sampledDecodedOpcode              <= Decoded_Sub;
                elsif tOpcode(5 downto 0)= OpCode_Lessthanorequal or tOpcode(5 downto 0)= OpCode_Lessthan
                    or tOpcode(5 downto 0) = OpCode_Ulessthanorequal or tOpcode(5 downto 0)= OpCode_Ulessthan then
                    sampledDecodedOpcode              <= Decoded_Comparison;
                end if;
            end if;
            if IMPL_EQBRANCH=true then
                if tOpcode(5 downto 0) = OpCode_EqBranch or tOpcode(5 downto 0)= OpCode_NeqBranch then
                    sampledDecodedOpcode              <= Decoded_EqBranch;
                end if;
            end if;
            if IMPL_STOREBH=true then
                if tOpcode(5 downto 0) = OpCode_StoreB or tOpcode(5 downto 0) = OpCode_StoreH then
                    sampledDecodedOpcode              <= Decoded_StoreBH;
                end if;
            end if;
            -- LOADB and LOADH don't do any bitshifting based on address- it's the supporting
            -- SOC's responsibility to make sure the result is in the low order bits.
            if IMPL_LOADBH=true then
                if tOpcode(5 downto 0) = OpCode_LoadB or tOpcode(5 downto 0) = OpCode_LoadH then
    --            if tOpcode(5 downto 0) = OpCode_LoadH then -- Disable LoadB for now, since it doesn't yet work.
                    sampledDecodedOpcode              <= Decoded_LoadBH;
                end if;
            end if;
            if IMPL_SHIFT=true then
                if tOpcode(5 downto 0) = OpCode_Lshiftright or tOpcode(5 downto 0) = OpCode_Ashiftright or tOpcode(5 downto 0) = OpCode_Ashiftleft then
                    sampledDecodedOpcode              <= Decoded_Shift;
                end if;
            end if;
        elsif (tOpcode(7 downto 4) = OpCode_AddSP) then
            sampledDecodedOpcode                      <= Decoded_AddSP;
        else
            case tOpcode(3 downto 0) is
                when OpCode_Break =>
                    sampledDecodedOpcode              <= Decoded_Break;
                when OpCode_PushSP =>
                    sampledDecodedOpcode              <= Decoded_PushSP;
                when OpCode_PopPC =>
                    sampledDecodedOpcode              <= Decoded_PopPC;
                when OpCode_Add =>
                    sampledDecodedOpcode              <= Decoded_Add;
                when OpCode_Or =>
                    sampledDecodedOpcode              <= Decoded_Or;
                when OpCode_And =>
                    sampledDecodedOpcode              <= Decoded_And;
                when OpCode_Load =>
                    sampledDecodedOpcode              <= Decoded_Load;
                when OpCode_Not =>
                    sampledDecodedOpcode              <= Decoded_Not;
                when OpCode_Flip =>
                    sampledDecodedOpcode              <= Decoded_Flip;
                when OpCode_Store =>
                    sampledDecodedOpcode              <= Decoded_Store;
                when OpCode_PopSP =>
                    sampledDecodedOpcode              <= Decoded_PopSP;
                when others =>
                    sampledDecodedOpcode              <= Decoded_Nop;
            end case;  -- tOpcode(3 downto 0)
        end if; -- tOpcode
    end process;
 
 
    opcodeControl: process(clk, reset, comparison_sub_result, shift_count, memBRead)
        variable spOffset       : unsigned(4 downto 0);
        variable tMultResult    : unsigned(wordSize*2-1 downto 0);
    begin
 
        if IMPL_COMPARISON_SUB=true and comparison_sub_result='0'&X"00000000" then
            comparison_eq                             <= '1';
        else
            comparison_eq                             <= '0';
        end if;
   
        if IMPL_SHIFT=true and shift_count="000000" then
            shift_done                                <= '1';
        else 
            shift_done                                <= '0';
        end if;
   
        -- Needs to happen outside the clock edge
        eqbranch_zero<='0';
        if IMPL_EQBRANCH=true and memBRead=X"00000000" then
            eqbranch_zero                             <= '1';
        end if;
   
        if reset = '1' then
            state                                     <= State_Resync;
            break                                     <= '0';
            sp                                        <= to_unsigned(STACK_ADDR, maxAddrBit)(ADDR_32BIT_RANGE);
            pc                                        <= (others => '0');
            idim_flag                                 <= '0';
            begin_inst                                <= '0';
            memAAddr                                  <= (others => '0');
            memBAddr                                  <= (others => '0');
            memAWriteEnable                           <= '0';
            memBWriteEnable                           <= '0';
            out_mem_writeEnable                       <= '0';
            out_mem_readEnable                        <= '0';
            out_mem_bEnable                           <= '0';
            out_mem_hEnable                           <= '0';
            memAWrite                                 <= (others => '0');
            memBWrite                                 <= (others => '0');
            inInterrupt                               <= '0';
            fetchneeded                               <= '1';
            interrupt_ack                             <= '0';
            interrupt_done                            <= '0';
            if DEBUG_CPU = true then
                debugRec                              <= ZPU_DBG_T_INIT;
                debugCnt                              <= 0;
                debugLoad                             <= '0';
            end if;
    
        elsif (clk'event and clk = '1') then

            if DEBUG_CPU = true then
                debugLoad                             <= '0';
            end if;     

            memAWriteEnable                           <= '0';
            memBWriteEnable                           <= '0';

            -- If the cpu can run, continue with next state.
            --
            if DEBUG_CPU = false or (DEBUG_CPU = true and debugReady = '1') then

                -- This saves ca. 100 LUT's, by explicitly declaring that the
                -- memAWrite can be left at whatever value if memAWriteEnable is
                -- not set.
                memAWrite                                 <= (others => DontCareValue);
                memBWrite                                 <= (others => DontCareValue);
              --out_mem_addr                              <= (others => DontCareValue);
              --mem_write                                 <= (others => DontCareValue);
                spOffset                                  := (others => DontCareValue);
                
                -- We want memAAddr to remain stable since the length of the fetch depends on external RAM.
              --memAAddr                                  <= (others => DontCareValue);
              --memBAddr(ADDR_32BIT_RANGE)            <= (others => DontCareValue);
                
                out_mem_writeEnable                       <= '0';
              --out_mem_bEnable                           <= '0';
              --out_mem_hEnable                           <= '0';
                out_mem_readEnable                        <= '0';
                begin_inst                                <= '0';
              --out_mem_addr                              <= std_logic_vector(memARead(ADDR_BIT_RANGE));
              --mem_write                                 <= std_logic_vector(memBRead);
        
                decodedOpcode                             <= sampledDecodedOpcode;
                opcode                                    <= sampledOpcode;
        
                -- If interrupt is active, we only clear the interrupt state once the PC is reset to the address which was suspended after the
                -- interrupt, this prevents recursive interrupt triggers, desirable in cetain circumstances but not for this current design.
                --
                interrupt_ack                             <= '0';             -- Reset interrupt acknowledge if set, width is 1 clock only.
                interrupt_done                            <= '0';             -- Reset interrupt done if set, width is 1 clock only.
                if inInterrupt = '1' and pc(ADDR_BIT_RANGE) = interrupt_suspended_addr(ADDR_BIT_RANGE) then
                    inInterrupt                           <= '0';             -- no longer in an interrupt
                    interrupt_done                        <= '1';             -- Interrupt service routine complete.
                end if;
                
                -- Handle shift instructions
                IF IMPL_SHIFT=true then
                    if shift_done='0' then
                        if shift_direction='1' then
                            shift_reg                     <= shift_reg(30 downto 0)&"0";    -- Shift left
                        else
                            shift_reg                     <= shift_sign&shift_reg(31 downto 1); -- Shift right
                        end if;
                        shift_count                       <= shift_count-1;
                    end if;
                end if;
        
                -- Pipelining of addition
                add_low                                   <= ("00"&memARead(15 downto 0)) + ("00"&memBRead(15 downto 0));
        
                if IMPL_MULTIPLY=true then
                    tMultResult                           := memARead * memBRead;
                end if;
        
                if IMPL_COMPARISON_SUB=true then
                    comparison_sub_result                 <= unsigned('0'&memBRead)-unsigned('0'&memARead);
                    comparison_sign_mod                   <= memARead(wordSize-1) xor memBRead(wordSize-1);
                end if;
        
                case state is
        
                    when State_Execute =>
                        opcode_saved                                <= opcode;
                        state                                       <= State_Fetch;
                        -- at this point:
                        -- memBRead contains opcode word
                        -- memARead contains top of stack
                        pc                                          <= pc + 1;
            
                        fetchneeded                                 <= '1'; 
                        state                                       <= State_Fetch;
                        if CACHE = true or inrom = '0' then
                            if pc(1 downto 0) /= "11" then -- We fetch four bytes at a time.
                                fetchneeded                         <= '0';
                                state                               <= State_Decode;
                            end if;
                        end if;
            
                        -- during the next cycle we'll be reading the next opcode       
                        spOffset(4)                                 := not opcode(4);
                        spOffset(3 downto 0)                        := unsigned(opcode(3 downto 0));


                        -- Debug code, if enabled, writes out the current instruction.
                        if DEBUG_CPU = true and DEBUG_LEVEL >= 1 then
                            debugRec.FMT_DATA_PRTMODE               <= "00";
                            debugRec.FMT_PRE_SPACE                  <= '0';
                            debugRec.FMT_POST_SPACE                 <= '0';
                            debugRec.FMT_PRE_CR                     <= '1';
                            debugRec.FMT_POST_CRLF                  <= '1';
                            debugRec.FMT_SPLIT_DATA                 <= "00";
                            debugRec.DATA_BYTECNT                   <= std_logic_vector(to_unsigned(0, 3));
                            debugRec.DATA2_BYTECNT                  <= std_logic_vector(to_unsigned(0, 3));
                            debugRec.DATA3_BYTECNT                  <= std_logic_vector(to_unsigned(0, 3));
                            debugRec.DATA4_BYTECNT                  <= std_logic_vector(to_unsigned(0, 3));
                            debugRec.WRITE_DATA                     <= '0';
                            debugRec.WRITE_DATA2                    <= '0';
                            debugRec.WRITE_DATA3                    <= '0';
                            debugRec.WRITE_DATA4                    <= '0';
                            debugRec.WRITE_OPCODE                   <= '1';
                            debugRec.WRITE_DECODED_OPCODE           <= '1';
                            debugRec.WRITE_PC                       <= '1';
                            debugRec.WRITE_SP                       <= '1';
                            debugRec.WRITE_STACK_TOS                <= '1';
                            debugRec.WRITE_STACK_NOS                <= '1';
                            debugRec.DATA(63 downto 0)              <= (others => '0');
                            debugRec.DATA2(63 downto 0)             <= (others => '0');
                            debugRec.DATA3(63 downto 0)             <= (others => '0');
                            debugRec.DATA4(63 downto 0)             <= (others => '0');
                            debugRec.OPCODE                         <= opcode;
                            debugRec.DECODED_OPCODE                 <= std_logic_vector(to_unsigned(DecodedOpcodeType'POS(decodedOpcode), 6));
                            debugRec.PC(ADDR_BIT_RANGE)             <= std_logic_vector(pc);
                            debugRec.SP(ADDR_32BIT_RANGE)           <= std_logic_vector(sp);
                            debugRec.STACK_TOS                      <= std_logic_vector(memARead);
                            debugRec.STACK_NOS                      <= std_logic_vector(memBRead);
                            debugLoad                               <= '1';
                        end if;

                        idim_flag <= '0';
           
                        case decodedOpcode is
               
                            when Decoded_Interrupt =>
                                interrupt_ack                      <= '1';                           -- Acknowledge interrupt.
                                interrupt_suspended_addr           <= pc(ADDR_BIT_RANGE);            -- Save address which got interrupted.
                                sp                                 <= sp - 1;
                                memAAddr                           <= sp - 1;
                                memAWriteEnable                    <= '1';
                                memAWrite                          <= (others => DontCareValue);
                                memAWrite(ADDR_BIT_RANGE)          <= pc;
                
                                pc                                 <= (others => '0');
                                pc(5 downto 0)                     <= to_unsigned(32, 6);            -- interrupt address
                                fetchneeded                        <= '1';                           -- Need to set this any time PC changes.
                                state                              <= State_Fetch;
                                report "ZPU jumped to interrupt!" severity note;
                
                            when Decoded_Im =>
                                idim_flag                          <= '1';
                                memAWriteEnable                    <= '1';
                                if (idim_flag = '0') then
                                    sp                             <= sp - 1;
                                    memAAddr                       <= sp-1;
                                    for i in wordSize-1 downto 7 loop
                                        memAWrite(i)               <= opcode(6);
                                    end loop;
                                    memAWrite(6 downto 0)          <= unsigned(opcode(6 downto 0));
                                    memBAddr                       <= sp;
                                else
                                    memAAddr                       <= sp;
                                    memAWrite(wordSize-1 downto 7) <= memARead(wordSize-8 downto 0);
                                    memAWrite(6 downto 0)          <= unsigned(opcode(6 downto 0));
                                    memBAddr                       <= sp+1;
                                end if;  -- idim_flag
                
                            when Decoded_StoreSP =>
                                memBWriteEnable                    <= '1';
                                memBAddr                           <= sp+spOffset;
                                memBWrite                          <= memARead;
                                sp                                 <= sp + 1;
                                state                              <= State_Resync;
                
                            when Decoded_LoadSP =>
                                sp                                 <= sp - 1;
                                memAAddr                           <= sp+spOffset;
                                state                              <= State_Fetch;
                
                            when Decoded_Emulate =>
                                sp                                 <= sp - 1;
                                memAWriteEnable                    <= '1';
                                memAAddr                           <= sp - 1;
                                memAWrite                          <= (others => DontCareValue);
                                memAWrite(ADDR_BIT_RANGE)          <= pc + 1;
                                -- The emulate address is:
                                --        98 7654 3210
                                -- 0000 00aa aaa0 0000
                                pc                                 <= (others => '0');
                                pc(9 downto 5)                     <= unsigned(opcode(4 downto 0));
                                fetchneeded                        <= '1';                                -- Need to set this any time pc changes.
                                state                              <= State_Fetch;
                
                            when Decoded_AddSP =>
                                memAAddr                           <= sp;
                                memBAddr                           <= sp+spOffset;
                                state                              <= State_AddSP;
                
                            when Decoded_Break =>
                                report "Break instruction encountered" severity failure;
                                break                              <= '1';
                                state                              <= State_Fetch;
                
                            when Decoded_PushSP =>
                                memAWriteEnable                    <= '1';
                                memAAddr                           <= sp - 1;
                                memBAddr                           <= sp;
                                sp                                 <= sp - 1;
                                memAWrite                          <= (others => DontCareValue);
                                memAWrite(ADDR_32BIT_RANGE)        <= sp;
                
                            when Decoded_PopPC =>
                                pc                                 <= memARead(ADDR_BIT_RANGE);
                                fetchneeded                        <= '1'; -- Need to set this any time PC changes.
                                sp                                 <= sp + 1;
                                memAAddr                           <= sp+1;
                                memBAddr                           <= sp+2;
                                state                              <= State_Fetch;
                
                            when Decoded_EqBranch =>
                                if IMPL_EQBRANCH=true then
                                    sp                             <= sp + 1;
                                    if (eqbranch_zero xor opcode(0))='0' then                              -- eqbranch is 55, neqbranch is 56
                                        pc                         <= pc + memARead(ADDR_BIT_RANGE);
                                        fetchneeded                <= '1';                                 -- Need to set this any time PC changes.
                                    end if;
                                    state                          <= State_IncSP;
                                end if;
                                    
                            when Decoded_Comparison =>
                                if IMPL_COMPARISON_SUB=true then
                                    sp                             <= sp + 1;
                                    state                          <= State_Comparison;
                                end if;
                
                            when Decoded_Add =>
                                sp                                 <= sp + 1;
                                state                              <= State_Add;
                
                            when Decoded_Sub =>
                                if IMPL_COMPARISON_SUB=true then
                                    sp                             <= sp + 1;
                                    state                          <= State_Sub;
                                end if;
                
                            when Decoded_Or =>
                                memAAddr                           <= sp+1;
                                memBAddr                           <= sp+2;
                                memAWriteEnable                    <= '1';
                                memAWrite                          <= memARead or memBRead;
                                sp                                 <= sp + 1;
                
                            when Decoded_And =>
                                memAAddr                           <= sp+1;
                                memBAddr                           <= sp+2;
                                memAWriteEnable                    <= '1';
                                memAWrite                          <= memARead and memBRead;
                                sp                                 <= sp + 1;
                
                            when Decoded_Xor =>
                                memAAddr                           <= sp+1;
                                memBAddr                           <= sp+2;
                                memAWriteEnable                    <= '1';
                                memAWrite                          <= memARead xor memBRead;
                                sp                                 <= sp + 1;
                
                            when Decoded_Mult =>
                                sp                                 <= sp + 1;
                                state                              <= State_Mult;
                
                            when Decoded_Load =>
                                if (memARead(ioBit) = '1') then
                                    out_mem_addr(1 downto 0)       <= "00";
                                    out_mem_addr(ADDR_32BIT_RANGE) <= std_logic_vector(memARead(ADDR_32BIT_RANGE));
                                    -- FIXME trigger some kind of alignment exception if memARead(1 downto 0) are not zero
                                    out_mem_readEnable             <= '1';
                                    state                          <= State_ReadIO;
                                else
                                    memAAddr                       <= memARead(ADDR_32BIT_RANGE);
                                    state                          <= State_Fetch;
                                end if;
                                 
                            when Decoded_LoadBH =>
                                out_mem_addr(ADDR_BIT_RANGE)       <= std_logic_vector(memARead(ADDR_BIT_RANGE));
                                out_mem_bEnable                    <= opcode(0); -- Loadb is opcode 51, %00110011
                                out_mem_hEnable                    <= not opcode(0); -- Loadh is opcode 34, %00100010
                                out_mem_readEnable                 <= '1';
                                state                              <= State_ReadIOBH;
                
                            when Decoded_EqNeq =>
                                sp                                 <= sp + 1;
                                state                              <= State_EqNeq;
                
                            when Decoded_Not =>
                                memAAddr                           <= sp;
                                memBAddr                           <= sp+1;
                                memAWriteEnable                    <= '1';
                                memAWrite                          <= not memARead;
                
                            when Decoded_Flip =>
                                memAAddr                           <= sp;
                                memBAddr                           <= sp+1;
                                memAWriteEnable                    <= '1';
                                for i in 0 to wordSize-1 loop
                                    memAWrite(i)                   <= memARead(wordSize-1-i);
                                end loop;
                
                            when Decoded_Store =>
                                memBAddr(ADDR_32BIT_RANGE)         <= sp + 1;
                                sp                                 <= sp + 1;
   
                                if (memARead(ioBit) = '0') then
                                    state                          <= State_Store;
                                else
                                    state                          <= State_WriteIO;
                                end if;
                
                            when Decoded_StoreBH =>
                                memBAddr(ADDR_32BIT_RANGE)         <= sp + 1;
                                sp                                 <= sp + 1;
                                state                              <= State_WriteIOBH;
                
                            when Decoded_PopSP =>
                                sp                                 <= memARead(ADDR_32BIT_RANGE);
                                state                              <= State_Resync;
                
                            when Decoded_Call =>
                                if IMPL_CALL=true then
                                    pc                             <= memARead(ADDR_BIT_RANGE);        -- Set PC to value on top of stack
                                    fetchneeded                    <= '1';                             -- Need to set this any time PC changes.
                
                                    memAWriteEnable                <= '1';
                                    memAAddr                       <= sp;                              -- Replace stack top with PC+1
                                    memAWrite                      <= (others => DontCareValue);
                                    memAWrite(ADDR_BIT_RANGE)      <= pc + 1;
                                    state                          <= State_Fetch;
                                end if;
                
                            when Decoded_Shift =>
                                IF IMPL_SHIFT=true then
                                    sp                             <= sp + 1;
                                    shift_count                    <= unsigned(memARead(5 downto 0));  -- 6 bit distance
                                    shift_reg                      <= memBRead;                        -- 32-bit value
                                    shift_direction                <= opcode(0);                       -- 1 for left, (Opcode 43 for Ashiftleft)
                                    shift_sign                     <= memBRead(31) and opcode(2);      -- 1 for arithmetic, (opcode 44 for Ashiftright, 42 for lshiftright)
                                    state                          <= State_Shift;
                                end if;
                
                            when Decoded_Nop =>
                                memAAddr                           <= sp;
                                state                              <= State_Fetch;
                
                            when others =>
                                null;
                
                        end case;  -- decodedOpcode
            
                    -- From this point on opcode is not guaranteed to be valid if using BlockRAM.
            
                    when State_ReadIO =>
                        memAAddr                                    <= sp;
                        if (in_mem_busy = '0') then
                            state                                   <= State_Fetch;
                            memAWriteEnable                         <= '1';
                            memAWrite                               <= unsigned(mem_read);
                        end if;
                        if CACHE=false then
                            fetchneeded                             <= '1'; -- Need to set this any time out_mem_addr changes.
                        end if;
            
                    when State_ReadIOBH =>
                        if IMPL_LOADBH=true then
                            out_mem_bEnable                         <= opcode_saved(0); -- Loadb is opcode 51, %00110011
                            out_mem_hEnable                         <= not opcode_saved(0); -- Loadh is copde 34, %00100010
                            if in_mem_busy = '0' then
                                memAAddr                            <= sp;
            --                  memAWrite(31 downto 16)<=(others =>'0');
                                memAWrite(31 downto 8)              <= (others =>'0');
            --                  if opcode_saved(0)='1' then -- byte read; upper 24 bits should be zeroed
            --                      if memARead(0)='1' then -- odd address
            --                          memAWrite(7 downto 0) <= unsigned(mem_read(7 downto 0));
            --                      else
            --                          memAWrite(7 downto 0) <= unsigned(mem_read(15 downto 8));
            --                      end if;
            --                  else    -- short read; upper word should be zeroed.
                                if opcode_saved(0)='0' then -- only write the top 8 bits for halfword reads
                                    memAWrite(15 downto 8)          <= unsigned(mem_read(15 downto 8));
                                end if;
                                memAWrite(7 downto 0)               <= unsigned(mem_read(7 downto 0));
            --                  end if;
                                state                               <= State_Fetch;
                                memAWriteEnable                     <= '1';
                                out_mem_bEnable                     <= '0';
                                out_mem_hEnable                     <= '0';
                            end if;
                            if CACHE=false then
                                fetchneeded                         <= '1'; -- Need to set this any time out_mem_addr changes.
                            end if;
                        end if;
            
                    when State_WriteIO =>
            --          mem_writeMask                     <= (others => '1');
                        sp                                          <= sp + 1;
                        out_mem_writeEnable                         <= '1';
                        out_mem_addr(1 downto 0)                    <= "00";
                        out_mem_addr(ADDR_BIT_RANGE)                <= std_logic_vector(memARead(ADDR_BIT_RANGE));
                        -- FIXME - trigger and alignment exception if memARead(1 downto 0) are not zero.
                        mem_write                                   <= std_logic_vector(memBRead);
                        state                                       <= State_WriteIODone;
                        if CACHE=false then
                            fetchneeded                             <= '1'; -- Need to set this any time out_mem_addr changes.
                        end if;
                                                -- (actually, only necessary for writes if mem_read doesn't hold its contents)
            
                    when State_WriteIOBH =>
                        if IMPL_STOREBH=true then
            --              mem_writeMask <= (others => '1');
                            sp                                      <= sp + 1;
                            out_mem_writeEnable                     <= '1';
                            out_mem_bEnable                         <= not opcode_saved(0); -- storeb is opcode 52
                            out_mem_hEnable                         <= opcode_saved(0); -- storeh is opcode 35
                            out_mem_addr                            <= std_logic_vector(memARead(ADDR_BIT_RANGE));
                            mem_write                               <= std_logic_vector(memBRead);
                            state                                   <= State_WriteIODone;
                            if CACHE=false then
                                fetchneeded                         <= '1'; -- Need to set this any time out_mem_addr changes.
                            end if;
                                                        -- (actually, only necessary for writes if mem_read doesn't hold its contents)
                        end if;
            
                    when State_WriteIODone =>
                        if (in_mem_busy = '0') then
                            state                                   <= State_Resync;
                            out_mem_bEnable                         <= '0';
                            out_mem_hEnable                         <= '0';
                        end if;
            
                    when State_Fetch =>
                        -- We need to resync. During the *next* cycle
                        -- we'll fetch the opcode @ pc and thus it will
                        -- be available for State_Execute the cycle after
                        -- next
                        memBAddr                                    <= pc(ADDR_32BIT_RANGE);
                        state                                       <= State_FetchNext;
            
                    when State_FetchNext =>
                        -- at this point memARead contains the value that is either
                        -- from the top of stack or should be copied to the top of the stack
                        if in_mem_busy='0' or fetchneeded='0' or inrom='1' then
                            memAWriteEnable                         <= '1';
                            memAWrite                               <= memARead;
                            memAAddr                                <= sp;
                            memBAddr                                <= sp + 1;
                            state                                   <= State_Decode;

                            -- If debug enabled, write out state during fetch.
                            if DEBUG_CPU = true and DEBUG_LEVEL >= 2 then
                                debugRec.FMT_DATA_PRTMODE           <= "00";
                                debugRec.FMT_PRE_SPACE              <= '0';
                                debugRec.FMT_POST_SPACE             <= '0';
                                debugRec.FMT_PRE_CR                 <= '1';
                                debugRec.FMT_POST_CRLF              <= '1';
                                debugRec.FMT_SPLIT_DATA             <= "00";
                                debugRec.DATA_BYTECNT               <= std_logic_vector(to_unsigned(4, 3));
                                debugRec.DATA2_BYTECNT              <= std_logic_vector(to_unsigned(0, 3));
                                debugRec.DATA3_BYTECNT              <= std_logic_vector(to_unsigned(0, 3));
                                debugRec.DATA4_BYTECNT              <= std_logic_vector(to_unsigned(0, 3));
                                debugRec.WRITE_DATA                 <= '1';
                                debugRec.WRITE_DATA2                <= '0';
                                debugRec.WRITE_DATA3                <= '0';
                                debugRec.WRITE_DATA4                <= '0';
                                debugRec.WRITE_OPCODE               <= '0';
                                debugRec.WRITE_DECODED_OPCODE       <= '0';
                                debugRec.WRITE_PC                   <= '1';
                                debugRec.WRITE_SP                   <= '1';
                                debugRec.WRITE_STACK_TOS            <= '1';
                                debugRec.WRITE_STACK_NOS            <= '1';
                                debugRec.DATA(63 downto 0)          <= X"4645544348000000";
                                debugRec.DATA2(63 downto 0)         <= (others => '0');
                                debugRec.DATA3(63 downto 0)         <= (others => '0');
                                debugRec.DATA4(63 downto 0)         <= (others => '0');
                                debugRec.OPCODE                     <= (others => '0');
                                debugRec.DECODED_OPCODE             <= (others => '0');
                                debugRec.PC(ADDR_BIT_RANGE)         <= std_logic_vector(pc);
                                debugRec.SP(ADDR_32BIT_RANGE)       <= std_logic_vector(sp);
                                debugRec.STACK_TOS                  <= std_logic_vector(memARead);
                                debugRec.STACK_NOS                  <= std_logic_vector(memBRead);
                                debugLoad                           <= '1';
                            end if;          
                        end if;
            
                    when State_StoreAndDecode =>
                        if interrupt_request = '1' and inInterrupt = '0' and idim_flag = '0' then
                            -- We got an interrupt, execute interrupt instead of next instruction
                            inInterrupt                             <= '1';
                            decodedOpcode                           <= Decoded_Interrupt;
                        end if;
                        memAWriteEnable                             <= '1';
                        memAWrite                                   <= memARead;
                        memAAddr                                    <= sp;
                        memBAddr                                    <= sp + 1;
                        state                                       <= State_Decode;
                         
                    when State_Decode =>
                        if interrupt_request = '1' and inInterrupt = '0' and idim_flag = '0' then
                            -- We got an interrupt, execute interrupt instead of next instruction
                            inInterrupt                             <= '1';
                            decodedOpcode                           <= Decoded_Interrupt;
                        end if;
                        -- during the State_Execute cycle we'll be fetching SP+1  (AMR - already done at FetchNext, yes?)
                        memAAddr                                    <= sp;
                        memBAddr                                    <= sp + 1;
                        if fetchneeded='1' then
                            cachedprogramword                       <= programword;
                            fetchneeded                             <= '0';
                        end if;
                        state                                       <= State_Execute;
            
                    when State_Store =>
                        sp                                          <= sp + 1;
                        memAWriteEnable                             <= '1';
                        memAAddr(ADDR_32BIT_RANGE)                  <= memARead(ADDR_32BIT_RANGE);
                        memAWrite                                   <= memBRead;
                        state                                       <= State_Resync;
            
                    when State_AddSP =>
                        state                                       <= State_AddSP2;
            
                    when State_AddSP2 =>
                        state                                       <= State_Add;
            
                    when State_Add =>
                        memAAddr                                    <= sp;
                        memBAddr                                    <= sp+1;
                        memAWriteEnable                             <= '1';
                        memAWrite(31 downto 16)                     <= memARead(31 downto 16)+memBRead(31 downto 16)+add_low(17 downto 16);
                        memAWrite(15 downto 0)                      <= add_low(15 downto 0);
                        state<=State_Decode;
                        if fetchneeded = '1' then
                            state                                   <= State_Fetch;
                        end if;
            
                    when State_Sub =>
                        memAAddr                                    <= sp;
                        memBAddr                                    <= sp+1;
                        memAWriteEnable                             <= '1';
                        memAWrite                                   <= comparison_sub_result(wordSize-1 downto 0);
                        state                                       <= State_Decode;
                        if fetchneeded = '1' then
                            state <= State_Fetch;
                        end if;
            
                    when State_Mult =>
                        memAAddr                                    <= sp;
                        memBAddr                                    <= sp+1;
                        memAWriteEnable                             <= '1';
                        memAWrite                                   <= tMultResult(wordSize-1 downto 0);
                        state                                       <= State_Decode;
                        if fetchneeded = '1' then
                            state                                   <= State_Fetch;
                        end if;
            
                    when State_IncSP =>
                        sp                                          <= sp+1;
                        state                                       <= State_Resync;
            
                    when State_Resync =>
                        memAAddr                                    <= sp;
                        memBAddr                                    <= sp+1;
                        state                                       <= State_Decode;
                        if fetchneeded = '1' then
                            state                                   <= State_Fetch;
                        end if;
            
                    when State_EqNeq =>
                        memAAddr                                    <= sp;
                        memBAddr                                    <= sp+1;
                        memAWriteEnable                             <= '1';
                        memAWrite                                   <= (others =>'0');
                        memAWrite(0)                                <= comparison_eq xor opcode_saved(4); -- eq is 46, neq is 48.
                        state                                       <= State_Decode;
                        if fetchneeded = '1' then
                            state                                   <= State_Fetch;
                        end if;
                            
                    when State_Comparison =>
                        memAAddr                                    <= sp;
                        memBAddr                                    <= sp+1;
                        memAWriteEnable                             <= '1';
                        memAWrite                                   <= (others => '0');
                        -- ulessthan: opcode 38, ulessthanorequal, 39
                        if opcode_saved(1) = '1' then
                            memAWrite(0)                            <= not (comparison_sub_result(wordSize) or (not opcode_saved(0) and comparison_eq));
                        else    -- Signed comparison, lt: 36, ult: 37
                            memAWrite(0)                            <= not ((comparison_sub_result(wordSize) xor comparison_sign_mod) or (not opcode_saved(0) and comparison_eq));
                        end if;
                        state                                       <= State_Decode;
                        if fetchneeded = '1' then
                            state                                   <= State_Fetch;
                        end if;
            
                    when State_Shift =>
                        if shift_done='1' then
                            memAAddr                                <= sp;
                            memBAddr                                <= sp+1;
                            memAWriteEnable                         <= '1';
                            memAWrite                               <= shift_reg;
                            state                                   <= State_Decode;
                            if fetchneeded = '1' then
                                state                               <= State_Fetch;
                            end if;
                        end if;

                     when State_Debug =>
                        case debugState is
                            when Debug_Start =>
    
                                -- Write out the primary data.
                                if DEBUG_CPU = true then
                                    debugRec.FMT_DATA_PRTMODE       <= "00";
                                    debugRec.FMT_PRE_SPACE          <= '0';
                                    debugRec.FMT_POST_SPACE         <= '0';
                                    debugRec.FMT_PRE_CR             <= '1';
                                    debugRec.FMT_POST_CRLF          <= '0';
                                    debugRec.FMT_SPLIT_DATA         <= "00";
                                    debugRec.DATA_BYTECNT           <= std_logic_vector(to_unsigned(0, 3));
                                    debugRec.DATA2_BYTECNT          <= std_logic_vector(to_unsigned(0, 3));
                                    debugRec.DATA3_BYTECNT          <= std_logic_vector(to_unsigned(0, 3));
                                    debugRec.DATA4_BYTECNT          <= std_logic_vector(to_unsigned(0, 3));
                                    debugRec.WRITE_DATA             <= '0';
                                    debugRec.WRITE_DATA2            <= '0';
                                    debugRec.WRITE_DATA3            <= '0';
                                    debugRec.WRITE_DATA4            <= '0';
                                    debugRec.WRITE_OPCODE           <= '0';
                                    debugRec.WRITE_DECODED_OPCODE   <= '0';
                                    debugRec.WRITE_PC               <= '1';
                                    debugRec.WRITE_SP               <= '1';
                                    debugRec.WRITE_STACK_TOS        <= '1';
                                    debugRec.WRITE_STACK_NOS        <= '1';
                                    debugRec.DATA(63 downto 0)      <= (others => '0');
                                    debugRec.DATA2(63 downto 0)     <= (others => '0');
                                    debugRec.DATA3(63 downto 0)     <= (others => '0');
                                    debugRec.DATA4(63 downto 0)     <= (others => '0');
                                    debugRec.OPCODE                 <= (others => '0');
                                    debugRec.DECODED_OPCODE         <= (others => '0');
                                    debugRec.PC(ADDR_BIT_RANGE)     <= std_logic_vector(pc);
                                    debugRec.SP(ADDR_32BIT_RANGE)   <= std_logic_vector(sp);
                                    debugRec.STACK_TOS              <= std_logic_vector(memARead);
                                    debugRec.STACK_NOS              <= std_logic_vector(memBRead);
                                    debugLoad                       <= '1';
                                    debugCnt                        <= 0;
                                    debugState                      <= Debug_DumpFifo;
                                end if;
    
                            when Debug_DumpFifo =>
                                -- Write out the opcode.
                                if DEBUG_CPU = true then
                                    debugRec.FMT_DATA_PRTMODE       <= "00";
                                    debugRec.FMT_PRE_SPACE          <= '0';
                                    debugRec.FMT_POST_SPACE         <= '1';
                                    debugRec.FMT_PRE_CR             <= '0';
                                    if debugCnt = 3 then
                                        debugRec.FMT_POST_CRLF      <= '1';
                                    else
                                        debugRec.FMT_POST_CRLF      <= '0';
                                    end if;
                                    debugRec.FMT_SPLIT_DATA         <= "00";
                                    debugRec.DATA_BYTECNT           <= std_logic_vector(to_unsigned(0, 3));
                                    debugRec.DATA2_BYTECNT          <= std_logic_vector(to_unsigned(0, 3));
                                    debugRec.DATA3_BYTECNT          <= std_logic_vector(to_unsigned(0, 3));
                                    debugRec.DATA4_BYTECNT          <= std_logic_vector(to_unsigned(0, 3));
                                    debugRec.WRITE_DATA             <= '0';
                                    debugRec.WRITE_DATA2            <= '0';
                                    debugRec.WRITE_DATA3            <= '0';
                                    debugRec.WRITE_DATA4            <= '0';
                                    debugRec.WRITE_OPCODE           <= '1';
                                    debugRec.WRITE_DECODED_OPCODE   <= '1';
                                    debugRec.WRITE_PC               <= '0';
                                    debugRec.WRITE_SP               <= '0';
                                    debugRec.WRITE_STACK_TOS        <= '0';
                                    debugRec.WRITE_STACK_NOS        <= '0';
                                    debugRec.DATA(63 downto 0)      <= (others => '0');
                                    debugRec.DATA2(63 downto 0)     <= (others => '0');
                                    debugRec.DATA3(63 downto 0)     <= (others => '0');
                                    debugRec.DATA4(63 downto 0)     <= (others => '0');
                                    debugRec.OPCODE                 <= opcode;
                                    debugRec.DECODED_OPCODE         <= std_logic_vector(to_unsigned(DecodedOpcodeType'POS(decodedOpcode), 6));
                                    debugRec.PC(ADDR_BIT_RANGE)     <= (others => '0');
                                    debugRec.SP(ADDR_32BIT_RANGE)   <= std_logic_vector(sp);
                                    debugRec.STACK_TOS              <= (others => '0');
                                    debugRec.STACK_NOS              <= (others => '0');
                                    debugLoad                       <= '1';
                                    debugCnt                        <= 0;
                                    debugState                      <= Debug_DumpFifo_1;
                                end if;
    
                            when Debug_DumpFifo_1 =>
                                -- Move onto next opcode in Fifo.
                                debugCnt                            <= debugCnt + 1;
                                if debugCnt = 3 then
                                    debugState                      <= Debug_End;
                                else
                                    debugState                      <= Debug_DumpFifo;
                                end if;
    
                            when Debug_End =>
                                state                               <= State_Execute;
                        end case;
            
                    when others =>
                        null;
            
                end case;  -- state
            end if; -- Debug
        end if;  -- reset, enable
    end process;

    -----------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Debugger output processor.
    -- This logic takes a debug record and expands it to human readable form then dispatches it to the debug serial port.
    -----------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Add debug uart if required. Increasing the TX and DBG Fifo depth can help short term (ie. initial start of the CPU)
    -- but once full, the debug run will eventually operate at the slowest denominator, ie. the TX speed and how quick it can
    -- shift 10 bits.
    DEBUG : if DEBUG_CPU = true generate
        DEBUGUART: entity work.zpu_uart_debug
            generic map (
                CLK_FREQ                 => CLK_FREQ                         -- Frequency of master clock.
            )
            port map (
                -- CPU Interface
                CLK                      => clk,                             -- master clock
                RESET                    => reset,                           -- high active sync reset
                DEBUG_DATA               => debugRec,                        -- write data
                CS                       => debugLoad,                       -- Chip Select.
                READY                    => debugReady,                      -- Debug processor ready for next command.
    
                -- Serial data
                TXD                      => debug_txd
            );
    end generate;
    -----------------------------------------------------------------------------------------------------------------------------------------------------------
    -- End of debugger output processor.
    -----------------------------------------------------------------------------------------------------------------------------------------------------------

end behave;