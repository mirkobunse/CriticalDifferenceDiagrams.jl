module CriticalDifferenceDiagrams

using Distributions: ccdf, Chisq, FDist
using HypothesisTests: HypothesisTest, pvalue, SignedRankTest
using MultipleTesting: adjust, Holm

export FriedmanTest # might be migrated to HypothesisTests.jl

# https://github.com/scipy/scipy/blob/v1.5.4/scipy/stats/stats.py#L7236-L7298
# friedman_p_value_1 = ccdf(Chisq(n_df), friedman_statistic)
# friedman_p_value_2 = ccdf(FDist(n_df_1, n_df_2), improved_statistic)
# if friedman_p_value >= alpha error("Reject") end

# https://juliastats.org/HypothesisTests.jl/stable/
# pvalue(SignedRankTest(x, y))

# https://juliangehring.github.io/MultipleTesting.jl/stable/adjustment.html#MultipleTesting.Holm
# adjust(pvals, Holm())

struct FriedmanTest <: HypothesisTest end

greet() = print("Hello World!")

end # module
