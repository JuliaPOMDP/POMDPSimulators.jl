using POMDPModels
using Test

let
    problem = BabyPOMDP()
    solver = RandomSolver(rng=Random.MersenneTwister(1))
    policy = solve(solver, problem)
    sim = RolloutSimulator(max_steps=10, rng=Random.MersenneTwister(1))
    if VERSION >= v"1.2"
        r1 = @inferred simulate(sim, problem, policy, updater(policy), initialstate_distribution(problem))
    else
        r1 = simulate(sim, problem, policy, updater(policy), initialstate_distribution(problem))
    end

    sim = RolloutSimulator(max_steps=10, rng=Random.MersenneTwister(1))
    if VERSION >= v"1.2"
        dummy = @inferred simulate(sim, problem, policy, updater(policy), nothing, true)
    else
        dummy = simulate(sim, problem, policy, updater(policy), nothing, true)
    end

    problem = LegacyGridWorld()
    solver = RandomSolver(rng=Random.MersenneTwister(1))
    policy = solve(solver, problem)
    sim = RolloutSimulator(max_steps=10, rng=Random.MersenneTwister(1))
    if VERSION >= v"1.2"
        r2 = @inferred simulate(sim, problem, policy, initialstate(problem, sim.rng))
    else
        r2 = simulate(sim, problem, policy, initialstate(problem, sim.rng))
    end

    problem = LegacyGridWorld()
    solver = RandomSolver(rng=Random.MersenneTwister(1))
    policy = solve(solver, problem)
    sim = RolloutSimulator(Random.MersenneTwister(1), 10) # new constructor
    if VERSION >= v"1.2"
        r2 = @inferred simulate(sim, problem, policy, initialstate(problem, sim.rng))
    else
        r2 = simulate(sim, problem, policy, initialstate(problem, sim.rng))
    end

    @test isapprox(r1, -27.27829, atol=1e-3)
    @test isapprox(r2, 0.0, atol=1e-3)
end
