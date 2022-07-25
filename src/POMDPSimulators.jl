module POMDPSimulators

Base.depwarn("""
             POMDPSimulators has been deprecated and functionality has been moved to POMDPTools.

             Please replace `using POMDPSimulators` with `using POMDPTools`.
             """, :POMDPSimulators)

using Reexport

@reexport using POMDPTools.Simulators

import POMDPTools
default_spec = POMDPTools.Simulators.default_spec

end # module
