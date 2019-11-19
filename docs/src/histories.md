# Histories

The results produced by [`HistoryRecorder`](@ref)s and the [`sim`](@ref) function are contained in `SimHistory` objects.

```@docs
SimHistory
```

## Examples

```jldoctest histaccess; output = false
using POMDPSimulators, POMDPs, POMDPModels, POMDPPolicies
hr = HistoryRecorder(max_steps=10)
hist = simulate(hr, BabyPOMDP(), FunctionPolicy(x->true))
step = hist[1] # all information available about the first step
step[:s] # the first state
step[:a] # the first action

# output

true
```

To see everything available in a step, use
```julia
keys(first(hist))
```

The entire history of each variable is available by using a `Symbol` instead of an index, i.e.
```julia
hist[:s]
```
will return a vector of the starting states for each step (note the difference between `:s` and `:sp`).

## `eachstep`

The [`eachstep`](@ref) function may also be useful:

```@docs
eachstep
```

### Examples:
```julia
collect(eachstep(h, "a,o"))
```
will produce a vector of action-observation named tuples.

```julia
collect(norm(sp-s) for (s,sp) in eachstep(h, "s,sp"))
```
will produce a vector of the distances traveled on each step (assuming the state is a Euclidean vector).

### Notes
- The iteration specification can be specified as a tuple of symbols (e.g. `(:s, :a)`) instead of a string.
- For type stability in performance-critical code, one should construct an iterator directly using `HistoryIterator{typeof(h), (:a,:r)}(h)` rather than `eachstep(h, "ar")`.

## Other Functions

`state_hist(h)`, `action_hist(h)`, `observation_hist(h)` `belief_hist(h)`, and `reward_hist(h)` will return vectors of the states, actions, and rewards, and `undiscounted_reward(h)` and `discounted_reward(h)` will return the total rewards collected over the trajectory. `n_steps(h)` returns the number of steps in the history. `exception(h)` and `backtrace(h)` can be used to hold an exception if the simulation failed to finish.

`view(h, range)` (e.g. `view(h, 1:n_steps(h)-4)`) can be used to create a view of the history object `h` that only contains a certain range of steps. The object returned by `view` is an `AbstractSimHistory` that can be iterated through and manipulated just like a complete `SimHistory`.
