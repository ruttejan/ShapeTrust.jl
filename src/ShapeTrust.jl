module ShapeTrust

include("SolutionConceptsEnum.jl")
include("GameTypesEnum.jl")
include("GamesCalculation.jl")
include("ShapleyCalculation.jl")
include("OwenCalculation.jl")
include("DecentralizedShapetrust.jl")


export shapetrust, shapleyConcept, owenConcept, minGame, avgGame, get_coalitional_structure



function shapetrust(TrustMatrix::Matrix{Float64}
                    ,sol_concept::solution_concept
                    ,game_type::game_type
                    ;approx::Bool=false
                    , decen::Bool=false
                    )

    # check - trust matrix dimensions
    if size(TrustMatrix, 1) != size(TrustMatrix, 2)
        error("TrustMatrix must be square")
    end

    # check - only numeric values and Inf
    if !all(x -> (isa(x, Number) || x == Inf), TrustMatrix)
        error("TrustMatrix must contain only numeric values or Inf")
    end

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

end # End of module ShapeTrust
