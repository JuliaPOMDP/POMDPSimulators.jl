# Sim

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

```@docs
sim
```
