# ShapeTrust

This package aims to implement ShapeTrust algorithm, which is a trust management algorithm that takes a trust matrix (local trusts of peers in a decentralized network) on input and returns global trust values for each peer.

There are multiple ways to calculate the values that differ in implementation of solution concepts (Shapley and Owen) and game definitions that differ in the external part (Min and Avg).

The main output is the "shapetrust()" function which takes the matrix as an input. Furthermore it takes arguments defining the solution concept, game definition and version of the algorithm (exact, approximate or decentralized calculation). For argument details see the function's docstring.

This package also provides function for generating a random matrix with trust values on interval [0, 1>. The inputs of this function are the number of peers and the level of sparsity of the network. See the docstring for more details.

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

matrix = gen_matrix(14)

@time exact_cen = shapetrust(matrix, shapleyConcept(), minGame())
@time exact_decen = shapetrust(matrix, shapleyConcept(), minGame(), decen=true)
@time approx_cen = shapetrust(matrix, shapleyConcept(), minGame(), approx=true, accuracy=1e-5)
println("Exact Centralized: ", exact_cen)
println("Exact Decentralized: ", exact_decen)
println("Approximate Centralized: ", approx_cen)
```