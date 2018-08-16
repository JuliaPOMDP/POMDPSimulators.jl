# a convenient way of interacting with a simulation
# maintained by @zsunberg

"""
    sim(polfunc::Function, mdp::MDP)
    sim(polfunc::Function, pomdp::POMDP)

Alternative way of running a simulation with a function specifying how to calculate the action at each timestep.

The intended usage is

    sim(mdp) do s
        # code that calculates action `a` based on `s` - this is the policy
        # you can also do other things like display something
        return a
    end

for an MDP or

    sim(pomdp) do o
        # code that does belief updates with observation `o` and calculates `a`
        # you can also do other things like display something
        return a
    end

for a POMDP.

Use the `simulator` keyword argument to specify any simulator to run the simulation. If nothing is specified for the simulator, a HistoryRecorder will be used as the simulator, with all keyword arguments forwarded to it, e.g.

    sim(mdp, max_steps=100) do s
        # ...
    end

will limit the simulation to 100 steps
"""
function sim end

function sim(polfunc::Function, mdp::MDP,
             initialstate=nothing;
             simulator=nothing,
             kwargs...
            )

    kwargd = Dict(kwargs)
    if initialstate==nothing && state_type(mdp) != Nothing
        if haskey(kwargd, :initialstate)
            initialstate = pop!(kwargd, :initialstate)
        else
            initialstate = default_init_state(mdp)
        end    
    end
    delete!(kwargd, :initialstate)
    if simulator==nothing
        simulator = HistoryRecorder(;kwargd...)
    end
    policy = FunctionPolicy(polfunc)
    simulate(simulator, mdp, policy, initialstate)
end

function sim(polfunc::Function, pomdp::POMDP,
             initialstate=nothing;
             simulator=nothing,
             initial_obs=nothing,
             updater=nothing,
             kwargs...
            )

    kwargd = Dict(kwargs)
    if initialstate==nothing && state_type(pomdp) != Void
        if haskey(kwargd, :initialstate)
            initialstate = pop!(kwargd, :initialstate)
        else
            initialstate = default_init_state(pomdp)
        end    
    end
    delete!(kwargd, :initialstate)
    if simulator==nothing
        simulator = HistoryRecorder(;kwargd...)
    end
    if initial_obs==nothing && obs_type(pomdp) != Void
        initial_obs = default_init_obs(pomdp, initialstate)
    end
    if updater==nothing
        updater = PrimedPreviousObservationUpdater{Any}(initial_obs)
    end
    policy = FunctionPolicy(polfunc)
    simulate(simulator, pomdp, policy, updater, initial_obs, initialstate)
end

function default_init_obs(p::POMDP, s)
    if implemented(generate_o, Tuple{typeof(p), typeof(s), typeof(Base.GLOBAL_RNG)})
        return generate_o(p, s, Base.GLOBAL_RNG)
    else
        return nothing
    end
end

@generated function default_init_state(p::Union{MDP,POMDP})
    if implemented(initialstate, Tuple{p, typeof(Base.GLOBAL_RNG)})
        return :(initialstate(p, Base.GLOBAL_RNG))
    else
        return quote
            error("""
                  Error in sim(::$(typeof(p))): No initial state specified.
                  
                  Please supply it as an argument after the mdp or define the method POMDPs.initialstate(::$(typeof(p)), ::$(typeof(Base.GLOBAL_RNG))) or define the method POMDPs.initialstate_distribution(::$(typeof(p))).

                  """)
        end
    end
end
