-----------------------------------------------------------------------------
--
--  GCD systolic implementation constants package
--
--  This package defines constants for systolic array implementation of
--  GCD computer
--
--  Revision History
--     03/15/2019 Sundar Pandian       Initial version
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package constants is

    ---------------------------
    -- USER FILLED CONSTANTS --
    ---------------------------
    constant ARRYSIZE   : integer := 10;    -- square matrix size for conway matrix

    ------------------------
    -- SUM MASK CONSTANTS --
    ------------------------
    -- cell alive case - needs number of alive neighbors to equal 2 or 3
    constant LIVE_MASK : std_logic_vector(1 downto 0) := "1-";
    -- cell dead  case - needs number of alive neighbors to equal 3
    constant DEAD_MASK : std_logic_vector(1 downto 0) := "11";

    constant NUM_NEIGHBORS : integer := 8; -- total number of neighbors
end package constants;

----------------------------------------------------------------------------
--
--  1 Bit Half Adder
--
--  Implementation of a half adder. This entity takes the one bit
--  inputs A and B and outputs the sum and carry out bits, using
--  combinational logic.
--
-- Inputs:
--      A: std_logic - 1 bit adder input
--      B: std_logic - 1 bit adder input
--
-- Outputs:
--      Sum: std_logic - 1 bit sum of A, B, and Cin
--      Cout: std_logic - 1 bit carry out value
--
--  Revision History:
--     03/15/2019 Sundar Pandian       Initial version
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity halfAdder is
    port(
        A           :  in      std_logic;  -- adder input
        B           :  in      std_logic;  -- adder input
        Cout        :  out     std_logic;  -- carry out value
        Sum         :  out     std_logic   -- sum of A, B with carry in
      );
end halfAdder;

architecture halfAdder of halfAdder is
    begin
        -- combinational logic for calculating A+B
        Sum <= A xor B;
        Cout <= A and B;
end halfAdder;

----------------------------------------------------------------------------
--
--  2 Bit Modified Adder
--
--  Implementation of a two bit adder modified for Conway's Game of Life.
--  Since cell state only changes when number of live neighbors equals 2 or
--  3, only need detect these values. All values above or below merely are
--  treated the same. 
--
-- Inputs:
--      A: std_logic_vector - 2 bit adder input
--      B: std_logic_vector - 2 bit adder input
--
-- Outputs:
--      Sum: std_logic_vector - 2 bit sum of A and B
--      OverF: std_logic - 1 bit overflow value
--
--  Revision History:
--     03/15/2019 Sundar Pandian       Initial version
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TwoBitAdder is
    port(
        A           :  in      std_logic_vector(1 downto 0);  -- adder input
        B           :  in      std_logic_vector(1 downto 0);  -- adder input
        Sum         :  out     std_logic_vector(1 downto 0);  -- sum of A, B
        OverF       :  out     std_logic    -- overflow value
      );
end TwoBitAdder;

architecture TwoBitAdder of TwoBitAdder is
    begin
        -- combinational logic for calculating A+B
        Sum(0) <= A(0) xor B(0);
        Sum(1) <= (A(0) and B(0)) xor A(1) xor B(1);
        OverF  <= (A(1) and B(1)) or
                  (A(1) and (A(0) and B(0))) or
                  (B(1) and (A(0) and B(0)));
end TwoBitAdder;