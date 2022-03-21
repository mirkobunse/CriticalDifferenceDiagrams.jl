# Python wrapper for CriticalDifferenceDiagrams.jl

The wrapper provides an interface through which the methods of CriticalDifferenceDiagrams.jl are exposed to Python. This short guide assumes you have read the [Home](@ref) section.


## Getting started

You need a working Julia installation on your system. To install Julia, please refer to [the official instructions](https://julialang.org/downloads/platform/#linux_and_freebsd). The wrapper, including all dependies, can then be installed with pip:

```
pip install https://github.com/mirkobunse/CriticalDifferenceDiagrams.jl/archive/py.tar.gz
```

The example plot from the [Home](@ref) section is then generated with the following Python code:

```python
import CriticalDifferenceDiagrams_jl as cdd
import pandas as pd
from wget import download

# we generate the above example from the underlying data
download("https://raw.githubusercontent.com/hfawaz/cd-diagram/master/example.csv")
df = pd.read_csv("example.csv")

plot = cdd.plot(
    df,
    "classifier_name", # the name of the treatment column
    "dataset_name",    # the name of the observation column
    "accuracy",        # the name of the outcome column
    maximize_outcome=True, # compute ranks for minimization (default) or maximization
    title="CriticalDifferenceDiagrams.jl" # give an optional title
)

# configure the preamble of PGFPlots.jl (optional)
cdd.pushPGFPlotsPreamble("\\usepackage{lmodern}")

# export to .svg, .tex, or .pdf
cdd.save("example.svg", plot)
```


## Performance

Importing the package and calling a method for the first time will be somewhat slow, due to Julia's just-in-time (JIT) compilation mechanism. JIT means that all functions are compiled when they are called for the first time in a session. As a result, the first call is super slow but subsequent calls are super fast. If your implementation design permits, generate multiple CD diagrams in each session to benefit from the JIT speedup of subsequent method calls.
