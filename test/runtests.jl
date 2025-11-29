# All imports needed for the all test files
using ShapeTrust
using Combinatorics
using Test

# All test files
include("gamesCalculationTest.jl")
include("shapleyCalculationTest.jl")
include("owenCalculationTest.jl")
include("decentralizedShapetrustTest.jl")
include("shapetrustTest.jl")