using Random

# struct for sudoku grid
mutable struct Grid
    n::Int # block size (n^2 - rows/columns/blocks total number)
    table::Matrix{Int}

    # Base concstructor
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

    # constructor from Matrix
    function Grid(n::Int, ref)
        table = copy(ref)
        new(n, table)
    end
end

# print grid
function Base.show(io::IO, g::Grid)
    for i in 1:(g.n * g.n)
        println(io, g.table[i, :])
    end
    println()
end

# mix operations
function transpose(g::Grid)
    g.table = g.table' 
end
 
function swap_rows_small(g::Grid)
    area = rand(1:g.n)
    line1 = rand(1:g.n)
    N₁ = (area - 1) * g.n + line1
    line2 = rand(1:g.n)
    while line1 == line2
        line2 = rand(1:g.n)
    end
    N₂ = (area - 1) * g.n + line2

    g.table[[N₁, N₂], :] = g.table[[N₂, N₁], :]
end


function swap_columns_small(g::Grid)
    transpose(g)
    swap_rows_small(g)
    transpose(g)
end

function swap_rows_area(g::Grid)
    area1 = rand(1:g.n)
    area2 = rand(1:g.n)
    while area1 == area2
        area2 = rand(1:g.n)
    end
    for i in 1:g.n
        N₁, N₂ = (area1 - 1) * g.n + i, (area2 - 1) * g.n + i
        g.table[[N₁, N₂], :] = g.table[[N₂, N₁], :]
    end
end
 
function swap_columns_area(g::Grid)
    transpose(g)
    swap_rows_area(g)
    transpose(g)
end

# mix function
function mix(g::Grid, amt=10)
    mix_func = [transpose, 
                swap_columns_area, 
                swap_columns_small,
                swap_rows_area,
                swap_rows_small,
                ]
    for i in 1:amt
        f = rand(mix_func)
        f(g)
    end
end