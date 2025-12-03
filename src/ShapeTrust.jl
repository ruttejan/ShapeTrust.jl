module ShapeTrust

include("SolutionConceptsEnum.jl")
include("GameTypesEnum.jl")
include("GamesCalculation.jl")
include("ShapleyCalculation.jl")
include("OwenCalculation.jl")
include("DecentralizedShapetrust.jl")


export shapetrust, shapleyConcept, owenConcept, minGame, avgGame, get_coalitional_structure, gen_matrix


"""
ShapeTrust calculation function.
Calls appropriate calculation methods based on the provided solution concept, game type and calculation flags.

# Arguments
- `TrustMatrix::Matrix{Float64}`: Trust matrix representing the trust relationships between agents
- `sol_concept::solution_concept`: Solution concept to use (shapleyConcept() or owenConcept())
- `game_type::game_type`: Game type to use (minGame() or avgGame())
- `approx::Bool=false`: Whether to use approximation for the calculation
- `decen::Bool=false`: Whether to use decentralized calculation (only for Shapley with Min game)
- `accuracy::Float64=1e-4`: Desired accuracy for approximation methods (only used if `approx` is true) - defaults to 1e-4 for faster convergence
# Returns
- `global_values::Vector{Float64}`: Calculated global trust values for each agent

# Errors
- If `TrustMatrix` is not square
- If `TrustMatrix` contains non-numeric values or values other than Inf
- If `TrustMatrix` has self loops (diagonal elements not Inf)
- If `game_type` is not recognized
- If `sol_concept` is not recognized
- If both `approx` and `decen` are true
- If `decen` is true but `sol_concept` is not shapleyConcept() or `game_type` is not minGame()
# Examples
```julia
using ShapeTrust
A = [Inf 0.5 0.2;
     0.3 Inf 0.4; 
     0.6 0.1 Inf]
# Exact (Centralized) Shapetrust values
values = shapetrust(A, shapleyConcept(), minGame())
# Approximate (Centralized) Shapetrust values
values_approx = shapetrust(A, shapleyConcept(), minGame(); approx=true)
# Exact (Decentralized) Shapetrust values - fastest method for Shapetrust
# Note: Decentralized calculation is only supported for Shapley concept with Min game
values_decen = shapetrust(A, shapleyConcept(), minGame(); decen=true)

# Owen values and Avg game
values_owen = shapetrust(A, owenConcept(), avgGame(), approx=true, accuracy=1e-4)

```

"""
function shapetrust(TrustMatrix::Matrix{Float64}
                    ,sol_concept::solution_concept
                    ,game_type::game_type
                    ;approx::Bool=false
                    , decen::Bool=false
                    , accuracy::Float64=1e-4
                    )

    # check - trust matrix dimensions
    if size(TrustMatrix, 1) != size(TrustMatrix, 2)
        error("TrustMatrix must be square")
    end

    # check - only numeric values and Inf
    if !all(x -> (isa(x, Number) || x == Inf), TrustMatrix)
        error("TrustMatrix must contain only numeric values or Inf")
    end

    # number of players
    n = size(TrustMatrix, 1)

    # check - no self loops
    if any(TrustMatrix[i, i] != Inf for i in 1:n)
        error("TrustMatrix must not have self loops (diagonal elements must be Inf)")
    end

    # check - game type
    if game_type != minGame() && game_type != avgGame()
        error("Unknown game type - must be minGame() or avgGame()")
    end

    # check - solution concept
    if sol_concept != shapleyConcept() && sol_concept != owenConcept()
        error("Unknown solution concept - must be shapleyConcept() or owenConcept()")
    end

    # check - approximation flag and decentralized flag
    if decen && approx
        error("Decentralized calculation cannot be done with approximation")
    end

    global_values = zeros(Float64, n)
    # decentralized calculation
    if decen
        # check - only shapley with min game is supported
        if sol_concept != shapleyConcept() || game_type != minGame()
            error("Decentralized calculation is only supported for Shapley concept with Min game")
        end
        global_values = decentralized_shapetrust(TrustMatrix)
    end

    # centralized calculation
    if sol_concept == shapleyConcept()
        if approx # use approximation
            num_samples = calculate_num_samples(TrustMatrix, game_type)
            # println("Using approx Shapley with ", num_samples, " samples")
            # println("Number of permutations: ", factorial(size(TrustMatrix, 1)))
            global_values, num_used_samples = approx_shapley(TrustMatrix, game_type, num_samples=num_samples)
            # println("Number of used samples: ", num_used_samples)
        else # calculate exactly
            global_values = exact_shapley(TrustMatrix, game_type)
        end

    elseif sol_concept == owenConcept()
        if approx # use approximation
            num_samples = calculate_num_samples(TrustMatrix, game_type)
            # println("Using approx Owen with ", num_samples, " samples")
            # println("Number of permutations: ", factorial(size(TrustMatrix, 1)))
            global_values, num_used_samples = approx_owen(TrustMatrix, game_type, num_samples=num_samples)
            # println("Number of used samples: ", num_used_samples)
        else # calculate exactly
            global_values = exact_owen(TrustMatrix, game_type)
        end
    end
    return global_values
end


"""
Generate a random trust matrix of size n x n with no self loops and with random trust values between 0 and 1, and Inf for no trust. 

# Arguments:
- `n::Int`: Number of players
# Returns:
- `Matrix{Float64}`: Generated trust matrix with random trust values and Inf for no trust
"""
function gen_matrix(n::Int)
    A = zeros(Float64, n, n)
    for i in 1:n
        for j in 1:n
            if i != j
                A[i, j] = rand() < 0.5 ? rand() : Inf # 50% chance of being Inf
            else
                A[i, j] = Inf
            end
        end
    end
    return A
end

end # End of module ShapeTrust
