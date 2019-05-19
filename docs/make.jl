using Documenter
using POMDPSimulators

makedocs(
    modules = [POMDPSimulators],
    format = Documenter.HTML(),
    sitename = "POMDPSimulators.jl"
)

deploydocs(
    repo = "github.com/JuliaPOMDP/POMDPSimulators.jl.git",
)

