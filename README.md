[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://mirkobunse.github.io/CriticalDifferenceDiagrams.jl/stable)
[![Build Status](https://github.com/mirkobunse/CriticalDifferenceDiagrams.jl/workflows/CI/badge.svg)](https://github.com/mirkobunse/CriticalDifferenceDiagrams.jl/actions)
[![codecov](https://codecov.io/gh/mirkobunse/CriticalDifferenceDiagrams.jl/branch/main/graph/badge.svg?token=LWBUWCH8OQ)](https://codecov.io/gh/mirkobunse/CriticalDifferenceDiagrams.jl)


# [Critical difference diagrams in Julia](https://mirkobunse.github.io/CriticalDifferenceDiagrams.jl/stable)

This package generates Tikz code for publication-ready vector graphics.

Critical difference (CD) diagrams are a powerful tool to compare outcomes of multiple treatments over multiple observations. For instance, in machine learning research we often compare the performance (= outcome) of multiple methods (= treatments) over multiple data sets (= observations). A wrapper for Python is also available.

**Regular CD diagrams:** indistinguishable methods are connected.

<img alt="docs/src/assets/example.svg" src="docs/src/assets/example.svg" width="480">

**2D sequences:** sequences of multiple CD diagrams can be arranged in a single 2-dimensional axis.

<img alt="docs/src/assets/2d_example.svg" src="docs/src/assets/2d_example.svg" width="480">

For more information, please refer to [the documentation](https://mirkobunse.github.io/CriticalDifferenceDiagrams.jl/stable).
