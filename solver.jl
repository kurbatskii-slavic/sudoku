using Base.Iterators


# main solver function
function solve_sudoku(size, grid)
    R, C = size # rows and columns number (R = C usually)
    N = R * C # number of elements

    X = vcat( # all possible restrictions
        [("rc", rc) for rc in product(0:N-1, 0:N-1)], # each tile has only 1 number
        [("rn", rn) for rn in product(0:N-1, 1:N)], # each row has only one number n
        [("cn", cn) for cn in product(0:N-1, 1:N)], # each column has only one number n
        [("bn", bn) for bn in product(0:N-1, 1:N)] # each block has only one number n
    )
    
    # all candidates (coordinates and values)
    Y = Dict{Tuple{Int,Int,Int}, Vector{Tuple{String, Tuple{Int,Int}}}}()
    for (r, c, n) in product(0:N-1, 0:N-1, 1:N) # r - row, c - column, n - number
        b = div(r, R) * R + div(c, C)  # Box number
        Y[(r, c, n)] = [ # all restrictions that cover (r, c, n)
            ("rc", (r, c)),
            ("rn", (r, n)),
            ("cn", (c, n)),
            ("bn", (b, n))]
    end
    
    X_dict, Y = exact_cover(X, Y)
    
    for i in 1:N
        for j in 1:N
            n = grid[i, j]
            if n ≠ 0
                select(X_dict, Y, (i-1, j-1, n)) # 
            end
        end
    end
    
    # find all solutions
    solutions = []
    for solution in solve(X_dict, Y)
        push!(solutions, copy(solution))
    end
    
    # convert solutions to Grid class
    result = Grid[]
    for sol in solutions
        new_grid = copy(grid)
        for (r, c, n) in sol
            new_grid[r+1, c+1] = n
        end
        push!(result, Grid(R, new_grid))
    end
    return result
end

# solve function overloading for Grid class
function solve_sudoku(g::Grid)
    solve_sudoku((g.n, g.n), g.table)
end

# some helpful functions
function exact_cover(X, Y)
    X_dict = Dict(j => Set() for j in X)
    for (i, row) in Y
        for j in row
            push!(X_dict[j], i)
        end
    end
    return X_dict, Y
end

# put number on yhe tile and delete satisfied restrictions
function select(X, Y, r)
    cols = []
    for j in Y[r]
        for i in copy(X[j])
            for k in Y[i]
                if k ≠ j
                    delete!(X[k], i)
                end
            end
        end
        value = X[j]
        delete!(X, j)
        push!(cols, value)
    end
    return cols
end

# remove number and restore restrictions
function deselect(X, Y, r, cols)
    for j in reverse(Y[r])
        X[j] = pop!(cols)
        for i in X[j]
            for k in Y[i]
                if k ≠ j
                    push!(X[k], i)
                end
            end
        end
    end
end

# solving sudoku
function solve!(X, Y, solution, solutions)
    if isempty(X)
        push!(solutions, copy(solution))
        return
    end
    c = first(keys(X))
    min_len = length(X[c])
    for (k, v) in X
        if length(v) < min_len
            min_len = length(v)
            c = k
        end
    end
    
    for r in collect(X[c])
        push!(solution, r)
        cols = select(X, Y, r)
        solve!(X, Y, solution, solutions)
        deselect(X, Y, r, cols)
        pop!(solution)
    end
end

# make an array of all possible solutions
function solve(X, Y)
    solutions = []
    solve!(X, Y, [], solutions)
    return solutions
end