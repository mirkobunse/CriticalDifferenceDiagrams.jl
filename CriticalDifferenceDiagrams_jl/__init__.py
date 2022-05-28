from julia_project import JuliaProject
from os.path import dirname, abspath

# initialize the Julia project
project = JuliaProject(
    name = "CriticalDifferenceDiagrams_jl",
    package_path = dirname(abspath(__file__)),
    version_spec = "= 1.6.5",
)
project.ensure_init(install_julia=True, depot=True, compile=False)

# evaluate the Julia side of the wrapper
project.julia.Main.eval("""
    import CriticalDifferenceDiagrams, DataFrames, PGFPlots
    pandas_to_julia(df::PyObject) =
        DataFrames.DataFrame(; map(c -> Symbol(c) => df[c].to_list(), df.columns)...)
    ranks_and_cliques(df::PyObject, treatment::String, observation::String, outcome::String; kwargs...) =
        CriticalDifferenceDiagrams.ranks_and_cliques(
            pandas_to_julia(df),
            Symbol(treatment),
            Symbol(observation),
            Symbol(outcome);
            kwargs...
        )
    plot(df::PyObject, treatment::String, observation::String, outcome::String; kwargs...) =
        CriticalDifferenceDiagrams.plot(
            pandas_to_julia(df),
            Symbol(treatment),
            Symbol(observation),
            Symbol(outcome);
            kwargs...
        )
    to_pairs(df::PyObject, treatment::String, observation::String, outcome::String) =
        CriticalDifferenceDiagrams.to_pairs(
            pandas_to_julia(df),
            Symbol(treatment),
            Symbol(observation),
            Symbol(outcome)
        )
    plot(x::Vector{Tuple{String, Vector{Tuple{String, Vector{T}}}}}; kwargs...) where T =
        CriticalDifferenceDiagrams.plot([ a => [ c => d for (c, d) in b ] for (a, b) in x ]...; kwargs...)
    save(outpath::String, plot::PGFPlots.Axis; kwargs...) =
        PGFPlots.save(outpath, plot; kwargs...)
    pushPGFPlotsPreamble(x::String) = PGFPlots.pushPGFPlotsPreamble(x)
""")

# define the Python side of the wrapper
def ranks_and_cliques(df, treatment, observation, outcome, **kwargs):
    return project.julia.Main.ranks_and_cliques(df, treatment, observation, outcome, **kwargs)
def plot(df_or_tuples, treatment=None, observation=None, outcome=None, **kwargs):
    if treatment is not None and observation is not None and outcome is not None: # 1d plot?
        return project.julia.Main.plot(df_or_tuples, treatment, observation, outcome, **kwargs)
    elif treatment is None and observation is None and outcome is None: # 2d plot?
        return project.julia.Main.plot(df_or_tuples, **kwargs)
    else:
        raise ValueError("treatment, observation, and outcome must all be None or not None")
def to_pairs(df, treatment, observation, outcome):
    return project.julia.Main.to_pairs(df, treatment, observation, outcome)
def save(outpath, plot, **kwargs):
    return project.julia.Main.save(outpath, plot, **kwargs)
def pushPGFPlotsPreamble(x):
    return project.julia.Main.pushPGFPlotsPreamble(x)
