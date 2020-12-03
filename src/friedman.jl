export ChisqFriedmanTest

using HypothesisTests: HypothesisTest, tiedrank_adj

# https://github.com/scipy/scipy/blob/v1.5.4/scipy/stats/stats.py#L7236-L7298
# friedman_p_value_1 = ccdf(Chisq(df), friedman_statistic)
# friedman_p_value_2 = ccdf(FDist(df_1, df_2), improved_statistic)
# if friedman_p_value >= alpha error("Reject") end

"""
    ChisqFriedmanTest(X)

`X` has shape `(n_observations, n_treatments)`.
"""
struct ChisqFriedmanTest <: HypothesisTest
    F::Float64 # test statistic
    df::Int # number of degrees of freedom
    r::Vector{Float64} # average ranks
    n::Int # number of observations per treatment
    k::Int # number of treatments
end

function ChisqFriedmanTest(X::Matrix{T}) where T <: Real
    n = size(X, 1)
    k = size(X, 2)
    r = mean(rank_with_average_ties(X); dims=1)[:] # average rank of each method
    return ChisqFriedmanTest(
        12*n/(k*(k+1)) * sum((r .- (k+1)/2).^2),
        k-1,
        r,
        n,
        k
    ) # test statistic with k-1 degrees of freedom
end

function rank_with_average_ties(X::Matrix{T}) where T <: Real
	R = zeros(size(X))
	@inbounds for i in 1:size(X, 1)
	    R[i, :], _ = tiedrank_adj(X[i, :]) # ranking for the i-th observation
    end
    return R
end

HypothesisTests.pvalue(x::ChisqFriedmanTest) = pvalue(Chisq(x.df), x.F; tail=:right)

HypothesisTests.testname(::ChisqFriedmanTest) = "Friedman test with χ²-statistic"
HypothesisTests.population_param_of_interest(x::ChisqFriedmanTest) =
    ("Average ranks of treatments", "all equal", NaN) # = (name, value under h0, point estimate)
HypothesisTests.default_tail(test::ChisqFriedmanTest) = :right

function HypothesisTests.show_params(io::IO, x::ChisqFriedmanTest, indent)
    println(io, indent, "number of treatments:                 ", x.k)
    println(io, indent, "number of observations per treatment: ", x.n)
    println(io, indent, "χ²-statistic:                         ", x.F)
    print(io, indent,   "average ranks:                        ")
    show(io, x.r)
    println(io)
    println(io, indent, "number of degrees of freedom:         ", x.df)
end
