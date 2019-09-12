# HistoryRecorder
# maintained by @zsunberg

"""
A simulator that records the history for later examination

The simulation will be terminated when either
1) a terminal state is reached (as determined by `isterminal()` or
2) the discount factor is as small as `eps` or
3) max_steps have been executed

Keyword Arguments:
    - `rng`: The random number generator for the simulation
    - `capture_exception::Bool`: whether to capture an exception and store it in the history, or let it go uncaught, potentially killing the script
    - `show_progress::Bool`: show a progress bar for the simulation
    - `eps`
    - `max_steps`
    - `sizehint::Int`: the expected length of the simulation (for preallocation)

Usage (optional arguments in brackets):

    hr = HistoryRecorder()
    history = simulate(hr, pomdp, policy, [updater [, init_belief [, init_state]]])
"""
struct HistoryRecorder <: Simulator
    rng::AbstractRNG

    # options
    capture_exception::Bool
    show_progress::Bool

    # optional: if these are null, they will be ignored
    max_steps::Union{Nothing,Any}
    eps::Union{Nothing,Any}
    sizehint::Union{Nothing,Integer}
end

# This is the only stable constructor
function HistoryRecorder(;rng=MersenneTwister(rand(UInt32)),
                          eps=nothing,
                          max_steps=nothing,
                          sizehint=nothing,
                          capture_exception=false,
                          show_progress=false)
    return HistoryRecorder(rng, capture_exception, show_progress, max_steps, eps, sizehint)
end

@POMDP_require simulate(sim::HistoryRecorder, pomdp::POMDP, policy::Policy) begin
    @req updater(::typeof(policy))
    up = updater(policy)
    @subreq simulate(sim, pomdp, policy, up)
end

@POMDP_require simulate(sim::HistoryRecorder, pomdp::POMDP, policy::Policy, bu::Updater) begin
    @req initialstate_distribution(::typeof(pomdp))
    dist = initialstate_distribution(pomdp)
    @subreq simulate(sim, pomdp, policy, bu, dist)
end

function simulate(sim::HistoryRecorder, pomdp::POMDP, policy::Policy, bu::Updater=updater(policy))
    dist = initialstate_distribution(pomdp)
    return simulate(sim, pomdp, policy, bu, dist)
end

@POMDP_require simulate(sim::HistoryRecorder, pomdp::POMDP, policy::Policy, bu::Updater, dist::Any) begin
    P = typeof(pomdp)
    S = statetype(pomdp)
    A = actiontype(pomdp)
    O = obstype(pomdp)
    @req initialize_belief(::typeof(bu), ::typeof(dist))
    @req isterminal(::P, ::S)
    @req discount(::P)
    @req generate_sor(::P, ::S, ::A, ::typeof(sim.rng))
    b = initialize_belief(bu, dist)
    B = typeof(b)
    @req action(::typeof(policy), ::B)
    @req update(::typeof(bu), ::B, ::A, ::O)
end

function simulate(sim::HistoryRecorder,
                           pomdp::POMDP{S,A,O}, 
                           policy::Policy,
                           bu::Updater,
                           initialstate_dist::Any,
                           is::Any=initialstate(pomdp, sim.rng)
                  ) where {S,A,O}

    initial_belief = initialize_belief(bu, initialstate_dist)
    if sim.max_steps == nothing
        max_steps = typemax(Int)
    else
        max_steps = sim.max_steps
    end
    if sim.eps != nothing
        max_steps = min(max_steps, ceil(Int,log(sim.eps)/log(discount(pomdp))))
    end
    if sim.sizehint == nothing
        sizehint = min(max_steps, 1000)
    else
        sizehint = sim.sizehint
    end

    # aliases for the histories to make the code more concise
    exception = nothing
    backtrace = nothing

    if sim.show_progress
        if (sim.max_steps == nothing) && (sim.eps == nothing)
            error("If show_progress=true in a HistoryRecorder, you must also specify max_steps or eps.")
        end
        prog = Progress(max_steps, "Simulating..." )
    end

    disc = 1.0
    step = 1

    it = POMDPSimIterator(default_spec(pomdp),
                          pomdp,
                          policy,
                          bu,
                          rng,
                          initial_belief,
                          is,
                          max_steps)

    try
        if sim.show_progress
            # this strange construct is here so that type inferrence doesn't depend on show_progress
            hist = collect(begin
                               next!(prog)
                               step
                           end for step in it)
        else
            hist = collect(it)
        end
    catch ex
        if sim.capture_exception
            exception = ex
            backtrace = catch_backtrace()
        else
            rethrow(ex)
        end
    end

    if sim.show_progress
        finish!(prog)
    end

    return SimHistory(promot_hist(hist), discount(pomdp), exception, backtrace)
end

@POMDP_require simulate(sim::HistoryRecorder, mdp::MDP, policy::Policy) begin
    init_state = initialstate(mdp, sim.rng)
    @subreq simulate(sim, mdp, policy, init_state)
end

@POMDP_require simulate(sim::HistoryRecorder, mdp::MDP, policy::Policy, initialstate::Any) begin
    P = typeof(mdp)
    S = statetype(mdp)
    A = actiontype(mdp)
    @req isterminal(::P, ::S)
    @req action(::typeof(policy), ::S)
    @req generate_sr(::P, ::S, ::A, ::typeof(sim.rng))
    @req discount(::P)
end

function simulate(sim::HistoryRecorder,
                  mdp::MDP{S,A}, policy::Policy,
                  init_state::S=initialstate(mdp, sim.rng)) where {S,A}
    
    if sim.max_steps == nothing
        max_steps = typemax(Int)
    else
        max_steps = sim.max_steps
    end
    if sim.eps != nothing
        max_steps = min(max_steps, ceil(Int,log(sim.eps)/log(discount(mdp))))
    end
    if sim.sizehint == nothing
        sizehint = min(max_steps, 1000)
    else
        sizehint = sim.sizehint
    end

    # aliases for the histories to make the code more concise
    sh = sizehint!(Vector{S}(undef, 0), sizehint)
    ah = sizehint!(Vector{A}(undef, 0), sizehint)
    rh = sizehint!(Vector{Float64}(undef, 0), sizehint)
    ih = sizehint!(Vector{Any}(undef, 0), sizehint)
    aih = sizehint!(Vector{Any}(undef, 0), sizehint)
    exception = nothing
    backtrace = nothing

    if sim.show_progress
        if (sim.max_steps == nothing) && (sim.eps == nothing)
            error("If show_progress=true in a HistoryRecorder, you must also specify max_steps or eps.")
        end
        prog = Progress(max_steps, "Simulating..." )
    end
    
    push!(sh, init_state)

    disc = 1.0
    step = 1

    try
        while !isterminal(mdp, sh[step]) && step <= max_steps
            a, ai = action_info(policy, sh[step])
            push!(ah, a)
            push!(aih, ai)

            sp, r, i = generate_sri(mdp, sh[step], ah[step], sim.rng)

            push!(sh, sp)
            push!(rh, r)
            push!(ih, i)

            disc *= discount(mdp)
            step += 1

            if sim.show_progress
                next!(prog)
            end
        end
    catch ex
        if sim.capture_exception
            exception = ex
            backtrace = catch_backtrace()
        else
            rethrow(ex)
        end
    end

    if sim.show_progress
        finish!(prog)
    end

    return MDPHistory(sh, ah, rh, ih, aih, discount(mdp), exception, backtrace)
end

function promote_history(hist::AbstractVector)
    if isconcretetype(eltype(hist))
        return hist
    else
        # it would really astound me if this branch was type stable
        names = fieldnames(first(hist))
        types = fieldtypes(first(hist))
        for step in hist
            @assert fieldnames(step) == names
            types = map(promote_rule, types, fieldtypes(step))
        end
        NT = NamedTuple{names, Tuple{types...}}
        return convert(Vector{NT}, hist)
    end
end
