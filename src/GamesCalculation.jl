using Combinatorics

export get_all_games, get_all_external_games, calculate_game, external_game, internal_game

function internal_game(C::Matrix, indices_collection::Vector{Int})
    partial_matrix = C[indices_collection, indices_collection]
    # here we can substitute undefined values with 0
    partial_matrix[findall(x -> x == Inf, partial_matrix)] .= 0 
    return sum(partial_matrix)
end

function external_game(C::Matrix, indices_complement, indices_collection, game::minGame)
    partial_matrix = C[indices_complement, indices_collection]
    # minimum from incoming edges
    mins = minimum.(eachcol(partial_matrix))
    mins[findall(x -> mins[x] == Inf, 1:length(mins))] .= 0
    return sum(mins)
end

function external_game(C::Matrix, indices_complement, indices_collection, game::avgGame)
    partial_matrix = C[indices_complement, indices_collection]
    # sum of averages from incoming edges
    # get number of elements in each column that are not Inf
    counts = [count(x -> x != Inf, col) for col in eachcol(partial_matrix)]
    partial_matrix[findall(x -> x == Inf, partial_matrix)] .= 0
    # get averages from each column
    avgs = sum.(eachcol(partial_matrix)) ./ counts
    avgs[findall(x -> isnan(x), avgs)] .= 0
    return sum(avgs)
end

function get_all_games(C::Matrix, game::game_type)
    n = size(C, 1)

    tmp = [i for i in 1:n]

    indices_collection = collect(powerset(tmp, 0,n))
    indices_complement = [setdiff(tmp, x) for x in indices_collection]

    m = length(indices_collection)
    games = Dict{Array, Float64}()
    games[indices_collection[1]] = 0
    for i in 2:m

        tmp = 0
        # first part of the game equation (sum of all edges)
        tmp += internal_game(C, indices_collection[i])

        # second part of the game equation (minimum from edges)
        if !isempty(indices_complement[i])
            tmp += external_game(C, indices_complement[i], indices_collection[i], game)
        end
        
        games[indices_collection[i]] = tmp
    end

    return games, n
end

function calculate_game(coalition::Vector{Int}, C::Matrix, game::game_type)
    if isempty(coalition)
        return 0.0
    end
    coalition_complement = setdiff([i for i in 1:size(C, 1)], coalition)

    tmp = internal_game(C, coalition)

    if isempty(coalition_complement)
        return tmp
    end

    tmp += external_game(C, coalition_complement, coalition, game)

    return tmp
end

# Compute the min and max marginal contribution for minGame
function min_max_marginal_contribution_of_i(C::Matrix, i::Int, game::minGame)
    n = size(C)[1]
    Ccopy = copy(C)
    Ccopy[findall(x -> x == Inf, Ccopy)] .= 0
    xmaxi = 0
    xmini = 0
    rowi = Ccopy[i, :]
    coli = Ccopy[:, i]
    xmaxi += sum(rowi) + sum(coli)
    xmini += xmaxi
    for j in setdiff(1:n, [i])
        max_val = maximum([Ccopy[j, k] - Ccopy[j, i] for k in setdiff(1:n, [i])])
        xmaxi += max_val
    end
    
    return xmini, xmaxi
end

# Compute the min and max marginal contribution for avgGame
function min_max_marginal_contribution_of_i(C::Matrix, i::Int, game::avgGame)
    n = size(C)[1]
    Ccopy = copy(C)
    Ccopy[findall(x -> x == Inf, Ccopy)] .= 0
    xmaxi = 0
    xmini = 0
    rowi = Ccopy[i, :]
    coli = Ccopy[:, i]
    xmaxi += sum(rowi) + sum(coli)
    for j in setdiff(1:n, [i])
        max_val = maximum([Ccopy[j, k] - Ccopy[j, i] for k in setdiff(1:n, [i])])
        xmaxi += max_val / 2
    end
    
    return xmini, xmaxi
end

# Calculate number of samples for approximation defined in Castro et al. 2009
# Javier Castro, Daniel Gómez, Juan Tejada,
# Polynomial calculation of the Shapley value based on sampling,
# Computers & Operations Research,
# Volume 36, Issue 5,
# 2009,
# Pages 1726-1730,
# ISSN 0305-0548,
# https://doi.org/10.1016/j.cor.2008.04.004.
# (https://www.sciencedirect.com/science/article/pii/S0305054808000804)
function calculate_num_samples(C::Matrix, game::game_type)
    n = size(C)[1]
    xmax = 0
    xmin = Inf
    
    for i in 1:n
        xmini, xmaxi = min_max_marginal_contribution_of_i(C, i, game)
        if xmaxi > xmax
            xmax = xmaxi
        end
        if xmini < xmin
            xmin = xmini
        end
    end

    Z = 2.576 # for alpha 0.99 - probability
    e = 10^(-4) # error
    num_samples = (Z^2 / (4 * e)) * (xmax - xmin)^2

    num_samples = round(Int, num_samples)
    return num_samples
end

