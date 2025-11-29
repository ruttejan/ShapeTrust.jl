using ShapeTrust


# example 5x5 matrix
A = [Inf 1.0 Inf Inf;
    1.0 Inf 2.0 Inf;
    Inf 2.0 Inf 3.0;
    Inf Inf 3.0 Inf]

@time sh_exact = shapetrust(A, shapleyConcept(), minGame());
@time ow = shapetrust(A, owenConcept(), minGame());
@time dec = shapetrust(A, shapleyConcept(), minGame(), decen=true);
diff1 = maximum(abs.(ow - sh_exact))
diff2 = maximum(abs.(dec - sh_exact))
println("Max difference Owen vs Exact Shapley: ", diff1)
println("Max difference Decentralized Shapley vs Exact Shapley: ", diff2)


