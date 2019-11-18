struct DisplaySimulator
    display::Union{AbstractDisplay, Nothing}
    render_kwargs
    max_fps::Float64
    predisplay::Function
    extra_initial::Bool
    extra_final::Bool
    stepsim::StepSimulator
end

function DisplaySimulator(;display=nothing,
                           render_kwargs=NamedTuple(),
                           max_fps=10,
                           predisplay=(d)->nothing,
                           extra_initial=false,
                           extra_final=true,
                           max_steps=nothing,
                           spec=CompleteSpec(),
                           rng=Random.GLOBAL_RNG
                         )
    stepsim = StepSimulator(rng, max_steps, spec)
    return DisplaySimulator(display,
                            render_kwargs,
                            max_fps,
                            predisplay,
                            extra_initial,
                            extra_final,
                            stepsim)
end

function simulate(sim::DisplaySimulator, m, args...)
    rsum = 0.0
    disc = 1.0
    dt = 1/sim.max_fps
    tm = time()
    isinitial = true
    last = NamedTuple()

    for step in simulate(sim.stepsim, m, args...)
        if isinitial && sim.extra_initial
            isinitial = false
            istep = initialstep(m, step)
            vis = render(m, istep; sim.render_kwargs...)
            perform_display(sim, vis)
            sleep_until(tm += dt)
        end

        vis = render(m, step; sim.render_kwargs...)
        perform_display(sim, vis)
        rsum += disc*get(step, :r, missing)
        disc *= discount(m)
        sleep_until(tm += dt)

        last = step
    end

    if sim.extra_final
        fstep = finalstep(m, last)
        vis = render(m, fstep; sim.render_kwargs...)
        perform_display(sim, vis)
    end

    if ismissing(rsum)
        return nothing
    else
        return rsum
    end
end

sleep_until(t) = sleep(max(t-time(), 0.0))

initialstep(m::MDP, step) = (t=0, sp=get(step, :s, missing))
initialstep(m::POMDP, step) = (t=0,
                               sp=get(step, :s, missing),
                               bp=get(step, :b, missing))
finalstep(m::MDP, last) = (done=true,
                           t=get(last, :t, missing) + 1,
                           s=get(last, :sp, missing))
finalstep(m::POMDP, last) = (done=true,
                             t=get(last, :t, missing) + 1,
                             s=get(last, :sp, missing),
                             b=get(last, :bp, missing))


function perform_display(sim::DisplaySimulator, vis)
    sim.predisplay(sim.display)
    if sim.display===nothing
        display(vis)
    else
        display(sim.display, vis)
    end
end
