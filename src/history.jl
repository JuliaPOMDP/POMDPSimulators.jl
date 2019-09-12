# SimHistory
# maintained by @zsunberg

abstract type AbstractSimHistory{NT} <: AbstractVector{NT} end

nt_type(::Type{H}) where H<:AbstractSimHistory{NT} where NT = NT
nt_type(h::AbstractSimHistory) = nt_type(typeof(h))

"""
    SimHistory

An (PO)MDP simulation history returned by `simulate(::HistoryRecorder, ::Union{MDP,POMDP},...)`.

This is an `AbstractVector` of `NamedTuples` containing the states, actions, etc.

# Examples
```
hist[1][:s] # returns the first state in the history
```
```
hist[:a] # returns all of the actions in the history
```
"""
struct SimHistory{NT} <: AbstractSimHistory{NT}
    hist::Vector{NT}

    discount::Float64

    # if an exception is captured, it will be stored here
    exception::Union{Nothing, Exception}
    backtrace::Union{Nothing, Any}
end

# accessors: use these to access the members - in case the implementation changes
n_steps(h::SimHistory) = length(h.hist)
hist(h::SimHistory) = h.hist

state_hist(h::AbstractSimHistory) = push!([step.s for step in hist(h)], last(hist(h)).sp)
action_hist(h::AbstractSimHistory) = h[:a]
observation_hist(h::AbstractSimHistory) = h[:o]
belief_hist(h::AbstractSimHistory) = h[:b]
reward_hist(h::AbstractSimHistory) = h[:r]
info_hist(h::AbstractSimHistory) = h[:i]
ainfo_hist(h::AbstractSimHistory) = h[:ai]
uinfo_hist(h::AbstractSimHistory) = h[:ui]

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

Base.getindex(h::SimHistory, i::Int) = hist(h)[i]
Base.getindex(h::SimHistory, s::Symbol) = (step[s] for step in hist(h))

# SubHistory
const Inds = Union{AbstractRange,Colon,Real}
Base.view(h::AbstractSimHistory, inds::Inds) = SubHistory(h, inds)

struct SubHistory{NT, H<:AbstractSimHistory{NT}, I<:Inds} <: AbstractSimHistory{NT}
    parent::H
    inds::I
end

n_steps(h::SubHistory) = length(h.inds)
hist(h::SubHistory) = view(hist(h.parents), h.inds)

exception(h::SubHistory) = exception(h.parent)
Base.backtrace(h::SubHistory) = backtrace(h.parent)
POMDPs.discount(h::SubHistory) = discount(h.parent)


# iterators
struct HistoryIterator{H<:AbstractSimHistory, SPEC}
    history::H
end

hist(it::HistoryIterator) = it.history
spec(it::HistoryIterator) = typeof(it).parameters[2]

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
- Any node in the (PO)MDP Dynamic Decision network (by default :s, :a, :sp, :o, :r)
- `b` - the initial belief in the step (for POMDPs only)
- `bp` - the belief after being updated based on `o` (for POMDPs only)
- `ai` - info from the policy decision (from `action_info`)
- `ui` - info from the belief update (from `update_info`)
- `t` - the timestep index
"""
eachstep(hist::AbstractSimHistory, spec) = HistoryIterator(hist, spec)
eachstep(mh::AbstractSimHistory) = hist(h)

function step_tuple(it::HistoryIterator, i::Int)
    if isa(spec, Tuple)
        return select(hist(it)[i], spec(it))
    else
        @assert isa(spec, Symbol)
        return hist(it)[i][spec(it)]
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