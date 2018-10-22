# a convenient way of interacting with a simulation
# maintained by @zsunberg

"""
    sim(polfunc::Function, mdp::MDP; [<keyword arguments>])
    sim(polfunc::Function, pomdp::POMDP; [<keyword arguments>])

Alternative way of running a simulation with a function specifying how to calculate the action at each timestep.

# Usage

    sim(mdp) do s
        # code that calculates action `a` based on `s` - this is the policy
        # you can also do other things like display something
        return a
    end

for an MDP or

    sim(pomdp) do o
        # code that does belief updates with observation `o` and calculates `a`
        # you can also do other things like display something
        # by default the initial `o` is the initial state distribution
        return a
    end

for a POMDP.

# Keyword Arguments

## All Versions

- `initialstate`: the initial state for the simulation
- `simulator`: keyword argument to specify any simulator to run the simulation. If nothing is specified for the simulator, a HistoryRecorder will be used as the simulator, with all keyword arguments forwarded to it, e.g.
  ```
  sim(mdp, max_steps=100, show_progress=true) do s
      # ...
  end
  ```
  will limit the simulation to 100 steps.

## POMDP Version

- `initialobs`: this will control the initial observation given to the policy function. If this is not defined the following defaults be used if available (1) `initialstate_distribution(m)`, (2) `generate_o(m, sp, rng)`, (3) `missing`.
- `updater`: if provided, this updater will be used to update the belief, and the belief will be used as the argument to the policy function.
"""
function sim end

function sim(polfunc::Function, mdp::MDP;
             initialstate=nothing,
             simulator=nothing,
             kwargs...
            )

    kwargd = Dict(kwargs)
    if initialstate==nothing && statetype(mdp) != Nothing
        initialstate = default_init_state(mdp)
    end
    if simulator==nothing
        simulator = HistoryRecorder(;kwargd...)
    end
    policy = FunctionPolicy(polfunc)
    simulate(simulator, mdp, policy, initialstate)
end

function sim(polfunc::Function, pomdp::POMDP;
             initialstate=nothing,
             simulator=nothing,
             initialobs=nothing,
             updater=nothing,
             kwargs...
            )

    kwargd = Dict(kwargs)
    if initialstate==nothing && statetype(pomdp) != Nothing
        initialstate = default_init_state(pomdp)
    end
    if simulator==nothing
        simulator = HistoryRecorder(;kwargd...)
    end
    if updater==nothing
        updater = PreviousObservationUpdater()
    end
    if initialobs==nothing && obstype(pomdp) != Nothing
        initialobs = default_init_obs(pomdp, initialstate)
    end
    policy = FunctionPolicy(polfunc)
    simulate(simulator, pomdp, policy, updater, initialobs, initialstate)
end

function default_init_obs(p::POMDP, s)
    if implemented(initialstate_distribution, Tuple{typeof(p)})
        return initialstate_distribution(p)
    elseif implemented(generate_o, Tuple{typeof(p), typeof(s), typeof(Random.GLOBAL_RNG)})
        return generate_o(p, s, Random.GLOBAL_RNG)
    else
        return missing
    end
end

@generated function default_init_state(p::Union{MDP,POMDP})
    if implemented(initialstate, Tuple{p, typeof(Random.GLOBAL_RNG)})
        return :(initialstate(p, Random.GLOBAL_RNG))
    else
        return quote
            error("""
                  Error in sim(::$(typeof(p))): No initial state specified.
                  
                  Please supply it as an argument after the mdp or define the method POMDPs.initialstate(::$(typeof(p)), ::$(typeof(Random.GLOBAL_RNG))) or define the method POMDPs.initialstate_distribution(::$(typeof(p))).

                  """)
        end
    end
end

@deprecate sim(f::Function, m::Union{POMDP, MDP}, initialstate; kwargs...) sim(f, m; initialstate=initialstate, kwargs...)
