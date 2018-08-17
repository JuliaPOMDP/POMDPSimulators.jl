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
    if initialstate==nothing && statetype(mdp) != Nothing
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
             initialobs=nothing,
             updater=nothing,
             kwargs...
            )

    kwargd = Dict(kwargs)
    if initialstate==nothing && statetype(pomdp) != Nothing
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
    if initialobs==nothing && obstype(pomdp) != Nothing
        initialobs = default_init_obs(pomdp, initialstate)
    end
    if updater==nothing
        updater = PreviousObservationUpdater()
    end
    policy = FunctionPolicy(polfunc)
    simulate(simulator, pomdp, policy, updater, initialobs, initialstate)
end

function default_init_obs(p::POMDP, s)
    if implemented(generate_o, Tuple{typeof(p), typeof(s), typeof(Random.GLOBAL_RNG)})
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
