# struct for sudoku grid
mutable struct Grid
    n::Int # block size (n^2 - rows/columns/blocks total number)
    table::Matrix{Int}
    function Grid(n::Int=3)
        N = n * n # blocks total number
        table = Matrix{Int}(undef, N, N)
        for i in 0:(N-1)
            for j in 0:(N-1)
                table[i+1, j+1] = (i * n + div(i, n) + j) % N + 1 # formula for start grid elements
            end
        end
        new(n, table)
    end
end

# print grid
function Base.show(io::IO, g::Grid)
    for i in 1:(g.n * g.n)
        println(io, g.table[i, :])
    end
end

show(Grid())
