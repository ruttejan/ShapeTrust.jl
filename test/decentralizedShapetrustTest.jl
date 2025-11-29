
@testset "Test internal_value function" begin
    A = [Inf 0.5 0.2;
         0.1 Inf 0.3;
         0.4 0.6 Inf]
    expected_internal_values = [
        (0.7 + 0.5) / 2,  # Player 1
        (0.4 + 1.1) / 2,  # Player 2
        (0.5 + 1.0) / 2   # Player 3
    ]
    for i in 1:3
        calculated_value = internal_value(i, A)
        @test calculated_value == expected_internal_values[i]
    end
end

@testset "Test external_value function" begin
    A = [Inf 0.5 0.2 Inf;
         0.1 Inf 0.3 0.4;
         Inf Inf Inf 0.6;
         0.7 Inf Inf Inf]
    neighbors_dict = Dict(
        1 => [2, 4],
        2 => [1],
        3 => [1, 2],
        4 => [2, 3]
    )

    incoming_values = Dict(
        1 => [(0.1, 2), (0.7, 4)],
        2 => [(0.5, 1)],
        3 => [(0.2, 1), (0.3, 2)],
        4 => [(0.4, 2), (0.6, 3)]
    )
    expected_external_values = [
       -0.0833333, # Player 1
       0.3166667,  # Player 2
       0.15,       # Player 3
       0.3         # Player 4
    ]
    for i in 1:4
        calculated_value = external_value(i, neighbors_dict[i], incoming_values)
        @test calculated_value ≈ expected_external_values[i] atol=1e-6
    end
end