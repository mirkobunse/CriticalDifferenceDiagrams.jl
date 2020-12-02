module CriticalDifferenceDiagrams

using HypothesisTests: HypothesisTest, pvalue, SignedRankTest
using MultipleTesting: adjust, Holm

export FriedmanTest # might be migrated to HypothesisTests.jl

# https://juliastats.org/HypothesisTests.jl/stable/
# pvalue(SignedRankTest(x, y))

# https://juliangehring.github.io/MultipleTesting.jl/stable/adjustment.html#MultipleTesting.Holm
# adjust(pvals, Holm())

struct FriedmanTest <: HypothesisTest end

greet() = print("Hello World!")

end # module
