using Combinatorics
using LinearAlgebra
using Random

export exact_owen, approx_owen, get_coalitional_structure, get_all_permutations_owen


# Function that creates sets that form the coalitional structure
# All players that received a 0 trust from any other player form a singleton and the rest form one big set
function get_coalitional_structure(C::Matrix, n::Integer)
    coal_structure = []
    rest = []
    for i in 1:n
        if !isempty(findall(x -> x == 0.0, C[:, i]))
            push!(coal_structure, [i])
        else
            push!(rest, i)
        end
    end
    push!(coal_structure, rest)
    return coal_structure
end

function get_all_permutations_owen(block_perms)
    final_perms = []

    # get all permutations of the big block
    rest_block_perms = []
    for j in eachindex(block_perms[1])
        if !(typeof(block_perms[1][j]) == Vector{Int64})
            rest_block_perms = collect(permutations(block_perms[1][j]))     
        end
    end


    # create all final permutations by inserting all big block permutations in the place where the big block was before for each block permutationss
    for i in eachindex(block_perms)
        for j in eachindex(block_perms[i])
            if !(typeof(block_perms[i][j]) == Vector{Int64})
                for r in eachrow(rest_block_perms)
                    push!(final_perms, collect(Iterators.flatten(vcat(block_perms[i][1:j-1], r, block_perms[i][j+1:end]))))
                end
            end
        end
    end
    return final_perms
end

function exact_owen(C::Matrix, game::game_type=minGame())
    games, n = get_all_games(C, game)
    coal_structure = get_coalitional_structure(C, n)
    block_perms = collect(permutations(coal_structure))
    
    final_perms = get_all_permutations_owen(block_perms)
    peer_sums = zeros(Float64, n)

    # calculation of owen (shapley) values from players permutations
    for perm in eachrow(final_perms)
        # perm is an array which has the form of 2d array
        perm = perm[1] # flatten it to 1d
        coalition = Int[]
        game_value_prev = 0.0
        for i in perm
            push!(coalition, i)
            sort!(coalition)
            game_value = games[coalition]
            marginal_contribution = game_value - game_value_prev
            peer_sums[i] += marginal_contribution
            game_value_prev = game_value
        end
    end

    # average with the number of permutations
    owen_values = peer_sums ./ length(final_perms)
    return owen_values
end


function approx_owen(C::Matrix, game::game_type=minGame(); num_samples::Int=10000000)
    n = size(C, 1)
    coal_structure = get_coalitional_structure(C, n)
    peer_sums = zeros(Float64, n)

    owen_values = zeros(Float64, n)

    for sample in 1:num_samples
        # shuffle the coalitional structure
        shuffled_blocks = shuffle(coal_structure)
        # within each block shuffle the players
        perm = []
        for block in shuffled_blocks
            shuffled_block = shuffle(block)
            append!(perm, shuffled_block)
        end

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

        new_owen_values = peer_sums ./ sample
        if all(abs.(new_owen_values - owen_values) .< 1e-6)
            return new_owen_values, sample
        end
        owen_values = new_owen_values
    end

    return owen_values, num_samples
end