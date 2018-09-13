# History

## History Recorder

`HistoryRecorder` runs a simulation and records the trajectory. It returns an `MDPHistory` or `POMDPHistory` (see `history.jl` below).

```julia
hr = HistoryRecorder(max_steps=100)
pomdp = TigerPOMDP()
policy = RandomPolicy(pomdp)

h = simulate(hr, pomdp, policy)
```

```@docs
HistoryRecorder
```

## SimHistory

```@docs
eachstep
```

Examples:
```julia
collect(eachstep(h, "ao"))
```
will produce a vector of action-observation tuples.

```julia
collect(norm(sp-s) for (s,sp) in eachstep(h, "s,sp"))
```
will produce a vector of the distances traveled on each step (assuming the state is a Euclidean vector).

Notes:
- The iteration specification can be specified as a tuple of symbols (e.g. `(:s, :a)`) instead of a string.
- For type stability in performance-critical code, one should construct an iterator directly using `HistoryIterator{typeof(h), (:a,:r)}(h)` rather than `eachstep(h, "ar")`.

`state_hist(h)`, `action_hist(h)`, `observation_hist(h)` `belief_hist(h)`, and `reward_hist(h)` will return vectors of the states, actions, and rewards, and `undiscounted_reward(h)` and `discounted_reward(h)` will return the total rewards collected over the trajectory. `n_steps(h)` returns the number of steps in the history. `exception(h)` and `backtrace(h)` can be used to hold an exception if the simulation failed to finish.

`view(h, range)` (e.g. `view(h, 1:n_steps(h)-4)`) can be used to create a view of the history object `h` that only contains a certain range of steps. The object returned by `view` is a `SimHistory` that can be iterated through and manipulated just like a complete `SimHistory`.

### MDPHistory

An `MDPHistory` represents a state-action-reward history from simulating an MDP. Subtype of `SimHistory`

```@docs
MDPHistory
```

### POMDPHistory

A `POMDPHistory` contains a record of the states, actions, observations, rewards, and beliefs encountered during a simulation of a POMDP.
Subtype of `SimHistory`



