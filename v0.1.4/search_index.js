var documenterSearchIndex = {"docs":
[{"location":"api-reference/#API-reference","page":"API reference","title":"API reference","text":"","category":"section"},{"location":"api-reference/","page":"API reference","title":"API reference","text":"Below, you find a listing of all public methods of this package. Any other method you might find in the source code is not intended for direct usage.","category":"page"},{"location":"api-reference/","page":"API reference","title":"API reference","text":"CurrentModule = CriticalDifferenceDiagrams","category":"page"},{"location":"api-reference/#Critical-difference-diagrams","page":"API reference","title":"Critical difference diagrams","text":"","category":"section"},{"location":"api-reference/","page":"API reference","title":"API reference","text":"If you do not want to generate a plot, but want to know about the semantic content of a CD diagram, you can use the function ranks_and_cliques instead of plot.","category":"page"},{"location":"api-reference/","page":"API reference","title":"API reference","text":"plot\nranks_and_cliques","category":"page"},{"location":"api-reference/#CriticalDifferenceDiagrams.plot","page":"API reference","title":"CriticalDifferenceDiagrams.plot","text":"plot(t_1 => x_1, t_2 => x_2, ..., t_k =>  x_k; kwargs...)\nplot(df, treatment, observation, outcome; kwargs...)\n\nReturn a PGFPlots axis which contains a critical difference diagram for n repeated observations of k treatments.\n\nThe input data are arranged in treatments t_i => x_i, each of which has a name t_i and n associated observations x_i. You can omit the names, either providing the separate x_i alone or by providing all observations as a single (n, k)-shaped matrix X. Alternatively, you can provide a DataFrame df with the columns treatment, observation, and outcome.\n\nThe analysis starts with a FriedmanTest to check if any of the treatments differ. If so, the differences between each pair of treatments is checked with a Holm-adjusted Wilcoxon SignedRankTest. The cliques represent groups of treatments which are not significantly distinguishable from each other.\n\nkwargs\n\nalpha=0.05 is the significance level in the hypothesis tests.\nmaximize_outcome=false specifies whether the ranks represent a maximization or a minimization of the outcomes.\ntitle=nothing is an optional string to be printed above the diagram.\nreverse_x=false reverses the direction of the x axis from right-to-left (default) to left-to-right.\n\n2-dimensional sequences of CD diagrams\n\nYou can arrange a sequence of CD diagrams in a single 2-dimensional axis. In the following, each item in the sequence consists of a pair s_i => [args_i...] of the item's name s_i and the regular CD diagram arguments args_i... that are documented above.\n\nplot(\n    s_1 => [t_11 => x_11, t_12 => x_12, ..., t_1k =>  x_1k],\n    s_2 => [t_21 => x_21, t_22 => x_22, ..., t_2k =>  x_2k],\n    ...,\n    s_j => [t_j1 => x_j1, t_j2 => x_j2, ..., t_jk =>  x_jk];\n    kwargs...\n)\n\n\n\n\n\n","category":"function"},{"location":"api-reference/#CriticalDifferenceDiagrams.ranks_and_cliques","page":"API reference","title":"CriticalDifferenceDiagrams.ranks_and_cliques","text":"ranks_and_cliques(t_1 => x_1, t_2 => x_2, ..., t_k =>  x_k; kwargs...)\nranks_and_cliques(x_1, x_2, ..., x_k; kwargs...)\nranks_and_cliques(X; kwargs...)\nranks_and_cliques(df, treatment, observation, outcome; kwargs...)\n\nReturn a tuple (avg_ranks, cliques) of the average ranks of k treatments in n repeated observations, together with the cliques of indistinguishable treatments.\n\nThe input data are arranged in treatments t_i => x_i, each of which has a name t_i and n associated observations x_i. You can omit the names, either providing the separate x_i alone or by providing all observations as a single (n, k)-shaped matrix X. Alternatively, you can provide a DataFrame df with the columns treatment, observation, and outcome.\n\nThe analysis starts with a FriedmanTest to check if any of the treatments differ. If so, the differences between each pair of treatments is checked with a Holm-adjusted Wilcoxon SignedRankTest. The cliques represent groups of treatments which are not significantly distinguishable from each other.\n\nkwargs\n\nalpha=0.05 is the significance level in the hypothesis tests.\nmaximize_outcome=false specifies whether the ranks represent a maximization or a minimization of the outcomes.\n\n\n\n\n\n","category":"function"},{"location":"api-reference/#Friedman-test","page":"API reference","title":"Friedman test","text":"","category":"section"},{"location":"api-reference/","page":"API reference","title":"API reference","text":"The Friedman test might eventually be migrated to HypothesisTests.jl.","category":"page"},{"location":"api-reference/","page":"API reference","title":"API reference","text":"FriedmanTest\nFDistFriedmanTest\nChisqFriedmanTest\naverage_ranks","category":"page"},{"location":"api-reference/#CriticalDifferenceDiagrams.FriedmanTest","page":"API reference","title":"CriticalDifferenceDiagrams.FriedmanTest","text":"FriedmanTest(x_1, x_2, ..., x_k; kwargs...) = FDistFriedmanTest(x_1, x_2, ..., x_k; kwargs...)\nFriedmanTest(X; kwargs...) = FDistFriedmanTest(X; kwargs...)\n\nTest the null hypothesis that n repeated observations of a set of k treatments    have the same distribution across all treatments. These observations are arranged    in k vectors x_i of n observations each or in an (n, k)-shaped matrix X.\n\nThe default version of this test, the FDistFriedmanTest, uses an F-distributed statistic.\n\nSee also: FDistFriedmanTest, ChisqFriedmanTest\n\nKeyword arguments\n\nmaximize_outcome=false specifies whether the ranks represent a maximization or a minimization of the outcomes.\n\n\n\n\n\n","category":"type"},{"location":"api-reference/#CriticalDifferenceDiagrams.FDistFriedmanTest","page":"API reference","title":"CriticalDifferenceDiagrams.FDistFriedmanTest","text":"FDistFriedmanTest(x_1, x_2, ..., x_k; kwargs...)\nFDistFriedmanTest(X; kwargs...)\n\nTest the null hypothesis that n repeated observations of a set of k treatments    have the same distribution across all treatments. These observations are arranged    in k vectors x_i of n observations each or in an (n, k)-shaped matrix X.\n\nThis version of the FriedmanTest uses an F-distributed statistic.\n\nKeyword arguments\n\nmaximize_outcome=false specifies whether the ranks represent a maximization or a minimization of the outcomes.\n\n\n\n\n\n","category":"type"},{"location":"api-reference/#CriticalDifferenceDiagrams.ChisqFriedmanTest","page":"API reference","title":"CriticalDifferenceDiagrams.ChisqFriedmanTest","text":"ChisqFriedmanTest(x_1, x_2, ..., x_k; kwargs...)\nChisqFriedmanTest(X; kwargs...)\n\nTest the null hypothesis that n repeated observations of a set of k treatments    have the same distribution across all treatments. These observations are arranged    in k vectors x_i of n observations each or in an (n, k)-shaped matrix X.\n\nThis version of the FriedmanTest uses a χ²-distributed statistic.\n\nKeyword arguments\n\nmaximize_outcome=false specifies whether the ranks represent a maximization or a minimization of the outcomes.\n\n\n\n\n\n","category":"type"},{"location":"api-reference/#CriticalDifferenceDiagrams.average_ranks","page":"API reference","title":"CriticalDifferenceDiagrams.average_ranks","text":"average_ranks(x) where x <: FriedmanTest\n\nReturn the average ranks of methods in the FriedmanTest.\n\n\n\n\n\n","category":"function"},{"location":"#Home","page":"Home","title":"CriticalDifferenceDiagrams.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Critical difference (CD) diagrams are a powerful tool to compare outcomes of multiple treatments over multiple observations. For instance, in machine learning research we often compare the performance (outcome) of multiple methods (treatments) over multiple data sets (observations). This Julia package generates Tikz code to produce publication-ready vector graphics. A wrapper for Python is also available.","category":"page"},{"location":"#Reading-a-CD-diagram","page":"Home","title":"Reading a CD diagram","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Let's take a look at the treatments clf1 to clf5. Their position represents their mean ranks across all outcomes of the observations, where low ranks indicate that a treatment wins more often than its competitors with higher ranks. Two or more treatments are connected with each other if we can not tell their outcomes apart, in the sense of statistical significance. For the above example, we can not tell from the data whether clf3 and clf5 are actually different from each other. We can tell, however, that both of them are different from all of the other treatments. This example above is adapted from https://github.com/hfawaz/cd-diagram.","category":"page"},{"location":"","page":"Home","title":"Home","text":"<img alt=\"assets/example.svg\" src=\"assets/example.svg\" style=\"width: 480px; max-width: 100%; margin: 2em auto; display: block;\">","category":"page"},{"location":"","page":"Home","title":"Home","text":"A diagram like the one above concisely represents multiple hypothesis tests that are conducted over the observed outcomes. Before anything is plotted at all, the Friedman test tells us whether there are significant differences at all. If this test fails, we have not sufficient data to tell any of the treatments apart and we must abort. If, however, the test sucessfully rejects this possibility we can proceed with the post-hoc analysis. In this second step, a Wilcoxon signed-rank test tells us whether each pair of treatments exhibits a significant difference. Since we are testing multiple hypotheses, we must adjust the Wilcoxon test with Holm's method. For each group of treatments which we can not distinguish from the Holm-adjusted Wilcoxon test, we add a thick line to the diagram.","category":"page"},{"location":"#Getting-started","page":"Home","title":"Getting started","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"CriticalDifferenceDiagrams.jl can be installed through the Julia package manager. From the Julia REPL, type ] to enter the Pkg mode of the REPL. Then run","category":"page"},{"location":"","page":"Home","title":"Home","text":"pkg> add CriticalDifferenceDiagrams","category":"page"},{"location":"","page":"Home","title":"Home","text":"The example plot above is then generated with the following code:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using CriticalDifferenceDiagrams, CSV, DataFrames, Downloads, PGFPlots\n\n# we generate the above example from the underlying data\nurl = \"https://raw.githubusercontent.com/hfawaz/cd-diagram/master/example.csv\"\ndf = CSV.read(Downloads.download(url), DataFrame)\n\nplot = CriticalDifferenceDiagrams.plot(\n    df,\n    :classifier_name, # the name of the treatment column\n    :dataset_name,    # the name of the observation column\n    :accuracy;         # the name of the outcome column\n    maximize_outcome=true, # compute ranks for minimization (default) or maximization\n    title=\"CriticalDifferenceDiagrams.jl\" # give an optional title\n)\n\n# configure the preamble of PGFPlots.jl (optional)\npushPGFPlotsPreamble(\"\"\"\n    \\\\usepackage{lmodern}\n\"\"\")\n\n# export to .svg, .tex, or .pdf\nPGFPlots.save(\"example.svg\", plot)","category":"page"},{"location":"#Cautions","page":"Home","title":"Cautions","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The hypothesis tests underneath the CD diagram do not account for variances of the outcomes. It is therefore important that these outcomes are \"reliable\" in the sense that each of them is obtained from a sufficiently large sample. Ideally, they come from a cross validation or from a repeated stratified split. Moreover, all treatments must have been evaluated on the same set of observations.","category":"page"},{"location":"#dimensional-sequences-of-CD-diagrams","page":"Home","title":"2-dimensional sequences of CD diagrams","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"You can arrange a series of CD diagrams in a single 2-dimensional axis. Each row in such a plot is a separate CD diagram.","category":"page"},{"location":"","page":"Home","title":"Home","text":"<img alt=\"assets/2d_example.svg\" src=\"assets/2d_example.svg\" style=\"width: 480px; max-width: 100%; margin: 2em auto; display: block;\">","category":"page"},{"location":"","page":"Home","title":"Home","text":"You create a 2-dimensional sequence of CD diagrams by calling the plot function on a sequence of (title, data) pairs. The data consists of the same pairs that a 1-dimensional CD diagram would use.","category":"page"},{"location":"","page":"Home","title":"Home","text":"sequence = Pair{String, Vector{Pair{String, Vector}}}[]\npush!(sequence, \"A\" => CriticalDifferenceDiagrams.to_pairs(\n    CSV.read(file1, DataFrame), :method, :dataset, :accuracy\n))\npush!(sequence, \"B\" => CriticalDifferenceDiagrams.to_pairs(\n    CSV.read(file2, DataFrame), :method, :dataset, :accuracy\n))\nplot = CriticalDifferenceDiagrams.plot(sequence...; maximize_outcome=true)","category":"page"},{"location":"","page":"Home","title":"Home","text":"The API reference of the plot method provides additional information on how to generate sequences of CD diagrams, which are arranged in a single 2-dimensional axis.","category":"page"},{"location":"#Citing","page":"Home","title":"Citing","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"CD diagrams have originally been proposed in the following article:","category":"page"},{"location":"","page":"Home","title":"Home","text":"@article{demsar2006statistical,\n  title={Statistical comparisons of classifiers over multiple data sets},\n  author={Dem{\\v{s}}ar, Janez},\n  journal={The Journal of Machine learning research},\n  volume={7},\n  number={1},\n  pages={1--30},\n  year={2006}\n}","category":"page"},{"location":"","page":"Home","title":"Home","text":"However, the above article favors Nemenyi's test for the post-hoc analysis. It has later been argued that Wilcoxon's signed rank test (or the sign test) are more appropriate for the post-hoc assessment of the pairwise differences:","category":"page"},{"location":"","page":"Home","title":"Home","text":"@article{benavoli2016should,\n  title={Should we really use post-hoc tests based on mean-ranks?},\n  author={Benavoli, Alessio and Corani, Giorgio and Mangili, Francesca},\n  journal={The Journal of Machine Learning Research},\n  volume={17},\n  number={1},\n  pages={152--161},\n  year={2016}\n}","category":"page"},{"location":"python-wrapper/#Python-wrapper-for-CriticalDifferenceDiagrams.jl","page":"Python wrapper","title":"Python wrapper for CriticalDifferenceDiagrams.jl","text":"","category":"section"},{"location":"python-wrapper/","page":"Python wrapper","title":"Python wrapper","text":"The wrapper provides an interface through which the methods of CriticalDifferenceDiagrams.jl are exposed to Python. This short guide assumes you have read the Home section.","category":"page"},{"location":"python-wrapper/#Getting-started","page":"Python wrapper","title":"Getting started","text":"","category":"section"},{"location":"python-wrapper/","page":"Python wrapper","title":"Python wrapper","text":"The wrapper can be installed with pip:","category":"page"},{"location":"python-wrapper/","page":"Python wrapper","title":"Python wrapper","text":"pip install https://github.com/mirkobunse/CriticalDifferenceDiagrams.jl/archive/py.tar.gz\npython -c \"import CriticalDifferenceDiagrams_jl\"","category":"page"},{"location":"python-wrapper/","page":"Python wrapper","title":"Python wrapper","text":"The second step ensures that all Julia dependencies, including Julia itself, are installed.","category":"page"},{"location":"python-wrapper/","page":"Python wrapper","title":"Python wrapper","text":"The example plot from the Home section is then generated with the following Python code:","category":"page"},{"location":"python-wrapper/","page":"Python wrapper","title":"Python wrapper","text":"import CriticalDifferenceDiagrams_jl as cdd\nimport pandas as pd\nfrom wget import download\n\n# we generate the above example from the underlying data\ndownload(\"https://raw.githubusercontent.com/hfawaz/cd-diagram/master/example.csv\")\ndf = pd.read_csv(\"example.csv\")\n\nplot = cdd.plot(\n    df,\n    \"classifier_name\", # the name of the treatment column\n    \"dataset_name\",    # the name of the observation column\n    \"accuracy\",        # the name of the outcome column\n    maximize_outcome=True, # compute ranks for minimization (default) or maximization\n    title=\"CriticalDifferenceDiagrams.jl\" # give an optional title\n)\n\n# configure the preamble of PGFPlots.jl (optional)\ncdd.pushPGFPlotsPreamble(\"\\\\usepackage{lmodern}\")\n\n# export to .svg, .tex, or .pdf\ncdd.save(\"example.svg\", plot)","category":"page"},{"location":"python-wrapper/#Performance","page":"Python wrapper","title":"Performance","text":"","category":"section"},{"location":"python-wrapper/","page":"Python wrapper","title":"Python wrapper","text":"The first import CriticalDifferenceDiagrams_jl installs all Julia dependencies, which takes some time. Therefore, we recommend to call","category":"page"},{"location":"python-wrapper/","page":"Python wrapper","title":"Python wrapper","text":"python -c \"import CriticalDifferenceDiagrams_jl\"","category":"page"},{"location":"python-wrapper/","page":"Python wrapper","title":"Python wrapper","text":"as a part of the installation process, as described in the Getting started section.","category":"page"},{"location":"python-wrapper/","page":"Python wrapper","title":"Python wrapper","text":"Calling a method for the first time will be somewhat slow, due to Julia's just-in-time (JIT) compilation mechanism. JIT means that all functions are compiled when they are called for the first time in a session. As a result, the first call is quite slow but subsequent calls are super fast. If your implementation design permits, generate multiple CD diagrams in a single session to benefit from the JIT speedup of subsequent method calls.","category":"page"}]
}
