module CriticalDifferenceDiagrams

using Distributions, Graphs, HypothesisTests, MultipleTesting, Statistics

include("friedman.jl") # should be migrated to HypothesisTests.jl

const PairwiseTest = NamedTuple{(:i, :j, :p),Tuple{Int64,Int64,Float64}} # type alias

"""
    plot(x_1, x_2, ..., x_k; kwargs...)
    plot(X; kwargs...)

Plot a critical difference diagram for `n` repeated observations of `k` treatments.
The observations are arranged in `k` vectors `x_i` of `n` observations each or in
an `(n, k)`-shaped matrix `X`.

# kwargs

- `alpha=0.05` is the significance level in the `FriedmanTest`.
- `names=["t1", "t2", ..., "tk"]` are the names of the `k` treatments.
"""
function plot(X::AbstractMatrix{T}; alpha::Float64=0.05, names::Vector{String}=_defaultnames(size(X, 2))) where T <: Real
    # test whether there are differences at all
    friedman = FriedmanTest(X)
    if pvalue(friedman) >= alpha
        error("No significant differences between treatments at α=$alpha")
    end

    # adjust pair-wise Wilcoxon signed-rank tests with Holm's method
    P = _adjust_pairwise_tests!(
        _pairwise_tests(X, SignedRankTest),
        Holm()
    )

    # find max-cliques of indistinguishable methods
    cliques = _indistinguishable_cliques(P, size(X, 2), alpha)
    return map(clique -> names[clique], cliques) # TODO plot instead of returning the cliques
end
plot(x::AbstractVector{T}...; kwargs...) where T <: Real = plot(hcat(x...); kwargs...)

function _indistinguishable_cliques(P::Vector{PairwiseTest}, k::Int, alpha::Float64)
    g = simple_graph(k; is_directed=false)
    for P_k in P
        if P_k.p >= alpha
            add_edge!(g, P_k.i, P_k.j) # methods are not distinguishable
        end
    end
    return maximal_cliques(g)
end

function _adjust_pairwise_tests!(P::Vector{PairwiseTest}, method::PValueAdjustment)
    adjusted_p = adjust(map(x->x.p, P), method)
    @inbounds for k in 1:length(P)
        P[k] = (; i=P[k].i, j=P[k].j, p=adjusted_p[k])
    end # replace each entry with an adjusted tuple
    return P
end

# the test_constructor must have two arguments and result in a HypothesisTest object
function _pairwise_tests(X::AbstractMatrix{T}, test_constructor::Function) where T <: Real
    k = size(X, 2) # number of treatments
    P = PairwiseTest[]
    for i in 1:k, j in i:k # for each pair of treatments
        push!(P, (;
            i = i,
            j = j,
            p = pvalue(test_constructor(X[:, i], X[:, j]))
        )) # NamedTuple with keys i, j, and p
    end
    return sort!(P; lt = (a, b)->isless(a.p, b.p)) # sort by p-value
end

_defaultnames(k) = ["t$i" for i in 1:k]

end # module
