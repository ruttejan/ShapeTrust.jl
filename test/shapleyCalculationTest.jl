
@testset "Test get_other_indices function" begin
    indices = [[1, 2], [1, 3], [2, 3], [1], [2], [3], []]
    i = 2
    expected_output = [[1, 3], [1], [3], []]
    calculated_output = get_other_indices(indices, i)
    @test calculated_output == expected_output
end

@testset "Test calculate_shapley function" begin
    C = [Inf 1.0 2.0;
         1.0 Inf 3.0;
         2.0 3.0 Inf]
    game = minGame()
    expected_shapley = [10/3, 46/12, 58/12]
    calculated_shapley1 = calculate_shapley(C, game)
    games, n = get_all_games(C, game)
    calculated_shapley2 = calculate_shapley(games, n)
    @test expected_shapley ≈ calculated_shapley1 atol=1e-6
    @test expected_shapley ≈ calculated_shapley2 atol=1e-6

    game = avgGame()
    expected_shapley = [3.25, 4.0, 4.75]
    calculated_shapley1 = calculate_shapley(C, game)
    games, n = get_all_games(C, game)
    calculated_shapley2 = calculate_shapley(games, n)
    @test expected_shapley ≈ calculated_shapley1 atol=1e-6  
    @test expected_shapley ≈ calculated_shapley2 atol=1e-6
end