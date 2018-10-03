# Parallel

POMDPSimulators contains a utility for running many Monte Carlo simulations in parallel to evaluate performance. The basic workflow involves the following steps:

1. Create a vector of [`Sim`](@ref) objects, each specifying how a single simulation should be run.
2. Use the [`run_parallel`](@ref) or [`run`](@ref) function to run the simulations.
3. Analyze the results of the simulations contained in the [`DataFrame`](https://github.com/JuliaData/DataFrames.jl) returned by [`run_parallel`](@ref).

An extended example is shown below [TODO: move this to POMDPExamples].

By default, only the discounted rewards from each simulation are recorded, but arbitrary information can be recorded as described in the next section.

## Specifying information to be recorded

The [`run_parallel`](@ref) and [`run`](@ref) functions accept a function (normally specified via the [`do` syntax](https://docs.julialang.org/en/v1/manual/functions/#Do-Block-Syntax-for-Function-Arguments-1)) that takes the [`Sim`](@ref) object and [history](@ref Histories) of the simulation and extracts relevant statistics as a named tuple. For example, if the desired characteristics are the number of steps in the simulation and the reward, [`run_parallel`](@ref) would be invoked as follows:
```julia
df = run_parallel(queue) do sim::Sim, hist::SimHistory
    return (n_steps=n_steps(hist), reward=discounted_reward(hist))
end
```
These statistics are combined into a [`DataFrame`](https://github.com/JuliaData/DataFrames.jl), with each line representing a single simulation, allowing for statistical analysis. For example,
```julia
mean(df[:reward]./df[:n_steps])
```
would compute the average reward per step with each simulation weighted equally regardless of length.


## Example

```julia
using POMDPModels
using POMDPPolicies
using POMDPSimulators

pomdp = BabyPOMDP()
fwc = FeedWhenCrying()
rnd = solve(RandomSolver(MersenneTwister(7)), pomdp)

q = [] # vector of the simulations to be run
push!(q, Sim(pomdp, fwc, max_steps=32, rng=MersenneTwister(4), metadata=Dict(:policy=>"feed when crying")))
push!(q, Sim(pomdp, rnd, max_steps=32, rng=MersenneTwister(4), metadata=Dict(:policy=>"random")))

# this creates two simulations, one with the feed-when-crying policy and one with a random policy

data = run_parallel(q)

# by default, the dataframe output contains the reward and the contents of `metadata`
@show data
# data = 2×2 DataFrames.DataFrame
# │ Row │ policy             │ reward   │
# ├─────┼────────────────────┼──────────┤
# │ 1   │ "feed when crying" │ -4.5874  │
# │ 2   │ "random"           │ -27.4139 │

# to perform additional analysis on each of the simulations one can define a processing function with the `do` syntax:
data2 = run_parallel(q, progress=false) do sim, hist
println("finished a simulation - final state was $(last(state_hist(hist)))")
return [:steps=>n_steps(hist), :reward=>discounted_reward(hist)]
end

@show data2
# 2×3 DataFrames.DataFrame
# │ Row │ policy             │ reward   │ steps │
# ├─────┼────────────────────┼──────────┼───────┤
# │ 1   │ "feed when crying" │ -18.2874 │ 32.0  │
# │ 2   │ "random"           │ -17.7054 │ 32.0  │

```

## Sim objects

Each simulation should be specified by a [`Sim`](@ref) object which contains all the information needed to run a simulation, including the `Simulator`, `POMDP` or `MDP`, `Policy`, `Updater`, and any other ingredients.

```@docs
Sim
```

## Running simulations

The simulations are actually carried out by the `run` and `run_parallel` functions.

```@docs
run_parallel
```

The `run` function is also provided to run simulations in serial (this is often useful for debugging). Note that the documentation below also contains a section for the builtin julia `run` function, even though it is not relevant here.

```@docs
run
```
