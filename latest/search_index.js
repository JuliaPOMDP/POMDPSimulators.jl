var documenterSearchIndex = {"docs": [

{
    "location": "history_recorder.html#",
    "page": "History",
    "title": "History",
    "category": "page",
    "text": ""
},

{
    "location": "history_recorder.html#History-1",
    "page": "History",
    "title": "History",
    "category": "section",
    "text": ""
},

{
    "location": "history_recorder.html#POMDPSimulators.HistoryRecorder",
    "page": "History",
    "title": "POMDPSimulators.HistoryRecorder",
    "category": "type",
    "text": "A simulator that records the history for later examination\n\nThe simulation will be terminated when either\n\na terminal state is reached (as determined by isterminal() or\nthe discount factor is as small as eps or\nmax_steps have been executed\n\nKeyword Arguments:     - rng: The random number generator for the simulation     - capture_exception::Bool: whether to capture an exception and store it in the history, or let it go uncaught, potentially killing the script     - show_progress::Bool: show a progress bar for the simulation     - eps     - max_steps     - sizehint::Int: the expected length of the simulation (for preallocation)\n\nUsage (optional arguments in brackets):     hr = HistoryRecorder()     history = simulate(hr, pomdp, policy, [updater [, initbelief [, initstate]]])\n\n\n\n\n\n"
},

{
    "location": "history_recorder.html#History-Recorder-1",
    "page": "History",
    "title": "History Recorder",
    "category": "section",
    "text": "HistoryRecorder runs a simulation and records the trajectory. It returns an MDPHistory or POMDPHistory (see history.jl below).hr = HistoryRecorder(max_steps=100)\npomdp = TigerPOMDP()\npolicy = RandomPolicy(pomdp)\n\nh = simulate(hr, pomdp, policy)HistoryRecorder"
},

{
    "location": "history_recorder.html#POMDPSimulators.eachstep",
    "page": "History",
    "title": "POMDPSimulators.eachstep",
    "category": "function",
    "text": "for t in eachstep(hist, [spec])\n    ...\nend\n\nIterate through the steps in SimHistory hist. spec is a tuple of symbols or string that controls what is returned for each step.\n\nFor example,\n\nfor (s, a, r, sp) in eachstep(h, \"(s, a, r, sp)\")    \n    println(\"reward $r received when state $sp was reached after action $a was taken in state $s\")\nend\n\nreturns the start state, action, reward and destination state for each step of the simulation.\n\nThe possible valid elements in the iteration specification are\n\ns - the initial state in a step\nb - the initial belief in the step (for POMDPs only)\na - the action taken in the step\nr - the reward received for the step\nsp - the final state at the end of the step (s\')\no - the observation received during the step (note that this is usually based on sp instead of s)\nbp - the belief after being updated based on o (for POMDPs only)\ni - info from the state transition (from generate_sri for MDPs or generate_sori for POMDPs)\nai - info from the policy decision (from action_info)\nui - info from the belief update (from update_info)\nt - the timestep index\n\n\n\n\n\n"
},

{
    "location": "history_recorder.html#SimHistory-1",
    "page": "History",
    "title": "SimHistory",
    "category": "section",
    "text": "eachstepExamples:collect(eachstep(h, \"ao\"))will produce a vector of action-observation tuples.collect(norm(sp-s) for (s,sp) in eachstep(h, \"s,sp\"))will produce a vector of the distances traveled on each step (assuming the state is a Euclidean vector).Notes:The iteration specification can be specified as a tuple of symbols (e.g. (:s, :a)) instead of a string.\nFor type stability in performance-critical code, one should construct an iterator directly using HistoryIterator{typeof(h), (:a,:r)}(h) rather than eachstep(h, \"ar\").state_hist(h), action_hist(h), observation_hist(h) belief_hist(h), and reward_hist(h) will return vectors of the states, actions, and rewards, and undiscounted_reward(h) and discounted_reward(h) will return the total rewards collected over the trajectory. n_steps(h) returns the number of steps in the history. exception(h) and backtrace(h) can be used to hold an exception if the simulation failed to finish.view(h, range) (e.g. view(h, 1:n_steps(h)-4)) can be used to create a view of the history object h that only contains a certain range of steps. The object returned by view is a SimHistory that can be iterated through and manipulated just like a complete SimHistory."
},

{
    "location": "history_recorder.html#POMDPSimulators.MDPHistory",
    "page": "History",
    "title": "POMDPSimulators.MDPHistory",
    "category": "type",
    "text": "An object that contains a MDP simulation history\n\nReturned by simulate when called with a HistoryRecorder. Iterate through the (s, a, r, s\') tuples in MDPHistory h like this:\n\nfor (s, a, r, sp) in eachstep(h)\n    # do something\nend\n\n\n\n\n\n"
},

{
    "location": "history_recorder.html#MDPHistory-1",
    "page": "History",
    "title": "MDPHistory",
    "category": "section",
    "text": "An MDPHistory represents a state-action-reward history from simulating an MDP. Subtype of SimHistoryMDPHistory"
},

{
    "location": "history_recorder.html#POMDPHistory-1",
    "page": "History",
    "title": "POMDPHistory",
    "category": "section",
    "text": "A POMDPHistory contains a record of the states, actions, observations, rewards, and beliefs encountered during a simulation of a POMDP. Subtype of SimHistory"
},

{
    "location": "index.html#",
    "page": "-",
    "title": "-",
    "category": "page",
    "text": "POMDPSimulators is a collection of utilities for stepping through and recording rollouts of POMDPs.jl models."
},

{
    "location": "parallel.html#",
    "page": "Parallel",
    "title": "Parallel",
    "category": "page",
    "text": ""
},

{
    "location": "parallel.html#POMDPSimulators.run_parallel",
    "page": "Parallel",
    "title": "POMDPSimulators.run_parallel",
    "category": "function",
    "text": "run_parallel(queue::Vector{Sim})\nrun_parallel(f::Function, queue::Vector{Sim})\n\nRun Sim objects in queue in parallel and return results as a DataFrame.\n\nBy default, the DataFrame will contain the reward for each simulation and the metadata provided to the sim.\n\nArguments\n\nqueue: List of Sim objects to be executed\nf: Function to process the results of each simulation\n\nThis function should take two arguments, (1) the Sim that was executed and (2) the result of the simulation, by default a SimHistory. It should return a dictionary or vector of pairs of Symbols and values that will appear in the dataframe. See Examples below.\n\nKeyword Arguments\n\nprogress: a ProgressMeter.Progress for showing progress through the simulations; progress=false will suppress the progress meter\n\nExamples\n\nrun_parallel(queue) do sim, hist\n    return [:n_steps=>n_steps(hist), :reward=>discounted_reward(hist)]\nend\n\nwill return a dataframe with with the number of steps and the reward in it.\n\n\n\n\n\n"
},

{
    "location": "parallel.html#Parallel-1",
    "page": "Parallel",
    "title": "Parallel",
    "category": "section",
    "text": "The run_parallel function can be used to conveniently run simulations in parallel. Example:using POMDPModels\nusing POMDPPolicies\nusing POMDPSimulators\n\npomdp = BabyPOMDP()\nfwc = FeedWhenCrying()\nrnd = solve(RandomSolver(MersenneTwister(7)), pomdp)\n\nq = [] # vector of the simulations to be run\npush!(q, Sim(pomdp, fwc, max_steps=32, rng=MersenneTwister(4), metadata=Dict(:policy=>\"feed when crying\")))\npush!(q, Sim(pomdp, rnd, max_steps=32, rng=MersenneTwister(4), metadata=Dict(:policy=>\"random\")))\n\n# this creates two simulations, one with the feed-when-crying policy and one with a random policy\n\ndata = run_parallel(q)\n\n# by default, the dataframe output contains the reward and the contents of `metadata`\n@show data\n# data = 2×2 DataFrames.DataFrame\n# │ Row │ policy             │ reward   │\n# ├─────┼────────────────────┼──────────┤\n# │ 1   │ \"feed when crying\" │ -4.5874  │\n# │ 2   │ \"random\"           │ -27.4139 │\n\n# to perform additional analysis on each of the simulations one can define a processing function with the `do` syntax:\ndata2 = run_parallel(q, progress=false) do sim, hist\nprintln(\"finished a simulation - final state was $(last(state_hist(hist)))\")\nreturn [:steps=>n_steps(hist), :reward=>discounted_reward(hist)]\nend\n\n@show data2\n# 2×3 DataFrames.DataFrame\n# │ Row │ policy             │ reward   │ steps │\n# ├─────┼────────────────────┼──────────┼───────┤\n# │ 1   │ \"feed when crying\" │ -18.2874 │ 32.0  │\n# │ 2   │ \"random\"           │ -17.7054 │ 32.0  │\nrun_parallel"
},

{
    "location": "rollout.html#",
    "page": "Rollout",
    "title": "Rollout",
    "category": "page",
    "text": ""
},

{
    "location": "rollout.html#Rollout-1",
    "page": "Rollout",
    "title": "Rollout",
    "category": "section",
    "text": ""
},

{
    "location": "rollout.html#POMDPSimulators.RolloutSimulator",
    "page": "Rollout",
    "title": "POMDPSimulators.RolloutSimulator",
    "category": "type",
    "text": "A fast simulator that just returns the reward\n\nThe simulation will be terminated when either\n\na terminal state is reached (as determined by isterminal() or\nthe discount factor is as small as eps or\nmax_steps have been executed\n\nKeyword Arguments:     - eps     - max_steps\n\nUsage (optional arguments in brackets):     ro = RolloutSimulator()     history = simulate(ro, pomdp, policy, [updater [, initbelief [, initstate]]])\n\n\n\n\n\n"
},

{
    "location": "rollout.html#RolloutSimulator-1",
    "page": "Rollout",
    "title": "RolloutSimulator",
    "category": "section",
    "text": "RolloutSimulator is the simplest MDP or POMDP simulator. When simulate is called, it simply simulates a single trajectory of the process and returns the dis counted reward.rs = RolloutSimulator()\nmdp = GridWorld()\npolicy = RandomPolicy(mdp)\n\nr = simulate(rs, mdp, policy)RolloutSimulator"
},

{
    "location": "sim.html#",
    "page": "Sim",
    "title": "Sim",
    "category": "page",
    "text": ""
},

{
    "location": "sim.html#POMDPSimulators.sim",
    "page": "Sim",
    "title": "POMDPSimulators.sim",
    "category": "function",
    "text": "sim(polfunc::Function, mdp::MDP)\nsim(polfunc::Function, pomdp::POMDP)\n\nAlternative way of running a simulation with a function specifying how to calculate the action at each timestep.\n\nThe intended usage is\n\nsim(mdp) do s\n    # code that calculates action `a` based on `s` - this is the policy\n    # you can also do other things like display something\n    return a\nend\n\nfor an MDP or\n\nsim(pomdp) do o\n    # code that does belief updates with observation `o` and calculates `a`\n    # you can also do other things like display something\n    return a\nend\n\nfor a POMDP.\n\nUse the simulator keyword argument to specify any simulator to run the simulation. If nothing is specified for the simulator, a HistoryRecorder will be used as the simulator, with all keyword arguments forwarded to it, e.g.\n\nsim(mdp, max_steps=100) do s\n    # ...\nend\n\nwill limit the simulation to 100 steps\n\n\n\n\n\n"
},

{
    "location": "sim.html#Sim-1",
    "page": "Sim",
    "title": "Sim",
    "category": "section",
    "text": "The sim function provides a convenient way to interact with a POMDP or MDP environment. The first argument is a function that is called at every time step and takes a state (in the case of an MDP) or an observation (in the case of a POMDP) as the argument and then returns an action. The second argument is a pomdp or mdp. It is intended to be used with Julia\'s do syntax as follows:pomdp = TigerPOMDP()\nhistory = sim(pomdp, max_steps=10) do obs\nprintln(\"Observation was $obs.\")\nreturn TIGER_OPEN_LEFT\nendThis allows a flexible and general way to interact with a POMDP environment without creating new Policy types.Note: by default, since there is no observation before the first action, on the first call to the do block, obs is nothing.sim"
},

{
    "location": "stepthrough.html#",
    "page": "Stepping through",
    "title": "Stepping through",
    "category": "page",
    "text": ""
},

{
    "location": "stepthrough.html#POMDPSimulators.stepthrough",
    "page": "Stepping through",
    "title": "POMDPSimulators.stepthrough",
    "category": "function",
    "text": "stepthrough(problem, policy, [spec])\nstepthrough(problem, policy, [spec], [rng=rng], [max_steps=max_steps], [initialstate=initialstate])\n\nCreate a simulation iterator. This is intended to be used with for loop syntax to output the results of each step as the simulation is being run. \n\nExample:\n\npomdp = BabyPOMDP()\npolicy = RandomPolicy(pomdp)\n\nfor (s, a, o, r) in stepthrough(pomdp, policy, \"s,a,o,r\", max_steps=10)\n    println(\"in state $s\")\n    println(\"took action $o\")\n    println(\"received observation $o and reward $r\")\nend\n\nThe spec argument can be a string, tuple of symbols, or single symbol and follows the same pattern as eachstep called on a SimHistory object.\n\nUnder the hood, this function creates a StepSimulator with spec and returns a [PO]MDPSimIterator by calling simulate with all of the arguments except spec. All keyword arguments are passed to the StepSimulator constructor.\n\n\n\n\n\n"
},

{
    "location": "stepthrough.html#Stepping-through-1",
    "page": "Stepping through",
    "title": "Stepping through",
    "category": "section",
    "text": "The stepthrough function exposes a simulation as an iterator so that the steps can be iterated through with a for loop syntax as follows:pomdp = BabyPOMDP()\npolicy = RandomPolicy(pomdp)\n\nfor (s, a, o, r) in stepthrough(pomdp, policy, \"s,a,o,r\", max_steps=10)\nprintln(\"in state $s\")\nprintln(\"took action $o\")\nprintln(\"received observation $o and reward $r\")\nendstepthroughThe StepSimulator contained in this file can provide the same functionality with the following syntax:sim = StepSimulator(\"s,a,r,sp\")\nfor (s,a,r,sp) in simulate(sim, problem, policy)\n# do something\nendStepSimulator"
},

]}
