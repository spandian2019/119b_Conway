# Python code to generate testbench vectors for
# VHDL testing of Conway's Game of Life
import numpy as np
ON = 1
OFF = 0
vals = [1, 0]

def randomGrid(N): 
  
    """returns a grid of NxN random values"""
    return np.random.choice(vals, N*N, p=[0.2, 0.8]).reshape(N, N)

def update(grid, N): 
    # copy grid since we require 8 neighbors  
    # for calculation and we go line by line  
    newGrid = grid.copy() 
    for i in range(N): 
        for j in range(N): 
  
            # compute 8-neghbor sum 
            if i == 0:
                if j == 0:
                    total = int((grid[i, (j+1)] + 
                                 grid[(i+1), j] +
                                 grid[(i+1), (j+1)])) 
                elif j == N-1:
                    total = int((grid[i, (j-1)] +
                                 grid[(i+1), j] +
                                 grid[(i+1), (j-1)])) 
                else:
                    total = int((grid[i, (j-1)] + grid[i, (j+1)] + 
                                 grid[(i+1), j] +
                                 grid[(i+1), (j-1)] + grid[(i+1), (j+1)]))
            elif i == N-1:
                if j == 0:
                    total = int((grid[i, (j+1)] + 
                                 grid[(i-1), j] +
                                 grid[(i-1), (j+1)])) 
                elif j == N-1:
                    total = int((grid[i, (j-1)] +
                                 grid[(i-1), j] +
                                 grid[(i-1), (j-1)])) 
                else:
                    total = int((grid[i, (j-1)] + grid[i, (j+1)] + 
                                 grid[(i-1), j] +
                                 grid[(i-1), (j-1)] + grid[(i-1), (j+1)])) 
            else:
                if j == 0:
                    total = int((grid[i, (j+1)] + 
                                 grid[(i-1), j] + grid[(i+1), j] + 
                                 grid[(i-1), (j+1)] + 
                                 grid[(i+1), (j+1)])) 
                elif j == N-1:
                    total = int((grid[i, (j-1)] +
                                 grid[(i-1), j] + grid[(i+1), j] + 
                                 grid[(i-1), (j-1)] +
                                 grid[(i+1), (j-1)])) 
                else:
                    total = int((grid[i, (j-1)] + grid[i, (j+1)] + 
                                 grid[(i-1), j] + grid[(i+1), j] + 
                                 grid[(i-1), (j-1)] + grid[(i-1), (j+1)] + 
                                 grid[(i+1), (j-1)] + grid[(i+1), (j+1)])) 
  
            # apply Conway's rules 
            if grid[i, j]  == ON: 
                if (total < 2) or (total > 3): 
                    newGrid[i, j] = OFF 
            else: 
                if total == 3: 
                    newGrid[i, j] = ON 
    print(newGrid)
    return newGrid

# main() function 
def main():       
    # set grid size 
    N = 10 
          
    # declare grid 
    grid = np.array([]) 
    finalGrid = np.array([])
  
    grid = randomGrid(N)
    finalGrid = grid.copy()

    file = open("vectors.txt", "w")

    for i in range(N):
        for j in range(N):
            file.write("\'")
            file.write(str(grid[i][j]))
            file.write("\', ")
        file.write("\n")
    file.write("\n\n")


    print(grid)

    for i in range(5):
        finalGrid = update(finalGrid, N)
    
    for i in range(N):
        for j in range(N):
            file.write("\'")
            file.write(str(finalGrid[i][j]))
            file.write("\', ")
        file.write("\n")

    file.close()
    print(finalGrid)

  
# call main 
if __name__ == '__main__': 
    main() 