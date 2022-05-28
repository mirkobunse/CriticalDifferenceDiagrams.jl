@testset "2D" begin
    df = CSV.read("2d.csv", DataFrame)
    sequence = Pair{String, Vector{Pair{String, Vector}}}[]
    push!(sequence, "A" => CriticalDifferenceDiagrams._to_pairs(
        df, :method, :dataset, :accuracy
    ))
    push!(sequence, "B" => CriticalDifferenceDiagrams._to_pairs(
        df, :method, :dataset, :accuracy
    ))
    plot = CriticalDifferenceDiagrams.plot(sequence...; maximize_outcome=true)
    PGFPlots.save("2d.pdf", plot)
end
