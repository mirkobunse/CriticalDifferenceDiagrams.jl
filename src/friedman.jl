export average_ranks, ChisqFriedmanTest, FDistFriedmanTest, FriedmanTest

using HypothesisTests: HypothesisTest, tiedrank_adj

FRIEDMAN_DOC = """
   Test the null hypothesis that `n` repeated observations of a set of `k` treatments
   have the same distribution across all treatments. These observations are arranged
   in `k` vectors `x_i` of `n` observations each or in an `(n, k)`-shaped matrix `X`.
""" # documentation that is shared across subtypes of FriedmanTest

"""
    FriedmanTest(x_1, x_2, ..., x_k) = FDistFriedmanTest(x_1, x_2, ..., x_k)
    FriedmanTest(X) = FDistFriedmanTest(X)

$(FRIEDMAN_DOC)

The default version of this test, the `FDistFriedmanTest`, uses an F-distributed statistic.

**See also:** `FDistFriedmanTest`, `ChisqFriedmanTest`
"""
abstract type FriedmanTest <: HypothesisTest end

"""
    ChisqFriedmanTest(x_1, x_2, ..., x_k)
    ChisqFriedmanTest(X)

$(FRIEDMAN_DOC)

This version of the `FriedmanTest` uses a χ²-distributed statistic.
"""
struct ChisqFriedmanTest <: FriedmanTest
    F::Float64 # test statistic
    df::Int # number of degrees of freedom
    r::Vector{Float64} # average ranks
    n::Int # number of observations per treatment
    k::Int # number of treatments
end

"""
    FDistFriedmanTest(x_1, x_2, ..., x_k)
    FDistFriedmanTest(X)

$(FRIEDMAN_DOC)

This version of the `FriedmanTest` uses an F-distributed statistic.
"""
struct FDistFriedmanTest <: FriedmanTest
    F::Float64 # test statistic
    chisq::ChisqFriedmanTest
    df_1::Int # degrees of freedom (first dimension)
    df_2::Int # second dimension
end

FriedmanTest(X::AbstractMatrix{T}) where T <: Real = FDistFriedmanTest(X)
FriedmanTest(x::AbstractVector{T}...) where T <: Real = FDistFriedmanTest(x...)

function ChisqFriedmanTest(X::AbstractMatrix{T}) where T <: Real
    n = size(X, 1)
    k = size(X, 2)
    if k < 3
        throw(ArgumentError("The Friedman test requires at least 3 treatments; only $k were given"))
    end
    r = mean(rank_with_average_ties(X); dims=1) # average rank of each method
    return ChisqFriedmanTest(
        12*n/(k*(k+1)) * sum((r .- (k+1)/2).^2),
        k-1,
        vec(r), # convert row-matrix to vector
        n,
        k
    ) # test statistic with k-1 degrees of freedom
end
ChisqFriedmanTest(x::AbstractVector{T}...) where T <: Real =
    ChisqFriedmanTest(hcat(x...))

function FDistFriedmanTest(X::AbstractMatrix{T}) where T <: Real
    chisq = ChisqFriedmanTest(X)
    return FDistFriedmanTest(
        (chisq.n - 1) * chisq.F / (chisq.n * (chisq.k - 1) - chisq.F),
        chisq,
        chisq.k-1,
        (chisq.k-1)*(chisq.n-1)
    ) # test statistic with k-1 and (k-1)*(n-1) degrees of freedom
end
FDistFriedmanTest(x::AbstractVector{T}...) where T <: Real =
    FDistFriedmanTest(hcat(x...))

function rank_with_average_ties(X::AbstractMatrix{T}) where T <: Real
    R = zeros(size(X))
    @inbounds for i in 1:size(X, 1)
        R[i, :], _ = tiedrank_adj(X[i, :]) # ranking for the i-th observation
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
    print(io, indent,   "average ranks:                        ")
    show(io, x.chisq.r)
    println(io)
    println(io, indent, "number of degrees of freedom:         ", x.df_1, ", ", x.df_2)
end

function HypothesisTests.show_params(io::IO, x::ChisqFriedmanTest, indent)
    println(io, indent, "number of treatments:                 ", x.k)
    println(io, indent, "number of observations per treatment: ", x.n)
    println(io, indent, "χ²-statistic:                         ", x.F)
    print(io, indent,   "average ranks:                        ")
    show(io, x.r)
    println(io)
    println(io, indent, "number of degrees of freedom:         ", x.df)
end
