using CriticalDifferenceDiagrams, CSV, DataFrames, HypothesisTests, PGFPlots, Test

include("friedman.jl")

# download and read a test data set and remove the intermediate file
function _getdata(url="https://raw.githubusercontent.com/hfawaz/cd-diagram/master/example.csv")
    @info "Downloading $url"
    testfile = download(url)
    df = CSV.read(testfile, DataFrame)
    rm(testfile)
    return df, :classifier_name, :dataset_name, :accuracy # = (df, treatment, observation, outcome)
end

@testset "ranks_and_cliques" begin
    ranks, cliques = CriticalDifferenceDiagrams.ranks_and_cliques(_getdata()...; maximize_outcome=true)
    treatments, ranks = collect.(zip(ranks...)) # separate the pairs

    # compare the cliques with those in https://github.com/hfawaz/cd-diagram
    @test Set(["clf3", "clf5"]) in Set.(cliques) # ignore the order of treatments
    @test Set(["clf4", "clf2", "clf1"]) in Set.(cliques)

    # compare the order of ranks with those in https://github.com/hfawaz/cd-diagram
    @test treatments[sortperm(ranks)] == ["clf3", "clf5", "clf4", "clf2", "clf1"]
end

include("readme.jl")
