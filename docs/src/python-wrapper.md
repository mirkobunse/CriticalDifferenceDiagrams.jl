# Python wrapper for CriticalDifferenceDiagrams.jl

The wrapper provides an interface through which the methods of CriticalDifferenceDiagrams.jl are exposed to Python. This short guide assumes you have read the [Home](@ref) section.


## Getting started

The wrapper can be installed with pip:

```
pip install https://github.com/mirkobunse/CriticalDifferenceDiagrams.jl/archive/py.tar.gz
python -c "import CriticalDifferenceDiagrams_jl"
```

The second step ensures that all Julia dependencies, including Julia itself, are installed.

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
    title="CriticalDifferenceDiagrams.jl", # give an optional title
    alpha=0.05, # the significance level (default: 0.05)
    adjustment="holm" # "holm" (default) or "bonferroni"
)

# configure the preamble of PGFPlots.jl (optional)
cdd.pushPGFPlotsPreamble("\\usepackage{lmodern}")

# export to .svg, .tex, or .pdf
cdd.save("example.svg", plot)
```

A 2-dimensional plot can be generated in analogy to the example from the [Home](@ref) section:

```python
sequence = [
    ("title 1", cdd.to_pairs(df1, "treatment", "dataset", "outcome")),
    ("title 2", cdd.to_pairs(df2, "treatment", "dataset", "outcome"))
]
plot = cdd.plot(sequence, maximize_outcome=True, title="2-dimensional")
```


## Performance

The first `import CriticalDifferenceDiagrams_jl` installs all Julia dependencies, which takes some time. Therefore, we recommend to call

```
python -c "import CriticalDifferenceDiagrams_jl"
```

as a part of the installation process, as described in the [Getting started](#Getting-started) section.

Calling a method for the first time will be somewhat slow, due to Julia's just-in-time (JIT) compilation mechanism. JIT means that all functions are compiled when they are called for the first time in a session. As a result, the first call is quite slow but subsequent calls are super fast. If your implementation design permits, generate multiple CD diagrams in a single session to benefit from the JIT speedup of subsequent method calls.
