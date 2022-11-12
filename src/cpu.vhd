-- cpu.vhd: Simple 8-bit CPU (BrainFuck interpreter)
-- Copyright (C) 2022 Brno University of Technology,
--                    Faculty of Information Technology
-- Author(s): xzoube02 <login AT stud.fit.vutbr.cz>
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity cpu is
 port (
   CLK   : in std_logic;  -- hodinovy signal
   RESET : in std_logic;  -- asynchronni reset procesoru
   EN    : in std_logic;  -- povoleni cinnosti procesoru
 
   -- synchronni pamet RAM
   DATA_ADDR  : out std_logic_vector(12 downto 0); -- adresa do pameti
   DATA_WDATA : out std_logic_vector(7 downto 0); -- mem[DATA_ADDR] <- DATA_WDATA pokud DATA_EN='1'
   DATA_RDATA : in std_logic_vector(7 downto 0);  -- DATA_RDATA <- ram[DATA_ADDR] pokud DATA_EN='1'
   DATA_RDWR  : out std_logic;                    -- cteni (0) / zapis (1)
   DATA_EN    : out std_logic;                    -- povoleni cinnosti
   
   -- vstupni port
   IN_DATA   : in std_logic_vector(7 downto 0);   -- IN_DATA <- stav klavesnice pokud IN_VLD='1' a IN_REQ='1'
   IN_VLD    : in std_logic;                      -- data platna
   IN_REQ    : out std_logic;                     -- pozadavek na vstup data
   
   -- vystupni port
   OUT_DATA : out  std_logic_vector(7 downto 0);  -- zapisovana data
   OUT_BUSY : in std_logic;                       -- LCD je zaneprazdnen (1), nelze zapisovat
   OUT_WE   : out std_logic                       -- LCD <- OUT_DATA pokud OUT_WE='1' a OUT_BUSY='0'
 );
end cpu;


-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of cpu is

  --- PC
          signal pc_reg : std_logic_vector(12 downto 0);
          signal pc_inc : std_logic;
          signal pc_dec : std_logic;
  --- PC

  --- PTR
          signal ptr_reg : std_logic_vector(12 downto 0);
          signal ptr_inc : std_logic;
          signal ptr_dec : std_logic;
  --- PTR

  ---FSM stavy
          type fsm_state is (
            s_start,
            s_fetch,
            s_decode,
            s_pointer_inc,
            s_pointer_dec,
            s_value_inc,
            s_value_dec,
            s_while_start,
            s_while_end,
            s_write,
            s_load,
            s_null
          )
          signal state : fsm_state := s_start;
          signal nState : fsm_state;
  --- MUX
        signal mx_select : std_logic_vector(1 downto 0) := (others => '0');
        signal mx_output : std_logic_vector(12 downto 0) := (others => '0');
  --- MUX

  --- MUX2
        signal mx2_select : std_logic_vector(1 downto 0) := (others => '0');
        signal mx2_output : std_logic_vector(7 downto 0) := (others => '0');
  --- MUX2
begin
  --- PC ---
      pc: process (CLK, RESET, pc_inc, pc_dec)
      begin

      end process;
  --- PC ---
  --- MUX2 ---
          mux2: process (CLK, RESET, mx2_select) is
            begin
                  if RESET = '1' then
                            mx2_output <= (others => '0')
                  elsif rising_edge(CLK) then
                            case mx2_select is
                              when "00" =>
                                mx2_output <= IN_DATA;
                              when "01" =>
                                mx2_output <= DATA_RDATA + 1;
                              when "10" =>
                                mx2_output <= DATA_RDATA - 1;
                              when others =>
                                mx2_output <= (others => '0');
                            end case;
                  end if;
            end process;
            DATA_WDATA <= mx2_output;
  --- MUX2 ---


  --- FSM ---
          state_logic: process (CLK, RESET, EN) is
            begin
              if RESET = '1' then
                  state <= s_start;
                  elsif rising_edge(CLK) then
                    if EN = '1' then
                      state <= nState;
                    end if;
                  end if;            
            end process;

            fsm: process (state, OUT_BUSY, IN_VLD)
  --- FSM ---
end behavioral;

