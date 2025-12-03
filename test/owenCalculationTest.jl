
@testset "Test get_coalitional_structure function" begin
    C = [Inf 1.0 2.0 3.0;
         1.0 Inf 4.0 5.0;
         2.0 4.0 Inf 6.0;
         3.0 5.0 6.0 Inf]
    expected_output = [[1, 2, 3, 4]]
    n = 4
    calculated_output = get_coalitional_structure(C, n)
    @test calculated_output == expected_output

    C = [Inf 0.0 Inf Inf;
         1.0 Inf 2.0 Inf;
         Inf 2.0 Inf 3.0;
         Inf Inf 3.0 Inf]

    expected_output = [[2], [1, 3, 4]]
    calculated_output = get_coalitional_structure(C, n)
    @test calculated_output == expected_output
end

@testset "Test get_all_permutations_owen function" begin
    coalitional_structure = Vector{Vector{Int}}([[2], [1, 3, 4]])
    expected_output = [
        [2, 1, 3, 4],
        [2, 1, 4, 3],
        [2, 3, 1, 4],
        [2, 3, 4, 1],
        [2, 4, 1, 3],
        [2, 4, 3, 1],
        [1, 3, 4, 2],
        [1, 4, 3, 2],
        [3, 1, 4, 2],
        [3, 4, 1, 2],
        [4, 1, 3, 2],
        [4, 3, 1, 2]
    ]
    block_perms = collect(permutations(coalitional_structure))
    calculated_output = get_all_permutations_owen(block_perms)
    @test size(calculated_output) == size(expected_output)
    for i in eachindex(expected_output)
        row = expected_output[i, :]
        @test row in eachrow(calculated_output)
    end

    # Test with single block coalitional structure
    coalitional_structure = Vector{Vector{Int}}([[1, 2, 3]])
    expected_output = [
        [1, 2, 3],
        [1, 3, 2],
        [2, 1, 3],
        [2, 3, 1],
        [3, 1, 2],
        [3, 2, 1]
    ]
    block_perms = collect(permutations(coalitional_structure))
    calculated_output = get_all_permutations_owen(block_perms)
    @test size(calculated_output) == size(expected_output)
    for i in eachindex(expected_output)
        row = expected_output[i, :]
        @test row in eachrow(calculated_output)
    end

    # Test with all singletons coalitional structure
    coalitional_structure = Vector{Vector{Int}}([[1], [2], [3]])
    expected_output = [
        [1, 2, 3],
        [1, 3, 2],
        [2, 1, 3],
        [2, 3, 1],
        [3, 1, 2],
        [3, 2, 1]
    ]
    block_perms = collect(permutations(coalitional_structure))
    calculated_output = get_all_permutations_owen(block_perms)
    @test size(calculated_output) == size(expected_output)
    for i in eachindex(expected_output)
        row = expected_output[i, :]
        @test row in eachrow(calculated_output)
    end
end