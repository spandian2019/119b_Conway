----------------------------------------------------------------------------
--
--  Conway's Game of Life
--
--  This file contains all the entities for synthesizing a systolic array
--  implementation for Conway's Game of Life. This is a cellular automaton
--  existing on an infinite 2-d hex mesh of cells. Each cell may be in one
--  of two states: live or dead. The state of a cell is determined by the
--  state of the eight cells around it. At each "tick" of time, each cell's
--  state is determined as follows:
--
--  Game of Life: Rules
--      Any live cell with < 2 live neighbors dies of loneliness
--      Any live cell with > 3 live neighbors dies of overpopulation
--      Any live cell with exactly 2 or 3 neighbors continues living
--      Any dead cell with exactly 3 live neighbors is reborn
--  
--  Initialize the game by fully pushing in a combination of live and dead
--  cells into the DataIn signal. This can occur while the Shift signal is
--  active. Upon each clk tick with Shift active, the current value of
--  DataIn is shifted into the mesh array. 
--  The array can also be shifted out of the DataOut signal, shifting out
--  each clk tick when the Shift signal is enabled.
--
--  States -- determined by Shift and NextTimeTick signals
--      Idle    -- No change, all cells maintain state
--      Shift   -- each cell take state of cell directly to its left
--                 first cell of first row takes in DataIn
--                 first cell of each row takes data from last cell of prev
--      Run     -- runs Conway's Game of Life
--
--  Edge Cases:
--      The outer ring of cells treat all empty borders around them as
--      dead cells
--
--  Limitations:
--
--  Entities contained:
--      sys_array   : generates hex mesh array of the cell
--                      PEs to play Conway's Game of Life
--      conway_cell : uses neighbor states to determine if cell should be
--                      alive or dead
--
--  Revision History:
--     03/15/2019 Sundar Pandian       Initial version
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--
--  sys_array
--
--  Implements the systolic array utilizing the PE declared later in the
--  file. Interconnect is using hex mesh. Each cell broadcasts its life
--  to all its neighbors and takes in all its neighbors' states.
-- 
--  conway_cell PE is generated ARRYSIZE*ARRYSIZE times
--
--  Inputs:
--      CLK                     - clock signal
--      NextTimeTick            - Run state signal (1 bit)
--      Shift                   - Shift state signal (1 bit)
--      DataIn                  - data shift input (1 bit)
--
--  Outputs:
--      DataOut                 - data shift output (1 bit)
--
--  Initialize the game by fully pushing in a combination of live and dead
--  cells into the DataIn signal. This can occur while the Shift signal is
--  active. Upon each clk tick with Shift active, the current value of
--  DataIn is shifted into the mesh array. 
--  The array can also be shifted out of the DataOut signal, shifting out
--  each clk tick when the Shift signal is enabled.
--
--  States -- determined by Shift and NextTimeTick signals
--      Idle    -- No change, all cells maintain state
--      Shift   -- each cell take state of cell directly to its left
--                 first cell of first row takes in DataIn
--                 first cell of each row takes data from last cell of prev
--      Run     -- runs Conway's Game of Life
--
--  Edge Cases:
--      The outer ring of cells treat all empty borders around them as
--      dead cells
--
--  Limitations:
--
--  Entities contained:
--      conway_cell : uses neighbor states to determine if cell should be
--                      alive or dead
--
--  Revision History:
--     03/15/2019 Sundar Pandian       Initial version
--
----------------------------------------------------------------------------

-- libraries
library  ieee;
use  ieee.std_logic_1164.all;
use  ieee.numeric_std.all;
use work.constants.all;

entity  sys_array  is

    port (
            CLK             : in    std_logic;
            NextTimeTick    : in    std_logic;
            Shift           : in    std_logic;
            DataIn          : in    std_logic;
            DataOut         : out   std_logic
    );

end  sys_array;

--
--  sys_array hex_mesh architecture
--

architecture  hex_mesh  of  sys_array  is

component  conway_cell  is
    port (
            CLK             : in    std_logic;
            NextTimeTick    : in    std_logic;
            Shift           : in    std_logic;
            n_0             : in    std_logic;
            n_1             : in    std_logic;
            n_2             : in    std_logic;
            n_3             : in    std_logic;
            n_4             : in    std_logic;
            n_5             : in    std_logic;
            n_6             : in    std_logic;
            n_7             : in    std_logic;

            life            : out   std_logic
    );
end  component;

 
-- array for synthesizing cell state signals
type OPARR is array (0 to ARRYSIZE+1, 0 to ARRYSIZE+1) of std_logic;
signal CellStates     : OPARR;

-- signal buffer for wrapping last row elmnt to 
--   start of next row for shifting
signal wrapRow : std_logic_vector(0 to ARRYSIZE-1);

begin

    -- port mappings
    -- each PE connected in a hex mesh

    -- zero out first and last rows of CellStates 2d array
    zero_row: for i in 0 to ARRYSIZE+1 generate
        CellStates(0, i) <= '0' when i /= ARRYSIZE else -- first row all zeros
                            DataIn;                     -- except DataIn signal
        CellStates(ARRYSIZE+1, i) <= '0';
    end generate zero_row;

    -- zero out first and last columns of CellStates 2d array 
    --   ignore first and last elements in each column because
    --   already zero'd out from previous row zeros
    zero_col: for i in 1 to ARRYSIZE generate
        CellStates(i, 0) <= '0';
        CellStates(i, ARRYSIZE+1) <= '0';
    end generate zero_col;

    -- i serves as row index
    -- j serves as col index
    row_gen: for i in 1 to ARRYSIZE generate
            -- shifts in cell state from last elmnt in prev row during
            --  Shift mode of operation
            -- or shifts in 0 since edge cell
            wrapRow(i-1) <= (CellStates(i-1, ARRYSIZE) and Shift);

            conway_celli1: conway_cell
                port map (
                    CLK          => CLK,
                    NextTimeTick => NextTimeTick,
                    Shift        => Shift,
                    n_0          => '0',
                    n_1          => CellStates(i-1, 1),
                    n_2          => CellStates(i-1, 2),
                    n_3          => wrapRow(i-1),
                    n_4          => CellStates(i, 2),
                    n_5          => '0',
                    n_6          => CellStates(i+1, 1),
                    n_7          => CellStates(i+1, 2),
                    life         => CellStates(i, 1)
                );

        col_gen: for j in 2 to ARRYSIZE generate
            conway_cellij: conway_cell
                port map (
                    CLK          => CLK,
                    NextTimeTick => NextTimeTick,
                    Shift        => Shift,
                    n_0          => CellStates(i-1, j-1),
                    n_1          => CellStates(i-1, j),
                    n_2          => CellStates(i-1, j+1),
                    n_3          => CellStates(i, j-1),
                    n_4          => CellStates(i, j+1),
                    n_5          => CellStates(i+1, j-1),
                    n_6          => CellStates(i+1, j),
                    n_7          => CellStates(i+1, j+1),
                    life         => CellStates(i, j)
                );
        end generate col_gen;
    end generate row_gen;

    DataOut <= CellStates(ARRYSIZE, ARRYSIZE);

end  hex_mesh;


----------------------------------------------------------------------------
--
--  conway_cell PE
--
--  Implements single cell for Conway's Game of Life. The cell has a state
--  that gets outputted, its life. When the cell is alive, its state is '1',
--  otherwise it's a '0'. There are three modes of operation for each cell, 
--  determined by the input signals: NextTimeTick and Shift. When neither
--  signal is active, the state is Idle. When Shift is active, the state is
--  Shift. When NextTimeTick is active, the state is Run. When both are
--  active, it is an unsupported state, and the Game runs while shifting out
--  This will end in a garbage state for the system. State descriptions are
--  as follows:
--  
--  States -- determined by Shift and NextTimeTick signals
--      Idle    -- No change, all cells maintain state
--      Shift   -- each cell take state of cell directly to its left
--                 first cell of first row takes in DataIn
--                 first cell of each row takes data from last cell of prev
--      Run     -- runs Conway's Game of Life
--
--  Inputs:
--      CLK                     - clock signal
--      NextTimeTick            - Run state signal (1 bit)
--      Shift                   - Shift state signal (1 bit)
--      n_0                     - neighbor 0 state input (1 bit)
--      n_1                     - neighbor 1 state input (1 bit)
--      n_2                     - neighbor 2 state input (1 bit)
--      n_3                     - neighbor 3 state input (1 bit)
--      n_4                     - neighbor 4 state input (1 bit)
--      n_5                     - neighbor 5 state input (1 bit)
--      n_6                     - neighbor 6 state input (1 bit)
--      n_7                     - neighbor 7 state input (1 bit)
--
--  Outputs:
--      life                    - cell state (1 bit)
--
--  Revision History:
--     03/15/2019 Sundar Pandian       Initial version
--
----------------------------------------------------------------------------

-- libraries
library  ieee;
use  ieee.std_logic_1164.all;
use  ieee.numeric_std.all;
use work.constants.all;

entity  conway_cell  is

    port (
            CLK             : in    std_logic;
            NextTimeTick    : in    std_logic;
            Shift           : in    std_logic;
            n_0             : in    std_logic;
            n_1             : in    std_logic;
            n_2             : in    std_logic;
            n_3             : in    std_logic;
            n_4             : in    std_logic;
            n_5             : in    std_logic;
            n_6             : in    std_logic;
            n_7             : in    std_logic;

            life            : out   std_logic
    );

end  conway_cell;

--
--  conway_cell PE architecture
--

architecture  PE  of  conway_cell  is

component halfAdder is
    port(
        A           :  in      std_logic;  -- adder input
        B           :  in      std_logic;  -- adder input
        Cout        :  out     std_logic;  -- carry out value
        Sum         :  out     std_logic   -- sum of A, B with carry in
      );
end component;

component TwoBitAdder is
    port(
        A           :  in      std_logic_vector(1 downto 0);  -- adder input
        B           :  in      std_logic_vector(1 downto 0);  -- adder input
        Sum         :  out     std_logic_vector(1 downto 0);  -- sum of A, B
        OverF       :  out     std_logic    -- overflow value
      );
end component;

-- neighbor state vector
signal state_vector : std_logic_vector(NUM_NEIGHBORS-1 downto 0);

-- intermediate two bit vector sum buffers
type SUMARR is array (natural range <>) of std_logic_vector(1 downto 0);
signal int_sums_0 : SUMARR(NUM_NEIGHBORS/2-1 downto 0);
signal int_sums_1 : SUMARR(NUM_NEIGHBORS/4-1 downto 0);

-- overflow value vector
signal overF_vector : std_logic_vector(2 downto 0);

-- neighbor life count over three flag
signal overThree : std_logic;

-- final sum vector
signal final_sum : std_logic_vector(1 downto 0);

-- cell life buffer
signal cellLife : std_logic;
signal prevLife : std_logic;

begin

    state_vector <= n_7 & n_6 & n_5 & n_4 & n_3 & n_2 & n_1 & n_0; -- place in state vector buffer

    -- generate two bit vectors out of sums of pairs of neighbor states
    half_adders: for i in NUM_NEIGHBORS/2-1 downto 0 generate
        half_adderi: halfAdder
            port map (
                A => state_vector(2*i),
                B => state_vector(2*i+1),
                Cout => int_sums_0(i)(1),
                Sum => int_sums_0(i)(0)
            );
    end generate half_adders;

    -- generate second level of intermediate sum vectors
    two_bit_adders: for i in NUM_NEIGHBORS/4-1 downto 0 generate
        TwoBitAdderi: TwoBitAdder
            port map (
                A => int_sums_0(2*i),
                B => int_sums_0(2*i+1),
                Sum => int_sums_1(i),
                OverF => overF_vector(i+1)
            );
    end generate two_bit_adders;

    -- generate final sum vector
    TwoBitAdderFinal: TwoBitAdder
        port map (
            A => int_sums_1(0),
            B => int_sums_1(1),
            Sum => final_sum,
            OverF => overF_vector(0)
        );

    -- if any intermediate sum was over 3, total number of living neighbors
    --  is over 3
    overThree <= overF_vector(0) or overF_vector(1) or overF_vector(2);

    

    -- if over 3 neighbors alive when cell is alive or dead, next state is dead
    -- otherwise, sum needs to match for specific case when alive or dead
    cellLife <= '1' when ((std_match(final_sum, LIVE_MASK) and 
                             overThree = '0' and prevLife = '1') or
                          (std_match(final_sum, DEAD_MASK) and 
                             overThree = '0' and prevLife = '0')) and
                         (NextTimeTick = '1') else
                '0' when NextTimeTick = '1' else
                
    -- shifts in previous row elmnt value when Shift mode of operation
                n_3 when Shift = '1' else
    -- maintains state in Idle mode of operation
                prevLife;


    -- synchronize outputs
    synch: process(CLK)
    begin
        if rising_edge(CLK) then
            prevLife <= cellLife; -- to access current state
            life <= cellLife;
        end if;
    end process;

end  PE;