from julia.api import Julia
jl = Julia(compiled_modules=False)

from julia import Main
Main.eval("""
    import Pkg
    Pkg.activate(".")

    import CriticalDifferenceDiagrams, DataFrames, Pandas, PGFPlots

    ranks_and_cliques(df::PyObject, treatment::String, observation::String, outcome::String; kwargs...) =
        CriticalDifferenceDiagrams.ranks_and_cliques(
            DataFrames.DataFrame(Pandas.DataFrame(df)),
            Symbol(treatment),
            Symbol(observation),
            Symbol(outcome);
            kwargs...
        )

    plot(df::PyObject, treatment::String, observation::String, outcome::String; kwargs...) =
        CriticalDifferenceDiagrams.plot(
            DataFrames.DataFrame(Pandas.DataFrame(df)),
            Symbol(treatment),
            Symbol(observation),
            Symbol(outcome);
            kwargs...
        )
    
    save(outpath::String, plot::PGFPlots.Axis; kwargs...) =
        PGFPlots.save(outpath, plot; kwargs...)

    pushPGFPlotsPreamble(x::String) = PGFPlots.pushPGFPlotsPreamble(x)
""")

def ranks_and_cliques(df, treatment, observation, outcome, **kwargs):
    return Main.ranks_and_cliques(df, treatment, observation, outcome, **kwargs)

def plot(df, treatment, observation, outcome, **kwargs):
    return Main.plot(df, treatment, observation, outcome, **kwargs)

def save(outpath, plot, **kwargs):
    return Main.save(outpath, plot, **kwargs)

def pushPGFPlotsPreamble(x):
    return Main.pushPGFPlotsPreamble(x)
