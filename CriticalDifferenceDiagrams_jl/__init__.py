from pkg_resources import resource_filename
import platform
if platform.system() == "Linux":
    ext = "so"
elif platform.system() == "Darwin":
    ext = "dylib"
elif platform.system() == "Windows":
    ext = "dll"
else:
    raise ValueError("Can't install on system " + platform.system())
sysimage_path = resource_filename(__name__, "sys." + ext)
print("Starting Julia from the sysimage " + sysimage_path)

from julia.api import LibJulia
api = LibJulia.load()
api.sysimage = sysimage_path
api.init_julia()

from julia import Main
Main.eval("""
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
