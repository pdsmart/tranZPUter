-- ZPU
--
-- Copyright 2004-2008 oharboe - �yvind Harboe - oyvind.harboe@zylin.com
-- Copyright 2008 alvieboy - �lvaro Lopes - alvieboy@alvie.com
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.zpu_pkg.all;


-- mem_writeEnable - set to '1' for a single cycle to send off a write request.
--                   mem_write is valid only while mem_writeEnable='1'.
-- mem_readEnable - set to '1' for a single cycle to send off a read request.
-- 
-- mem_busy - It is illegal to send off a read/write request when mem_busy='1'.
--            Set to '0' when mem_read  is valid after a read request.
--            If it goes to '1'(busy), it is on the cycle after mem_read/writeEnable
--            is '1'.
-- mem_addr - address for read/write request
-- mem_read - read data. Valid only on the cycle after mem_busy='0' after 
--            mem_readEnable='1' for a single cycle.
-- mem_write - data to write
-- mem_writeMask - set to '1' for those bits that are to be written to memory upon
--                 write request
-- break - set to '1' when CPU hits break instruction
-- interrupt - set to '1' until interrupts are cleared by CPU. 
 
entity zpu_core_medium is
    generic (
        CLK_FREQ                  : integer := 100000000;   -- Frequency of the input clock.            
        STACK_ADDR                : integer := 0            -- Initial stack address on CPU start.        
    );
    port (
        clk                       : in  std_logic;
        areset                    : in  std_logic;
        enable                    : in  std_logic; 
        in_mem_busy               : in  std_logic; 
        mem_read                  : in  std_logic_vector(WORD_32BIT_RANGE);
        mem_write                 : out std_logic_vector(WORD_32BIT_RANGE);
        out_mem_addr              : out std_logic_vector(ADDR_BIT_RANGE);
        out_mem_writeEnable       : out std_logic; 
        out_mem_bEnable           : out std_logic;  -- Enable byte write
        out_mem_hEnable           : out std_logic;  -- Enable halfword write
        out_mem_readEnable        : out std_logic;
        mem_writeMask             : out std_logic_vector(WORD_4BYTE_RANGE);
        -- Set to one to jump to interrupt vector
        -- The ZPU will communicate with the hardware that caused the
        -- interrupt via memory mapped IO or the interrupt flag can
        -- be cleared automatically
        interrupt_request         : in  std_logic;
        interrupt_ack             : out std_logic; -- Interrupt acknowledge, ZPU has entered Interrupt Service Routine.
        interrupt_done            : out std_logic; -- Interrupt service routine completed/done.
        break                     : out std_logic;
        debug_txd                 : out std_logic  -- Debug serial output.
    );
end zpu_core_medium;

architecture behave of zpu_core_medium is

    type InsnType is 
    (
        State_Add,                      -- 00
        State_AddSP,                    -- 01
        State_AddTop,                   -- 02
        State_Alshift,                  -- 03
        State_And,                      -- 04
        State_Break,                    -- 05
        State_Call,                     -- 06
        State_Callpcrel,                -- 07
--      State_Div,                      
        State_Dup,                      -- 08
        State_DupStackB,                -- 09
        State_Emulate,                  -- 0a
        State_Eq,                       -- 0b
        State_Flip,                     -- 0c
        State_Im,                       -- 0d
        State_Lessthan,                 -- 0e
        State_Lessthanorequal,          -- 0f
        State_Load,                     -- 10
        State_Loadb,                    -- 11
        State_Loadh,                    -- 12
        State_LoadSP,                   -- 13
--      State_Mod,
        State_Mult,                     -- 14
        State_Neq,                      -- 15
        State_Neqbranch,                -- 16
        State_Nop,                      -- 17
        State_Not,                      -- 18
        State_Or,                       -- 19
        State_Pop,                      -- 1a
        State_PopDown,                  -- 1b
        State_PopPC,                    -- 1c
        State_PopPCRel,                 -- 1d
        State_PopSP,                    -- 1e
--      State_PushPC,
        State_PushSP,                   -- 1f
        State_Pushspadd,                -- 20
        State_Shift,                    -- 21
        State_Store,                    -- 22
        State_Storeb,                   -- 23
        State_Storeh,                   -- 24
        State_StoreSP,                  -- 25
        State_Sub,                      -- 26
        State_Ulessthan,                -- 27
        State_Ulessthanorequal,         -- 28
        State_Xor,                      -- 29
        State_InsnFetch
    );
    
    type StateType is 
    (
        State_Load2,
        State_Popped,
        State_LoadSP2,
        State_LoadSP3,
        State_AddSP2,
        State_Fetch,
        State_Execute,
        State_Decode,
        State_Decode2,
        State_Resync,
        
        State_StoreSP2,
        State_Resync2,
        State_Resync3,
        State_Loadb2,
        State_Storeb2,
        State_Mult2,
        State_Mult3,
        State_Mult5,
        State_Mult4,
        State_BinaryOpResult2,
        State_BinaryOpResult,
        State_Idle,
        State_Interrupt,
        State_Debug
    ); 
    --
    type DebugType is 
    (
        Debug_Start,
        Debug_DumpFifo,
        Debug_DumpFifo_1,
        Debug_End
    );
    
    signal pc                              : unsigned(ADDR_BIT_RANGE);
    signal sp                              : unsigned(ADDR_32BIT_RANGE);
    signal interrupt_suspended_addr        : unsigned(ADDR_BIT_RANGE);
    signal incSp                           : unsigned(ADDR_32BIT_RANGE);
    signal incIncSp                        : unsigned(ADDR_32BIT_RANGE);
    signal decSp                           : unsigned(ADDR_32BIT_RANGE);
    signal stackA                          : unsigned(WORD_32BIT_RANGE);
    signal binaryOpResult                  : unsigned(WORD_32BIT_RANGE);
    signal binaryOpResult2                 : unsigned(WORD_32BIT_RANGE);
    signal multResult2                     : unsigned(WORD_32BIT_RANGE);
    signal multResult3                     : unsigned(WORD_32BIT_RANGE);
    signal multResult                      : unsigned(WORD_32BIT_RANGE);
    signal multA                           : unsigned(WORD_32BIT_RANGE);
    signal multB                           : unsigned(WORD_32BIT_RANGE);
    signal stackB                          : unsigned(WORD_32BIT_RANGE);
    signal idim_flag                       : std_logic;
    signal busy                            : std_logic;
    signal mem_writeEnable                 : std_logic; 
    signal mem_readEnable                  : std_logic;
    signal mem_addr                        : std_logic_vector(ADDR_32BIT_RANGE);
    signal mem_delayAddr                   : std_logic_vector(ADDR_32BIT_RANGE);
    signal mem_delayReadEnable             : std_logic;
    
    signal inInterrupt                     : std_logic;
    
    signal decodeWord                      : std_logic_vector(WORD_32BIT_RANGE);
    
    
    signal state                           : StateType;
    signal debugState                      : DebugType;
    signal debugCnt                        : integer;
    signal debugRec                        : zpu_dbg_t;
    signal debugLoad                       : std_logic;
    signal debugReady                      : std_logic;
    signal insn                            : InsnType;
    type InsnArray is array(0 to wordBytes-1) of InsnType;
    signal decodedOpcode                   : InsnArray;
    
    type OpcodeArray is array(0 to wordBytes-1) of std_logic_vector(7 downto 0);
    
    signal opcode                          : OpcodeArray;
    
    signal begin_inst                      : std_logic;
    signal trace_opcode                    : std_logic_vector(7 downto 0);
    signal trace_pc                        : std_logic_vector(ADDR_BIT_RANGE);
    signal trace_sp                        : std_logic_vector(ADDR_32BIT_RANGE);
    signal trace_topOfStack                : std_logic_vector(WORD_32BIT_RANGE);
    signal trace_topOfStackB               : std_logic_vector(WORD_32BIT_RANGE);

    signal clkDivider                      : unsigned(31 downto 0);
    
begin


--   traceFileGenerate:
--   if Generate_Trace generate
--    trace_file: trace port map (
--           clk => clk,
--           begin_inst => begin_inst,
--           pc => trace_pc,
--        opcode => trace_opcode,
--        sp => trace_sp,
--        memA => trace_topOfStack,
--        memB => trace_topOfStackB,
--        busy => busy,
--        intsp => (others => 'U')
--        );
--    end generate;

    -- Not yet implemented.
    out_mem_bEnable                        <= '0';  -- Enable byte write
    out_mem_hEnable                        <= '0';  -- Enable halfword write
    
    -- the memory subsystem will tell us one cycle later whether or 
    -- not it is busy
    out_mem_writeEnable                    <= mem_writeEnable;
    out_mem_readEnable                     <= mem_readEnable;
    out_mem_addr(ADDR_32BIT_RANGE)         <= mem_addr;
    out_mem_addr(minAddrBit-1 downto 0)    <= (others => '0');
    
    incSp                                  <= sp + 1;
    incIncSp                               <= sp + 2;
    decSp                                  <= sp - 1;

    multiPipe: process(clk, areset)
        variable tMultResult      : unsigned(wordSize*2-1 downto 0);
    begin
        if areset = '1' then
            tMultResult := (others => '0');
        elsif (clk'event and clk = '1') then
            -- we must multiply unconditionally to get pipelined multiplication
            tMultResult                    := multA * multB;
            multResult3                    <= multResult2;
            multResult2                    <= multResult;
            multResult                     <= tMultResult(wordSize-1 downto 0);
        end if;
    end process;
            

    opcodeControl: process(clk, areset)
        variable tOpcode                   : std_logic_vector(OpCode_Size-1 downto 0);
        variable spOffset                  : unsigned(4 downto 0);
        variable tSpOffset                 : unsigned(4 downto 0);
        variable nextPC                    : unsigned(ADDR_BIT_RANGE);
        variable tNextState                : InsnType;
        variable tDecodedOpcode            : InsnArray;
        variable tCPURun                   : std_logic;        
     --   variable tMultResult      : unsigned(wordSize*2-1 downto 0);
    begin
        if areset = '1' then
            state                          <= State_Idle;
            break                          <= '0';
            tCPURun                        := '1';
            sp                             <= to_unsigned(STACK_ADDR, maxAddrBit)(ADDR_32BIT_RANGE);
            pc                             <= (others => '0');
            idim_flag                      <= '0';
            begin_inst                     <= '0';
            inInterrupt                    <= '0';
            mem_writeEnable                <= '0'; 
            mem_readEnable                 <= '0';
            multA                          <= (others => '0');
            multB                          <= (others => '0');
            mem_writeMask                  <= (others => '1');
            interrupt_ack                  <= '0';
            interrupt_done                 <= '0';
            clkDivider                     <= (others => '0');
            if DEBUG_CPU = true then
                debugRec                   <= ZPU_DBG_T_INIT;
                debugCnt                   <= 0;
                debugLoad                  <= '0';
            end if;

        elsif (clk'event and clk = '1') then
            -- we must multiply unconditionally to get pipelined multiplication
       --     tMultResult                    := multA * multB;
       --     multResult3                    <= multResult2;
       --     multResult2                    <= multResult;
       --     multResult                     <= tMultResult(wordSize-1 downto 0);
            
            binaryOpResult2                <= binaryOpResult; -- pipeline a bit.

            multA                          <= (others => DontCareValue);
            multB                          <= (others => DontCareValue);
            
         --   mem_addr                       <= (others => DontCareValue);
            mem_readEnable                 <='0';
            mem_writeEnable                <='0';
          --  mem_write                      <= (others => DontCareValue);

            if DEBUG_CPU = true then
                debugLoad                  <= '0';
            end if;

            if (mem_writeEnable = '1') and (mem_readEnable = '1') then
                report "read/write collision" severity failure;
            end if;

            
            -- At the moment, the main state machine wont run at full (100MHz) speed, only 1/2 speed, hence the divider.
            -- Once the delay causing it to fail is removed, freq reduced or re-engineered, remove this divider.
            clkDivider                     <= clkDivider + 1;
            if clkDivider(4) = '1' then
                clkDivider                 <= (others => '0');
                if DEBUG_CPU = false or (DEBUG_CPU = true and debugReady = '1') then
                    tCPURun                := '1';
                end if;
            else
                tCPURun                    := '0';
            end if;

            spOffset(4)                    := not opcode(to_integer(pc(byteBits-1 downto 0)))(4);
            spOffset(3 downto 0)           := unsigned(opcode(to_integer(pc(byteBits-1 downto 0)))(3 downto 0));
            nextPC                         := pc + 1;

            -- prepare trace snapshot
            trace_opcode                   <= opcode(to_integer(pc(byteBits-1 downto 0)));
            trace_pc                       <= std_logic_vector(pc);
            trace_sp                       <= std_logic_vector(sp);
            trace_topOfStack               <= std_logic_vector(stackA);
            trace_topOfStackB              <= std_logic_vector(stackB);
            begin_inst                     <= '0';

            -- If interrupt is active, we only clear the interrupt state once the PC is reset to the address which was suspended after the
            -- interrupt, this prevents recursive interrupt triggers, desirable in cetain circumstances but not for this current design.
            --
            interrupt_ack                  <= '0';             -- Reset interrupt acknowledge if set, width is 1 clock only.
            interrupt_done                 <= '0';             -- Reset interrupt done if set, width is 1 clock only.
            if inInterrupt = '1' and pc(ADDR_BIT_RANGE) = interrupt_suspended_addr(ADDR_BIT_RANGE) then
                inInterrupt                <= '0';             -- no longer in an interrupt
                interrupt_done             <= '1';             -- Interrupt service routine complete.
            end if;

            -- If the cpu can run, continue with next state.
            --
            if tCPURun = '1' then            
                case state is
                    when State_Idle =>
                        if enable = '1' then
                            state                         <= State_Resync; 
                        end if;
                    -- Initial state of ZPU, fetch top of stack + first instruction 
                    when State_Resync =>
                        if in_mem_busy = '0' then
                            mem_addr                      <= std_logic_vector(sp);
                            mem_readEnable                <= '1';
                            state                         <= State_Resync2;
                        end if;
                    when State_Resync2 =>
                        if in_mem_busy = '0' then
                            stackA                        <= unsigned(mem_read);
                            mem_addr                      <= std_logic_vector(incSp);
                            mem_readEnable                <= '1';
                            state                         <= State_Resync3;
    
                             -- If debug enabled, write out state during resync.
                          --if DEBUG_CPU = true then
                          --    debugRec.FMT_DATA_PRTMODE     <= "00";
                          --    debugRec.FMT_PRE_SPACE        <= '0';
                          --    debugRec.FMT_POST_SPACE       <= '0';
                          --    debugRec.FMT_PRE_CR           <= '1';
                          --    debugRec.FMT_POST_CRLF        <= '1';
                          --    debugRec.FMT_SPLIT_DATA       <= "00";
                          --    debugRec.DATA_BYTECNT         <= std_logic_vector(to_unsigned(5, 3));
                          --    debugRec.WRITE_DATA           <= '1';
                          --    debugRec.WRITE_OPCODE         <= '0';
                          --    debugRec.WRITE_DECODED_OPCODE <= '0';
                          --    debugRec.WRITE_PC             <= '1';
                          --    debugRec.WRITE_SP             <= '1';
                          --    debugRec.WRITE_STACK_TOS      <= '1';
                          --    debugRec.WRITE_STACK_NOS      <= '1';
                          --    debugRec.DATA                 <= X"524553594E430000";
                          --    debugRec.PC(ADDR_BIT_RANGE)   <= std_logic_vector(pc);
                          --    debugRec.SP(ADDR_32BIT_RANGE) <= std_logic_vector(sp);
                          --    debugRec.STACK_TOS            <= std_logic_vector(stackA);
                          --    debugRec.STACK_NOS            <= std_logic_vector(stackB);
                          --    debugLoad                     <= '1';
                          --end if;                       
                        end if;
                    when State_Resync3 =>
                        if in_mem_busy = '0' then
                            stackB                        <= unsigned(mem_read);
                            mem_addr                      <= std_logic_vector(pc(ADDR_32BIT_RANGE));
                            mem_readEnable                <= '1';
                            state                         <= State_Decode;
                        end if;
                    when State_Decode =>
                        if in_mem_busy = '0' then
                            decodeWord                    <= mem_read;
                            state                         <= State_Decode2;
                            -- Do not recurse into ISR while interrupt line is active
                            if interrupt_request = '1' and inInterrupt = '0' and idim_flag = '0' then
                                -- We got an interrupt, execute interrupt instead of next instruction
                                inInterrupt               <= '1';
                                interrupt_ack             <= '1';                           -- Acknowledge interrupt.
                                interrupt_suspended_addr  <= pc(ADDR_BIT_RANGE);            -- Save address which got interrupted.
                                sp                        <= decSp;
                                mem_writeEnable           <= '1';
                                mem_addr                  <= std_logic_vector(incSp);
                                mem_write                 <= std_logic_vector(stackB);
                                stackA                    <= (others => DontCareValue);
                                stackA(ADDR_BIT_RANGE)    <= pc;
                                stackB                    <= stackA;
                                pc                        <= to_unsigned(32, maxAddrBit);
                                state                     <= State_Interrupt;
                            end if;
                        end if;
                    when State_Interrupt =>
                        if in_mem_busy = '0' then
                            mem_addr                      <= std_logic_vector(pc(ADDR_32BIT_RANGE));
                            mem_readEnable                <= '1';
                            state                         <= State_Decode;
                            report "ZPU jumped to interrupt!" severity note;
                        end if;
                    when State_Decode2 =>
                        -- decode 4 instructions in parallel
                        for i in 0 to wordBytes-1 loop
                            tOpcode := decodeWord((wordBytes-1-i+1)*8-1 downto (wordBytes-1-i)*8);
    
                            tSpOffset(4)                  := not tOpcode(4);
                            tSpOffset(3 downto 0)         :=unsigned(tOpcode(3 downto 0));
    
                            opcode(i) <= tOpcode;
                            if (tOpcode(7 downto 7) = OpCode_Im) then
                                tNextState                := State_Im;
                            elsif (tOpcode(7 downto 5)=OpCode_StoreSP) then
                                if tSpOffset = 0 then
                                    tNextState            := State_Pop;
                                elsif tSpOffset = 1 then
                                    tNextState            := State_PopDown;
                                else
                                    tNextState            := State_StoreSP;
                                end if;
                            elsif (tOpcode(7 downto 5)=OpCode_LoadSP) then
                                if tSpOffset = 0 then
                                    tNextState            := State_Dup;
                                elsif tSpOffset = 1 then
                                    tNextState            := State_DupStackB;
                                else
                                    tNextState            := State_LoadSP;
                                end if;
                            elsif (tOpcode(7 downto 5) = OpCode_Emulate) then
                                tNextState                := State_Emulate;
                                if tOpcode(5 downto 0) = OpCode_Neqbranch then
                                    tNextState            := State_Neqbranch;
                                elsif tOpcode(5 downto 0) = OpCode_Eq then
                                    tNextState            := State_Eq;
                                elsif tOpcode(5 downto 0) = OpCode_Lessthan then
                                    tNextState            := State_Lessthan;
                                elsif tOpcode(5 downto 0) = OpCode_Lessthanorequal then
                                    tNextState            := State_Lessthanorequal;          --
                                elsif tOpcode(5 downto 0) = OpCode_Ulessthan then
                                    tNextState            := State_Ulessthan;
                                elsif tOpcode(5 downto 0) = OpCode_Ulessthanorequal then
                                    tNextState            := State_Ulessthanorequal;         --
                                elsif tOpcode(5 downto 0) = OpCode_Loadb then
                                    tNextState            := State_Loadb;
                                elsif tOpcode(5 downto 0) = OpCode_Loadh then
                                    -- Emulated
                                elsif tOpcode(5 downto 0) = OpCode_Mult then
                                    tNextState            := State_Mult;
                                elsif tOpcode(5 downto 0) = OpCode_Storeb then
                                    tNextState            := State_Storeb;
                                elsif tOpcode(5 downto 0) = OpCode_Storeh then
                                    -- Emulated
                                elsif tOpcode(5 downto 0) = OpCode_Pushspadd then
                                    tNextState            := State_Pushspadd;
                                elsif tOpcode(5 downto 0) = OpCode_Callpcrel then
                                    tNextState            := State_Callpcrel;
                                elsif tOpcode(5 downto 0) = OpCode_Call then
                                    tNextState            := State_Call;                     --
                                elsif tOpcode(5 downto 0) = OpCode_Sub then
                                    tNextState            := State_Sub;
                                elsif tOpcode(5 downto 0) = OpCode_PopPCRel then
                                    tNextState            := State_PopPCRel;                 --
                                elsif tOpcode(5 downto 0) = OpCode_Lshiftright then
                                    -- Emulated
                                elsif tOpcode(5 downto 0) = OpCode_Ashiftleft then
                                    -- Emulated
                                elsif tOpcode(5 downto 0) = OpCode_Ashiftright then
                                    -- Emulated
                                end if;                                
                            elsif (tOpcode(7 downto 4)=OpCode_AddSP) then
                                if tSpOffset = 0 then
                                    tNextState            := State_Shift;
                                elsif tSpOffset = 1 then
                                    tNextState            := State_AddTop;
                                else
                                    tNextState            := State_AddSP;
                                end if;
                            else
                                case tOpcode(3 downto 0) is
                                    when OpCode_Nop       => tNextState    := State_Nop;
                                    when OpCode_PushSP    => tNextState    := State_PushSP;
                                    when OpCode_PopPC     => tNextState    := State_PopPC;
                                    when OpCode_Add       => tNextState    := State_Add;
                                    when OpCode_Or        => tNextState    := State_Or;
                                    when OpCode_And       => tNextState    := State_And;
                                    when OpCode_Load      => tNextState    := State_Load;
                                    when OpCode_Not       => tNextState    := State_Not;
                                    when OpCode_Flip      => tNextState    := State_Flip;
                                    when OpCode_Store     => tNextState    := State_Store;
                                    when OpCode_PopSP     => tNextState    := State_PopSP;
                                    when others           => tNextState    := State_Break;
    
                                end case;
                            end if;
                            tDecodedOpcode(i)             := tNextState;
                            
                        end loop;
                        
                        insn                              <= tDecodedOpcode(to_integer(pc(byteBits-1 downto 0)));
                        
                        -- once we wrap, we need to fetch
                        tDecodedOpcode(0)                 := State_InsnFetch;
    
                        decodedOpcode                     <= tDecodedOpcode;
                      --state                             <= State_Execute;
                        if DEBUG_CPU = true then
                            state                         <= State_Execute;
                            debugState                    <= Debug_Start;                    
                        else
                            state                         <= State_Execute;
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
                                    debugRec.STACK_TOS              <= std_logic_vector(stackA);
                                    debugRec.STACK_NOS              <= std_logic_vector(stackB);
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
                                    debugRec.OPCODE                 <= opcode(debugCnt);
                                    debugRec.DECODED_OPCODE         <= std_logic_vector(to_unsigned(InsnType'POS(tDecodedOpcode(debugCnt)), 6));
                                    debugRec.PC(ADDR_BIT_RANGE)     <= (others => '0');
                                    debugRec.SP(ADDR_32BIT_RANGE)   <= (others => '0');
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
    
                        -- Each instruction must:
                        --
                        -- 1. set idim_flag
                        -- 2. increase pc if applicable
                        -- 3. set next state if appliable
                        -- 4. do it's operation
                         
                    when State_Execute =>
    
                        -- Debug code, if enabled, writes out the current instruction.
                        if DEBUG_CPU = true and insn /= State_InsnFetch then

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
                            debugRec.OPCODE                         <= opcode(to_integer(pc(byteBits-1 downto 0)));
                            debugRec.DECODED_OPCODE                 <= std_logic_vector(to_unsigned(InsnType'POS(insn), 6));
                            debugRec.PC(ADDR_BIT_RANGE)             <= std_logic_vector(pc);
                            debugRec.SP(ADDR_32BIT_RANGE)           <= std_logic_vector(sp);
                            debugRec.STACK_TOS                      <= std_logic_vector(stackA);
                            debugRec.STACK_NOS                      <= std_logic_vector(stackB);
                            debugLoad                               <= '1';
                        end if;                        
    
                        insn                              <= decodedOpcode(to_integer(nextPC(byteBits-1 downto 0)));
                                        
                        case insn is
                            when State_InsnFetch =>
                                state                               <= State_Fetch;
                            when State_Im =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '1';
                                    pc                              <= pc + 1;
                                    
                                    if idim_flag = '1' then 
                                        stackA(wordSize-1 downto 7) <= stackA(wordSize-8 downto 0);
                                        stackA(6 downto 0)          <= unsigned(opcode(to_integer(pc(byteBits-1 downto 0)))(6 downto 0));
                                    else
                                        mem_writeEnable             <= '1';
                                        mem_addr                    <= std_logic_vector(incSp);
                                        mem_write                   <= std_logic_vector(stackB);
                                        stackB                      <= stackA;
                                        sp                          <= decSp;
                                        for i in wordSize-1 downto 7 loop
                                            stackA(i)               <= opcode(to_integer(pc(byteBits-1 downto 0)))(6);
                                        end loop;
                                        stackA(6 downto 0)          <= unsigned(opcode(to_integer(pc(byteBits-1 downto 0)))(6 downto 0));
                                    end if;
                                end if;
                            when State_StoreSP =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    state                           <= State_StoreSP2;
                                    
                                    mem_writeEnable <= '1';
                                    mem_addr                        <= std_logic_vector(sp+spOffset);
                                    mem_write                       <= std_logic_vector(stackA);
                                    stackA                          <= stackB;
                                    sp                              <= incSp;
                                end if;
                        
                            when State_LoadSP =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    state                           <= State_LoadSP2;
            
                                    sp                              <= decSp;
                                    mem_writeEnable                 <= '1';
                                    mem_addr                        <= std_logic_vector(incSp);
                                    mem_write                       <= std_logic_vector(stackB);
                                end if;
                            when State_Emulate =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    sp                              <= decSp;
                                    mem_writeEnable                 <= '1';
                                    mem_addr                        <= std_logic_vector(incSp);
                                    mem_write                       <= std_logic_vector(stackB);
                                    stackA                          <= (others => DontCareValue);
                                    stackA(ADDR_BIT_RANGE)          <= pc + 1;
                                    stackB                          <= stackA;
                                    
                                    -- The emulate address is:
                                    --        98 7654 3210
                                    -- 0000 00aa aaa0 0000
                                    pc                              <= (others => '0');
                                    pc(9 downto 5)                  <= unsigned(opcode(to_integer(pc(byteBits-1 downto 0)))(4 downto 0));
                                    state                           <= State_Fetch;
                                end if;
                            when State_Callpcrel =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    stackA                          <= (others => DontCareValue);
                                    stackA(ADDR_BIT_RANGE)          <= pc + 1;
                                    
                                    pc                              <= pc + stackA(ADDR_BIT_RANGE);
                                    state                           <= State_Fetch;
                                end if;
                            when State_Call =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    stackA                          <= (others => DontCareValue);
                                    stackA(ADDR_BIT_RANGE)          <= pc + 1;
                                    pc                              <= stackA(ADDR_BIT_RANGE);
                                    state                           <= State_Fetch;
                                end if;
                            when State_AddSP =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    state                           <= State_AddSP2;
                                    
                                    mem_readEnable                  <= '1';
                                    mem_addr                        <= std_logic_vector(sp+spOffset);
                                end if;
                            when State_PushSP =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    pc                              <= pc + 1;
                                    
                                    sp                              <= decSp;
                                    stackA                          <= (others => '0');
                                    stackA(ADDR_32BIT_RANGE)        <= sp;
                                    stackB                          <= stackA;
                                    mem_writeEnable                 <= '1';
                                    mem_addr                        <= std_logic_vector(incSp);
                                    mem_write                       <= std_logic_vector(stackB);
                                end if;
                            when State_PopPC =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    pc                              <= stackA(ADDR_BIT_RANGE);
                                    sp                              <= incSp;
                                    
                                    mem_writeEnable                 <= '1';
                                    mem_addr                        <= std_logic_vector(incSp);
                                    mem_write                       <= std_logic_vector(stackB);
                                    state                           <= State_Resync;
                                end if;
                            when State_PopPCRel =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    pc                              <= stackA(ADDR_BIT_RANGE) + pc;
                                    sp                              <= incSp;
                                    
                                    mem_writeEnable                 <= '1';
                                    mem_addr                        <= std_logic_vector(incSp);
                                    mem_write                       <= std_logic_vector(stackB);
                                    state                           <= State_Resync;
                                end if;
                            when State_Add =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    stackA                          <= stackA + stackB;
                                    
                                    mem_readEnable                  <= '1';
                                    mem_addr                        <= std_logic_vector(incIncSp);
                                    sp                              <= incSp;
                                    state                           <= State_Popped;
                                end if;
                            when State_Sub =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    binaryOpResult                  <= stackB - stackA;
                                    state                           <= State_BinaryOpResult;
                                end if;
                            when State_Pop =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    mem_addr                        <= std_logic_vector(incIncSp);
                                    mem_readEnable                  <= '1';
                                    sp                              <= incSp;
                                    stackA                          <= stackB;
                                    state                           <= State_Popped;                        
                                end if;
                            when State_PopDown =>
                                if in_mem_busy = '0' then
                                    -- PopDown leaves top of stack unchanged
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    mem_addr                        <= std_logic_vector(incIncSp);
                                    mem_readEnable                  <= '1';
                                    sp                              <= incSp;
                                    state                           <= State_Popped;                        
                                end if;
                            when State_Or =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    stackA                          <= stackA or stackB;
                                    mem_readEnable                  <= '1';
                                    mem_addr                        <= std_logic_vector(incIncSp);
                                    sp                              <= incSp;
                                    state                           <= State_Popped;
                                end if;
                            when State_And =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
            
                                    stackA                          <= stackA and stackB;
                                    mem_readEnable                  <= '1';
                                    mem_addr                        <= std_logic_vector(incIncSp);
                                    sp                              <= incSp;
                                    state                           <= State_Popped;
                                end if;
                            when State_Eq =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
            
                                    binaryOpResult                  <= (others => '0');
                                    if (stackA = stackB) then
                                        binaryOpResult(0)           <= '1';
                                    end if;
                                    state                           <= State_BinaryOpResult;
                                end if;
                            when State_Ulessthan =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
            
                                    binaryOpResult                  <= (others => '0');
                                    if (stackA<stackB) then
                                        binaryOpResult(0)           <= '1';
                                    end if;
                                    state                           <= State_BinaryOpResult;
                                end if;
                            when State_Ulessthanorequal =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
            
                                    binaryOpResult <= (others => '0');
                                    if (stackA<=stackB) then
                                        binaryOpResult(0)           <= '1';
                                    end if;
                                    state                           <= State_BinaryOpResult;
                                end if;
                            when State_Lessthan =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
            
                                    binaryOpResult                                           <= (others => '0');
                                    if (signed(stackA)<signed(stackB)) then
                                        binaryOpResult(0)           <= '1';
                                    end if;
                                    state                           <= State_BinaryOpResult;
                                end if;
                            when State_Lessthanorequal =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
            
                                    binaryOpResult                  <= (others => '0');
                                    if (signed(stackA)<=signed(stackB)) then
                                        binaryOpResult(0)           <= '1';
                                    end if;
                                    state                           <= State_BinaryOpResult;
                                end if;
                            when State_Load =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    state                           <= State_Load2;
                                    
                                    mem_addr                        <= std_logic_vector(stackA(ADDR_32BIT_RANGE));
                                    mem_readEnable                  <= '1';
                                end if;
    
                            when State_Dup =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    pc                              <= pc + 1; 
                                    
                                    sp                              <= decSp;
                                    stackB                          <= stackA;
                                    mem_write                       <= std_logic_vector(stackB);
                                    mem_addr                        <= std_logic_vector(incSp);
                                    mem_writeEnable                 <= '1';
                                end if;
                            when State_DupStackB =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    pc                              <= pc + 1; 
                                    
                                    sp                              <= decSp;
                                    stackA                          <= stackB;
                                    stackB                          <= stackA;
                                    mem_write                       <= std_logic_vector(stackB);
                                    mem_addr                        <= std_logic_vector(incSp);
                                    mem_writeEnable                 <= '1';
                                end if;
                            when State_Store =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    pc                              <= pc + 1;
                                    mem_addr                        <= std_logic_vector(stackA(ADDR_32BIT_RANGE));
                                    mem_write                       <= std_logic_vector(stackB);
                                    mem_writeEnable                 <= '1';
                                    sp                              <= incIncSp;
                                    state                           <= State_Resync;
                                end if;
                            when State_PopSP =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    pc                              <= pc + 1;
                                    
                                    mem_write                       <= std_logic_vector(stackB);
                                    mem_addr                        <= std_logic_vector(incSp);
                                    mem_writeEnable                 <= '1';
                                    sp                              <= stackA(ADDR_32BIT_RANGE);
                                    state                           <= State_Resync;
                                end if;
                            when State_Nop =>    
                                begin_inst                          <= '1';
                                idim_flag                           <= '0';
                                pc                                  <= pc + 1;
                            when State_Not =>
                                begin_inst                          <= '1';
                                idim_flag                           <= '0';
                                pc                                  <= pc + 1; 
                                
                                stackA                              <= not stackA;
                            when State_Flip =>
                                begin_inst                          <= '1';
                                idim_flag                           <= '0';
                                pc                                  <= pc + 1; 
                                
                                for i in 0 to wordSize-1 loop
                                    stackA(i)                       <= stackA(wordSize-1-i);
                                  end loop;
                            when State_AddTop =>
                                begin_inst                          <= '1';
                                idim_flag                           <= '0';
                                pc                                  <= pc + 1; 
                                
                                stackA                              <= stackA + stackB;
                            when State_Shift =>
                                begin_inst                          <= '1';
                                idim_flag                           <= '0';
                                pc                                  <= pc + 1; 
                                
                                stackA(wordSize-1 downto 1)         <= stackA(wordSize-2 downto 0);
                                stackA(0)                           <= '0';
                            when State_Pushspadd =>
                                begin_inst                          <= '1';
                                idim_flag                           <= '0';
                                pc                                  <= pc + 1; 
                                
                                stackA                              <= (others => '0');
                                stackA(ADDR_32BIT_RANGE)            <= stackA((maxAddrBit-1)-minAddrBit downto 0)+sp;
                            when State_Neqbranch =>
                                -- branches are almost always taken as they form loops
                                begin_inst                          <= '1';
                                idim_flag                           <= '0';
                                sp                                  <= incIncSp;
                                if (stackB/=0) then
                                    pc                              <= stackA(ADDR_BIT_RANGE) + pc;
                                else
                                    pc                              <= pc + 1;
                                end if;        
                                -- need to fetch stack again.                
                                state                               <= State_Resync;
                            when State_Mult =>
                                begin_inst                          <= '1';
                                idim_flag                           <= '0';
            
                                multA                               <= stackA;
                                multB                               <= stackB;
                                state                               <= State_Mult2;
                            when State_Break =>
                                report "Break instruction encountered" severity failure;
                                break                               <= '1';
                            when State_Loadb =>
                                if in_mem_busy = '0' then
                                    begin_inst <= '1';
                                    idim_flag                       <= '0';
                                    state                           <= State_Loadb2;
                                    
                                    mem_addr                        <= std_logic_vector(stackA(ADDR_32BIT_RANGE));
                                    mem_readEnable                  <= '1';
                                end if;
                            when State_Storeb =>
                                if in_mem_busy = '0' then
                                    begin_inst                      <= '1';
                                    idim_flag                       <= '0';
                                    state                           <= State_Storeb2;
                                    
                                    mem_addr                        <= std_logic_vector(stackA(ADDR_32BIT_RANGE));
                                    mem_readEnable                  <= '1';
                                end if;
                    
                            when others =>
                                sp                                  <= (others => DontCareValue);
                                report "Illegal instruction" severity failure;
                                break                               <= '1';
                        end case;
    
    
                    when State_StoreSP2 =>
                        if in_mem_busy = '0' then
                            mem_addr                                <= std_logic_vector(incSp);
                            mem_readEnable                          <= '1';
                            state                                   <= State_Popped;
                        end if;
                    when State_LoadSP2 =>
                        if in_mem_busy = '0' then
                            state                                   <= State_LoadSP3;
                            mem_readEnable                          <= '1';
                            mem_addr                                <= std_logic_vector(sp+spOffset+1);
                        end if;
                    when State_LoadSP3 =>
                        if in_mem_busy = '0' then
                            pc                                      <= pc + 1;
                            state                                   <= State_Execute;
                            stackB                                  <= stackA;
                            stackA                                  <= unsigned(mem_read);
                        end if;
                    when State_AddSP2 =>
                        if in_mem_busy = '0' then
                            pc                                      <= pc + 1;
                            state                                   <= State_Execute;
                            stackA                                  <= stackA + unsigned(mem_read);
                        end if;
                    when State_Load2 =>
                        if in_mem_busy = '0' then
                            stackA                                  <= unsigned(mem_read);
                            pc                                      <= pc + 1;
                            state                                   <= State_Execute;
                        end if;
                    when State_Loadb2 =>
                        if in_mem_busy = '0' then
                            stackA                                  <= (others => '0');
                            stackA(7 downto 0)                      <= unsigned(mem_read(((wordBytes-1-to_integer(stackA(byteBits-1 downto 0)))*8+7) downto (wordBytes-1-to_integer(stackA(byteBits-1 downto 0)))*8));
                            pc                                      <= pc + 1;
                            state                                   <= State_Execute;
                        end if;
                    when State_Storeb2 =>
                        if in_mem_busy = '0' then
                            mem_addr                                <= std_logic_vector(stackA(ADDR_32BIT_RANGE));
                            mem_write                               <= mem_read;
                            mem_write(((wordBytes-1-to_integer(stackA(byteBits-1 downto 0)))*8+7) downto (wordBytes-1-to_integer(stackA(byteBits-1 downto 0)))*8) <= std_logic_vector(stackB(7 downto 0));
                            mem_writeEnable                         <= '1';
                            pc                                      <= pc + 1;
                            sp                                      <= incIncSp;
                            state                                   <= State_Resync;
                        end if;
                    when State_Fetch =>
                        if in_mem_busy = '0' then
                            mem_addr                                <= std_logic_vector(pc(ADDR_32BIT_RANGE));
                            mem_readEnable                          <= '1';
                            state                                   <= State_Decode;
    
                            -- If debug enabled, write out state during fetch.
                            if DEBUG_CPU = true then
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
                                debugRec.STACK_TOS                  <= std_logic_vector(stackA);
                                debugRec.STACK_NOS                  <= std_logic_vector(stackB);
                                debugLoad                           <= '1';
                            end if;  
                        end if;
                    when State_Mult2 =>
                        state                                       <= State_Mult3;
                    when State_Mult3 =>
                        state                                       <= State_Mult4;
                    when State_Mult4 =>
                        state                                       <= State_Mult5;
                    when State_Mult5 =>
                        if in_mem_busy = '0' then
                            stackA                                  <= multResult3;
                            mem_readEnable                          <= '1';
                            mem_addr                                <= std_logic_vector(incIncSp);
                            sp                                      <= incSp;
                            state                                   <= State_Popped;
                        end if;
                    when State_BinaryOpResult =>    
                        state                                       <= State_BinaryOpResult2;
                    when State_BinaryOpResult2 =>
                        mem_readEnable                              <= '1';
                        mem_addr                                    <= std_logic_vector(incIncSp);
                        sp                                          <= incSp;
                        stackA                                      <= binaryOpResult2;
                        state                                       <= State_Popped;
                    when State_Popped =>
                        if in_mem_busy = '0' then
                            pc                                      <= pc + 1;
                            stackB                                  <= unsigned(mem_read);
                            state                                   <= State_Execute;
                        end if;
                    when others =>    
                        sp                                          <= (others => DontCareValue);
                        report "Illegal state" severity failure;
                        break                                       <= '1';
                end case;
            end if;
        end if;
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
                RESET                    => areset,                          -- high active sync reset
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
