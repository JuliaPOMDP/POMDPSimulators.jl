
@testset "GridWorld sim" begin 
    mdp = LegacyGridWorld(terminals=Set())
    hist = sim(mdp, max_steps=100) do state
        @assert isa(state, GridWorldState)    
        acts = actions(mdp)
        return rand(acts)
    end
    @test length(hist) == 100
end


@testset "BabyPOMDP sim" begin 
    pomdp = BabyPOMDP()
    hist = sim(pomdp, max_steps=100, initialobs=false) do obs
        @assert isa(obs, Bool)
        acts = actions(pomdp)
        return rand(acts)
    end
    @test length(hist) == 100

    hist = sim(pomdp, false, max_steps=100) do obs
        acts = actions(pomdp)
        return rand(acts)
    end
    @test length(hist) == 100

    hist = sim(pomdp, initialstate=true, max_steps=100) do obs
        acts = actions(pomdp)
        return rand(acts)
    end
    @test length(hist) == 100

    hist = sim(pomdp, max_steps=100, DiscreteUpdater(pomdp)) do b
        @assert isa(b, DiscreteBelief)
        acts = actions(pomdp)
        return rand(acts)
    end

end
