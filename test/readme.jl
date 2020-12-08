if Sys.islinux() && get(ENV, "TRAVIS_OS_NAME", "linux") == "linux"
    @info "Asserting that lualatex is installed" Sys.islinux() get(ENV, "TRAVIS_OS_NAME", "")
    @assert success(`lualatex -v`) # make sure the PDF and SVG export will work
end

@testset "README.jl example" begin
    url = "https://raw.githubusercontent.com/hfawaz/cd-diagram/master/example.csv"
    df = CSV.read(download(url), DataFrame)

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

    # export to .tex; linux also supports .pdf and .svg files
    extensions = ["tex"]
    if Sys.islinux() && get(ENV, "TRAVIS_OS_NAME", "linux") == "linux"
        @info "Adding linux-only tests" Sys.islinux() get(ENV, "TRAVIS_OS_NAME", "")
        push!(extensions, "pdf", "svg")
    else
        @warn "Skipping linux-only tests" Sys.islinux() get(ENV, "TRAVIS_OS_NAME", "")
    end
    for ext in extensions
        PGFPlots.save("example.$ext", plot)
        @test isfile("example.$ext")
    end
end
