
@testset "Test Shapley vs Owen for various game types and settings with no zero trust values" begin
    # Write your tests here.
    A = [Inf 0.5 0.2 Inf;
         0.1 Inf 0.3 0.4;
         Inf Inf Inf 0.6;
         0.7 Inf Inf Inf]
    
    # Test Shapley vs Owen for various game types and settings
    # No zero trust values in A means both should be equal

    # Exact calculations Shapley vs Owen for minGame
    sh = shapetrust(A, shapleyConcept(), minGame())
    ow = shapetrust(A, owenConcept(), minGame())
    @test sh ≈ ow atol=1e-6

    # Exact calculations Shapley vs Owen for avgGame
    sh = shapetrust(A, shapleyConcept(), avgGame())
    ow = shapetrust(A, owenConcept(), avgGame())
    @test sh ≈ ow atol=1e-6

    # Approximate calculations Shapley vs Owen for minGame
    sh = shapetrust(A, shapleyConcept(), minGame(), approx=true, accuracy=1e-7)
    ow = shapetrust(A, owenConcept(), minGame(), approx=true, accuracy=1e-7)
    @test sh ≈ ow atol=1e-1

    # Approximate calculations Shapley vs Owen for avgGame
    sh = shapetrust(A, shapleyConcept(), avgGame(), approx=true, accuracy=1e-7)
    ow = shapetrust(A, owenConcept(), avgGame(), approx=true, accuracy=1e-7)
    @test sh ≈ ow atol=1e-1
end

@testset "Test exact Owen vs approximate Owen for various game types with some zero trust values" begin
    # Write your tests here.
    A = [Inf 0.5 0.0 Inf;
         0.1 Inf 0.3 0.4;
         0.0 Inf Inf 0.6;
         0.7 Inf Inf Inf]
    
    # Test exact Owen vs approximate Owen for various game types with some zero trust values

    # Exact calculations Owen for minGame
    ow_exact = shapetrust(A, owenConcept(), minGame())
    # Approximate calculations Owen for minGame
    ow_approx = shapetrust(A, owenConcept(), minGame(), approx=true, accuracy=1e-7)
    @test ow_exact ≈ ow_approx atol=1e-1

    # Exact calculations Owen for avgGame
    ow_exact = shapetrust(A, owenConcept(), avgGame())
    # Approximate calculations Owen for avgGame
    ow_approx = shapetrust(A, owenConcept(), avgGame(), approx=true, accuracy=1e-7)
    @test ow_exact ≈ ow_approx atol=1e-1
end

@testset "Test Decentralized Shapetrust vs Exact Shapetrust for minGame" begin
    # Write your tests here.
    A = [Inf 0.5 0.2 Inf;
         0.1 Inf 0.3 0.4;
         Inf Inf Inf 0.6;
         0.7 Inf Inf Inf]
    
    # Test Decentralized Shapetrust vs Exact Shapetrust for minGame
    sh_exact = shapetrust(A, shapleyConcept(), minGame())
    sh_decentralized = shapetrust(A, shapleyConcept(), minGame(), decen=true)
    @test sh_exact ≈ sh_decentralized atol=1e-6
end