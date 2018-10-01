# Rollout

## RolloutSimulator

`RolloutSimulator` is the simplest MDP or POMDP simulator. When `simulate` is called, it simply simulates a single trajectory of the process and returns the discounted reward.

```julia
rs = RolloutSimulator()
mdp = GridWorld()
policy = RandomPolicy(mdp)

r = simulate(rs, mdp, policy)
```

```@docs
RolloutSimulator
```

