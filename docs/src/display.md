# Display

## `DisplaySimulator`

The `DisplaySimulator` displays each step of a simulation in real time through a multimedia display such as a Jupyter notebook or [ElectronDisplay](https://github.com/queryverse/ElectronDisplay.jl).
Specifically it uses `POMDPModelTools.render` and the built-in Julia [`display` function](https://docs.julialang.org/en/v1/base/io-network/#Base.Multimedia.display) to visualize each step.

Example:
```julia
using POMDPs
using POMDPModels
using POMDPPolicies
using POMDPSimulators
using ElectronDisplay
ElectronDisplay.CONFIG.single_window = true

ds = DisplaySimulator()
m = SimpleGridWorld()
simulate(ds, m, RandomPolicy(m))
```

```@docs
DisplaySimulator
```

## Display-specific tips

The following tips may be helpful when using particular displays.

### Jupyter notebooks

By default, in a Jupyter notebook, the visualizations of all steps are displayed in the output box one after another. To make the output animated instead, where the image is overwritten at each step, one may use
```julia
DisplaySimulator(predisplay=(d)->IJulia.clear_output(true))
```

### ElectronDisplay

By default, ElectronDisplay will open a new window for each new step. To prevent this, use
```julia
ElectronDisplay.CONFIG.single_window = true
```
