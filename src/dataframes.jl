using DataFrames

ranks_and_cliques(df::AbstractDataFrame, treatment::Symbol, observation::Symbol, outcome::Symbol; kwargs...) =
    ranks_and_cliques(
        map(pairs(groupby(sort(df, observation), treatment))) do (key, group)
            key[treatment] => group[!, outcome]
        end...; # map from treatment name to all outcomes, which appear in the same order
        kwargs...
    )
