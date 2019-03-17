----------------------------------------------------------------------------
--
--  Test Bench for conway
--
--  This is a test bench for the conway entity.  The test bench
--  thoroughly tests the entity by exercising it and checking the outputs.
--  The testbench first tests some preset edge cases, defined in test vectors
--  Then it goes into 32 randomized test cases, using a for loop to compute
--  the conway for these random test cases.
--  Upon each error, the two operands are outputted as well as their
--  expected conway and the received conway.
--
--  Revision History:
--     03/15/2019 Sundar Pandian       Initial version
--
----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.TBconstants.all;
use work.constants.all;

entity conway_tb is
end conway_tb;

architecture TB_ARCHITECTURE of conway_tb is

    -- Component declaration of the tested unit
    component sys_array is
        port (
            CLK             : in    std_logic;
            NextTimeTick    : in    std_logic;
            Shift           : in    std_logic;
            DataIn          : in    std_logic;
            DataOut         : out   std_logic
        );
    end  component;

    -- signals for porting inputs
    signal CLK         :  std_logic;
    signal NextTimeTick : std_logic;
    signal Shift        : std_logic;
    signal DataIn       : std_logic;

    -- signals for porting outputs
    signal DataOut      : std_logic;

    -- clock period
    constant clk_time : time := 20 ns;
    -- SIM process flag
    signal END_SIM : BOOLEAN := FALSE;

begin

    -- Unit Under Test port map
    UUT : sys_array
        port map  (
            CLK => CLK,
            NextTimeTick => NextTimeTick,
            Shift => Shift,
            DataIn => DataIn,
            DataOut => DataOut
        );

    -- now generate the stimulus and test it
    process

        -- loop indices
        variable i : integer;
        variable j : integer;

    begin  -- of stimulus process
        -- sets initial state -- all zeros
        Shift <= '0';
        DataIn <= '0';
        NextTimeTick <= '0';

        wait for 100*clk_time;

        Shift <= '1';

        wait for clk_time*0.7;

        for j in 0 to NumTests-1 loop
            for i in 0 to ARRYSIZE*ARRYSIZE-1 loop
                DataIn <= InputTest(j, i); -- push in test vector DataIn values
                wait for clk_time;
            end loop;

            Shift <= '0'; -- stop shifting

            wait for clk_time;
            NextTimeTick <= '1'; -- start system
            wait for clk_time*NumTests;
            NextTimeTick <= '0'; -- stop system after 5 iterations
            wait for clk_time;

            Shift <= '1'; -- start shifting values out to check

            -- check with test vectors every clock
            for i in 0 to ARRYSIZE*ARRYSIZE-1 loop
                assert (OutputTest(j, i) = DataOut)
                    report  "DataOut failure at elmnt number " & integer'image(i)
                    severity  ERROR;
                wait for clk_time;
            end loop;
        end loop;

        wait for clk_time*0.3;
        END_SIM <= TRUE;
        wait;
        -- and just keep looping in the process
    end process; -- end of stimulus process

    CLOCK_CLK : process
    begin

        -- this process generates a clock with a defined period and 50% duty cycle
        -- stop the clock when end of simulation is reached
        if END_SIM = FALSE then
            CLK <= '0';
            wait for clk_time/2;
        else
            wait;
        end if;

        if END_SIM = FALSE then
            CLK <= '1';
            wait for clk_time/2;
        else
            wait;
        end if;

    end process;

end TB_ARCHITECTURE;