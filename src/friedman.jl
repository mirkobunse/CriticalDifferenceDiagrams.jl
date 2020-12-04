export average_ranks, ChisqFriedmanTest, FDistFriedmanTest, FriedmanTest

using HypothesisTests: HypothesisTest, tiedrank_adj

FRIEDMAN_DOC = """
   Test the null hypothesis that `n` repeated observations of a set of `k` treatments
   have the same distribution across all treatments. These observations are arranged
   in `k` vectors `x_i` of `n` observations each or in an `(n, k)`-shaped matrix `X`.
""" # documentation that is shared across subtypes of FriedmanTest
FRIEDMAN_KWARGS_DOC = """
   # Keyword arguments
   
   - `maximize_outcome=false` specifies whether the ranks represent a maximization or a
     minimization of the outcomes.
"""

"""
    FriedmanTest(x_1, x_2, ..., x_k; kwargs...) = FDistFriedmanTest(x_1, x_2, ..., x_k; kwargs...)
    FriedmanTest(X; kwargs...) = FDistFriedmanTest(X; kwargs...)

$(FRIEDMAN_DOC)

The default version of this test, the `FDistFriedmanTest`, uses an F-distributed statistic.

**See also:** `FDistFriedmanTest`, `ChisqFriedmanTest`

$(FRIEDMAN_KWARGS_DOC)
"""
abstract type FriedmanTest <: HypothesisTest end

"""
    ChisqFriedmanTest(x_1, x_2, ..., x_k; kwargs...)
    ChisqFriedmanTest(X; kwargs...)

$(FRIEDMAN_DOC)

This version of the `FriedmanTest` uses a χ²-distributed statistic.

$(FRIEDMAN_KWARGS_DOC)
"""
struct ChisqFriedmanTest <: FriedmanTest
    F::Float64 # test statistic
    df::Int # number of degrees of freedom
    r::Vector{Float64} # average ranks
    n::Int # number of observations per treatment
    k::Int # number of treatments
    maximize_outcome::Bool # which optimization the ranks represent
end

"""
    FDistFriedmanTest(x_1, x_2, ..., x_k; kwargs...)
    FDistFriedmanTest(X; kwargs...)

$(FRIEDMAN_DOC)

This version of the `FriedmanTest` uses an F-distributed statistic.

$(FRIEDMAN_KWARGS_DOC)
"""
struct FDistFriedmanTest <: FriedmanTest
    F::Float64 # test statistic
    chisq::ChisqFriedmanTest
    df_1::Int # degrees of freedom (first dimension)
    df_2::Int # second dimension
end

FriedmanTest(X::AbstractMatrix{T}; kwargs...) where T <: Real = FDistFriedmanTest(X; kwargs...)
FriedmanTest(x::AbstractVector{T}...; kwargs...) where T <: Real = FDistFriedmanTest(x...; kwargs...)

function ChisqFriedmanTest(X::AbstractMatrix{T}; maximize_outcome::Bool=false) where T <: Real
    n = size(X, 1)
    k = size(X, 2)
    if k < 3
        throw(ArgumentError("The Friedman test requires at least 3 treatments; only $k were given"))
    end
    r = mean(rank_with_average_ties(X, maximize_outcome); dims=1) # average rank of each method
    return ChisqFriedmanTest(
        12*n/(k*(k+1)) * sum((r .- (k+1)/2).^2),
        k-1,
        vec(r), # convert row-matrix to vector
        n,
        k,
        maximize_outcome
    ) # test statistic with k-1 degrees of freedom
end
ChisqFriedmanTest(x::AbstractVector{T}...; kwargs...) where T <: Real =
    ChisqFriedmanTest(hcat(x...); kwargs...)

function FDistFriedmanTest(X::AbstractMatrix{T}; kwargs...) where T <: Real
    chisq = ChisqFriedmanTest(X; kwargs...)
    return FDistFriedmanTest(
        (chisq.n - 1) * chisq.F / (chisq.n * (chisq.k - 1) - chisq.F),
        chisq,
        chisq.k-1,
        (chisq.k-1)*(chisq.n-1)
    ) # test statistic with k-1 and (k-1)*(n-1) degrees of freedom
end
FDistFriedmanTest(x::AbstractVector{T}...) where T <: Real =
    FDistFriedmanTest(hcat(x...))

function rank_with_average_ties(X::AbstractMatrix{T}, maximize_outcome::Bool) where T <: Real
    R = zeros(size(X))
    @inbounds for i in 1:size(X, 1)
        R[i, :], _ = tiedrank_adj(
            maximize_outcome ? -1 .* X[i, :] : X[i, :]
        ) # ranking for the i-th observation, wrt maximization or minimization
    end
    return R
end

"""
    average_ranks(x) where x <: FriedmanTest

Return the average ranks of methods in the `FriedmanTest`.
"""
average_ranks(x::FDistFriedmanTest) = x.chisq.r
average_ranks(x::ChisqFriedmanTest) = x.r

HypothesisTests.pvalue(x::FDistFriedmanTest) = pvalue(FDist(x.df_1, x.df_2), x.F; tail=:right)
HypothesisTests.pvalue(x::ChisqFriedmanTest) = pvalue(Chisq(x.df), x.F; tail=:right)

HypothesisTests.testname(::FDistFriedmanTest) = "Friedman test with F-statistic"
HypothesisTests.testname(::ChisqFriedmanTest) = "Friedman test with χ²-statistic"
HypothesisTests.population_param_of_interest(x::FriedmanTest) =
    ("Average ranks of treatments", "all equal", NaN) # = (name, value under h0, point estimate)
HypothesisTests.default_tail(test::FriedmanTest) = :right

function HypothesisTests.show_params(io::IO, x::FDistFriedmanTest, indent)
    println(io, indent, "number of treatments:                 ", x.chisq.k)
    println(io, indent, "number of observations per treatment: ", x.chisq.n)
    println(io, indent, "F-statistic:                          ", x.F)
    println(io, indent, "optimization target of the ranks:     ", x.chisq.maximize_outcome ? "maximization" : "minimization")
    print(io, indent,   "average ranks:                        ")
    show(io, x.chisq.r)
    println(io)
    println(io, indent, "number of degrees of freedom:         ", x.df_1, ", ", x.df_2)
end

function HypothesisTests.show_params(io::IO, x::ChisqFriedmanTest, indent)
    println(io, indent, "number of treatments:                 ", x.k)
    println(io, indent, "number of observations per treatment: ", x.n)
    println(io, indent, "χ²-statistic:                         ", x.F)
    println(io, indent, "optimization target of the ranks:     ", x.maximize_outcome ? "maximization" : "minimization")
    print(io, indent,   "average ranks:                        ")
    show(io, x.r)
    println(io)
    println(io, indent, "number of degrees of freedom:         ", x.df)
end
