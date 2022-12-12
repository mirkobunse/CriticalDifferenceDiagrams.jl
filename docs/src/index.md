# [CriticalDifferenceDiagrams.jl](@id Home)

Critical difference (CD) diagrams are a powerful tool to compare outcomes of multiple treatments over multiple observations. For instance, in machine learning research we often compare the performance (i.e., outcome) of multiple methods (i.e., treatments) over multiple data sets (i.e., observations). This Julia package generates Tikz code to produce publication-ready vector graphics. A [wrapper for Python](python-wrapper/) is also available.


## Reading a CD diagram

Let's take a look at the treatments `clf1` to `clf5`. Their position represents their mean ranks across all outcomes of the observations, where low ranks indicate that a treatment wins more often than its competitors with higher ranks. Two or more treatments are connected with each other if we can not tell their outcomes apart, in the sense of statistical significance. For the above example, we can not tell from the data whether `clf3` and `clf5` are actually different from each other. We can tell, however, that both of them are different from all of the other treatments. This example above is adapted from [github.com/hfawaz/cd-diagram](https://github.com/hfawaz/cd-diagram).

```@raw html
<img alt="assets/example.svg" src="assets/example.svg" style="width: 480px; max-width: 100%; margin: 2em auto; display: block;">
```

### Hypothesis testing

A diagram like the one above concisely represents multiple hypothesis tests that are conducted over the observed outcomes. Before anything is plotted at all, the *Friedman test* tells us whether there are significant differences at all. If this test fails, we have not sufficient data to tell any of the treatments apart and we must abort. If, however, the test sucessfully rejects this possibility we can proceed with the post-hoc analysis. In this second step, a *Wilcoxon signed-rank test* tells us whether each pair of treatments exhibits a significant difference.

### Multiple testing

Since we are testing multiple hypotheses, we must *adjust* the Wilcoxon test with Holm's method or with Bonferroni's method. For each group of treatments which we can not distinguish from the Holm-adjusted (or Bonferroni-adjusted) Wilcoxon test, we add a thick line to the diagram.

Whether we choose Holm's method or Bonferroni's method for the adjustment depends on our personal requirements. Holm's method has the advantage of a greater statistical power than Bonferroni's method, i.e., this adjustment is capable of rejecting more null hypotheses that indeed should be rejected. However, its disadvantage is that the rejection of each null hypothesis depends on the outcome of other null hypotheses. If this property is not desired, one should instead use Bonferroni's method, which ensures that each pair-wise hypothesis test is independent from all others.


## Getting started

CriticalDifferenceDiagrams.jl can be installed through the Julia package manager. From the Julia REPL, type `]` to enter the Pkg mode of the REPL. Then run

```
pkg> add CriticalDifferenceDiagrams
```

The example plot above is then generated with the following code:

```julia
using CriticalDifferenceDiagrams, CSV, DataFrames, Downloads, PGFPlots

# we generate the above example from the underlying data
url = "https://raw.githubusercontent.com/hfawaz/cd-diagram/master/example.csv"
df = CSV.read(Downloads.download(url), DataFrame)

plot = CriticalDifferenceDiagrams.plot(
    df,
    :classifier_name, # the name of the treatment column
    :dataset_name,    # the name of the observation column
    :accuracy;         # the name of the outcome column
    maximize_outcome=true, # compute ranks for minimization (default) or maximization
    title="CriticalDifferenceDiagrams.jl", # give an optional title
    alpha=0.05, # the significance level (default: 0.05)
    adjustment=:holm # :holm (default) or :bonferroni
)

# configure the preamble of PGFPlots.jl (optional)
pushPGFPlotsPreamble("""
    \\usepackage{lmodern}
""")

# export to .svg, .tex, or .pdf
PGFPlots.save("example.svg", plot)
```


## Cautions

The hypothesis tests underneath the CD diagram do not account for variances of the outcomes. It is therefore important that these outcomes are *reliable* in the sense that each of them is obtained from a sufficiently large sample. Ideally, they come from a cross validation or from a repeated stratified split. Moreover, all treatments must have been evaluated on the same set of observations.

The adjustments by Holm and Bonferroni can lead to different cliques. For more information, see the [Multiple testing](#multiple-testing) section above.


## 2-dimensional sequences of CD diagrams

You can arrange a series of CD diagrams in a single 2-dimensional axis. Each row in such a plot is a separate CD diagram.

```@raw html
<img alt="assets/2d_example.svg" src="assets/2d_example.svg" style="width: 480px; max-width: 100%; margin: 2em auto; display: block;">
```

You create a 2-dimensional sequence of CD diagrams by calling the `plot` function on a sequence of `(title, data)` pairs. The data consists of the same pairs that a 1-dimensional CD diagram would use.

```julia
sequence = Pair{String, Vector{Pair{String, Vector}}}[]
push!(sequence, "title 1" => CriticalDifferenceDiagrams.to_pairs(
    df1, :treatment, :dataset, :outcome
))
push!(sequence, "title 2" => CriticalDifferenceDiagrams.to_pairs(
    df2, :treatment, :dataset, :outcome
))
plot = CriticalDifferenceDiagrams.plot(sequence...; maximize_outcome=true)
```

The [API reference](@ref) of the `plot` method provides additional information on how to generate sequences of CD diagrams, which are arranged in a single 2-dimensional axis.

## Citing

CD diagrams have originally been proposed in the following article:

```
@article{demsar2006statistical,
  title={Statistical comparisons of classifiers over multiple data sets},
  author={Dem{\v{s}}ar, Janez},
  journal={The Journal of Machine learning research},
  volume={7},
  number={1},
  pages={1--30},
  year={2006}
}
```

However, the above article favors Nemenyi's test for the post-hoc analysis.
It has later been argued that Wilcoxon's signed rank test (or the sign test)
are more appropriate for the post-hoc assessment of the pairwise differences:

```
@article{benavoli2016should,
  title={Should we really use post-hoc tests based on mean-ranks?},
  author={Benavoli, Alessio and Corani, Giorgio and Mangili, Francesca},
  journal={The Journal of Machine Learning Research},
  volume={17},
  number={1},
  pages={152--161},
  year={2016}
}
```
