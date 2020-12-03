@testset "ChisqFriedmanTest" begin
    catalysts = [
        84.5  78.4  83.1;
        82.8  79.1  79.9;
        79.1  78.0  77.8;
        80.2  76.0  77.9;
    ] # http://calcscience.uwe.ac.uk/w2/am/Ch12/12_5_KWFriedman.pdf

    friedman = ChisqFriedmanTest(catalysts) # example 12.12
    @test friedman.F ≈ 6.5
    @test pvalue(friedman) < 0.05 # reject that all are equal
    @test HypothesisTests.default_tail(friedman) == :right
    @test friedman.df == 2
    @test friedman.k == 3
    @test friedman.n == 4

    friedman = ChisqFriedmanTest(catalysts') # example 12.13
    @test friedman.F ≈ 7.4
    @test pvalue(friedman) >= 0.05
    @test HypothesisTests.default_tail(friedman) == :right
    @test friedman.df == 3
    @test friedman.k == 4
    @test friedman.n == 3

    friedman = ChisqFriedmanTest(
        [6, 4, 3, 3], # tree 1
        [4, 3, 3, 2], # tree 2
        [4, 2, 1, 1], # tree 3
        [2, 1, 2, 1] # tree 4
    ) # assignment Q12.8
    @test friedman.F ≈ 9.525
    @test pvalue(friedman) < 0.05
    @test HypothesisTests.default_tail(friedman) == :right
    @test friedman.df == 3
    @test friedman.k == 4
    @test friedman.n == 4
end
