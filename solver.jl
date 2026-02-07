using Base.Iterators

function solve_sudoku(size, grid)
    R, C = size
    N = R * C

    X = vcat(
        [("rc", rc) for rc in product(0:N-1, 0:N-1)],
        [("rn", rn) for rn in product(0:N-1, 1:N)],
        [("cn", cn) for cn in product(0:N-1, 1:N)],
        [("bn", bn) for bn in product(0:N-1, 1:N)]
    )
    
    Y = Dict{Tuple{Int,Int,Int}, Vector{Tuple{String, Tuple{Int,Int}}}}()
    for (r, c, n) in product(0:N-1, 0:N-1, 1:N)
        b = div(r, R) * R + div(c, C)  # Box number
        Y[(r, c, n)] = [
            ("rc", (r, c)),
            ("rn", (r, n)),
            ("cn", (c, n)),
            ("bn", (b, n))]
    end
    
    X_dict, Y = exact_cover(X, Y)
    
    for i in 1:N
        for j in 1:N
            n = grid[i][j]
            if n ≠ 0
                select(X_dict, Y, (i-1, j-1, n))
            end
        end
    end
    
    solutions = []
    for solution in solve(X_dict, Y)
        push!(solutions, copy(solution))
    end
    
    for solution in solutions
        new_grid = deepcopy(grid)
        for (r, c, n) in solution
            new_grid[r + 1][c + 1] = n
        end
        display(new_grid)
        println()
    end
end

function exact_cover(X, Y)
    X_dict = Dict(j => Set() for j in X)
    for (i, row) in Y
        for j in row
            push!(X_dict[j], i)
        end
    end
    return X_dict, Y
end

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

function solve(X, Y)
    solutions = []
    solve!(X, Y, [], solutions)
    return solutions
end

# Тестовый пример
grid = [
    [5, 0, 9, 6, 7, 2, 0, 8, 0],
    [8, 0, 3, 9, 0, 1, 2, 7, 0],
    [2, 0, 7, 0, 0, 8, 0, 9, 0],
    [3, 7, 8, 2, 1, 6, 5, 4, 9],
    [6, 5, 4, 8, 9, 0, 0, 0, 2],
    [1, 9, 2, 0, 0, 5, 8, 6, 0],
    [7, 3, 1, 5, 6, 4, 9, 2, 8],
    [9, 8, 5, 0, 2, 0, 6, 0, 4],
    [4, 2, 6, 0, 8, 9, 0, 5, 0]
]

solve_sudoku((3, 3), grid)