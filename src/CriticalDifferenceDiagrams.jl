module CriticalDifferenceDiagrams

using Distributions, HypothesisTests, MultipleTesting, Statistics

include("friedman.jl") # should be migrated to HypothesisTests.jl

# https://juliastats.org/HypothesisTests.jl/stable/
# pvalue(SignedRankTest(x, y))

# https://juliangehring.github.io/MultipleTesting.jl/stable/adjustment.html#MultipleTesting.Holm
# adjust(pvals, Holm())


end # module
