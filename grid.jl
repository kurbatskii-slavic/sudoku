using Random

# struct for sudoku grid
mutable struct Grid
    n::Int # block size (n^2 - rows/columns/blocks total number)
    table::Matrix{Int} # Matrix with numbers

    # base concstructor
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

# print grid with block separators
function Base.show(io::IO, g::Grid)
    N = g.n * g.n
    for i in 1:N
        # horizontal line
        if i % g.n == 1 && i != 1
            println(io, "-" ^ (2N + g.n - 1))
        end
        for j in 1:N
            # vertical line
            if j % g.n == 1 && j != 1
                print(io, "| ")
            end
            val = g.table[i, j]
            if val == 0
                print(io, ". ")
            else
                print(io, val, " ")
            end
        end
        println(io)
    end
    println()
end


# mix operations
function transpose(g::Grid)
    g.table = g.table' 
end

# swap rows within area
function swap_rows_small(g::Grid)
    area = rand(1:g.n) # choose area
    row1 = rand(1:g.n) # choose first row (local number)
    N₁ = (area - 1) * g.n + row1 # row1 global number
    row2 = rand(1:g.n) # choose second row (local number)
    while row1 == row2 # check if they are equal
        row2 = rand(1:g.n)
    end
    N₂ = (area - 1) * g.n + row2 # row2 global number

    g.table[[N₁, N₂], :] = g.table[[N₂, N₁], :] # swap rows
end

# swap columns within area (equal to rows of gᵀ)
function swap_columns_small(g::Grid)
    transpose(g)
    swap_rows_small(g)
    transpose(g)
end

# swap two rows areas
function swap_rows_area(g::Grid)
    area1 = rand(1:g.n)
    area2 = rand(1:g.n)
    while area1 == area2
        area2 = rand(1:g.n)
    end
    for i in 1:g.n
        N₁, N₂ = (area1 - 1) * g.n + i, (area2 - 1) * g.n + i # rows global numbers
        g.table[[N₁, N₂], :] = g.table[[N₂, N₁], :] # swap
    end
end

# swap two columns areas (equal to rows of gᵀ)
function swap_columns_area(g::Grid)
    transpose(g)
    swap_rows_area(g)
    transpose(g)
end

# mix function (combine random transformations)
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