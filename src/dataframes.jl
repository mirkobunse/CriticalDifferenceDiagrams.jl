using DataFrames

ranks_and_cliques(df::AbstractDataFrame, treatment::Symbol, observation::Symbol, outcome::Symbol; kwargs...) =
    ranks_and_cliques(to_pairs(df, treatment, observation, outcome)...; kwargs...)

plot(df::AbstractDataFrame, treatment::Symbol, observation::Symbol, outcome::Symbol; kwargs...) =
    plot(to_pairs(df, treatment, observation, outcome)...; kwargs...)

to_pairs(df::AbstractDataFrame, treatment::Symbol, observation::Symbol, outcome::Symbol) =
    map(pairs(groupby(sort(df, observation), treatment))) do (key, group)
        String(key[treatment]) => group[!, outcome]
    end # map from treatment name to all outcomes, which appear in the same order

@deprecate _to_pairs(df::AbstractDataFrame, x::Symbol, y::Symbol, z::Symbol) to_pairs(df, x, y, z)
