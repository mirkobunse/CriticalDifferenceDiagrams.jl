@assert success(`lualatex -v`) # make sure the PDF and SVG export will work

@testset "README.jl example" begin
    url = "https://raw.githubusercontent.com/hfawaz/cd-diagram/main/example.csv"
    df = CSV.read(Downloads.download(url), DataFrame)

    plot = CriticalDifferenceDiagrams.plot(
        df,
        :classifier_name, # the name of the treatment column
        :dataset_name,    # the name of the observation column
        :accuracy;        # the name of the outcome column
        maximize_outcome=true, # compute ranks for minimization (default) or maximization
        title="CriticalDifferenceDiagrams.jl" # give an optional title
    )

    # configure the preamble of PGFPlots.jl (optional)
    pushPGFPlotsPreamble("""
        \\usepackage{lmodern}
    """)

    # export to svg; also possible are .tex and .pdf files
    for ext in ["tex", "pdf", "svg"]
        PGFPlots.save("example.$ext", plot)
        @test isfile("example.$ext")
    end
end
