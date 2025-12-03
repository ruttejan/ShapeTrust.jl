# ShapeTrust

This package aims to implement ShapeTrust algorithm, which is a trust managementalgorithm that takes a trust matrix (local trusts of peers in a decentralized network) on input and returns global trust values for each peer.

There are multiple ways to calculate the values. There are implemented 2 solution concepts (Shapley and Owen) and two different game definitions that differ in the external part (Min and Avg).

# Instalation

This package is not registered and therefore can be installed only in the following ways:

In the julia terminal.

```
julia> ]
pkg> add https://github.com/ruttejan/ShapeTrust.jl
```

Directly in a julia source code file.

```
using Pkg
Pkg.add(url="https://github.com/ruttejan/ShapeTrust.jl")
```

# Example

After you install this package you can use it in source code files like this:

```
using ShapeTrust

# generates a matrix with values between 0 and 1
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

matrix = gen_matrix(14)

@time exact_cen = shapetrust(matrix, shapleyConcept(), minGame())
@time exact_decen = shapetrust(matrix, shapleyConcept(), minGame(), decen=true)
@time approx_cen = shapetrust(matrix, shapleyConcept(), minGame(), approx=true, accuracy=1e-5)
println("Exact Centralized: ", exact_cen)
println("Exact Decentralized: ", exact_decen)
println("Approximate Centralized: ", approx_cen)
```