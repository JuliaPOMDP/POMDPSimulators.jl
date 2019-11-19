using Documenter
using POMDPSimulators

makedocs(
    modules = [POMDPSimulators],
    format = Documenter.HTML(),
    sitename = "POMDPSimulators.jl",
    pages = ["index.md",
             "which.md",
             "rollout.md",
             "parallel.md",
             "history_recorder.md",
             "histories.md",
             "stepthrough.md",
             "display.md",
             "sim.md"]
)

deploydocs(
    repo = "github.com/JuliaPOMDP/POMDPSimulators.jl.git",
)
