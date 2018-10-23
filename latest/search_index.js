var documenterSearchIndex = {"docs": [

{
    "location": "histories.html#",
    "page": "Histories",
    "title": "Histories",
    "category": "page",
    "text": ""
},

{
    "location": "histories.html#POMDPSimulators.eachstep",
    "page": "Histories",
    "title": "POMDPSimulators.eachstep",
    "category": "function",
    "text": "for t in eachstep(hist, [spec])\n    ...\nend\n\nIterate through the steps in SimHistory hist. spec is a tuple of symbols or string that controls what is returned for each step.\n\nFor example,\n\nfor (s, a, r, sp) in eachstep(h, \"(s, a, r, sp)\")    \n    println(\"reward $r received when state $sp was reached after action $a was taken in state $s\")\nend\n\nreturns the start state, action, reward and destination state for each step of the simulation.\n\nAlternatively, instead of expanding the steps implicitly, the elements of the step can be accessed as fields (since each step is a NamedTuple):\n\nfor step in eachstep(h, \"(s, a, r, sp)\")    \n    println(\"reward $(step.r) received when state $(step.sp) was reached after action $(step.a) was taken in state $(step.s)\")\nend\n\nThe possible valid elements in the iteration specification are\n\ns - the initial state in a step\nb - the initial belief in the step (for POMDPs only)\na - the action taken in the step\nr - the reward received for the step\nsp - the final state at the end of the step (s\')\no - the observation received during the step (note that this is usually based on sp instead of s)\nbp - the belief after being updated based on o (for POMDPs only)\ni - info from the state transition (from generate_sri for MDPs or generate_sori for POMDPs)\nai - info from the policy decision (from action_info)\nui - info from the belief update (from update_info)\nt - the timestep index\n\n\n\n\n\n"
},

{
    "location": "histories.html#Histories-1",
    "page": "Histories",
    "title": "Histories",
    "category": "section",
    "text": "The results produced by HistoryRecorders and the sim function are contained in SimHistory objects. A SimHistory can be thought of as a colletion of NamedTuples that each represent a step of the simulation. These named tuples should be accessed using the eachstep function.eachstep"
},

{
    "location": "histories.html#Examples:-1",
    "page": "Histories",
    "title": "Examples:",
    "category": "section",
    "text": "collect(eachstep(h, \"a,o\"))will produce a vector of action-observation named tuples.collect(norm(sp-s) for (s,sp) in eachstep(h, \"s,sp\"))will produce a vector of the distances traveled on each step (assuming the state is a Euclidean vector).Notes:The iteration specification can be specified as a tuple of symbols (e.g. (:s, :a)) instead of a string.\nFor type stability in performance-critical code, one should construct an iterator directly using HistoryIterator{typeof(h), (:a,:r)}(h) rather than eachstep(h, \"ar\").state_hist(h), action_hist(h), observation_hist(h) belief_hist(h), and reward_hist(h) will return vectors of the states, actions, and rewards, and undiscounted_reward(h) and discounted_reward(h) will return the total rewards collected over the trajectory. n_steps(h) returns the number of steps in the history. exception(h) and backtrace(h) can be used to hold an exception if the simulation failed to finish.view(h, range) (e.g. view(h, 1:n_steps(h)-4)) can be used to create a view of the history object h that only contains a certain range of steps. The object returned by view is a SimHistory that can be iterated through and manipulated just like a complete SimHistory."
},

{
    "location": "histories.html#POMDPSimulators.MDPHistory",
    "page": "Histories",
    "title": "POMDPSimulators.MDPHistory",
    "category": "type",
    "text": "An object that contains a MDP simulation history\n\nReturned by simulate when called with a HistoryRecorder. Iterate through the (s, a, r, s\') tuples in MDPHistory h like this:\n\nfor (s, a, r, sp) in eachstep(h)\n    # do something\nend\n\n\n\n\n\n"
},

{
    "location": "histories.html#POMDPSimulators.POMDPHistory",
    "page": "Histories",
    "title": "POMDPSimulators.POMDPHistory",
    "category": "type",
    "text": "An object that contains a POMDP simulation history\n\nReturned by simulate when called with a HistoryRecorder. Iterate through the (s, b, a, r, s\', o) tuples in POMDPHistory h like this:\n\nfor (s, b, a, r, sp, o) in eachstep(h, \"s,b,a,r,sp,o\")\n    # do something\nend\n\n\n\n\n\n"
},

{
    "location": "histories.html#Concrete-Types-1",
    "page": "Histories",
    "title": "Concrete Types",
    "category": "section",
    "text": "There are two concrete types of SimHistory depending on whether the problem was an MDP or a POMDP.MDPHistory\nPOMDPHistory"
},

{
    "location": "history_recorder.html#",
    "page": "History Recorder",
    "title": "History Recorder",
    "category": "page",
    "text": ""
},

{
    "location": "history_recorder.html#POMDPSimulators.HistoryRecorder",
    "page": "History Recorder",
    "title": "POMDPSimulators.HistoryRecorder",
    "category": "type",
    "text": "A simulator that records the history for later examination\n\nThe simulation will be terminated when either\n\na terminal state is reached (as determined by isterminal() or\nthe discount factor is as small as eps or\nmax_steps have been executed\n\nKeyword Arguments:     - rng: The random number generator for the simulation     - capture_exception::Bool: whether to capture an exception and store it in the history, or let it go uncaught, potentially killing the script     - show_progress::Bool: show a progress bar for the simulation     - eps     - max_steps     - sizehint::Int: the expected length of the simulation (for preallocation)\n\nUsage (optional arguments in brackets):\n\nhr = HistoryRecorder()\nhistory = simulate(hr, pomdp, policy, [updater [, init_belief [, init_state]]])\n\n\n\n\n\n"
},

{
    "location": "history_recorder.html#History-Recorder-1",
    "page": "History Recorder",
    "title": "History Recorder",
    "category": "section",
    "text": "A HistoryRecorder runs a simulation and records the trajectory. It returns a history record (MDPHistory or POMDPHistory).hr = HistoryRecorder(max_steps=100)\npomdp = TigerPOMDP()\npolicy = RandomPolicy(pomdp)\n\nh = simulate(hr, pomdp, policy)More examples can be found in the POMDPExamples Package.HistoryRecorder"
},

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Home-1",
    "page": "Home",
    "title": "Home",
    "category": "section",
    "text": "POMDPSimulators is a collection of utilities for simulating POMDPs.jl models. All of the simulators in this package should conform to the POMDPs.jl Simulation Standard.Examples can be found in the simulation tutorial in the POMDPExamples package.If you are just getting started, probably the easiest way to begin is the stepthrough function. Otherwise, consult the Which Simulator Should I Use? page."
},

{
    "location": "parallel.html#",
    "page": "Parallel",
    "title": "Parallel",
    "category": "page",
    "text": ""
},

{
    "location": "parallel.html#Parallel-1",
    "page": "Parallel",
    "title": "Parallel",
    "category": "section",
    "text": "POMDPSimulators contains a utility for running many Monte Carlo simulations in parallel to evaluate performance. The basic workflow involves the following steps:Create a vector of Sim objects, each specifying how a single simulation should be run.\nUse the run_parallel or run function to run the simulations.\nAnalyze the results of the simulations contained in the DataFrame returned by run_parallel.An extended example is shown below [TODO: move this to POMDPExamples].By default, only the discounted rewards from each simulation are recorded, but arbitrary information can be recorded as described in the next section."
},

{
    "location": "parallel.html#Specifying-information-to-be-recorded-1",
    "page": "Parallel",
    "title": "Specifying information to be recorded",
    "category": "section",
    "text": "The run_parallel and run functions accept a function (normally specified via the do syntax) that takes the Sim object and history of the simulation and extracts relevant statistics as a named tuple. For example, if the desired characteristics are the number of steps in the simulation and the reward, run_parallel would be invoked as follows:df = run_parallel(queue) do sim::Sim, hist::SimHistory\n    return (n_steps=n_steps(hist), reward=discounted_reward(hist))\nendThese statistics are combined into a DataFrame, with each line representing a single simulation, allowing for statistical analysis. For example,mean(df[:reward]./df[:n_steps])would compute the average reward per step with each simulation weighted equally regardless of length."
},

{
    "location": "parallel.html#Example-1",
    "page": "Parallel",
    "title": "Example",
    "category": "section",
    "text": "Examples can be found in the POMDPExamples Package"
},

{
    "location": "parallel.html#POMDPSimulators.Sim",
    "page": "Parallel",
    "title": "POMDPSimulators.Sim",
    "category": "type",
    "text": "Represents everything needed to run and record a single simulation, including model, initial conditions, and metadata.\n\nA vector of Sim objects can be executed with run or run_parallel.\n\nKeyword Arguments\n\nrng::AbstractRNG=Random.GLOBAL_RNG\nmax_steps::Int=typemax(Int)\nsimulator::Simulator=HistoryRecorder(rng=rng, max_steps=max_steps)\nmetadata::NamedTuple a named tuple (or dictionary) of metadata for the sim that will be recorded, e.g.(solver_iterations=500,)`.\n\n\n\n\n\n"
},

{
    "location": "parallel.html#Sim-objects-1",
    "page": "Parallel",
    "title": "Sim objects",
    "category": "section",
    "text": "Each simulation should be specified by a Sim object which contains all the information needed to run a simulation, including the Simulator, POMDP or MDP, Policy, Updater, and any other ingredients.Sim"
},

{
    "location": "parallel.html#POMDPSimulators.run_parallel",
    "page": "Parallel",
    "title": "POMDPSimulators.run_parallel",
    "category": "function",
    "text": "run_parallel(queue::Vector{Sim})\nrun_parallel(f::Function, queue::Vector{Sim})\n\nRun Sim objects in queue in parallel and return results as a DataFrame.\n\nBy default, the DataFrame will contain the reward for each simulation and the metadata provided to the sim.\n\nArguments\n\nqueue: List of Sim objects to be executed\nf: Function to process the results of each simulation\n\nThis function should take two arguments, (1) the Sim that was executed and (2) the result of the simulation, by default a SimHistory. It should return a named tuple that will appear in the dataframe. See Examples below.\n\nKeyword Arguments\n\nprogress: a ProgressMeter.Progress for showing progress through the simulations; progress=false will suppress the progress meter\n\nExamples\n\nrun_parallel(queue) do sim, hist\n    return (n_steps=n_steps(hist), reward=discounted_reward(hist))\nend\n\nwill return a dataframe with with the number of steps and the reward in it.\n\n\n\n\n\n"
},

{
    "location": "parallel.html#Base.run",
    "page": "Parallel",
    "title": "Base.run",
    "category": "function",
    "text": "run(command, args...; wait::Bool = true)\n\nRun a command object, constructed with backticks. Throws an error if anything goes wrong, including the process exiting with a non-zero status (when wait is true).\n\nIf wait is false, the process runs asynchronously. You can later wait for it and check its exit status by calling success on the returned process object.\n\nWhen wait is false, the process\' I/O streams are directed to devnull. When wait is true, I/O streams are shared with the parent process. Use pipeline to control I/O redirection.\n\n\n\n\n\nrun(queue::Vector{Sim})\nrun(f::Function, queue::Vector{Sim})\n\nRun the Sim objects in queue on a single process and return the results as a dataframe.\n\nSee run_parallel for more information.\n\n\n\n\n\n"
},

{
    "location": "parallel.html#Running-simulations-1",
    "page": "Parallel",
    "title": "Running simulations",
    "category": "section",
    "text": "The simulations are actually carried out by the run and run_parallel functions.run_parallelThe run function is also provided to run simulations in serial (this is often useful for debugging). Note that the documentation below also contains a section for the builtin julia run function, even though it is not relevant here.run"
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
    "text": "RolloutSimulator(rng, max_steps)\nRolloutSimulator(; <keyword arguments>)\n\nA fast simulator that just returns the reward\n\nThe simulation will be terminated when either\n\na terminal state is reached (as determined by isterminal() or\nthe discount factor is as small as eps or\nmax_steps have been executed\n\nKeyword arguments:\n\nrng: A random number generator to use.\neps: A small number; if γᵗ where γ is the discount factor and t is the time step becomes smaller than this, the simulation will be terminated.\nmax_steps: The maximum number of steps to simulate.\n\nUsage (optional arguments in brackets):\n\nro = RolloutSimulator()\nhistory = simulate(ro, pomdp, policy, [updater [, init_belief [, init_state]]])\n\nSee also: HistoryRecorder, run_parallel\n\n\n\n\n\n"
},

{
    "location": "rollout.html#RolloutSimulator-1",
    "page": "Rollout",
    "title": "RolloutSimulator",
    "category": "section",
    "text": "RolloutSimulator is the simplest MDP or POMDP simulator. When simulate is called, it simply simulates a single trajectory of the process and returns the discounted reward.rs = RolloutSimulator()\nmdp = GridWorld()\npolicy = RandomPolicy(mdp)\n\nr = simulate(rs, mdp, policy)More examples can be found in the POMDPExamples PackageRolloutSimulator"
},

{
    "location": "sim.html#",
    "page": "sim()",
    "title": "sim()",
    "category": "page",
    "text": ""
},

{
    "location": "sim.html#POMDPSimulators.sim",
    "page": "sim()",
    "title": "POMDPSimulators.sim",
    "category": "function",
    "text": "sim(polfunc::Function, mdp::MDP; [<keyword arguments>])\nsim(polfunc::Function, pomdp::POMDP; [<keyword arguments>])\n\nAlternative way of running a simulation with a function specifying how to calculate the action at each timestep.\n\nUsage\n\nsim(mdp) do s\n    # code that calculates action `a` based on `s` - this is the policy\n    # you can also do other things like display something\n    return a\nend\n\nfor an MDP or\n\nsim(pomdp) do o\n    # code that calculates \'a\' based on observation `o`\n    # optionally you could save \'o\' in a global variable or do a belief update\n    return a\nend\n\nor with a POMDP\n\nsim(pomdp, updater) do b\n    # code that calculates \'a\' based on belief `b`\n    # `b` is calculated by `updater`\n    return a\nend\n\nfor a POMDP and a belief updater.\n\nKeyword Arguments\n\nAll Versions\n\ninitialstate: the initial state for the simulation\nsimulator: keyword argument to specify any simulator to run the simulation. If nothing is specified for the simulator, a HistoryRecorder will be used as the simulator, with all keyword arguments forwarded to it, e.g.\nsim(mdp, max_steps=100, show_progress=true) do s\n    # ...\nend\nwill limit the simulation to 100 steps.\n\nPOMDP version\n\ninitialobs: this will control the initial observation given to the policy function. If this is not defined, generate_o(m, s, rng) will be used if it is available. If it is not, missing will be used.\n\nPOMDP and updater version\n\ninitialbelief: initialize_belief(updater, initialbelief) is the first belief that will be given to the policy function.\n\n\n\n\n\n"
},

{
    "location": "sim.html#sim-function-1",
    "page": "sim()",
    "title": "sim()",
    "category": "section",
    "text": "The sim function provides a convenient way to interact with a POMDP or MDP environment and return a history. The first argument is a function that is called at every time step and takes a state (in the case of an MDP) or an observation (in the case of a POMDP) as the argument and then returns an action. The second argument is a pomdp or mdp. It is intended to be used with Julia\'s do syntax as follows:pomdp = TigerPOMDP()\nhistory = sim(pomdp, max_steps=10) do obs\n    println(\"Observation was $obs.\")\n    return TIGER_OPEN_LEFT\nendThis allows a flexible and general way to interact with a POMDP environment without creating new Policy types.In the POMDP case, an updater can optionally be supplied as an additional positional argument if the policy function works with beliefs rather than directly with observations.More examples can be found in the POMDPExamples Packagesim"
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
    "text": "stepthrough(problem, policy, [spec])\nstepthrough(problem, policy, [spec], [rng=rng], [max_steps=max_steps])\nstepthrough(mdp::MDP, policy::Policy, [init_state], [spec]; [kwargs...])\nstepthrough(pomdp::POMDP, policy::Policy, [up::Updater, [initial_belief, [initial_state]]], [spec]; [kwargs...])\n\nCreate a simulation iterator. This is intended to be used with for loop syntax to output the results of each step as the simulation is being run. \n\nExample:\n\npomdp = BabyPOMDP()\npolicy = RandomPolicy(pomdp)\n\nfor (s, a, o, r) in stepthrough(pomdp, policy, \"s,a,o,r\", max_steps=10)\n    println(\"in state $s\")\n    println(\"took action $o\")\n    println(\"received observation $o and reward $r\")\nend\n\nThe optional spec argument can be a string, tuple of symbols, or single symbol and follows the same pattern as eachstep called on a SimHistory object.\n\nUnder the hood, this function creates a StepSimulator with spec and returns a [PO]MDPSimIterator by calling simulate with all of the arguments except spec. All keyword arguments are passed to the StepSimulator constructor.\n\n\n\n\n\n"
},

{
    "location": "stepthrough.html#Stepping-through-1",
    "page": "Stepping through",
    "title": "Stepping through",
    "category": "section",
    "text": "The stepthrough function exposes a simulation as an iterator so that the steps can be iterated through with a for loop syntax as follows:pomdp = BabyPOMDP()\npolicy = RandomPolicy(pomdp)\n\nfor (s, a, o, r) in stepthrough(pomdp, policy, \"s,a,o,r\", max_steps=10)\n    println(\"in state $s\")\n    println(\"took action $o\")\n    println(\"received observation $o and reward $r\")\nendMore examples can be found in the POMDPExamples Package.stepthroughThe StepSimulator contained in this file can provide the same functionality with the following syntax:sim = StepSimulator(\"s,a,r,sp\")\nfor (s,a,r,sp) in simulate(sim, problem, policy)\n    # do something\nend"
},

{
    "location": "which.html#",
    "page": "Which Simulator Should I Use?",
    "title": "Which Simulator Should I Use?",
    "category": "page",
    "text": ""
},

{
    "location": "which.html#Which-Simulator-Should-I-Use?-1",
    "page": "Which Simulator Should I Use?",
    "title": "Which Simulator Should I Use?",
    "category": "section",
    "text": "The simulators in this package provide interaction with simulations of MDP and POMDP environments from a variety of perspectives. Use this page to choose the best simulator to suit your needs."
},

{
    "location": "which.html#I-want-to-run-fast-rollout-simulations-and-get-the-discounted-reward.-1",
    "page": "Which Simulator Should I Use?",
    "title": "I want to run fast rollout simulations and get the discounted reward.",
    "category": "section",
    "text": "Use the Rollout Simulator."
},

{
    "location": "which.html#I-want-to-evaluate-performance-with-many-parallel-Monte-Carlo-simulations.-1",
    "page": "Which Simulator Should I Use?",
    "title": "I want to evaluate performance with many parallel Monte Carlo simulations.",
    "category": "section",
    "text": "Use the Parallel Simulator."
},

{
    "location": "which.html#I-want-to-closely-examine-the-histories-of-states,-actions,-etc.-produced-by-simulations.-1",
    "page": "Which Simulator Should I Use?",
    "title": "I want to closely examine the histories of states, actions, etc. produced by simulations.",
    "category": "section",
    "text": "Use the History Recorder."
},

{
    "location": "which.html#I-want-to-step-through-each-individual-step-of-a-simulation.-1",
    "page": "Which Simulator Should I Use?",
    "title": "I want to step through each individual step of a simulation.",
    "category": "section",
    "text": "Use the stepthrough function."
},

{
    "location": "which.html#I-want-to-interact-with-a-MDP-or-POMDP-environment-from-the-policy\'s-perspective-1",
    "page": "Which Simulator Should I Use?",
    "title": "I want to interact with a MDP or POMDP environment from the policy\'s perspective",
    "category": "section",
    "text": "Use the sim function."
},

{
    "location": "which.html#I-want-to-visualize-a-simulation.-1",
    "page": "Which Simulator Should I Use?",
    "title": "I want to visualize a simulation.",
    "category": "section",
    "text": "Visualization is not implemented directly in this package. However, the Blink POMDP Simulator package contains a simulator for visualization. Additionally, histories produced by a HistoryRecorder or sim are can be visualized using the render function from POMDPModelTools.See the Visualization Tutorial in POMDPExamples for more info."
},

]}
