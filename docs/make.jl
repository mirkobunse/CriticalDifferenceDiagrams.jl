using Documenter, CriticalDifferenceDiagrams

makedocs(;
    sitename = "CriticalDifferenceDiagrams.jl",
    pages = [
        "Home" => "index.md",
        "API reference" => "api-reference.md",
        "Python wrapper" => "python-wrapper.md"
    ],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
    )
)
