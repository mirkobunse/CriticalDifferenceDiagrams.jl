#
# CriticalDifferenceDiagrams.jl
# Copyright 2020-2021 Mirko Bunse
#
#
# Plot CD diagrams in Julia.
#
#
# CriticalDifferenceDiagrams.jl is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with CriticalDifferenceDiagrams.jl.  If not, see <http://www.gnu.org/licenses/>.
#
module CriticalDifferenceDiagrams

using Distributions, Graphs, HypothesisTests, MultipleTesting, PGFPlots, Requires, Statistics

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
the differences between each pair of treatments is checked with a Holm-adjusted or
Bonferroni-adjusted Wilcoxon `SignedRankTest`. The cliques represent groups of treatments
which are not significantly distinguishable from each other.

# kwargs

- `alpha=0.05` is the significance level in the hypothesis tests.
- `maximize_outcome=false` specifies whether the ranks represent a maximization or a
  minimization of the outcomes.
- `adjustment=:holm` specifies the adjustment method (`:holm` or `:bonferroni`).
""" # basic documentation

"""
    plot(t_1 => x_1, t_2 => x_2, ..., t_k =>  x_k; kwargs...)
    plot(df, treatment, observation, outcome; kwargs...)

Return a `PGFPlots` axis which contains a critical difference diagram for `n` repeated
observations of `k` treatments.

$(_DOC)
- `title=nothing` is an optional string to be printed above the diagram.
- `reverse_x=false` reverses the direction of the x axis from right-to-left (default) to
  left-to-right.

# 2-dimensional sequences of CD diagrams

You can arrange a sequence of CD diagrams in a single 2-dimensional axis. In the following,
each item in the sequence consists of a pair `s_i => [args_i...]` of the item's name `s_i`
and the regular CD diagram arguments `args_i...` that are documented above.

    plot(
        s_1 => [t_11 => x_11, t_12 => x_12, ..., t_1k =>  x_1k],
        s_2 => [t_21 => x_21, t_22 => x_22, ..., t_2k =>  x_2k],
        ...,
        s_j => [t_j1 => x_j1, t_j2 => x_j2, ..., t_jk =>  x_jk];
        kwargs...
    )
"""
function plot(x::Pair{String, T}...; title::Union{String,Nothing}=nothing, reverse_x::Bool=false, kwargs...) where T <: AbstractVector
    treatments, outcomes = collect.(zip(x...)) # separate the pairs
    ranks, cliques = ranks_and_cliques(outcomes...; kwargs...)
    cliques = filter(c_i -> length(c_i) > 1, cliques) # only plot cliques of size >= 2
    k = length(treatments)
    c = length(cliques)

    # axis with one layer per clustering
    changepoint = ceil(Int, k/2) # where to change from left to right
    a = Axis(style = _axis_style(k, changepoint, reverse_x), title=title)
    if !reverse_x && !iseven(k)
        changepoint -= 1
    end
    for (i, j) in enumerate(sortperm(ranks))
        push!(a, _treatment_command(
            treatments[j],
            ranks[j],
            (i <= changepoint ? 1 : k) * 1.0, # xpos is either 1 or k
            if reverse_x
                0.5 + (i <= changepoint ? i : k - i + (iseven(k) ? 1.0 : 1.5))
            else
                (iseven(k) ? 0.0 : 0.5) + (i <= changepoint ? i + 0.5 : k - i + (iseven(k) ? 1.5 : 1.0))
            end, # ypos
            reverse_x
        ))
    end
    for i in 1:c
        push!(a, _clique_command(
            minimum(ranks[cliques[i]]),
            maximum(ranks[cliques[i]]),
            1.5 * i / (c+1)
        ))
    end
    return a
end

# 2-dimensional version with a sequence of CD diagrams
function plot(x::Pair{String, T}...; title::Union{String,Nothing}=nothing, reverse_x::Bool=false, kwargs...) where {S <: AbstractVector, T <: AbstractVector{Pair{String, S}}}
    seq_names, seq_data = collect.(zip(x...)) # separate the pairs of the 2d sequence

    # collect ranks and cliques of each element in the sequence
    treatments = String[]
    ranks = Vector{Float64}[]
    cliques = Vector{Vector{Int}}[]
    for (i, x_i) in enumerate(seq_data)
        t_i, o_i = collect.(zip(x_i...))
        if i == 1
            treatments = t_i
        elseif t_i != treatments
            @error "Treatments differ between sequence elements $(seq_names[1]) and $(seq_names[i])" treatments t_i
            throw(ArgumentError("Treatments differ between sequence elements; also check their order!"))
        end
        r_i, c_i = ranks_and_cliques(o_i...; seq_name=seq_names[i], kwargs...)
        push!(ranks, r_i)
        push!(cliques, c_i)
    end
    k = length(treatments)

    # draw ranks along the sequence
    a = Axis(style = _2d_axis_style(k, seq_names, reverse_x), title=title)
    for i in 1:k
        push!(a, Plots.Linear(
            [ r[i] for r in ranks ], # x coordinates
            1:length(seq_names); # y coordinates
            legendentry = treatments[i],
            style = "only marks"
        ))
    end

    # draw cliques
    for i in 1:length(ranks)
        r_i = ranks[i]
        c_i = filter(c_j -> length(c_j) > 1, cliques[i])
        for j in 1:length(c_i)
            push!(a, _2d_clique_command(
                minimum(r_i[c_i[j]]),
                maximum(r_i[c_i[j]]),
                i + (j+.5) / (1.5*length(c_i)+1)
            ))
        end
    end

    return a
end

_axis_style(k::Int, changepoint::Int, reverse_x::Bool) =
    join([
        "axis x line=center",
        "axis y line=none",
        "xmin=1",
        "xmax=$(k)",
        "ymin=-$(changepoint+1.5)",
        "ymax=0",
        "scale only axis",
        "height=$(changepoint+2)\\baselineskip",
        "width=\\axisdefaultwidth",
        "ticklabel style={anchor=south, yshift=1.33*\\pgfkeysvalueof{/pgfplots/major tick length}, font=\\small}",
        "every tick/.style={yshift=.5*\\pgfkeysvalueof{/pgfplots/major tick length}}",
        "axis line style={-}",
        "title style={yshift=\\baselineskip}"
    ], ", ") *
      (k <= 5 ? ", xtick={$(join(1:k, ","))}" : "") *
      (reverse_x ? "" : ", x dir=reverse")
_treatment_command(label::String, rank::Float64, xpos::Float64, ypos::Float64, reverse_x::Bool) =
    Plots.Command(join([
        "\\draw[semithick, rounded corners=1pt] (axis cs:$rank, 0) |- (axis cs:$xpos, -$ypos) node[",
        "font=\\small, fill=white, inner xsep=5pt, outer xsep=-5pt, anchor=$(_label_anchor(xpos, reverse_x))",
        "] {$label}"
    ]))
_label_anchor(xpos::Float64, reverse_x::Bool) = ["west", "east"][1 + (Int(xpos==1) + Int(reverse_x)) % 2]
    # if reverse_x
    #     xpos==1 ? "west" : "east"
    # else
    #     xpos==1 ? "east" : "west"
    # end
_clique_command(minrank::Float64, maxrank::Float64, ypos::Float64) =
    Plots.Command(join([
        "\\draw[ultra thick, line cap=round] (axis cs:$minrank, -$ypos) -- (axis cs:$maxrank, -$ypos)"
    ]))

# 2-dimensional sequence versions
_2d_axis_style(k::Int, seq_names::AbstractVector{String}, reverse_x::Bool) =
    join([
        "title style={yshift=2\\baselineskip}",
        "y dir=reverse",
        "ytick={$(join(1:length(seq_names), ","))}",
        "yticklabels={$(join(map(x -> "{$x}", seq_names), ","))}",
        "xlabel={avg. rank}",
        "xlabel style={at={([yshift=-1pt]1,1)}, anchor=south west}",
        "grid=both",
        "axis line style={draw=none}",
        "tick style={draw=none}",
        "xticklabel pos=upper",
        "xmin=.5",
        "xmax=$(k).5",
        "ymin=.66",
        "ymax=$(length(seq_names) + .66)",
        "clip=false",
        "legend style={draw=none,fill=none,at={(1.1,.5)},anchor=west,row sep=.25em}"
    ], ", ") *
      (reverse_x ? "" : ", x dir=reverse")
_2d_clique_command(minrank::Float64, maxrank::Float64, ypos::Float64) =
    Plots.Command(join([
      "\\draw[semithick]",
      " ([yshift=2pt]axis cs:$minrank, $ypos) --",
      " ++(0pt, -2pt) --",
      " (axis cs:$maxrank, $ypos) --",
      " ++(0pt, 2pt)",
    ]))

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

const ADJUSTMENTS = Dict(
    :holm => Holm(),
    :bonferroni => Bonferroni(),
)

function ranks_and_cliques(X::AbstractMatrix{T}; alpha::Float64=0.05, maximize_outcome::Bool=false, adjustment::Symbol=:holm, seq_name::String="") where T <: Real
    # test whether there are differences at all
    friedman = FriedmanTest(X; maximize_outcome=maximize_outcome)
    if pvalue(friedman) >= alpha
        if seq_name != ""
            @error "Friedman cannot find significant differences between treatments at α=$alpha ($(seq_name))"
        else
            @error "Friedman cannot find significant differences between treatments at α=$alpha"
        end
        return average_ranks(friedman), [collect(1:size(X, 2))]
    end

    # adjust the pair-wise Wilcoxon signed-rank tests
    P = _adjust_pairwise_tests!(
        _pairwise_tests(X, SignedRankTest),
        ADJUSTMENTS[adjustment]
    )

    # find max-cliques of indistinguishable methods
    return average_ranks(friedman), _indistinguishable_cliques(average_ranks(friedman), P, size(X, 2), alpha)
end

const _PairwiseTest = NamedTuple{(:i, :j, :p),Tuple{Int64,Int64,Float64}} # type alias

function _indistinguishable_cliques(r::Vector{Float64}, P::Vector{_PairwiseTest}, k::Int, alpha::Float64)
    g = SimpleGraph(k)
    for P_k in P
        if P_k.p >= alpha
            for l in findall(r .== r[P_k.i])
                add_edge!(g, l, P_k.j) # add edges for all methods with equal ranks
            end
            for l in findall(r .== r[P_k.j])
                add_edge!(g, P_k.i, l)
            end # methods with edges are not distinguishable
        end
    end
    cliques = maximal_cliques(g)
    minranks = map(c -> minimum(r[c]), cliques)
    maxranks = map(c -> maximum(r[c]), cliques)
    dominated = map(1:length(cliques)) do i
        any(.|(
            .&(minranks .<= minranks[i], maxranks .> maxranks[i]),
            .&(minranks .< minranks[i], maxranks .>= maxranks[i])
        ))
    end # cliques that are entirely contained in another clique
    return cliques[.!(dominated)]
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
    for i in 1:k, j in (i+1):k # for each pair of treatments
        push!(P, (;
            i = i,
            j = j,
            p = clamp(pvalue(test_constructor(X[:, i], X[:, j])), 0, 1)
        )) # NamedTuple with keys i, j, and p
    end
    return sort!(P; lt = (a, b)->isless(a.p, b.p)) # sort by p-value
end

end # module
