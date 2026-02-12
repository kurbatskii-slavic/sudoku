include("grid.jl")
include("solver.jl")


function generate_sudoku(g::Grid)
    N = g.n^2 # row/column size
    table = copy(g.table)
    mask = zeros(N, N)
    density = N^2 # have filled grid at the start
    iter = 0
    while iter < N^2
        i, j = rand(1:N), rand(1:N) # pick random position
        if mask[i, j] == 0 # check if we have already tried this element
            mask[i, j] = 1
            iter += 1

            element = table[i, j] # store element if it is necessary for unique solution
            table[i, j] = 0 # remove element

            density -= 1 # remove 1 element
            solutions = solve_sudoku((g.n, g.n), table)
            if length(solutions) ≠ 1
                table[i, j] = element # restore changes
                density += 1
            end
        end
    end
    Grid(g.n, table)
end


g = Grid()
mix(g)
show(g)
s = generate_sudoku(g)
show(s)
show(g)
show(solve_sudoku(s)[1])