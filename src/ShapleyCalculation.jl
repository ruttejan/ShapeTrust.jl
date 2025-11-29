
using Combinatorics
using Random

export exact_shapley, approx_shapley, get_other_indices, calculate_shapley


function get_other_indices(indices, i)
    new_indices = copy(indices)
    deleteat!(new_indices, findall(x -> i in x, indices))
    return new_indices
end

# calculates the shapley value for obtained games
function calculate_shapley(games::Dict, n::Int) 
    # initialize shapley values   
    shapley = zeros(n)
    # extract all coalitions from the games dictionary (keys)
    indices = collect(keys(games))

    # calculate shapley value for each player
    for i in 1:n
        tmp = 0
        # get all coalitions that do not contain player i
        new_indices = get_other_indices(indices, i)
        # enumerate through all coalitions not containing i
        for A in new_indices
            l = length(A) # size of the coalition
            set_with_i = vcat(A, i) # coalition with player i added
            sort!(set_with_i) # sort for looking up in the dictionary of games
            marginal_contribution = games[set_with_i] - games[A] # marginal contribution of i to coalition A
            pA = 1 / (n * binomial(n - 1, l)) # weight of coalition A
            tmp += pA * marginal_contribution
        end

        shapley[i] = tmp
    end

    return shapley
end

# calculates the shapley value while calculating the games on the fly
# (this version is slower but saves memory)
function calculate_shapley(C::Matrix, game::game_type)    
    n = size(C, 1)
    shapley = zeros(n)

    for i in 1:n
        tmp = 0
        j = 0
        indices = [j for j in 1:n if j != i]
        for A in powerset(indices, 0, n-1)
            l = length(A)
            set_with_i = vcat(A, i)
            sort!(set_with_i)
            game_value_with_i = calculate_game(set_with_i, C, game)
            game_value_A = calculate_game(A, C, game)
            marginal_contribution = game_value_with_i - game_value_A

            if isnan(marginal_contribution)
                break
            end
            pA = 1 / (n * binomial(n - 1, l))
            tmp += pA * marginal_contribution
        end
        
        shapley[i] = tmp
    end

    return shapley
end

function approx_shapley(C::Matrix, game::game_type; num_samples::Int=1000000)
    n = size(C, 1)
    peer_sums = zeros(Float64, n)
    shapley = zeros(Float64, n)

    for sample in 1:num_samples
        perm = randperm(n)
        coalition = Int[]
        game_value_prev = 0.0
        for i in perm
            push!(coalition, i)
            sort!(coalition)
            game_value = calculate_game(coalition, C, game)
            marginal_contribution = game_value - game_value_prev
            peer_sums[i] += marginal_contribution
            game_value_prev = game_value
        end

        new_shapley = peer_sums ./ sample
        if all(abs.(shapley - new_shapley) .< 1e-6)
            return new_shapley, sample
        end
        shapley = new_shapley
    end

    return shapley, num_samples
end

function exact_shapley(C::Matrix, game::game_type)
    n = size(C, 1)
    if n > 15
        @warn "Exact Shapley calculation may be very slow for n > 15"
    end

    if n > 22
        @warn "Exact Shapley calculation will be done using less memory-intensive method for n > 22, but it will be very slow"
    end

    shapley = zeros(Float64, n)
    if n > 22
        shapley = calculate_shapley(C, game)
    else
        games, n = get_all_games(C, game)
        shapley = calculate_shapley(games, n)
    end

    return shapley
end
