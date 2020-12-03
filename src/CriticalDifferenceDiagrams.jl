module CriticalDifferenceDiagrams

using Distributions, Graphs, HypothesisTests, MultipleTesting, Requires, Statistics

function __init__()
    @require DataFrames="a93c6f00-e57d-5684-b7b6-d8193f3e46c0" include("dataframes.jl")
end

include("friedman.jl") # should be migrated to HypothesisTests.jl

_DOC = """
The input data are arranged in treatments `t_i => x_i`, each of which has a name `t_i` and
`n` associated observations `x_i`. You can omit the names, either providing the separate
`x_i` alone or by providing all observations as a single `(n, k)`-shaped matrix `X`.
Alternatively, you can provide a DataFrame `df` with the columns `treatment`, `observation`,
and `outcome`.

The analysis starts with a `FriedmanTest` to check if any of the treatments differ. If so,
the differences between each pair of treatments is checked with a Holm-adjusted Wilcoxon
`SignedRankTest`. The cliques represent groups of treatments which are not significantly
distinguishable from each other.

# kwargs

- `alpha=0.05` is the significance level in the hypothesis tests.
""" # basic documentation

"""
    plot(t_1 => x_1, t_2 => x_2, ..., t_k =>  x_k; kwargs...)
    plot(x_1, x_2, ..., x_k; kwargs...)
    plot(X; kwargs...)
    plot(df, treatment, observation, outcome; kwargs...)

Plot a critical difference diagram for `n` repeated observations of `k` treatments.

$(_DOC)
"""
function plot end

"""
    ranks_and_cliques(t_1 => x_1, t_2 => x_2, ..., t_k =>  x_k; kwargs...)
    ranks_and_cliques(x_1, x_2, ..., x_k; kwargs...)
    ranks_and_cliques(X; kwargs...)
    ranks_and_cliques(df, treatment, observation, outcome; kwargs...)

Return a tuple `(avg_ranks, cliques)` of the average ranks of `k` treatments in
`n` repeated observations, together with the cliques of indistinguishable treatments.

$(_DOC)
"""
function ranks_and_cliques(x::Pair{String, T}...; kwargs...) where T <: AbstractVector
    x_keys, x_values = collect.(zip(x...)) # split pairs
    ranks, cliques = ranks_and_cliques(x_values...; kwargs...)
    rankperm = sortperm(ranks)
    return x_keys[rankperm] .=> ranks[rankperm], map(clique -> x_keys[clique], cliques)
end

ranks_and_cliques(x::AbstractVector{T}...; kwargs...) where T <: Real =
    ranks_and_cliques(hcat(x...); kwargs...)

function ranks_and_cliques(X::AbstractMatrix{T}; alpha::Float64=0.05) where T <: Real
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
    return average_ranks(friedman), _indistinguishable_cliques(P, size(X, 2), alpha)
end

const _PairwiseTest = NamedTuple{(:i, :j, :p),Tuple{Int64,Int64,Float64}} # type alias

function _indistinguishable_cliques(P::Vector{_PairwiseTest}, k::Int, alpha::Float64)
    g = simple_graph(k; is_directed=false)
    for P_k in P
        if P_k.p >= alpha
            add_edge!(g, P_k.i, P_k.j) # methods are not distinguishable
        end
    end
    return maximal_cliques(g)
end

function _adjust_pairwise_tests!(P::Vector{_PairwiseTest}, method::PValueAdjustment)
    adjusted_p = adjust(map(x->x.p, P), method)
    @inbounds for k in 1:length(P)
        P[k] = (; i=P[k].i, j=P[k].j, p=adjusted_p[k])
    end # replace each entry with an adjusted tuple
    return P
end

# the test_constructor must have two arguments and result in a HypothesisTest object
function _pairwise_tests(X::AbstractMatrix{T}, test_constructor::Function) where T <: Real
    k = size(X, 2) # number of treatments
    P = _PairwiseTest[]
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
