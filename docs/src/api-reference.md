# API reference

Below, you find a listing of all public methods of this package. Any other method you might find in the source code is not intended for direct usage.

```@meta
CurrentModule = CriticalDifferenceDiagrams
```


## Critical difference diagrams

If you do not want to generate a plot, but want to know about the semantic content of a CD diagram, you can use the function [`ranks_and_cliques`](@ref) instead of [`plot`](@ref).

```@docs
plot
ranks_and_cliques
```


## Friedman test

The Friedman test might eventually be migrated to [HypothesisTests.jl](https://github.com/JuliaStats/HypothesisTests.jl).

```@docs
FriedmanTest
FDistFriedmanTest
ChisqFriedmanTest
average_ranks
```
