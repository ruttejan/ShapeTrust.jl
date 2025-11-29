

@testset "Test internal_game function" begin
    C = [Inf 1.0 2.0;
         1.0 Inf 3.0;
         2.0 3.0 Inf]
    indices_collection = [1, 2]
    expected_output = 2.0
    calculated_output = internal_game(C, indices_collection)
    @test calculated_output == expected_output
end

@testset "Test external_game function" begin
    C = [Inf 1.0 2.0;
         1.0 Inf 3.0;
         2.0 3.0 Inf]
    indices_complement = [1]
    indices_collection = [2, 3]
    game = minGame()
    expected_output = 3.0 # (C[1,2] + C[1,3])
    calculated_output = external_game(C, indices_complement, indices_collection, game)
    @test calculated_output == expected_output
end

@testset "Test get_all_games function" begin
    C = [Inf 1.0 2.0;
         1.0 Inf 3.0;
         2.0 3.0 Inf
        ]
    
    # get all games for minGame
    game = minGame()
    expected_games = Dict{Vector{Int}, Float64}()
    expected_games[[]] = 0.0
    expected_games[[1]] = 1.0
    expected_games[[2]] = 1.0
    expected_games[[3]] = 2.0
    expected_games[[1, 2]] = 7.0
    expected_games[[1, 3]] = 8.0
    expected_games[[2, 3]] = 9.0
    expected_games[[1, 2, 3]] = 12.0
    games, n = get_all_games(C, game)
    @test length(games) == 8  # 2^3 coalitions
    @test n == 3
    for (coalition, value) in expected_games
        @test games[coalition] == value
    end

    # get all games for avgGame
    game = avgGame()
    expected_games = Dict{Vector{Int}, Float64}()
    expected_games[[]] = 0.0
    expected_games[[1]] = 1.5
    expected_games[[2]] = 2.0
    expected_games[[3]] = 2.5
    expected_games[[1, 2]] = 7.0
    expected_games[[1, 3]] = 8.0
    expected_games[[2, 3]] = 9.0
    expected_games[[1, 2, 3]] = 12.0
    games, n = get_all_games(C, game)
    @test length(games) == 8  # 2^3 coalitions
    @test n == 3
    for (coalition, value) in expected_games
        @test games[coalition] == value
    end
end

@testset "Test calculate_game function" begin
    C = [Inf 1.0 2.0;
         1.0 Inf 3.0;
         2.0 3.0 Inf]
    coalition = [1, 2]
    game = minGame()
    expected_output = 7.0
    calculated_output = calculate_game(coalition, C, game)
    @test calculated_output == expected_output

    coalition = [2]
    game = avgGame()
    expected_output = 2.0
    calculated_output = calculate_game(coalition, C, game)
    @test calculated_output == expected_output
end