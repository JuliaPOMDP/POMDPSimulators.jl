# POMDPSimulators.jl

#### [`rollout.jl`](src/rollout.jl)

`RolloutSimulator` is the simplest MDP or POMDP simulator. When `simulate` is called, it simply simulates a single trajectory of the process and returns the discounted reward.

```julia
rs = RolloutSimulator()
mdp = GridWorld()
policy = RandomPolicy(mdp)

r = simulate(rs, mdp, policy)
```
See output of `?RolloutSimulator` for a list of keyword arguments.

#### [`history_recorder.jl`](src/history_recorder.jl)

`HistoryRecorder` runs a simulation and records the trajectory. It returns an `MDPHistory` or `POMDPHistory` (see `history.jl` below).

```julia
hr = HistoryRecorder(max_steps=100)
pomdp = TigerPOMDP()
policy = RandomPolicy(pomdp)

h = simulate(hr, pomdp, policy)
```
See the output of `?HistoryRecorder` for a list of keyword arguments.

#### [`history.jl`](src/history.jl)
Contains types for representing simulation histories (i.e. trajectories or episodes).

An `MDPHistory` represents a state-action-reward history from simulating an MDP. A `POMDPHistory` contains a record of the states, actions, observations, rewards, and beliefs encountered during a simulation of a POMDP. Both of these are subtypes of `SimHistory`.

The steps of any `SimHistory` object `h` can be iterated through as follows:

```julia
for (s, a, r, sp) in eachstep(h, "(s, a, r, sp)")    
println("reward $r received when state $sp was reached after action $a was taken in state $s")
end
```

The possible valid elements in the iteration specification are
- `s` - the initial state in a step
- `b` - the initial belief in the step (for POMDPs only)
- `a` - the action taken in the step
- `r` - the reward received for the step
- `sp` - the final state at the end of the step (s')
- `o` - the observation received during the step (note that this is usually based on `sp` instead of `s`)
- `bp` - the belief after being updated based on `o` (for POMDPs only)
- `i` - info from the state transition (from `generate_sri` for MDPs or `generate_sori` for POMDPs)
- `ai` - info from the policy decision (from `action_info`)
- `ui` - info from the belief update (from `update_info`)

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


#### [`sim.jl`](src/sim.jl)
The `sim` function provides a convenient way to interact with a POMDP or MDP environment. The first argument is a function that is called at every time step and takes a state (in the case of an MDP) or an observation (in the case of a POMDP) as the argument and then returns an action. The second argument is a pomdp or mdp. It is intended to be used with Julia's `do` syntax as follows:

```julia
pomdp = TigerPOMDP()
history = sim(pomdp, max_steps=10) do obs
println("Observation was $obs.")
return TIGER_OPEN_LEFT
end
```
This allows a flexible and general way to interact with a POMDP environment without creating new `Policy` types.

Note: by default, since there is no observation before the first action, on the first call to the `do` block, `obs` is `nothing`.

#### [`stepthrough.jl`](src/stepthrough.jl)
The `stepthrough` function exposes a simulation as an iterator so that the steps can be iterated through with a for loop syntax as follows:

```julia
pomdp = BabyPOMDP()
policy = RandomPolicy(pomdp)

for (s, a, o, r) in stepthrough(pomdp, policy, "s,a,o,r", max_steps=10)
println("in state $s")
println("took action $o")
println("received observation $o and reward $r")
end
```
For more information, see the documentation for the `stepthrough` function.

The `StepSimulator` contained in this file can provide the same functionality with the following syntax:
```julia
sim = StepSimulator("s,a,r,sp")
for (s,a,r,sp) in simulate(sim, problem, policy)
# do something
end
```

#### [`parallel.jl`](src/parallel.jl)
The `run_parallel` function can be used to conveniently run simulations in parallel. Example:

```julia
using POMDPToolbox
using POMDPModels

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
