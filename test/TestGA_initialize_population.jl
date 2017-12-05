using Base.Test

include("GA.jl")

@testset "Test GA gen_random_rule" begin
    df = DataFrame(A = ["n", 1,2,3,4], B=["c", -1, -1, 1, 1], C=["c", "a","a","a","b"], D=["c", true, false, true, false])
    ds = DataSet(df, DataMeta(Dict()))
    pre_process!(ds)
    @test length(ds.meta.attrs) == 4
    @test ds.meta.attrs[:A].min == 1
    @test ds.meta.attrs[:A].max == 4
    @test ds.meta.attrs[:B].levels[1] == 2
    @test ds.meta.attrs[:B].levels[2] == 2
    @test ds.meta.attrs[:C].levels[1] == 3
    @test ds.meta.attrs[:C].levels[2] == 1
    @test ds.meta.attrs[:D].levels[1] == 2
    @test ds.meta.attrs[:D].levels[2] == 2
    rule = gen_random_rule(ds)
    @test 2 <= length(rule.atoms)
    @test 3 >= length(rule.atoms)
    @test rule.class == -1
    @test length(rule.atoms) == length(unique(keys(rule.atoms)))
    for k in keys(rule.atoms)
        atom = rule.atoms[k]
        if typeof(atom) == RangeRule
            @test atom.min >= ds.meta.attrs[k].min
            @test atom.max <= ds.meta.attrs[k].max
        else
            @test typeof(atom) == PointRule
            @test haskey(ds.meta.attrs[k].levels, atom.val)
        end
    end
end

@testset "Test GA gen_rules_from_example" begin
    df = DataFrame(A = ["n", 1,2,3,4], B=["c", -1, -1, 1, 1], C=["c", "a","a","a","b"], D=["c", true, false, true, false])
    ds = DataSet(df, DataMeta(Dict()))
    pre_process!(ds)
    rule_set = gen_rules_from_example(ds, 4)
    @test length(rule_set.rules) == 4
    for rule in rule_set.rules
        @test 2 <= length(rule.atoms)
        @test 3 >= length(rule.atoms)
        @test length(rule.atoms) == length(unique(keys(rule.atoms)))
        for k in keys(rule.atoms)
            atom = rule.atoms[k]
            if typeof(atom) == RangeRule
                @test atom.min >= ds.meta.attrs[k].min
                @test atom.max <= ds.meta.attrs[k].max
            else
                @test typeof(atom) == PointRule
                @test haskey(ds.meta.attrs[k].levels, atom.val)
            end
        end
    end
end

@testset "Test GA gen_rules_from_example" begin
    df = DataFrame(A = ["n", 1,2,3,4], B=["c", -1, -1, 1, 1], C=["c", "a","a","a","b"], D=["c", true, false, true, false])
    ds = DataSet(df, DataMeta(Dict()))
    pre_process!(ds)
    population = initialize_population(ds)
    @test length(population) == 100
end
