# SimHistory
# maintained by @zsunberg

# Ordering of a complete step tuple:
# (The general structure is (mdp core, t, mdp info, pomdp core, pomdp info))
const COMPLETE_POMDP_STEP = (:s,:a,:r,:sp,:t,:i,:ai,:b,:o,:bp,:ui)
const COMPLETE_MDP_STEP = COMPLETE_POMDP_STEP[1:7]

const MDPStep{S,A} = NamedTuple{COMPLETE_MDP_STEP, Tuple{S,A,Float64,S,Int,Any,Any}}
const POMDPStep{S,A,O,B} = NamedTuple{COMPLETE_POMDP_STEP, Tuple{S,A,Float64,S,Int,Any,Any,B,O,B,Any}}

abstract type SimHistory{NT} <: AbstractVector{NT} end
abstract type AbstractMDPHistory{S,A} <: SimHistory{MDPStep{S,A}} end
abstract type AbstractPOMDPHistory{S,A,O,B} <: SimHistory{POMDPStep{S,A,O,B}} end

nt_type(::Type{H}) where H<:SimHistory{NT} where NT = NT
nt_type(h::SimHistory) = nt_type(typeof(h))

"""
    MDPHistory

An MDP simulation history returned by `simulate(::HistoryRecorder, ::MDP,...)`.

This is an `AbstractVector` of `NamedTuples` containing the states, actions, etc.

# Examples
```
hist[1][:s] # returns the first state in the history
```
```
hist[:a] # returns all of the actions in the history
```
"""
struct MDPHistory{S,A} <: AbstractMDPHistory{S,A}
    state_hist::Vector{S}
    action_hist::Vector{A}
    reward_hist::Vector{Float64}
    info_hist::Vector{Any}
    ainfo_hist::Vector{Any}

    discount::Float64

    # if an exception is captured, it will be stored here
    exception::Union{Nothing, Exception}
    backtrace::Union{Nothing, Any}
end

"""
    POMDPHistory

An POMDP simulation history returned by `simulate(::HistoryRecorder, ::POMDP,...)`.

This is an `AbstractVector` of `NamedTuples` containing the states, actions, etc.

# Examples
```
hist[1][:s] # returns the first state in the history
```
```
hist[:a] # returns all of the actions in the history
```

"""
struct POMDPHistory{S,A,O,B} <: AbstractPOMDPHistory{S,A,O,B}
    state_hist::Vector{S}
    action_hist::Vector{A}
    observation_hist::Vector{O}
    belief_hist::Vector{B}
    reward_hist::Vector{Float64}
    info_hist::Vector{Any}
    ainfo_hist::Vector{Any}
    uinfo_hist::Vector{Any}

    discount::Float64

    # if an exception is captured, it will be stored here
    exception::Union{Nothing, Exception}
    backtrace::Union{Nothing, Any}
end

# accessors: use these to access the members - in case the implementation changes
n_steps(h::SimHistory) = length(h.state_hist)-1

state_hist(h::SimHistory) = h.state_hist
action_hist(h::SimHistory) = h.action_hist
observation_hist(h::SimHistory) = h.observation_hist
belief_hist(h::SimHistory) = h.belief_hist
reward_hist(h::SimHistory) = h.reward_hist
info_hist(h::SimHistory) = h.info_hist
ainfo_hist(h::SimHistory) = h.ainfo_hist
uinfo_hist(h::SimHistory) = h.uinfo_hist

exception(h::SimHistory) = h.exception
Base.backtrace(h::SimHistory) = h.backtrace
POMDPs.discount(h::SimHistory) = h.discount

undiscounted_reward(h::SimHistory) = sum(reward_hist(h))
function discounted_reward(h::SimHistory)
    disc = 1.0
    r_total = 0.0
    for i in 1:length(reward_hist(h))
        r_total += disc*reward_hist(h)[i]
        disc *= discount(h)
    end
    return r_total
end


# AbstractArray interface
Base.size(h::SimHistory) = (n_steps(h),)

function Base.getindex(h::MDPHistory, i::Int)
    return nt_type(h)((state_hist(h)[i],
                       action_hist(h)[i],
                       reward_hist(h)[i],
                       state_hist(h)[i+1],
                       i,
                       info_hist(h)[i],
                       ainfo_hist(h)[i]
                      ))
end

function Base.getindex(h::POMDPHistory, i::Int)
    return nt_type(h)((state_hist(h)[i],
                       action_hist(h)[i],
                       reward_hist(h)[i],
                       state_hist(h)[i+1],
                       i,
                       info_hist(h)[i],
                       ainfo_hist(h)[i],
                       belief_hist(h)[i],
                       observation_hist(h)[i],
                       belief_hist(h)[i+1],
                       uinfo_hist(h)[i]
                      ))
end

function Base.getindex(h::SimHistory, s::Symbol)
    if s == :s
        return state_hist(h)[1:end-1]
    elseif s == :a
        return action_hist(h)
    elseif s == :r
        return reward_hist(h)
    elseif s == :sp
        return state_hist(h)[2:end]
    elseif s == :t
        return 1:n_steps(h)
    elseif s == :i
        return info_hist(h)
    elseif s == :ai
        return ainfo_hist(h)
    elseif s == :b
        return belief_hist(h)[1:n_steps(h)]
    elseif s == :o
        return observation_hist(h)
    elseif s == :bp
        if length(belief_hist(h)) < n_steps(h)+1
            @warn("Requested :bp from a SimHistory, however bp was not calculated for the last step so a shortened vector will be returned.")
        end
        return belief_hist(h)[2:end]
    elseif s == :ui
        return uinfo_hist(h)
    end
end


const Inds = Union{AbstractRange,Colon,Real}

Base.view(h::AbstractMDPHistory, inds::Inds) = SubMDPHistory(h, inds)
Base.view(h::AbstractPOMDPHistory, inds::Inds) = SubPOMDPHistory(h, inds)

struct SubMDPHistory{S,A,H<:AbstractMDPHistory,I<:Inds} <: AbstractMDPHistory{S,A}
    parent::H
    inds::I
end
SubMDPHistory(h::AbstractMDPHistory{S,A}, inds::I) where {S,A,I<:Inds} = SubMDPHistory{S,A,typeof(h),I}(h, inds)

struct SubPOMDPHistory{S,A,O,B,H<:AbstractPOMDPHistory,I<:Inds} <: AbstractPOMDPHistory{S,A,O,B}
    parent::H
    inds::I
end
SubPOMDPHistory(h::AbstractPOMDPHistory{S,A,O,B}, inds::I) where {S,A,O,B,I<:Inds} = SubPOMDPHistory{S,A,O,B,typeof(h),I}(h, inds)

const SubHistory = Union{SubMDPHistory, SubPOMDPHistory}

n_steps(h::SubHistory) = length(h.inds)

state_hist(h::SubHistory) = state_hist(h.parent)[minimum(h.inds):maximum(h.inds)+1]
action_hist(h::SubHistory) = action_hist(h.parent)[h.inds]
observation_hist(h::SubHistory) = observation_hist(h.parent)[h.inds]
belief_hist(h::SubHistory) = belief_hist(h.parent)[h.inds]
reward_hist(h::SubHistory) = reward_hist(h.parent)[h.inds]
info_hist(h::SubHistory) = info_hist(h.parent)[h.inds]
ainfo_hist(h::SubHistory) = ainfo_hist(h.parent)[h.inds]
uinfo_hist(h::SubHistory) = uinfo_hist(h.parent)[h.inds]

exception(h::SubHistory) = exception(h.parent)
Base.backtrace(h::SubHistory) = backtrace(h.parent)
POMDPs.discount(h::SubHistory) = discount(h.parent)


# iterators
struct HistoryIterator{H<:SimHistory, SPEC}
    history::H
end

# Note this particular function is not type-stable
function HistoryIterator(history::SimHistory, spec::String)
    # XXX should throw warnings for unrecognized specification characters
    syms = [Symbol(m.match) for m in eachmatch(r"(sp|bp|ai|ui|s|a|r|b|o|i|t)", spec)]
    if length(syms) == 1
        return HistoryIterator{typeof(history), first(syms)}(history)
    else
        return HistoryIterator{typeof(history), tuple(syms...)}(history)
    end
end

function HistoryIterator(history::SimHistory, spec::Tuple)
    @assert all(isa(s, Symbol) for s in spec)
    return HistoryIterator{typeof(history), spec}(history)
end
HistoryIterator(h::SimHistory, spec::Symbol) = HistoryIterator{typeof(h), spec}(h)

"""
    for t in eachstep(hist, [spec])
        ...
    end

Iterate through the steps in `SimHistory` `hist`. `spec` is a tuple of symbols or string that controls what is returned for each step.

For example,
```julia
for (s, a, r, sp) in eachstep(h, "(s, a, r, sp)")    
    println("reward \$r received when state \$sp was reached after action \$a was taken in state \$s")
end
```
returns the start state, action, reward and destination state for each step of the simulation.

Alternatively, instead of expanding the steps implicitly, the elements of the step can be accessed as fields (since each step is a `NamedTuple`):
```julia
for step in eachstep(h, "(s, a, r, sp)")    
    println("reward \$(step.r) received when state \$(step.sp) was reached after action \$(step.a) was taken in state \$(step.s)")
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
- `t` - the timestep index
"""
eachstep(hist::SimHistory, spec) = HistoryIterator(hist, spec)

eachstep(mh::AbstractMDPHistory) = eachstep(mh, COMPLETE_MDP_STEP)
eachstep(mh::AbstractPOMDPHistory) = eachstep(mh, COMPLETE_POMDP_STEP)

function sym_to_call(sym::Symbol)
    if sym == :s
        return :(state_hist(it.history)[i])
    elseif sym == :a
        return :(action_hist(it.history)[i])
    elseif sym == :r
        return :(reward_hist(it.history)[i])
    elseif sym == :sp
        return :(state_hist(it.history)[i+1])
    elseif sym == :b
        return :(belief_hist(it.history)[i])
    elseif sym == :o
        return :(observation_hist(it.history)[i])
    elseif sym == :bp
        return :(belief_hist(it.history)[i+1])
    elseif sym == :i
        return :(info_hist(it.history)[i])
    elseif sym == :ai
        return :(ainfo_hist(it.history)[i])
    elseif sym == :ui
        return :(uinfo_hist(it.history)[i])
    elseif sym == :t
        return :(i)
    end
end

@generated function step_tuple(it::HistoryIterator, i::Int)
    spec = it.parameters[2]
    if isa(spec, Tuple)
        calls = []
        for sym in spec
            push!(calls, :($sym = $(sym_to_call(sym))))
        end

        return quote
            return ($(calls...),)
        end
    else
        @assert isa(spec, Symbol)
        return quote
            return $(sym_to_call(spec))
        end
    end
end

Base.length(it::HistoryIterator) = n_steps(it.history)
Base.getindex(it::HistoryIterator, i) = step_tuple(it, i)
function Base.iterate(it::HistoryIterator, i::Int = 1)
    if i > length(it)
        return nothing 
    else
        return (step_tuple(it, i), i+1)
    end
end

# hack so that histories display reasonably
# copied from base library
function Base.show(io::IO, t::Union{MDPStep, POMDPStep})
    print(io, shortname(t))
    print(io, "(")
    n = nfields(t)
    for i = 1:n
        typeinfo = get(io, :typeinfo, Any)
        print(io, fieldname(typeof(t),i), " = ")
        show(IOContext(io, :typeinfo =>
                       t isa typeinfo <: NamedTuple ? fieldtype(typeinfo, i) : Any),
             getfield(t, i))
        if i < n
            print(io, ", ")
        end
    end
    print(io, ")")
end
shortname(::MDPStep) = "MDPStep"
shortname(::POMDPStep) = "POMDPStep"
