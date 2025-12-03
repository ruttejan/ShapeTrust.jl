
export decentralized_shapetrust, internal_value, external_value

"""
Calculates the internal part of player {i}'s shapley value based on the trust matrix A.
Average of incoming and outgoing trust values.

# Arguments:
    - `i::Int`: The index of the player for which to calculate the internal value.
    - `A::Matrix{Float64}`: The trust matrix.
# Returns:
    - `Float64`: The internal value of player i.
"""
function internal_value(i::Int, A::Matrix{Float64})
    finiteA = copy(A)
    finiteA[.!isfinite.(finiteA)] .= 0.0
    # average of incoming and outgoing trust values
    return 0.5 * (sum(finiteA[i, :]) + sum(finiteA[:, i]))
end

"""
Calculates the external value for node i based on its neighbors and their incoming values and incoming values of i.

    Arguments:
    - `i::Int`: The index of the node for which to calculate the external value.
    - `neighbors_of_i::Vector{Int}`: The indices of the neighbors of node i (excluding i itself) for which i has some trust.
    - `incoming_values::Dict{Int, Vector{Tuple{Float64, Int}}}`: 
                        A dictionary mapping each neighbor j and i
                        to a vector of tuples (trust value, node index) 
                        representing the incoming trust values to each j and i from other nodes.
# Returns:
    - `Float64`: The external value of node i.
"""
function external_value(i::Int,
                        neighbors_of_i::Vector{Int},
                        incoming_values::Dict{Int, Vector{Tuple{Float64, Int}}})
    first_summand = 0.0
    second_summand = 0.0
    i_incoming_sorted = sort(incoming_values[i], by = x -> x[1])
    i_values = [x[1] for x in i_incoming_sorted]

    mi = length(i_values)
    for t in 1:mi
        b_i_t = i_values[t]
        b_i_t_minus_1 = t == 1 ? 0.0 : i_values[t - 1]
        Δt_i = b_i_t - b_i_t_minus_1
        first_summand += Δt_i / t
        
    end
    if mi != 0
        b_i_mi = i_values[mi]
        first_summand -= b_i_mi / (mi + 1)
    end

    for j in neighbors_of_i
        j_incoming_sorted = sort(incoming_values[j], by = x -> x[1])
        j_values = [x[1] for x in j_incoming_sorted]
        mj = length(j_values)
        rj = findfirst(x -> x[2] == i, j_incoming_sorted)
        # if i is not in incoming neighbors of j, skip - should not happen
        if rj === nothing
            continue
        end

        for t in (rj + 1):mj
            b_j_t = j_values[t]
            b_j_t_minus_1 = t == 1 ? 0.0 : j_values[t - 1]
            Δt_j = b_j_t - b_j_t_minus_1
            second_summand += Δt_j / t
        end
        if mj != 0
            b_j_mj = j_values[mj]
            second_summand -= b_j_mj / (mj + 1)
        end
    end
    
    return first_summand + second_summand
end

"""
Calculates the Shapetrust values for all players based on the trust matrix A in a decentralized manner.
Works only for shapleyConcept() with minGame().

# Arguments:
    - `A::Matrix{Float64}`: The trust matrix.
# Returns:
    - `Vector{Float64}`: The Shapetrust values for all players
"""
function decentralized_shapetrust(A::Matrix{Float64})
    n = size(A, 1)
    phi = zeros(Float64, n)
    for i in 1:n
        # neighbors_of_i: indices j where A[i,j] is finite
        neighbors_of_i = findall(x -> isfinite(x), A[i, :])

        neighbors_with_i = copy(neighbors_of_i)
        # include i itself
        push!(neighbors_with_i, i)

        # dictionary mapping each neighbor j and i
        # to a vector of tuples (trust value, node index) of incoming trust values
        # to each j and i from other nodes
        incoming_values = Dict{Int, Vector{Tuple{Float64, Int}}}()
        for j in neighbors_with_i
            in_idx = findall(x -> isfinite(x), A[:, j])
            incoming_list = Vector{Tuple{Float64, Int}}()
            for p in in_idx
                push!(incoming_list, (A[p, j], p))
            end
            incoming_values[j] = incoming_list
        end

        # calculate internal and external values for i
        int = internal_value(i, A)
        ext = external_value(i, neighbors_of_i, incoming_values)

        phi[i] = int + ext
    end
    return phi
end