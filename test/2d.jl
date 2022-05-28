@testset "2D" begin
    df = CSV.read("2d.csv", DataFrame)
    sequence = Pair{String, Vector{Pair{String, Vector}}}[]
    @test_deprecated CriticalDifferenceDiagrams._to_pairs(
        df, :method, :dataset, :accuracy
    ) # test that the old API still works but raises a warning
    push!(sequence, "A" => CriticalDifferenceDiagrams.to_pairs(
        df, :method, :dataset, :accuracy
    ))
    push!(sequence, "B" => CriticalDifferenceDiagrams.to_pairs(
        df, :method, :dataset, :accuracy
    ))
    plot = CriticalDifferenceDiagrams.plot(sequence...; maximize_outcome=true)
    PGFPlots.save("2d.pdf", plot)
end
