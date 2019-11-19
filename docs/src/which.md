# Which Simulator Should I Use?

The simulators in this package provide interaction with simulations of MDP and POMDP environments from a variety of perspectives. Use this page to choose the best simulator to suit your needs.

## I want to run fast rollout simulations and get the discounted reward.

Use the [Rollout Simulator](@ref Rollout).

## I want to evaluate performance with many parallel Monte Carlo simulations.

Use the [Parallel Simulator](@ref Parallel).

## I want to closely examine the histories of states, actions, etc. produced by simulations.

Use the [History Recorder](@ref History-Recorder).

## I want to step through each individual step of a simulation.

Use the [`stepthrough` function](@ref Stepping-through).

## I want to visualize a simulation.

Use the [`DisplaySimulator`](@ref Display).

Also see the [POMDPGifs package](https://github.com/JuliaPOMDP/POMDPGifs.jl) for creating gif animations.

## I want to interact with a MDP or POMDP environment from the policy's perspective

Use the [`sim` function](@ref sim-function).
